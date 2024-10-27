local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
  require("__flib__.gui"),

  require("__loaders-modernized__.scripts.migrations"),
  require("__loaders-modernized__.scripts.loaders-modernized")
})

if settings.startup["mdrn-migrate-from-miniloaders"].value then
  handler.add_lib(require("__loaders-modernized__.scripts.from-miniloader"))
end