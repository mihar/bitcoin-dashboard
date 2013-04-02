class BTCD.Persistence
  storage_key: '_btcd_persistence'

  constructor: ->
    # Check if localStorage is supported.
    if window and window['localStorage'] is null
      BTCD.error "Local storage is not supported. Persistance is disabled."
      return false

    BTCD.info '[PERSIST] Initializing'

    # Check if we have a persisted state and restore it.
    if @data() 
      # Start restore procedure.
      @restore()

      # Setup persistence after restore ends.
      BTCD.app.events.on 'persistence:restore:end', @init, this
    else
      # If we don't have a state or user doesn't want to restore.
      @reset() # Reset
      @init() # Initiate persistance monitoring

  init: ->    
    BTCD.app.events.on 'exchange:register', @persist, this
    BTCD.info '[PERSIST] Ready'

  reset: -> 
    BTCD.info 6, '[PERSIST] Resetting'
    localStorage[@storage_key] = null

  has_data: -> localStorage[@storage_key]? and localStorage[@storage_key].length and localStorage[@storage_key].length > 0

  data: -> 
    # Return any restored data from before.
    return @restored_data if @restored_data?
    
    # Check for existence of the storage key and that there is any data there.
    return false unless @has_data()

    BTCD.log 6, '[PERSIST] Reading stored data'

    # If we can read JSON from the storage.
    if restored_data = JSON.parse localStorage[@storage_key]
      # And if we have the mandatory three segments of data.
      if restored_data['exchanges']
        # Return and cache result.
        return @restored_data = restored_data

    # Everything else is false.
    false

  local_size: -> 
    if @has_data()
      localStorage[@storage_key].length
    else
      0
      
  size: -> 
    sum = 0
    for idx in [0..localStorage.length-1]
      if (key = localStorage[localStorage.key(idx)])?
        sum += key.length
    sum
  percent_full: -> Math.round((@size() / 2551000) * 100)
  percent_left: -> 100 - @percent_full()

  persistence_data: ->
    exchanges: _.map BTCD.dashboard.exchanges, (x) -> 
      name: x.name
      balance: x.get 'balance'

  persist: ->
    # Add warning when nearing storage limits.
    if @percent_full() > 90
      V.warn "[PERSIST] WARNING: Nearing storage limit (current size: #{@size()}B, space used: #{@percent_full()}%)"

    try
      localStorage[@storage_key] = JSON.stringify @persistence_data()
      BTCD.log 6, "[PERSIST] Persisted data and state (current size: #{@size()}B, space used: #{@percent_full()}%)"
    catch error
      BTCD.error "[PERSIST] ERROR: Cannot persist data (current size: #{@size()}B, space used: #{@percent_full()}%)"

  restore: ->
    unless @data()
      BTCD.error "No persisted data found, cannot restore."
      return false

    BTCD.info '[PERSIST] Restore started'

    # Hook restore procedure into various stages of the app bootup.
    BTCD.app.events.on 'init:dom:end', @restore_exchanges, this

  restore_exchanges: ->
    if @data() and exchanges = @data().exchanges
      for exchange in exchanges
        new BTCD.Exchanges[exchange.name](exchange.balance)

    BTCD.app.events.t 'persistence:restore:end'
