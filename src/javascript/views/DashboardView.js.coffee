class BTCD.DashboardView
  constructor: ->
    @model = BTCD.dashboard
    @model.on 'change:balance', @update_balance, this
    @model.on 'change:net_worth', @update_net_worth, this
    @model.on 'change:net_worth_diff', @update_net_worth, this
    @model.on 'change:net_worth_diff', @mark_diff, this

    BTCD.app.events.on 'exchange:register', @update_balance, this

  init: ->
    @balance_el = $ '#balance'
    @net_worth_el = $ '#net_worth'
    @diff_el = $ '#diff'

  update_page_title: (diff, net_worth) -> document.title = "#{@glyph_diff(diff)} #{diff} [#{net_worth}]"
  
  update_balance: -> @balance_el.find('strong').text @model.get('balance')
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
    return ["▼", "&darr;"] if diff < 0
    ["▲", "&uarr;"]
    
  glyph_diff: (diff) -> @visualize_diff(diff)[0]
  entity_diff: (diff) -> @visualize_diff(diff)[1]

  mark_diff: ->
    if @model.get('net_worth_diff_rolling_value') < 0
      $('body').removeClass('up').addClass('down')
    else
      $('body').removeClass('down').addClass('up')