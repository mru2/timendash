# Environment variables
require 'dotenv'
Dotenv.load

# Jenkins HTTPS credentials
JENKINS_USERNAME = ENV['JENKINS_USERNAME']

# Monitored application
JENKINS_PWD= ENV['JENKINS_PASSWORD']

require 'jenkins_api_client'

# Jenkins Resulsts possible
# SUCCESS
# UNSTABLE
# FAILURE
# NOT_BUILT
# ABORTED
def client
  @client ||= JenkinsApi::Client.new(:server_url => 'https://jenkins.clicrdv.com/',
                                   :ssl => true,
                                   :username => JENKINS_USERNAME,
                                   :password => JENKINS_PWD)
end


module Constants
  STATUSES = %w[failed passed running started broken timedout no_tests fixed success canceled]
  FAILED, PASSED, RUNNING, STARTED, BROKEN, TIMEDOUT, NOTESTS, FIXED, SUCCESS, CANCELED = STATUSES
  FAILED_C   = 0.05
  BROKEN_C   = 0.05
  TIMEDOUT_C = 0.3
  NO_TESTS_C = 0.5
  CANCELED_C = 0.5
  RUNNING_C  = 1.0
  STARTED_C  = 1.0
  FIXED_C    = 1.0
  PASSED_C   = 1.0
  SUCCESS_C  = 1.0
end

def broken_or_no_builds
  {
    label: 'N/A',
    value: 'N/A',
    committer: '',
    state: 'broken'
  }
end

def get_climate(builds = [])
  return '|' if builds.blank?
  statuses = builds.map { |build| get_build_state build }.compact
  weight = nil

  statuses.each do |status|
    factor = Constants.const_get("#{status.upcase}_C") rescue nil
    next unless factor
    weight = weight.nil? ? factor : weight * factor
  end

  case weight
  when 0.0..0.25  then '9'
  when 0.26..0.5  then '7'
  when 0.51..0.75 then '1'
  when 0.76..1.0  then 'v'
  else
    '|'
  end
end

def get_build_info(build={}, latests)
  return broken_or_no_builds if build.blank?
  {
    # label: "Build ##{build['number']}",
    # value: get_build_comments(build).last,
    committer: get_build_commiters(build).last,
    state: get_build_state(build),
    climate: get_climate(latests)
  }
end

def get_build_comments(build={})
  build_change_sets = build['changeSet']['items']
  build_change_sets.map { |change| change['comment'] }
end

def get_build_commiters(build={})
  build_change_sets = build['changeSet']['items']
  build_change_sets.map { |change| change['author']['fullName'] }
end

def get_build_state(build)
  build_result = build['result']
  return 'running' if build_result.nil?
  return 'failed' if build_result.downcase == 'failure'
  build_result.downcase
end

builds = client.job.list_all

SCHEDULER.every '5m', :first_in => 0 do |job|
  builds.each do |build|
    build_result = @client.api_get_request @client.job.list_details(build)['lastBuild']['url']
    latest_builds = @client.job.list_details(build)['builds'].first(5).map { |b| @client.api_get_request b['url'] }

    build_info = get_build_info(build_result, latest_builds)
    send_event("dashing-circleci-#{build}", { items: [build_info] })
  end

end
