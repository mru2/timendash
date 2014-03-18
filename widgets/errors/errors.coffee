class Dashing.Errors extends Dashing.Widget

  onData: (data) ->
    console.log('[Errors] Got data : ', data)
    error = data.error

    @set('date', error.created_at)
    @set('summary', error.summary)
