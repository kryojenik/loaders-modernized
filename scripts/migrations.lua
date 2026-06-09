local flib_migration    = require("__flib__.migration")
local loader_modernized = require("scripts.loaders-modernized")
local C                 = require("__loaders-modernized__.constants")

---Holds e.mod_changes for the duration of on_configuration_changed so version handlers can read it.
---@type table<string, {old_version: string?, new_version: string?}>?
local _current_mod_changes = nil
local _just_migrated = false

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
  ["0.7.11"] = function()
    storage.loader_modernized = nil
    loader_modernized.init_storage()
  end,
  ["1.0.0"] = function(migrations)
    local removed_loader = false
    for old, new in pairs(migrations.entity) do
      ---Don't use C.LOADER_PATTERN here.  Entity names followed this pattern before 2.0.0
      if string.find(old,"mdrn%-loader") and new == "" then
        removed_loader = true
      end
    end
    game.print{"strings.mdrn-compatibility-change"}
    if removed_loader then
      game.print{"strings.mdrn-compatibility-removed"}
    end
  end,
  ["1.0.4"] = function()
    game.print{"strings.mdrn-power-change"}
  end,
  ["1.9.9"] = function ()
    --  Need to track for some issues introduced in 2.0.0 migrations.
    --  This flag won't be set if the last save had LM 2.0.0 or 2.0.1
    --  Well need to apply some fixes in 2.0.2 in that case.
    storage.migrating_from_pre2x = true
  end,
  ["2.0.0"] = function()
    -- WFS only applied to stack tier loaders pre-2.0.0.
    -- Regular tier loaders should not get auto set to WFS.
    local had_wfs = settings.startup[C.SETTINGS.WAIT_FOR_FULL_STACK].value
                and settings.startup[C.SETTINGS.ENABLE_STACKING].value == C.STACKING.STACK_TIER
    local had_fill = not settings.startup[C.SETTINGS.RESPECT_INSERT_LIMITS].value
    settings.global[C.SETTINGS.DEFAULT_WAIT_FOR_FULL_STACK] = { value = had_wfs }
    settings.global[C.SETTINGS.DEFAULT_RESPECT_INSERT_LIMITS] = { value = not had_fill }
    storage.splits   = nil
    loader_modernized.on_configuration_changed()
    -- Rename storage.fast_replace_split → storage.fast_replace_variant.
    -- Convert stored `true` values to LMVariantFlags with split=true (all prior
    -- entries came from the split-lane fast-replace path).
    -- Convert surface key to surface_index from surface_name.
    if storage.fast_replace_split then
      local frs = storage.fast_replace_split
      local frv = {}
      for surface_key, surface_data in pairs(frs) do
        local surface_index = game.get_surface(surface_key).index
        local new_surface_data = {}
        for loader_key, _ in pairs(surface_data) do
          new_surface_data[loader_key] = { split = true, wfs = had_wfs, fill = had_fill }
        end
        frv[surface_index] = new_surface_data
      end
      storage.fast_replace_variant = frv
      storage.fast_replace_split   = nil
    end

    local existing_slow_loaders = false
    local loader_names = {}
    for l, _ in pairs(storage.variants) do
      loader_names[#loader_names + 1] = l
    end

    ---@param loaders LuaEntity[]
    local function swap_loaders(loaders)
      for _, loader in pairs(loaders) do
        local entity_name = loader.name == "entity-ghost" and loader.ghost_name or loader.name
        local base        = loader_modernized.variant_base(entity_name)
        local variant_flags = {
          split = string.find(entity_name, "%-split") and true or false,
          wfs   = had_wfs and storage.variants[base .. C.WFS_SUFFIX] ~= nil,
          fill  = had_fill,
        }

        if loader.loader_type == "output"
        and string.find(base, C.CHUTE_LOADER_PATTERN) then
          existing_slow_loaders = true
        end

        loader_modernized.swap_variant(loader, variant_flags)
      end
    end

    for _, surface in pairs(game.surfaces) do
      local loaders = surface.find_entities_filtered{name = loader_names}
      local ghosts  = surface.find_entities_filtered{type = "entity-ghost", ghost_name = loader_names}
      swap_loaders(loaders)
      swap_loaders(ghosts)
    end
    if existing_slow_loaders then
      settings.global[C.SETTINGS.CHUTE_DIRECTION] = { value = "input-output" }
      game.print{"strings.mdrn-chute-direction-change"}
    end
  end,
  ["2.0.1"] = function(migrations)
    local removed_loader = false
    for old, new in pairs(migrations.entity) do
      if string.find(old,"mdrn%-loader")
        and not string.find(old, "^factory%-linked")
        and not string.find(old, "projectile$")
        and new == "" then
        removed_loader = true
      end
    end
    if removed_loader then
      game.print{"strings.mdrn-compatibility-removed-2"}
    end
  end,
  ["2.0.2"] = function(migrations)
    if not storage.migrating_from_pre2x then
      -- We were too aggressive making stack loaders wfs in 2.0.0.  Warn players about the change and how to fix it if they want to.
      local loader_names = {}
      for l, _ in pairs(storage.variants) do
        if string.find(l,"%-wfs") then
          loader_names[#loader_names + 1] = l
        end
      end

      for _, surface in pairs(game.surfaces) do
        for _, loader in pairs(surface.find_entities_filtered{name = loader_names}) do
          if string.find(loader.name, "%-wfs") then
            game.print{"strings.mdrn-wfs-warning"}
            return
          end
        end

        for _, ghost in pairs(surface.find_entities_filtered{type = "entity-ghost", ghost_name = loader_names}) do
          if string.find(ghost.ghost_name, "%-wfs") then
            game.print{"strings.mdrn-wfs-warning"}
            return
          end
        end
      end
      storage.migrating_from_pre2x = nil
    end
  end,
  ["2.0.3"] = function()
    storage.slow_loaders = nil
  end,
  ["2.0.7"] = function()
    local lu_was_present = _current_mod_changes
      and _current_mod_changes["loader-utils"]
      and _current_mod_changes["loader-utils"].old_version ~= nil

    if not lu_was_present then return end

    if not settings.startup[C.SETTINGS.LU_MIGRATION].value then
      game.print{"strings.mdrn-lu-removed-warn"}
      if settings.startup[C.SETTINGS.ENABLE_STACKING].value ~= C.STACKING.ALL then
        game.print{"strings.mdrn-lu-stacking-warn"}
      end
      return
    end

    local lu_prefix_combos = {
      "lf-", "fs-", "rl-",
      "lf-fs-", "lf-rl-", "fs-rl-",
      "lf-fs-rl-",
    }

    local lu_names = {}
    for variant_name, _ in pairs(storage.variants) do
      for _, prefix in ipairs(lu_prefix_combos) do
        lu_names[#lu_names + 1] = prefix .. variant_name
      end
    end

    ---@param name string
    ---@return string inner
    ---@return boolean lf
    ---@return boolean fs
    ---@return boolean rl
    local function decode_lu(name)
      local lf = name:sub(1, 3) == "lf-"
      if lf then name = name:sub(4) end
      local fs = name:sub(1, 3) == "fs-"
      if fs then name = name:sub(4) end
      local rl = name:sub(1, 3) == "rl-"
      if rl then name = name:sub(4) end
      return name, lf, fs, rl
    end -- decode_lu()

    ---Inner LM suffixes are ignored; only LU prefix flags determine the target.
    ---Falls back progressively if the ideal variant is unavailable (e.g. wfs on a non-stacking tier).
    ---@param inner string
    ---@param lf boolean
    ---@param fs boolean
    ---@param rl boolean
    ---@return string?
    local function resolve_target(inner, lf, fs, rl)
      local base = loader_modernized.variant_base(inner)
      local fill = not rl
      local candidates = {
        base .. (lf and C.SPLIT_SUFFIX or "") .. (fs and C.WFS_SUFFIX or "") .. (fill and C.FILL_SUFFIX or ""),
        base .. (lf and C.SPLIT_SUFFIX or "") .. (fill and C.FILL_SUFFIX or ""),
        base .. (fill and C.FILL_SUFFIX or ""),
        base,
      }
      for _, candidate in ipairs(candidates) do
        if storage.variants[candidate] then return candidate end
      end
    end -- resolve_target()

    local migrated = 0

    ---@param entities LuaEntity[]
    local function migrate_entities(entities)
      for _, entity in ipairs(entities) do
        local is_ghost    = entity.name == "entity-ghost"
        local entity_name = is_ghost and entity.ghost_name or entity.name
        local inner, lf, fs, rl = decode_lu(entity_name)
        local target = resolve_target(inner, lf, fs, rl)
        if not target then goto continue end

        local params = {
          position                  = entity.position,
          direction                 = entity.direction,
          force                     = entity.force,
          type                      = entity.loader_type,
          quality                   = entity.quality,
          fast_replace              = true,
          create_build_effect_smoke = false,
          spill                     = false,
        }
        if is_ghost then
          params.name       = "entity-ghost"
          params.inner_name = target
        else
          params.name = target
        end
        local new = entity.surface.create_entity(params)
        if new then
          migrated = migrated + 1
        end
        ::continue::
      end
    end -- migrate_entities()

    for _, surface in pairs(game.surfaces) do
      migrate_entities(surface.find_entities_filtered{name = lu_names})
      migrate_entities(surface.find_entities_filtered{type = "entity-ghost", ghost_name = lu_names})
    end

    if settings.startup[C.SETTINGS.ENABLE_STACKING].value ~= C.STACKING.ALL then
      game.print{"strings.mdrn-lu-stacking-warn"}
    end

    game.print{"strings.mdrn-lu-migration-complete", migrated}
    storage.lu_migration_complete = true
    _just_migrated = true
  end,
}

local migrations = {}

migrations.on_configuration_changed = function(e)
  loader_modernized.update_variants()
  -- Set an upvalue so handlers see which mods were added or removed.
  _current_mod_changes = e.mod_changes
  flib_migration.on_config_changed(e, version_migrations, nil, e.migrations)
  _current_mod_changes = nil

  if not _just_migrated
    and settings.startup[C.SETTINGS.LU_MIGRATION].value
    and storage.lu_migration_complete then
   game.print{"strings.mdrn-lu-migration-reminder"}
  end
end -- migrations.on_configuration_changed()

return migrations
