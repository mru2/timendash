class Dashing.Rer extends Dashing.Widget

  onData: (data) ->    
    @set('time', "#{data.time}")
    @set('retard', "#{data.retard}")
