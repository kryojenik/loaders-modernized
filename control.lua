local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
  require("__loaders-modernized__.scripts.migrations"),

  require("__loaders-modernized__.scripts.loaders-modernized")
})