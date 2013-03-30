BTCD.ExchangeFeed = Backbone.Model.extend 
  sell_trend: 0
  sell_values: []
  buy_trend: 0
  buy_values: []

  update_trend: (kind, value) ->
    values = this["#{kind}_values"]
    
    if values.length > 0
      previous_value = values[values.length-1]

      this["#{kind}_trend"] = if previous_value > value
        -1
      else if previous_value < value
        1
      else
        0

    values.push value

  update: (buy_value, sell_value) ->
    if buy_value
      @update_trend 'buy', buy_value
      @set 'buy', buy_value
    if sell_value
      @update_trend 'sell', sell_value
      @set 'sell', sell_value

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
  process_data: (data) -> @update parseFloat(data.bid), parseFloat(data.ask)