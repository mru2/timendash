last = 0
current = 0

SCHEDULER.every '5s', :first_in => 0 do |job|

  last = current

  # TODO : replace with real API call
  current = (Time.now.to_i - 1377986400) * 0.517 + 24465747

  send_event('rdv_taken', { current: current, last: last })

end