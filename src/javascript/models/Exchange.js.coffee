BTCD.Exchange = Backbone.Model.extend
  initialize: (balance = 0) ->
    unless @name
      throw new Error('Missing name parameter.')

    # Register exchange.
    BTCD.balance.register this

    # Setup feed.
    @feed = new BTCD.ExchangeFeeds[@name]

    # Recalculate net worth on changes of balance or market price.
    @feed.on 'change:sell', @recalculate_net_worth, this
    @on 'change:balance', @recalculate_net_worth, this

    # Initialize basic values.
    @set 'net_worth', 0
    @set 'balance', balance

  recalculate_net_worth: (model, sell) -> @set 'net_worth', @get('balance') * sell

BTCD.Exchanges = {}

# MtGox
BTCD.Exchanges.MtGox = BTCD.Exchange.extend
  name: 'MtGox'

# Coinbase
BTCD.Exchanges.Coinbase = BTCD.Exchange.extend
  name: 'Coinbase'

# Bitstamp
BTCD.Exchanges.Bitstamp = BTCD.Exchange.extend
  name: 'Bitstamp'