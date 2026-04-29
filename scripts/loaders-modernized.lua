local C = require("__loaders-modernized__.constants")
local snapping = require("scripts.snapping")

local loader_modernized = {}

-- ─── Snapping API ────────────────────────────────────────────────────────────

-- Another mod can disable snapping by calling remote.call("loaders-modernized", "disable_snapping")
-- from its on_load and on_init handlers.
local snapping_enabled = true

-- ─── Private helpers ──────────────────────────────────────────────────────────

---Encode an entity position as a string key for the fast_replace_variant table.
---@param pos MapPosition
---@return string
local function pos_key(pos)
  return pos.x .. "," .. pos.y
end -- pos_key()

-- ─── Public helpers ───────────────────────────────────────────────────────────

---Strip all known variant suffixes from `name` to recover the base entity name.
---Strips in reverse canonical order: -fill → -wfs → -split.
---@param name string
---@return string
function loader_modernized.variant_base(name)
  name = string.gsub(name, C.FILL_PATTERN,  "")
  name = string.gsub(name, C.WFS_PATTERN,   "")
  name = string.gsub(name, C.SPLIT_PATTERN, "")
  return name
end -- loader_modernized.variant_base()

-- ─── Event handlers ───────────────────────────────────────────────────────────

---@param e BuiltEvent
local function on_entity_built(e)
  local entity = e.entity or e.destination
  if not entity.valid then return end

  -- Event filters narrow to loader types; still guard against other mods' loaders
  local name = entity.type == "entity-ghost" and entity.ghost_name or entity.name
  if not string.find(name, C.LOADER_PATTERN) then return end

  if snapping_enabled then snapping.snap(entity) end

  if storage.slow_loaders[loader_modernized.variant_base(name)]
  and settings.startup[C.SETTINGS.CHUTE_MODE].value ~= C.CHUTE.FILTERED
  and settings.global[C.SETTINGS.CHUTE_DIRECTION].value == "input" then
    entity.loader_type = "input"
  end

  local surface_data = storage.fast_replace_variant[entity.surface.index]
  local key          = pos_key(entity.position)
  local flags        = surface_data and surface_data[key]
  if flags then
    loader_modernized.swap_variant(entity, flags)
    surface_data[key] = nil
  elseif e.player_index ~= nil and loader_modernized.variant_base(name) == name then
    local player = game.get_player(e.player_index)
    if not player then return end
    local from_item = false
    if entity.type ~= "entity-ghost" then
      from_item = true
    elseif player.cursor_stack and player.cursor_stack.valid_for_read
    and string.find(player.cursor_stack.name, C.LOADER_PATTERN) then
      from_item = true
    elseif player.cursor_ghost
    and string.find(player.cursor_ghost.name.name, C.LOADER_PATTERN) then
      from_item = true
    end

    if from_item then
      local default_flags = {
        split = false,
        wfs   = settings.global[C.SETTINGS.DEFAULT_WAIT_FOR_FULL_STACK].value
                and storage.variants[name .. C.WFS_SUFFIX] ~= nil,
        fill  = not settings.global[C.SETTINGS.DEFAULT_RESPECT_INSERT_LIMITS].value,
      }
      if default_flags.wfs or default_flags.fill then
        loader_modernized.swap_variant(entity, default_flags)
      end
    end
  end
end -- on_entity_built()

---@param e EventData.on_player_joined_game
local function on_player_joined(e)
  storage.players[e.player_index] = storage.players[e.player_index]
    or { name = game.get_player(e.player_index).name }
end -- on_player_joined()

---@param e EventData.on_pre_entity_settings_pasted
local function on_settings_pasted(e)
  if not string.find(e.destination.name, C.LOADER_PATTERN) then return end

  local src_proto = e.source.prototype
  local dst_proto = e.destination.prototype

  ---@type LMVariantFlags
  local src_flags = {
    split = src_proto.per_lane_filters             and true or false,
    wfs   = src_proto.loader_wait_for_full_stack   and true or false,
    fill  = not src_proto.loader_respect_insert_limits,
  }
  ---@type LMVariantFlags
  local dst_flags = {
    split = dst_proto.per_lane_filters             and true or false,
    wfs   = dst_proto.loader_wait_for_full_stack   and true or false,
    fill  = not dst_proto.loader_respect_insert_limits,
  }

  if src_flags.split ~= dst_flags.split
  or src_flags.wfs   ~= dst_flags.wfs
  or src_flags.fill  ~= dst_flags.fill then
    loader_modernized.swap_variant(e.destination, src_flags)
  end
end -- on_settings_pasted()

---@param e EventData.on_pre_build
local function on_pre_build(e)
  local player = game.get_player(e.player_index)
  if not player then return end
  if player.is_cursor_empty() or player.is_cursor_blueprint() then return end

  local item_name = player.cursor_stack.valid_for_read
    and player.cursor_stack.name
    or player.cursor_ghost.name.name

  if not string.match(item_name, C.LOADER_PATTERN) then return end

  local surface = player.surface
  if not surface.can_fast_replace{
    position  = e.position,
    direction = e.direction,
    force     = player.force,
    name      = item_name,
  } then return end

  local entity = surface.find_entities_filtered{
    position = e.position,
    type     = {"loader-1x1", "entity-ghost"},
  }[1]
  if not entity then return end

  local proto = entity.prototype.type == "loader-1x1"
    and entity.prototype
    or entity.ghost_prototype

  ---@type LMVariantFlags
  local flags = {
    split = proto.per_lane_filters             and true or false,
    wfs   = proto.loader_wait_for_full_stack   and true or false,
    fill  = not proto.loader_respect_insert_limits,
  }
  -- Only persist if the entity being replaced has at least one variant flag set;
  -- a base-entity replacement needs no swap after placement.
  if flags.split or flags.wfs or flags.fill then
    local surface_data = storage.fast_replace_variant[surface.index] or {}
    surface_data[pos_key(entity.position)] = flags
    storage.fast_replace_variant[surface.index] = surface_data
  end
