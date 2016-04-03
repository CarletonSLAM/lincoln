require 'net/http'
require 'oauth'
require 'json'

# Slack API class for an example
class Slack
  def initialize
    @token = ENV['LINCOLN_API_TOKEN']
    @url = 'https://slack.com/api'
  end

  def channel_list
    uri = URI("#{@url}/channels.list")
    query(uri)
  end

  def channel_history(channel)
    uri = URI("#{@url}/channels.history")
    query(uri, channel: channel)
  end

  def message(channel, text)
    uri = URI("#{@url}/chat.postMessage")
    query(uri, channel: channel || 'C0XG4MB2Q', as_user: true, text: text)
  end

  private

  def query(uri, form_data = {})
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(form_data.merge(token: @token))
    response = nil
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      response = http.request(request)
    end

    bad_response(response)

    result = JSON.parse(response.body)

    bad_request(result)

    result
  end

  def bad_response(response)
    puts 'Could not Authenticate!' \
    "\nCode:#{response.code} Body:#{response.body}" if response.code != '200'
  end

  def bad_request(result)
    puts result if result['ok'] != true
  end
end
