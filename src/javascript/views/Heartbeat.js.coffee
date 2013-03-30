class BTCD.HeartbeatView extends Backbone.View
  id: 'heartbeat'

  initialize: ->
    BTCD.app.events.on 'heartbeat', @beat, this

  beat: -> 
    @$el.addClass 'pulsate'
    this_obj = this
    setTimeout ->
      this_obj.$el.removeClass 'pulsate'
    , 400

  render: ->
    @$el.text "♥"
    this