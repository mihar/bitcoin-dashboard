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

    # Setup persistence.
    BTCD.persistence = new BTCD.Persistence

    # Setup dashboard object.
    BTCD.dashboard = new BTCD.Dashboard

    # Setup views.
    BTCD.exchanges_view = new BTCD.ExchangesView
    BTCD.heartbeat_view = new BTCD.HeartbeatView

  dom_onload: ->
    BTCD.log 'DOM loaded, proceeding'
    BTCD.app.dom_exists = true

    @events.t 'init:dom:start'

    # Setup router.
    @router = new BTCD.Router

    # Initialize dashboard view.
    BTCD.dashboard_view = new BTCD.DashboardView

    # Apply views.
    $('#header').append BTCD.exchanges_view.el
    $('#header').append BTCD.heartbeat_view.render().el

    @events.t 'init:dom:end'