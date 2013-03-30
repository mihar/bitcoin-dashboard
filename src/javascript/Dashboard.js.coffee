class BTCD.Dashboard
  exchanges: []
  balance: 0
  balance_values: []
  net_worth: 0
  net_worth_values: []
  trend: 0

  constructor: ->
    BTCD.info 'Initializing dashboard'


  register: (exchange) ->
    return if @exchanges.indexOf(exchange) > -1

    BTCD.app.events.t 'exchange:register', exchange
    BTCD.info "Registering exchange #{exchange.name}", exchange
    @exchanges.push exchange

    # Setup events.
    exchange.on 'change:balance', @recalculate_all, this
    exchange.on 'change:net_worth', @recalculate_all, this
    exchange.feed.on 'change:sell_trend', @monitor_trends, this

  monitor_trends: (exchange, trend) ->
    if @trend isnt trend
      @trend = trend
      BTCD.app.events.t 'trend:change', trend

  recalculate_all: -> 
    @recalculate 'balance'
    @recalculate 'net_worth'

  recalculate: (which) ->
    sum = _.reduce @exchanges, (sum, exchange) -> 
      sum + exchange.get(which)
    , 0

    return if isNaN sum

    if sum isnt this[which]
      this[which] = sum
      this["#{which}_values"].push sum
      BTCD.app.events.t "#{which}:change", sum