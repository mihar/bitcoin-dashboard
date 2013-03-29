BTCD.Events =
  t: (event_name, options = {}) ->
    BTCD.log 6, "EVENT Triggered '#{event_name}'", options
    @trigger event_name, options