class BTCD.Balance
  exchanges: []
  balance: 0
  net_worth: 0

  constructor: ->
    BTCD.info 'Initializing balance'

  register: (exchange) ->
    return if @exchanges.indexOf(exchange) > -1

    BTCD.info "Registering exchange #{exchange.name}", exchange
    @exchanges.push exchange

    # Setup events.
    exchange.on 'change:balance', @recalculate_all, this
    exchange.on 'change:net_worth', @recalculate_all, this

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
      BTCD.app.events.t "#{which}:change", sum