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
  pp params
  respond(params)
  status 200
end

def respond(params)
  @lincoln ||= Slack.new
  tokens = params['text'].gsub(params['trigger_word'], '').strip.split
  pp mess = message(tokens)
  @lincoln.message(params[:channel_id], mess)
end

def message(tokens)
  namespace = Module.const_get(tokens.shift.upcase)
  pp namespace
  if tokens.empty?
    namespace == HELP ? HELP.help : 'what was that?'
  else
    method = tokens.shift.downcase
    if tokens.empty?
      namespace.public_send(method)
    else
      namespace.public_send(method, tokens)
    end
  end
rescue NameError
  'what was that?'
end
