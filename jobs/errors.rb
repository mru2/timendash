require 'httparty'
require 'active_support'

# Environment variables
require 'dotenv'
Dotenv.load

login = ENV['CLICRDV_LOGIN']
password = ENV['CLICRDV_PASSWORD']
host = ENV['CLICRDV_API_HOST']
errors_api_path = ENV['CLICRDV_ERRORS_API_PATH']

def truncate(s, length = 30, ellipsis = '...')
  if s.length > length
    s.to_s[0..length].gsub(/[^\w]\w+\s*$/, ellipsis)
  else
    s
  end
end


def time_ago(from_time)
  now = Time.now
  diff = (now - from_time).round

  # Seconds
  if diff < 60
    return "#{diff} seconds ago"
  # Minutes
  elsif (diff /= 60) < 60
    return "#{diff} minutes ago"
  elsif (diff /= 60) < 24
    return "#{diff} hours ago"
  elsif (diff /= 24) < 30
    return "#{diff} days ago"
  else
    return "more than a month ago"
  end
end


SCHEDULER.every '1m', :first_in => 0 do |job|

  # Get the latest error
  response = HTTParty.get "#{host}#{errors_api_path}?limit=1", :basic_auth => {:username => login, :password => password}
  error = response.parsed_response.first
  summary = {
    'created_at' => time_ago(Time.parse(error['created_at'])),
    'summary' => truncate(error['summary'], 100)
  }

  # Send the event
  send_event('error', {:error => summary})

end