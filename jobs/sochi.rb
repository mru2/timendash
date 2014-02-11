# Fetches the latest medal rankings for the sochi 2014 winter olympic games

require 'open-uri'
require 'json'

def get_medal_stats
  endpoint = 'http://olympics.clearlytech.com/api/v1/medals'
  JSON.parse(open(endpoint).read)
end


def format_stat(stat)
  {
    :country => stat['country_name'],
    :gold => stat['gold_count'],
    :silver => stat['silver_count'],
    :bronze => stat['bronze_count'],
    :rank => stat['rank']
  }
end

SCHEDULER.every '15s', :first_in => 0 do |job|

  # Get the latest medal stats
  medal_stats = get_medal_stats

  # Fetches the stats for france, its neighbours, and the top 3
  france_rank = medal_stats.find{|stat| stat['country_name'] == 'France'}['rank']

  medal_stats.select!{ |stat|
    [1, 2, 3, france_rank-1, france_rank, france_rank+1].include? stat['rank']
  }.sort_by!{ |stat|
    stat['rank']
  }

  # Format the resulting stats : country name, rank, gold silver and bronze count
  formatted_stats = medal_stats.map{|s|format_stat(s)}
  puts "Sending #{formatted_stats}"

  send_event('sochi', {:stats => formatted_stats})

end