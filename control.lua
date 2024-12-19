-- Using game provided event_handler.
local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
  require("__flib__.gui"),

  require("scripts.migrations"),
  require("scripts.loaders-modernized"),
  require("scripts.loader-gui")
})
