class Dashing.Sochi extends Dashing.Widget

  onData: (data) ->
    console.log('[Sochi] Got data : ', data)

    @set('medals', data.stats)
    # @set('time', "#{data.time}")
    # @set('retard', "#{data.retard}")
