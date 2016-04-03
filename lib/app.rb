require 'sinatra'
require 'httparty'
require 'json'
require 'pp'
require 'aws-sdk'
require_relative 'slack'
require_relative 'ec2'
require_relative 'help'

post '/gateway' do
  return unless params['token'] == ENV['LINCOLN_WEBHOOK_TOKEN']
  message(params['text'].gsub(params['trigger_word'], '').strip.split)
  status 200
end

def message(tokens)
  @lincoln ||= Slack.new
  namespace = Module.const_get(tokens.shift.upcase)
  if tokens.empty?
    if namespace == HELP
      HELP.help { |msg| @lincoln.message params[:channel_id], msg }
    else
      @lincoln.message params[:channel_id], namespace.public_send(:help)
    end
  else
    method = tokens.shift.downcase
    if tokens.empty?
      namespace.public_send(method) { |msg| @lincoln.message params[:channel_id], msg }
    else
      namespace.public_send(method, tokens) { |msg| @lincoln.message params[:channel_id], msg }
    end
  end
rescue NameError
  @lincoln.message params[:channel_id], 'what was that?'
end
