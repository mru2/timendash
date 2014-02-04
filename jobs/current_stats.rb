require 'httparty'

login = ENV['CLICRDV_LOGIN']
password = ENV['CLICRDV_PASSWORD']
host = ENV['CLICRDV_HOST']
current_connection_path = ENV['CLICRDV_CONNECTIONS_PATH']

SCHEDULER.every '5m', :first_in => 0 do |job|

  # Get the session id
  response =  HTTParty.get "#{host}/pro/login"
  session_id = response.headers['Set-Cookie'].match(/_session_id=(.+?);/)[1]
  cookie_header = {'Cookie' => "_session_id=#{session_id};"}

  # Login the user
  response = HTTParty.post "#{host}/pro/pro_login", :body => {:pro => {:email => login, :password => Digest::SHA1.hexdigest(password)}}, :headers => cookie_header

  # Find the current connected groups
  response = HTTParty.get "#{host}#{current_connection_path}?mode=group", :headers => cookie_header
  connected_groups = response.parsed_response['records'].count

  # Find the current connected pros
  response = HTTParty.get "#{host}#{current_connection_path}?mode=pro", :headers => cookie_header
  connected_pros = response.parsed_response['records'].count

  # Send the event
  send_event('current_stats', { groups: connected_groups, pros: connected_pros })

end