SNAPSHOT_DATE = Time.new(2013,9,1)
SNAPSHOT_RDV_TAKEN = 24465747
SNAPSHOT_TOTAL_USERS = 808398

RDV_TAKEN_PER_SECOND = 0.517
USER_SIGNUP_PER_SECOND = 0.01522

SCHEDULER.every '5m', :first_in => 0 do |job|

  # Send an estimation of the total users and rdvs taken
  time_delta = (Time.now - SNAPSHOT_DATE).to_i # delta in seconds

  total_rdvs_estimate = SNAPSHOT_RDV_TAKEN + (time_delta * RDV_TAKEN_PER_SECOND)
  total_users_estimate = SNAPSHOT_TOTAL_USERS + (time_delta * USER_SIGNUP_PER_SECOND)

  # Send the event
  send_event('total_stats', { users: total_users_estimate, rdvs: total_rdvs_estimate })

end