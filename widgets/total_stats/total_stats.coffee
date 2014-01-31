class Dashing.TotalStats extends Dashing.Widget

  @accessor 'users', Dashing.AnimatedValue
  @accessor 'rdvs', Dashing.AnimatedValue

  # onData: (data) ->    
  #   @set('users', data.users)
  #   @set('rdvs', data.rdvs)