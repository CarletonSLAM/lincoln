require 'aws-sdk'
require 'pp'

module EC2
  module_function

  def create(*args)
    name = args.flatten.first
    vm = create_instance(name)
    "#{name} was created. To login use " \
    "`ssh ubuntu@#{vm.public_ip_address} -i ~/.ssh/slam.pem`.\n" \
    'Use `link ec2 keypair` to get the keypair.'
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
  end

  def destroy(*args)
    vm = destroy_instance(*args.first)
    "Your vm (#{vm.id}) was destroyed."
  end

  def keypair
    'Not implemented.'
  end

  def create_instance(name)
    client = Aws::EC2::Client.new(region: 'us-west-2')
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
    client = Aws::EC2::Client.new(region: 'us-west-2')
    instances = client.describe_instances(filters: [
      {
        name: 'instance.group-id',
        values: ['sg-955d19f2']
      }])
    instances.reservations.map(&:instances).flatten
  end

  def destroy_instance(id)
    client = Aws::EC2::Client.new(region: 'us-west-2')
    resp = client.describe_instances(instance_ids: [id])
    instance = resp.reservations.first.instances.detect { |vm| vm.id == id }
    instance.terminate.first.wait_until_terminated
  end

  def ec2_instance_options
    {
      min_count: 1, # required
      max_count: 1, # required
      security_group_ids: ['sg-955d19f2'],
      instance_type: 't2.micro', # accepts t2.micro, t2.small, t2.medium, t2.large
      placement: { availability_zone: 'us-west-2b' },
      monitoring: { enabled: false }, # required
      instance_initiated_shutdown_behavior: 'terminate', # accepts stop, terminate
    }
  end
end
