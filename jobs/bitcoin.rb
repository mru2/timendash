require 'open-uri'
require 'json'

URL = "https://api.bitcoinaverage.com/ticker/global/EUR/"


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

bitcoin = Numeric.new

SCHEDULER.every '60s', :first_in => 0 do |job|

  value = JSON.parse(open(URL).read)["last"]

  send_event('bitcoin', bitcoin.push(value))

end