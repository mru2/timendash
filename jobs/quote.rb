require 'rss'


SCHEDULER.every '15m', :first_in => 0 do |job|

  quote = RSS::Parser.parse('http://www.legorafi.fr/feed/').items.first.title

  send_event('quote', { text: quote })

end