window.console = {} if not window.console
unless console.log
  console.log = ->
unless console.warn
  console.warn = ->
unless console.error
  console.error = ->
unless console.info
  console.info = ->

BTCD.console_output = ->
  args = Array.prototype.slice.call(arguments)

  # Filter out output function.
  output_routine = args[0]
  args.shift()
  return unless output_routine

  if args.length > 1
    level = parseInt args[0]
    if [0, 1, 2, 3, 4, 5, 6].indexOf(level) > -1
      args.shift()
      unless BTCD.app.debug_mode
        return false if BTCD.app.debug < level

  level = 0 if isNaN level
  level = 0 unless level?

  # Timestamp.
  date = new Date
  timestamp = "#{date.getUTCFullYear()}-#{date.getUTCMonth()+1}-#{date.getUTCDate()}@#{date.getUTCHours()}:#{date.getUTCMinutes()}:#{date.getUTCSeconds()}.#{date.getUTCMilliseconds()}"

  # Message is separate.
  msg = args[0]
  if args.length > 1
    args.shift()
  else
    args = []

  console[output_routine] "[#{BTCD.app.codename}:#{level}:#{timestamp}] #{msg}", args...
  true

BTCD.log = ->
  BTCD.console_output 'log', arguments...
BTCD.warn = ->
  BTCD.console_output 'warn', arguments...
BTCD.error = ->
  BTCD.console_output 'error', arguments...
BTCD.info = ->
  BTCD.console_output 'info', arguments...