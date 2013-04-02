BTCD.Dashboard = BTCD.AbstractExchange.extend
  exchanges: []

  initialize: ->
    BTCD.info 'Initializing dashboard'

    # Inherit shit.
    BTCD.Dashboard.__super__.initialize.apply this, arguments

  register: (exchange) ->
    if @exchanges.indexOf(exchange) > -1
      BTCD.warn "Exchange #{exchange.name} already registered. Skipping."
      return 

    # Register exchange in our array and trigger events.
    @exchanges.push exchange
    
    # Setup events.
    exchange.on 'change:balance', @sum_balance, this
    exchange.on 'change:net_worth', @sum_net_worth, this

    # Initialize data.
    @sum_balance()
    @sum_net_worth()

    BTCD.app.events.t 'exchange:register', exchange
    BTCD.info "Registering exchange #{exchange.name}", exchange

  sum_balance: -> @sum 'balance'
  sum_net_worth: -> @sum 'net_worth'
  sum: (what) ->
    sum = _.reduce @exchanges, (sum, exchange) -> 
      sum + exchange.get(what)
    , 0

    @update what, sum