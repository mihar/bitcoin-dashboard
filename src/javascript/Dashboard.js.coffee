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
    exchange.on 'change:net_worth_diff_rolling_values', @sum_net_worth_rolling, this

    # Initialize data.
    @sum_balance()
    @sum_net_worth()
    @sum_net_worth_rolling()

    BTCD.app.events.t 'exchange:register', exchange
    BTCD.info "Registering exchange #{exchange.name}", exchange

  sum_net_worth_rolling: ->
    unless @net_worth_diff
      sum = 0
    else
      sum = _.reduce @net_worth_diff.rolling_values, (sum, n) -> 
        sum + n
      , 0

    @set 'net_worth_diff_rolling_value', sum

  sum_balance: -> @sum 'balance'
  sum_net_worth: -> @sum 'net_worth'
  sum: (what) ->
    sum = _.reduce @exchanges, (sum, exchange) -> 
      sum + exchange.get(what)
    , 0

    @update what, sum