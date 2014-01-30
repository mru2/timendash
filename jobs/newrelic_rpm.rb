# Environment variables
require 'dotenv'
Dotenv.load

require 'newrelic_api'

# Newrelic API key
API_KEY = ENV['NEWRELIC_API_KEY']
 
# Monitored application
APP_NAME = ENV['NEWRELIC_APP_NAME']

# Class for handling meters
class Meter
  def initialize
    @value = 0
  end

  def push(value)
    @value = value
    {:value => @value}
  end
end


# Class for handling numeric values
class Numeric
  def initialize
    @last = 0
    @current = 0
  end

  def push(value)
    @last = @current
    @current = value

    {:last => @last, :current => @current}
  end
end

# Class for handling graphs
class Graph
  POINTS = 10 # Nb of points

  def initialize
    @points = (1..POINTS).map{|x| {:x => x, :y => 0} }
    @last_x = POINTS
  end

  def push(value)
    @points.shift
    @last_x += 1
    @points << {:x => @last_x, :y => value}
    {:points => @points}
  end
end


# Initialize new relic 
NewRelicApi.api_key = API_KEY
app = NewRelicApi::Account.find(:first).applications.select{|a|a.name == APP_NAME }.first

# Helper to get a metric value easily
def app.metric_value(metric_name)
  self.threshold_values.find{|v|v.name == metric_name}.metric_value
end

# Initialize metrics

rpm = Graph.new
response_time = Graph.new
cpu_load = Numeric.new
ram_load = Numeric.new

SCHEDULER.every '30s', :first_in => 0 do |job|
 
  metrics = app.threshold_values

  # Req Per Min
  send_event('newrelic_rpm', rpm.push(app.metric_value("Throughput")))

  # Response time
  send_event('newrelic_response_time', response_time.push(app.metric_value("Response Time")))

  # CPU and RAM load
  send_event('newrelic_cpu', cpu_load.push(app.metric_value("CPU")))
  send_event('newrelic_ram', ram_load.push(app.metric_value("Memory")))

  # app.threshold_values.each do |v|
  #   send_event("rpm_" + v.name.downcase.gsub(/ /, '_'), { value: v.metric_value })
  # end
 
end