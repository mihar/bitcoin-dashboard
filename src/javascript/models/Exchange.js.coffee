BTCD.Exchange = Backbone.Model.extend
  initialize: (balance = 0) ->
    unless @name
      throw new Error('Missing name parameter.')

    # Setup feed.
    @feed = new BTCD.ExchangeFeeds[@name]

    # Recalculate net worth on changes of balance or market price.
    @feed.on 'change:sell', @recalculate_net_worth, this
    @on 'change:balance', @recalculate_net_worth, this

    # Register exchange.
    BTCD.dashboard.register this
    
    # Initialize basic values.
    @set 'net_worth', 0
    @set 'net_worth_diff', 0
    @set 'balance', balance

  recalculate_net_worth: -> 
    if @has('balance') and @feed.has('sell')
      @set 'net_worth', @get('balance') * @feed.get('sell')

      if @previous('net_worth') isnt 0
        @set 'net_worth_diff', @get('net_worth') - @previous('net_worth')


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