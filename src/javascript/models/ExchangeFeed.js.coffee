BTCD.ExchangeFeed = Backbone.Model.extend 
  sell_values: []
  buy_values: []

  update_value: (kind, value) ->
    if @has kind
      if @get(kind) > value
        @set "#{kind}_trend", -1
      else if @get(kind) < value
        @set "#{kind}_trend", 1
    else
      @set "#{kind}_trend", 0

    this["#{kind}_values"].push value
    @set kind, value

  update: (buy_value, sell_value) ->
    @update_value 'buy', buy_value if buy_value
    @update_value 'sell', sell_value if sell_value

BTCD.ExchangeFeedSocket = BTCD.ExchangeFeed.extend
  initialize: -> 
    _.bindAll this, 'process_message'
    @connect() if @socket_url?

  connect: ->
    @connection = io.connect @socket_url
    @connection.on 'message', @process_message

BTCD.ExchangeFeedPoll = BTCD.ExchangeFeed.extend
  polling_interval: 5000

  initialize: -> 
    _.bindAll this, 'process_data'
    @poll() if @poll_url?

  poll: ->
    this_obj = this
    this.poll_timeout = setTimeout -> 
      this_obj.poll()
    , @polling_interval

    $.get @poll_url, @process_data


BTCD.ExchangeFeeds = {}

# MtGox
BTCD.ExchangeFeeds.MtGox = BTCD.ExchangeFeedSocket.extend
  socket_url: 'https://socketio.mtgox.com/mtgox'

  process_message: (data) ->
    if data and data.ticker
      @update parseFloat(data.ticker.buy.value), parseFloat(data.ticker.sell.value)

# Coinbase
BTCD.ExchangeFeeds.Coinbase = BTCD.ExchangeFeedPoll.extend
  poll_url: 'https://coinbase.com/api/v1/prices/sell'
  process_data: (data) -> @update null, parseFloat(data.amount)

# Bitstamp
BTCD.ExchangeFeeds.Bitstamp = BTCD.ExchangeFeedPoll.extend
  poll_url: 'https://www.bitstamp.net/api/ticker/'
  process_data: (data) -> @update parseFloat(data.ask), parseFloat(data.bid)

# BTC-E
BTCD.ExchangeFeeds.BTCE = BTCD.ExchangeFeedPoll.extend
  poll_url: 'https://btc-e.com/api/1/ticker'
  process_data: (data) -> 
    if data and data.ticker
      @update data.ticker.buy, data.ticker.sell
