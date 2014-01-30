last = 0
current = 0

SCHEDULER.every '5s', :first_in => 0 do |job|

  last = current

  # TODO : replace with real API call
  current = (Time.now.to_i - 1377986400) * 0.01522 + 808398

  send_event('total_users', { current: current, last: last })

end