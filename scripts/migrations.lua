local flib_migration = require("__flib__.migration")

local version_migrations = {
  ["0.6.4"] = function()
    local store = storage.loader_modernized or {}
    store.players = store.players or {}
    for _, player in pairs(game.players) do
      store.players[player.index] = store.players[player.index] or {}
    end

    storage.loader_modernized = store
  end,
  ["0.7.0"] = function()
    for _, p in pairs(game.players) do
      local window = p.gui.screen.mdrn_loader_warning_window
      if window then
        window.destroy()
      end
    end
  end,
  ["0.7.9"] = function()
    local store = storage.loader_modernized or {}
    storage = store
    storage.fast_replace_split = {}
    for i, player in pairs(game.players) do
      storage.players[i].name = player.name
    end
  end
}

local migrations = {}

migrations.on_configuration_changed = function(e)
  flib_migration.on_config_changed(e, version_migrations)
end

return migrations