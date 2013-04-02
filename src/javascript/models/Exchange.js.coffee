BTCD.AbstractExchange = Backbone.Model.extend
  max_history: 750

  initialize: (balance = 0) ->
    # Everyone should keep track of changes in net worth.
    @on 'change:net_worth', @calculate_diff, this

    # Initialize basic values.
    @set 'net_worth', 0
    @set 'net_worth_diff', 0
    @set 'balance', balance

  calculate_diff: ->
    if @previous('net_worth') and @get('net_worth') and @previous('net_worth') > 0 and @get('net_worth') > 0
      @update 'net_worth_diff', @get('net_worth') - @previous('net_worth')

  track: (what, value) ->
    this["#{what}_values"] ||= [] 
    values = this["#{what}_values"] # Values array shortcut.

    # Purge values.
    values.shift() if values.length > @max_history
    # Last value.
    values.push value

  update: (what, value) ->
    return if value is @get value # Skip if hasn't changed.
    return if isNaN value # We like Naan bread, but we don't like NaN!
    return if parseInt(value) is 0 # Skip if zero.

    # Track history.
    @track what, value
    
    # Finally set value.
    @set what, value

    value

BTCD.Exchange = BTCD.AbstractExchange.extend
  initialize: (balance) ->
    unless @name
      throw new Error('Missing name parameter.')

    # Setup feed.
    @feed = new BTCD.ExchangeFeeds[@name]

    # Recalculate net worth on changes of balance or market price.
    @on 'change:balance', @calculate_net_worth, this
    @feed.on 'change:sell', @calculate_net_worth, this

    # Register exchange.
    BTCD.dashboard.register this
    
    # Call the super's initializer.
    BTCD.Exchange.__super__.initialize.apply this, arguments

  calculate_net_worth: -> 
    if @has('balance') and @feed.has('sell')
      @update 'net_worth', @get('balance') * @feed.get('sell')



##
# EXCHANGE CLASSES
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

# BTC-E
BTCD.Exchanges.BTCE = BTCD.Exchange.extend
  name: 'BTCE'