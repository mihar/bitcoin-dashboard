class BTCD.ExchangesView extends Backbone.View
  id: 'exchanges'
  tagName: 'aside'

  initialize: ->
    BTCD.app.events.on 'exchange:register', @append, this

  append: (exchange) ->
    exchange_view = new BTCD.ExchangeView model: exchange
    @$el.append exchange_view.render().el

class BTCD.ExchangeView extends Backbone.View
  className: 'exchange'       

  initialize: ->
    @balance_el = $ '<div class="balance">Balance: <strong>0</strong></div>'
    @net_worth_el = $ '<div class="net_worth">Net worth: <strong>0</strong></div>'

    @model.on 'change:net_worth', @update_net_worth, this
    @model.on 'change:balance', @update_balance, this

    # Initialize data.
    @update_balance()
    @update_net_worth()

  update_balance: -> @balance_el.find('strong').text @model.get 'balance'
  update_net_worth: -> @net_worth_el.find('strong').text "$#{@model.get('net_worth').toFixed(2)}"
    
  render: ->
    @$el.append $('<h2>').text(@model.name)
    @$el.append @balance_el
    @$el.append @net_worth_el

    this