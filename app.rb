require 'sinatra'
require 'httparty'
require 'json'
require 'pp'
require 'aws-sdk'

post '/gateway' do
  pp params, params['token'], ENV['LINCOLN_WEBHOOK_TOKEN']
  return unless params['token'] == ENV['LINCOLN_WEBHOOK_TOKEN']
  action = params['text'].gsub(params['trigger_word'], '').strip

  case action
  when 'test'
    resp = HTTParty.get('https://api.github.com/repos/carletonslam/lincoln')
    resp = JSON.parse resp.body
    pp "There are #{resp['open_issues_count']} open issues on lincoln"
    respond_message "There are #{resp['open_issues_count']} open issues on lincoln"
  when 'ec2 create'
    vm = create_instance
    respond_message("Your vm was created as #{vm.public_ip_address}. To login use " \
    "`ssh ubuntu@#{vm.public_ip_address} -i ~/.ssh/slam.pem`.\n" \
    'Use `lincoln ec2 keypair` to get the keypair.')
  when 'ec2 keypair'
    respond_message('Not implemented.')
  end
end

def respond_message(message)
  content_type :json
  { text: message }.to_json
end

def create_instance
  client = Aws::EC2::Client.new(region: 'us-west-2')
  vm = Aws::EC2::Resource.new(client: client)
  ami = vm.image('ami-5189a661')
  key_pair = vm.key_pair('slam')
  instance_options = ec2_instance_options.merge(
    image_id: ami.image_id,
    key_name: key_pair.name)
  vm.create_instances(instance_options).first.wait_until_running
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
