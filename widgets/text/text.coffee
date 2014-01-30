class Dashing.Text extends Dashing.Widget

  onData: (data) ->    
    @set('text', "“#{data.text}”")