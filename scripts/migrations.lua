local flib_migration = require("__flib__.migration")

--local from_miniloader = require("script.from-miniloader")
--local loaders_modernized = require("script.loaders-modernized")

local version_migrations = {}

local migrations = {}

local function find_all_miniloaders()
  local miniloader_parts = {}
  for k,v in pairs(prototypes.entity) do
    if string.find(v.name, ".*miniloader.*") then
      miniloader_parts[#miniloader_parts+1] = v.name
    end
  end

  local to_migrate = storage.miniloaders_to_migrate or {}
  for _, surface in pairs(game.surfaces) do
    local miniloaders = surface.find_entities_filtered{type = {"loader-1x1", "inserter"}, name = miniloader_parts}
    for _, m in pairs(miniloaders) do
      m.active = false
      m.operable = false
      if m.type == "loader-1x1" then
        to_migrate[m.unit_number] = {
          name = m.name,
          surface = m.surface,
          position = m.position,
          gps_tag = m.gps_tag
        }
      end
    end
  end

  storage.miniloaders_to_migrate = to_migrate
  log("got em")
end

local function replace_miniloaders()
  local miniloaders = storage.miniloaders_to_migrate
  for unit, ml in pairs(miniloaders) do
    local ml_entities = ml.surface.find_entities_filtered{position = ml.position}
    local name = string.gsub(ml.name, "miniloader", "mdrn")
    ml.surface.create_entity{

    }
  end
end

migrations.on_configuration_changed = function(e)
-- In runtime We need to fi all miniloaders, stopthem, provide a way to migrate them
  find_all_miniloaders()
  flib_migration.on_config_changed(e, version_migrations)
end

return migrations