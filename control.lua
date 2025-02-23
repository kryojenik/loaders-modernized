-- Using game provided event_handler.
local handler = require("event_handler")

handler.add_libraries({
  require("__flib__.gui"),

  require("scripts.migrations"),
  require("scripts.loaders-modernized"),
  require("scripts.loader-gui")
})
