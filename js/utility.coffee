# Levels
# 2 - DEBUG
# 3 - INFO

LOGLEVEL = 3

p = info = (args...) ->
  if console
    console.info args
  return if LOGLEVEL < 3
  _log args...

debug = (args...) ->
  if console
    if !console.log.apply
      console.log args
  return if LOGLEVEL < 2
  _log args...

_log = (args...) ->
  if console
    console.log args... if console.log.apply