end -- on_pre_build()

---@param e EventData.on_player_rotated_entity
local function on_entity_rotated(e)
  local entity = e.entity
  if not entity.valid then return end

  local name = entity.type == "entity-ghost" and entity.ghost_name or entity.name
  if string.find(name, C.LOADER_PATTERN)
  and storage.slow_loaders[loader_modernized.variant_base(name)]
  and settings.startup[C.SETTINGS.CHUTE_MODE].value ~= C.CHUTE.FILTERED
  and settings.global[C.SETTINGS.CHUTE_DIRECTION].value == "input" then
    entity.loader_type = "input"
  end
end -- on_entity_rotated()

---@param e EventData.on_surface_deleted
local function on_surface_deleted(e)
  storage.fast_replace_variant[e.surface_index] = nil
end -- on_surface_deleted()

-- ─── Public API ───────────────────────────────────────────────────────────────

---Replace entity with the variant described by `flags`, preserving quality and direction.
---@param old LuaEntity
---@param flags LMVariantFlags
---@param player_index uint?
---@return LuaEntity?
loader_modernized.swap_variant = function(old, flags, player_index)
  local proto = old.name == "entity-ghost"
    and old.ghost_prototype --[[@as LuaEntityPrototype]]
    or old.prototype

  local base_name  = loader_modernized.variant_base(proto.name)
  local suffix     = (flags.split and C.SPLIT_SUFFIX or "")
                  .. (flags.wfs   and C.WFS_SUFFIX   or "")
                  .. (flags.fill  and C.FILL_SUFFIX  or "")
  local new_name   = base_name .. suffix

  if not storage.variants[new_name] then return end
  if new_name == proto.name then return end  -- already the right variant

  local player = player_index and game.get_player(player_index) or nil
  local params = {
    name                    = new_name,
    fast_replace            = true,
    create_build_effect_smoke = false,
    position                = old.position,
    direction               = old.direction,
    force                   = old.force,
    type                    = old.loader_type,
    quality                 = old.quality,
    spill                   = false,
  }
  if old.name == "entity-ghost" then
    params.name       = "entity-ghost"
    params.inner_name = new_name
  end

  local new_entity = old.surface.create_entity(params)
  if not new_entity then return end
  new_entity.last_user = player
  return new_entity
end -- loader_modernized.swap_variant()

---Initialize (or re-initialize) global storage to a clean known state.
---Idempotent — safe to call from on_init or a migration handler.
function loader_modernized.init_storage()
  storage.players              = {}
  storage.fast_replace_variant = {}
  storage.slow_loaders         = {}
  for i, player in pairs(game.players) do
    storage.players[i] = { name = player.name }
  end
end -- loader_modernized.init_storage()

loader_modernized.on_init = function()
  loader_modernized.init_storage()
  loader_modernized.on_configuration_changed()
end -- loader_modernized.on_init()

loader_modernized.on_load = function()
  -- Filter entity-built events to loader types so the handler is not invoked
  -- for every entity placed in the game (significant performance gain in large maps).
  local entity_filters = {
    {filter = "type", type = "loader-1x1"},
    {filter = "ghost_type", type = "loader-1x1"},
  }
  script.set_event_filter(defines.events.on_built_entity,        entity_filters)
  script.set_event_filter(defines.events.on_entity_cloned,       entity_filters)
  script.set_event_filter(defines.events.on_robot_built_entity,  entity_filters)
  script.set_event_filter(defines.events.script_raised_built,    entity_filters)
  script.set_event_filter(defines.events.script_raised_revive,   entity_filters)

  remote.add_interface("loaders-modernized", {
    ---Disable automatic belt-snapping for all loaders placed by this mod.
    ---Call from your mod's on_init and on_load handlers.
    disable_snapping = function()
      snapping_enabled = false
    end,
  })
end -- loader_modernized.on_load()

loader_modernized.on_configuration_changed = function()
  local variants = {}
  for k in pairs(prototypes.get_entity_filtered{
    {filter = "type", type = "loader-1x1", "or"},
  }) do
    if string.find(k, C.LOADER_PATTERN) then  -- skip other mods' loaders
      variants[k] = true
    end
  end
  storage.variants = variants

  local base_speed = prototypes.entity["mdrn-loader"] and prototypes.entity["mdrn-loader"].belt_speed
  local slow = {}
  for k in pairs(variants) do
    local base_name = loader_modernized.variant_base(k)
    if base_speed and prototypes.entity[k].belt_speed < base_speed then
      slow[base_name] = true
    end
  end
  storage.slow_loaders = slow
end -- loader_modernized.on_configuration_changed()

loader_modernized.events = {
  [defines.events.on_built_entity]                  = on_entity_built,
  [defines.events.on_entity_cloned]                 = on_entity_built,
  [defines.events.on_robot_built_entity]            = on_entity_built,
  [defines.events.script_raised_built]              = on_entity_built,
  [defines.events.script_raised_revive]             = on_entity_built,
  [defines.events.on_player_joined_game]            = on_player_joined,
  [defines.events.on_pre_build]                     = on_pre_build,
  [defines.events.on_pre_entity_settings_pasted]    = on_settings_pasted,
  [defines.events.on_player_rotated_entity]          = on_entity_rotated,
  [defines.events.on_surface_deleted]               = on_surface_deleted,
}

return loader_modernized
