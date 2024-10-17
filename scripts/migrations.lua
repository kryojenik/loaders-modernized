local flib_migration = require("__flib__.migration")

--local from_miniloader = require("script.from-miniloader")
--local loaders_modernized = require("script.loaders-modernized")

local version_migrations = {}

local migrations = {}

migrations.on_configuration_changed = function(e)
  flib_migration.on_config_changed(e, version_migrations)
end

return migrations