class BTCD.Dashboard
  max_history: 750
  exchanges: []
  balance: 0
  previous_balance: 0
  balance_values: []
  net_worth: 0
  previous_net_worth: 0
  net_worth_values: []
  net_worth_diff: 0
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
    exchange.on 'change:net_worth', @recalculate_diff, this
    exchange.feed.on 'change:sell_trend', @monitor_trends, this

  monitor_trends: (exchange, trend) ->
    if @trend isnt trend
      @trend = trend
      BTCD.app.events.t 'trend:change', trend

  recalculate_all: -> 
    @recalculate 'balance'
    @recalculate 'net_worth'

  recalculate_diff: ->
    if @previous_net_worth and @net_worth and @previous_net_worth > 0 and @net_worth > 0
      diff = @net_worth - @previous_net_worth

      # Skip triggering an event or setting the variable if it hasn't changed or is 0.
      return if diff is @net_worth_diff 
      return if parseInt(diff) is 0
      
      @net_worth_diff = diff
      BTCD.app.events.t 'net_worth_diff:change', @net_worth_diff

  recalculate: (which) ->
    sum = _.reduce @exchanges, (sum, exchange) -> 
      sum + exchange.get(which)
    , 0

    return if isNaN sum # We like Naan, but we don't like NaN!

    if sum isnt this[which]
      this["previous_#{which}"] = this[which]
      this[which] = sum

      values = this["#{which}_values"]
      # Purge values.
      values.shift() if values.length > @max_history
      # Last value.
      values.push sum

      # Trigger event.
      BTCD.app.events.t "#{which}:change", sum