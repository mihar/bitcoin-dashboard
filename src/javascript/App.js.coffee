class BTCD.App
  codename: 'BTCDv0.1'
  # Debugging.
  debug: 6
  debug_mode: false

  events: _.extend(BTCD.Events, Backbone.Events)

  ##
  ## INIT
  init: ->
    BTCD.log 'App init'
    @events.t 'init:start'

    # DOM dependent init.
    @events.on 'dom:onload', @dom_onload, this

    @events.on 'init:dom:end', -> 
      @events.t 'init:end'
    , this

  dom_onload: ->
    BTCD.log 'DOM loaded, proceeding'
    BTCD.app.dom_exists = true

    @events.t 'init:dom:start'

    # Setup router.
    @router = new BTCD.Router

    @events.t 'init:dom:end'