BTCD.ExchangeFeed = Backbone.Model.extend 
  update: (buy_value, sell_value) ->
    @set 'buy', buy_value if buy_value
    @set 'sell', sell_value if sell_value

    BTCD.app.events.t 'heartbeat'

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
  poll_url: 'http://coincors.herokuapp.com/coinbase'
  process_data: (data) -> @update data.buy, data.sell

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
