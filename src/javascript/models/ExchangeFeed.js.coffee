BTCD.ExchangeFeed = Backbone.Model.extend {}

BTCD.ExchangeFeedSocket = BTCD.ExchangeFeed.extend
  initialize: -> 
    _.bindAll this, 'process_message'
    @connect() if @socket_url?

  connect: ->
    @connection = io.connect @socket_url
    @connection.on 'message', @process_message

BTCD.ExchangeFeedPoll = BTCD.ExchangeFeed.extend
  polling_interval: 5000

  initialize: -> @poll() if @poll_url?

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
      @set 'sell', parseFloat(data.ticker.sell.value)
      @set 'buy', parseFloat(data.ticker.buy.value)

# Coinbase
BTCD.ExchangeFeeds.Coinbase = BTCD.ExchangeFeedPoll.extend
  poll_url: 'https://coinbase.com/api/v1/prices/sell'
  process_data: (data) -> @set 'sell', parseFloat(data.amount)

# Bitstamp
BTCD.ExchangeFeeds.Bitstamp = BTCD.ExchangeFeedPoll.extend
  poll_url: 'https://www.bitstamp.net/api/ticker/'
  process_data: (data) -> 
    @set 'sell', parseFloat(data.ask)
    @set 'buy', parseFloat(data.bid)