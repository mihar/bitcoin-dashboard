class BTCD.MasterView
  constructor: ->
    BTCD.app.events.on 'balance:change', @update_balance, this
    BTCD.app.events.on 'net_worth:change', @update_net_worth, this
    BTCD.app.events.on 'net_worth_diff:change', @update_net_worth, this
    BTCD.app.events.on 'net_worth_diff:change', @mark_diff, this

    @balance_el = $ '#balance'
    @net_worth_el = $ '#net_worth'
    @diff_el = $ '#diff'

    @init()

  init: -> @update_balance BTCD.dashboard.balance

  update_balance: (data) -> @balance_el.find('strong').text data
  update_page_title: (diff, net_worth) -> document.title = "#{@glyph_diff(diff)} #{diff} [#{net_worth}]"
  update_net_worth: -> 
    net_worth = "$#{BTCD.dashboard.net_worth.toFixed(2)}"
    diff = BTCD.dashboard.net_worth_diff.toFixed(2)
      
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

  mark_diff: ->
    diff = BTCD.dashboard.net_worth_diff.toFixed(2)

    if diff > 0
      $('body').removeClass('down').addClass('up')
    else
      $('body').removeClass('up').addClass('down')