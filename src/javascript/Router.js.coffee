##
## ROUTER
class BTCD.Router extends Backbone.Router
  routes:
    '': 'root'

  initialize: ->
    BTCD.log 'Router init'
    BTCD.app.events.t 'router:init:end'

  root: -> 
