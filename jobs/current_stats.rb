require 'httparty'

login = ENV['CLICRDV_LOGIN']
password = ENV['CLICRDV_PASSWORD']

SCHEDULER.every '5m', :first_in => 0 do |job|

  # Get the session id
  response =  HTTParty.get 'https://admin.clicrdv.com/pro/login'
  session_id = response.headers['Set-Cookie'].match(/_session_id=(.+?);/)[1]
  cookie_header = {'Cookie' => "_session_id=#{session_id};"}

  # Login the user
  response = HTTParty.post 'https://admin.clicrdv.com/pro/pro_login', :body => {:pro => {:email => login, :password => Digest::SHA1.hexdigest(password)}}, :headers => cookie_header

  # Find the current connected groups
  response = HTTParty.get 'https://admin.clicrdv.com/admin/stats/get_current_connections?mode=group', :headers => cookie_header 
  connected_groups = response.parsed_response['records'].count

  # Find the current connected pros
  response = HTTParty.get 'https://admin.clicrdv.com/admin/stats/get_current_connections?mode=pro', :headers => cookie_header 
  connected_pros = response.parsed_response['records'].count

  # Send the event
  send_event('current_stats', { groups: connected_groups, pros: connected_pros })

end