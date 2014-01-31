class Dashing.CurrentStats extends Dashing.Widget

  @accessor 'groups', Dashing.AnimatedValue
  @accessor 'pros', Dashing.AnimatedValue

  # onData: (data) ->    
  #   @set('users', data.users)
  #   @set('rdvs', data.rdvs)