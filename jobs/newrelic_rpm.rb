# Environment variables
require 'dotenv'
Dotenv.load

require 'newrelic_api'

# Newrelic API key
API_KEY = ENV['NEWRELIC_API_KEY']
 
# Monitored application
APP_NAME = ENV['NEWRELIC_APP_NAME']

# Class for handling meters
class DoubleMeter
  def initialize
    @value_top = 0
    @value_bottom = 0
  end

  def push(values)
    @value_top = values.first
    @value_bottom = values.last
    {:'value-top' => @value_top, :'value-bottom' => @value_bottom}
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

rpm = Numeric.new
response_time = Numeric.new
server_load = DoubleMeter.new


SCHEDULER.every '30s', :first_in => 0 do |job|
 
  metrics = app.threshold_values

  # CPU and RAM load
  cpu = (app.metric_value("CPU") / 10).round(1)
  ram = (app.metric_value("Memory") / (4 * 12 * 1024) * 100).round(1)

  send_event('newrelic_load', server_load.push([cpu, ram]))

end