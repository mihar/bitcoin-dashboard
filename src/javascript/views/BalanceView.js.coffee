class BTCD.BalanceView extends Backbone.View
  id: 'balance'

  initialize: ->
    BTCD.app.events.on 'net_worth:change', @render, this

  render: ->
    @$el.text "$#{BTCD.balance.net_worth.toFixed(2)}"
    this