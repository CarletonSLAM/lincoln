require 'aws-sdk'
require 'pp'

module EC2
  module_function

  def create(*args)
    name = args.flatten.first
    yield 'Your vm is being created.'
    vm = create_instance(name)
    yield "#{name} (#{vm.instance_id}) was created. " \
      "To login use `ssh ubuntu@#{vm.public_ip_address} -i ~/.ssh/slam.pem`.\n"
  end

  def list
    instances = list_instances
    response = "```\n"
    instances.each do |vm|
      name_tag = vm.tags.detect { |tag| tag.key == 'Name' }
      name = "#{name_tag.value}:" if name_tag
      ip = " - #{vm.public_ip_address}" if vm.public_ip_address
      response << "#{name}#{vm.instance_id}#{ip}\n"
    end
    response << '```'
    yield response
  end

  def destroy(*args)
    id = args.flatten.first
    vm = destroy_instance(id)
    yield "Your vm (#{vm.instance_id}) was destroyed"
  end

  def keypair
    filepath = File.join(Dir.home, '.ssh', 'slam.pem')
    key = File.exist?(filepath) ? File.read(filepath) : ENV['SLAM_KEYPAIR']
    yield "```\n#{key}\n```"
  end

  def help
    "`link ec2 create :name`: create a new ec2 instance\n" \
    "`link ec2 list`: list the all ec2 instances\n" \
    "`link ec2 destroy :id`: destroy an instance\n" \
    "`link ec2 keypair`: display the slam keypair file\n"
  end

  def create_instance(name)
    client = Aws::EC2::Client.new(region: 'us-east-1')
    vm = Aws::EC2::Resource.new(client: client)
    ami = vm.image('ami-5189a661')
    key_pair = vm.key_pair('slam')
    instance_options = ec2_instance_options.merge(
      image_id: ami.image_id,
      key_name: key_pair.name)
    instance = vm.create_instances(instance_options).first.wait_until_running
    instance.create_tags(tags: [{ key: 'Name', value: name }])
    instance
  end

  def list_instances
    client = Aws::EC2::Client.new(region: 'us-east-1')
    instances = client.describe_instances(
      filters: [
        {
          name: 'instance.group-id',
          values: ['sg-a4c1b3df']
        }])
    instances.reservations.map(&:instances).flatten
  end

  def destroy_instance(id)
    client = Aws::EC2::Client.new(region: 'us-east-1')
    client.terminate_instances(instance_ids: [id]).terminating_instances.first
  end

  def ec2_instance_options
    {
      min_count: 1, # required
      max_count: 1, # required
      security_group_ids: ['sg-a4c1b3df'],
      instance_type: 't2.nano', # accepts t2.micro, t2.small, t2.medium, t2.large
      placement: { availability_zone: 'us-east-1b' },
      monitoring: { enabled: false }, # required
      instance_initiated_shutdown_behavior: 'terminate', # accepts stop, terminate
    }
  end
end
