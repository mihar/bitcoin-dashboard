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
    exchange.on 'change:balance', @recalculate, this
    exchange.on 'change:net_worth', @recalculate, this

  recalculate: -> 
    @balance = _.reduce @exchanges, (sum, exchange) -> 
      sum + exchange.get('balance')
    , 0
    @net_worth = _.reduce @exchanges, (sum, exchange) -> 
      sum + exchange.get('net_worth')
    , 0

