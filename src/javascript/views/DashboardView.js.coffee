class BTCD.DashboardView
  constructor: ->
    @model = BTCD.dashboard
    @model.on 'change:balance', @update_balance, this
    @model.on 'change:net_worth', @update_net_worth, this
    @model.on 'change:net_worth_diff', @update_net_worth, this
    @model.on 'change:net_worth_diff', @mark_diff, this

    @balance_el = $ '#balance'
    @net_worth_el = $ '#net_worth'
    @diff_el = $ '#diff'

    @init()

  init: -> @update_balance @model, @model.get 'balance'

  update_balance: (model, balance) -> @balance_el.find('strong').text balance
  update_page_title: (diff, net_worth) -> document.title = "#{@glyph_diff(diff)} #{diff} [#{net_worth}]"
  update_net_worth: -> 
    net_worth = "$#{@model.get('net_worth').toFixed(2)}"
    diff = @model.get('net_worth_diff').toFixed(2)
      
    # Update page title.
    @update_page_title diff, net_worth

    # Update DOM.
    @net_worth_el.find('strong').text net_worth
    @diff_el.find('.amount').text diff
    @diff_el.find('.direction').html @entity_diff(diff)

  visualize_diff: (diff) ->
    return ["▲", "&uarr;"] if diff > 0
    ["▼", "&darr;"]
  glyph_diff: (diff) -> @visualize_diff(diff)[0]
  entity_diff: (diff) -> @visualize_diff(diff)[1]

  mark_diff: (model, net_worth_diff) ->
    if net_worth_diff > 0
      $('body').removeClass('down').addClass('up')
    else
      $('body').removeClass('up').addClass('down')