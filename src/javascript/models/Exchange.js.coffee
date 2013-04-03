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

  time: -> Math.round(new Date().getTime() / 1000) # Current UNIX timestamp

  track_rolling: (what, value, period = 60) ->
    this[what].rolling_values ||= []
    this[what].rolling_times ||= []

    # Start sweeper.
    @sweep_rolling(what, period) unless this[what].sweeping

    # Push value and time.
    this[what].rolling_values.push value
    this[what].rolling_times.push @time()

  sweep_rolling: (what, period) ->
    this[what].sweeping = true
    times = this[what].rolling_times

    # Clean-up older than period.
    while true
      if times.length > 0 and times[0] < (@time() - period)
        this[what].rolling_values.shift()
        times.shift()
      else
        break

    @trigger "change:#{what}_rolling_values", this, this[what].rolling_values

    that = this
    setTimeout ->
      that.sweep_rolling what, period
    , (period / 12) * 1000

  track: (what, value) ->
    this[what] ||= {}
    this[what].values ||= []
    values = this[what].values # Values array shortcut.

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

    # Track rolling history.
    @track_rolling what, value, 60 if what is 'net_worth_diff'
    
    # Finally set value.
    @set what, value

    value

BTCD.Exchange = BTCD.AbstractExchange.extend
  initialize: (balance) ->
    unless @name
      throw new Error('Missing name parameter.')

    BTCD.info "Creating #{@name} exchange with #{balance} BTC balance."
    BTCD.app.events.t 'exchange:create', this

    # Setup feed.
    @feed = new BTCD.ExchangeFeeds[@name]

    # Recalculate net worth on changes of balance or market price.
    @on 'change:balance', @calculate_net_worth, this
    @feed.on 'change:sell', @calculate_net_worth, this
    
    # Call the super's initializer.
    BTCD.Exchange.__super__.initialize.apply this, arguments

    # Register exchange.
    BTCD.dashboard.register this

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