class BTCD.MasterView extends Backbone.View
  id: 'master'

  initialize: ->
    @balance_el = $ '<div class="balance">Balance: <strong>0</strong></div>'
    @net_worth_el = $ '<div class="net_worth">Net worth: <strong>0</strong></div>'

    BTCD.app.events.on 'balance:change', @update_balance, this
    BTCD.app.events.on 'net_worth:change', @update_net_worth, this
    BTCD.app.events.on 'trend:change', @highlight_trend, this

  update_balance: (data) -> @balance_el.find('strong').text data
  update_net_worth: (data) -> 
    net_worth = "$#{data.toFixed(2)}"
    document.title = "[#{net_worth}] BTC Dashboard"
    @net_worth_el.find('strong').text net_worth

  highlight_trend: (trend) ->
    if trend is 1
      $('body').removeClass('down').addClass('up')
    else if trend is -1
      $('body').removeClass('up').addClass('down')

  render: ->
    @$el.append @balance_el
    @$el.append @net_worth_el

    this