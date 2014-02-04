require 'open-uri'
require 'json'




# exemple de données reçues
# {
#    "info": [],
#    "trains": [{
#       "trainclass": "train",
#       "numero": "148622",
#       "ligne": "C",
#       "mission": "VICK",
#       "time": "14:48",
#       "destination": "Versailles Château Rive Gauche",
#       "retard": "+1 min",
#       "col2class": "col2",
#       "platform": null,
#       "dessertes": "Issy &bull; Meudon Val Fleury &bull; Chaville Vélizy &bull; Viroflay Rive Gauche &bull; Porchefontaine &bull; Versailles Château Rive Gauche"
#    }, 

SCHEDULER.every '60s', :first_in => 0 do |job|

  trains = JSON.parse(open("http://monrer.fr/json?s=ISP").read)["trains"]

  trains.select! do |t|
    t["dessertes"] =~ /Garigliano/i
  end

  next_train = trains.empty? ? {time: "Unknown", retard: ""} : trains.first

  send_event('rer', {time: next_train["time"], retard: next_train["retard"]})

end

