##
## INIT
BTCD.app = new BTCD.App
BTCD.app.events.on 'router:init:end', -> Backbone.history.start pushState: true
BTCD.app.init()

$ -> BTCD.app.events.t 'dom:onload'