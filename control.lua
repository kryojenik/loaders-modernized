local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
  require("script.migrations"),

  require("script.loaders-modernized")
})