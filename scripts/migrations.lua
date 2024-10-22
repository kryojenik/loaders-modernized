local flib_migration = require("__flib__.migration")

--local from_miniloader = require("script.from-miniloader")
--local loaders_modernized = require("script.loaders-modernized")

local version_migrations = {}

local migrations = {}

migrations.on_configuration_changed = function(e)
-- In runtime We need to find all miniloaders, stopthem, provide a way to migrate them

local miniloader_parts = {}
for k,v in pairs(prototypes.entity) do
  if string.find(v.name, ".*miniloader.*") then
    miniloader_parts[#miniloader_parts+1] = v.name
  end
end

for _, surface in pairs(game.surfaces) do
  local miniloaders = surface.find_entities_filtered{type = {"loader-1x1", "inserter"}, name = miniloader_parts}
  for _, m in pairs(miniloaders) do
    m.active = false
    m.operable = false
  end
end


  flib_migration.on_config_changed(e, version_migrations)
end

return migrations