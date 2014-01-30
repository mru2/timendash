class Dashing.Meter extends Dashing.Widget

  @accessor 'value-top', Dashing.AnimatedValue
  @accessor 'value-bottom', Dashing.AnimatedValue

  constructor: ->
    super
    @observe 'value-top', (value) ->
      $(@node).find(".top .meter").val(value).trigger('change')
    @observe 'value-bottom', (value) ->
      $(@node).find(".bottom .meter").val(value).trigger('change')

  ready: ->
    meter = $(@node).find(".meter")
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()
