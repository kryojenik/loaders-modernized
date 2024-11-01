local flib_migration = require("__flib__.migration")

local version_migrations = {
  ["0.6.4"] = function()
    local store = storage.loader_modernized or {}
    store.players = store.players or {}
    for _, player in pairs(game.players) do
      store.players[player.index] = store.players[player.index] or {}
    end

    storage.loader_modernized = store
  end
}

local migrations = {}

migrations.on_configuration_changed = function(e)
  flib_migration.on_config_changed(e, version_migrations)
end

return migrations