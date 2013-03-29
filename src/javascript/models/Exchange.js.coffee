BTCD.Exchange = Backbone.Model.extend
  initialize: ->
    unless @name
      throw new Error('Missing name parameter.')

    @feed = new BTCD.ExchangeFeeds[@name]


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