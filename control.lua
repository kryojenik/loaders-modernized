local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
  require("loaders-modernized.scripts.migrations"),

  require("loaders-modernized.scripts.loaders-modernized")
})