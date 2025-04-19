local flib_direction = require("__flib__.direction")
local flib_position = require("__flib__.position")

local transport_belt_connectables = {
  "transport-belt",
  "underground-belt",
  "splitter",
  "loader",
  "loader-1x1",
  "linked-belt",
  "lane-splitter",
}

local loader_modernized = {}

---Look for adjacent belt and snap the loader to connect to the belt
---@param entity LuaEntity
---@return boolean
local function snap_to_belt(entity)
  -- front_direction is the belt side
  -- back_direction is the inventory side
  local front_direction = entity.direction
  local back_direction = flib_direction.opposite(front_direction)
  if entity.loader_type == "input" then
    back_direction = front_direction
    front_direction = flib_direction.opposite(entity.direction)
  end

  local front_position = flib_position.add(entity.position, flib_direction.to_vector(front_direction))
  local back_position = flib_position.add(entity.position, flib_direction.to_vector(back_direction))
  local front = true
  local belt =
    entity.surface.find_entities_filtered({ position = front_position, type = transport_belt_connectables })[1]
  if not belt then
    belt =
      entity.surface.find_entities_filtered({ position = front_position, ghost_type = transport_belt_connectables })[1]
  end

  if not belt then
    front = false
    belt =
      entity.surface.find_entities_filtered({ position = back_position, type = transport_belt_connectables })[1]
  end

  if not belt then
    belt =
      entity.surface.find_entities_filtered({ position = back_position, ghost_type = transport_belt_connectables })[1]
  end

  if not belt then
    return false
  end

  if not front then
    entity.direction = flib_direction.opposite(entity.direction)
  end

  if belt.direction == flib_direction.opposite(entity.direction) then
    entity.loader_type = entity.loader_type == "output" and "input" or "output"
  elseif belt.direction ~= entity.direction then
    entity.loader_type = "output"
  end

  return true
end -- snap_to_belt()

---If we're not yet adjacent to a belt, find an entity to snap away from
---@param entity LuaEntity
local function snap_away_from_non_belt(entity)
  local front_direction = entity.direction
  local back_direction = flib_direction.opposite(front_direction)
  if entity.loader_type == "input" then
    back_direction = front_direction
    front_direction = flib_direction.opposite(entity.direction)
  end

  local front_position = flib_position.add(entity.position, flib_direction.to_vector(front_direction))
  local back_position = flib_position.add(entity.position, flib_direction.to_vector(back_direction))
  local non_belt = entity.surface.find_entities_filtered({
    position = back_position,
    type = transport_belt_connectables,
    ghost_type = transport_belt_connectables,
    invert = true
  })[1]

  if non_belt then
    return
  end

  non_belt = entity.surface.find_entities_filtered({
    position = front_position,
    type = transport_belt_connectables,
    ghost_type = transport_belt_connectables,
    invert = true
  })[1]

  if non_belt then
    entity.direction = flib_direction.opposite(entity.direction)
    entity.loader_type = entity.loader_type == "output" and "input" or "output"
    return
  end

end -- snap_away_from_non_belt()

---Entry into the snapping logic
---@param entity LuaEntity
local function snap(entity)
  if not snap_to_belt(entity) then
    snap_away_from_non_belt(entity)
  end
end -- snap()

---Handle on_entity_built
---@param e BuiltEvent
local function on_entity_built(e)
  local entity = e.entity or e.destination
  if not entity.valid then
    return
  end

  if not string.find(entity.name, ".*mdrn%-loader") and not (entity.type == "entity-ghost") then
    return
  end

  if entity.type == "entity-ghost" and not string.find(entity.ghost_name, ".*mdrn%-loader") then
    return
  end

  snap(entity)

  local position = entity.position.x .. "," .. entity.position.y
  local surface_name = entity.surface.name
  local surface_data = storage.fast_replace_split[surface_name] or {}
  if surface_data[position] then
    loader_modernized.swap_split(entity)
    surface_data[position] = nil
    storage.fast_replace_split[surface_name] = surface_data
  end
end -- on_entity_built()

---Handle on_player_joined
---@param e EventData.on_player_joined_game
local function on_player_joined(e)
  local players = storage.players or {}
  players[e.player_index] = players[e.player_index] or {}
end

---@param e EventData.on_pre_build
local function on_pre_build(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  if player.is_cursor_empty() or player.is_cursor_blueprint() then
    return
  end

  local item_name
  if player.cursor_stack.valid_for_read then
    item_name = player.cursor_stack.name
  else
    item_name = player.cursor_ghost.name.name
  end

  if not string.match(item_name, "mdrn%-loader") then
    return
  end

  local surface = player.surface
  local fast_replace = surface.can_fast_replace{
      position = e.position,
      direction = e.direction,
      force = player.force,
      name = item_name
  }

  if not fast_replace then
    return
  end

  local entity = surface.find_entities_filtered{position = e.position, type = {"loader-1x1", "entity-ghost"}}[1]
  local entity_name = string.match(entity.name, "mdrn%-loader") and entity.name or entity.ghost_name
  if string.match(entity_name, "-split") then
    local surface_data = storage.fast_replace_split[surface.name] or {}
    surface_data[entity.position.x .. "," .. entity.position.y] = true
    storage.fast_replace_split[surface.name] = surface_data
  end
end

---When switching state, replace the existing entity with the alternate entity.
---(tier-)mdrn-loader <-> (tier-)mdrn-loader-split
---The -split version has filter_count == 2 and filter configured per lane
---@param old LuaEntity
---@return LuaEntity?
loader_modernized.swap_split = function(old, player_index)
  local proto = old.prototype
  if old.name == "entity-ghost" then
    proto = old.ghost_prototype --[[@as LuaEntityPrototype]]
  end

  -- Grab the non-split entity from the split name and make it the new name.
  -- If it is not a split entity, make a new from the prototype name
  local base_name = string.match(proto.name, "^(.*)-split")
  local new_name = base_name or proto.name .. "-split"

  -- Retain quality when switching between split and non-split configurations
  local quality = old.quality
  local player = player_index and game.get_player(player_index) or nil

  local new = {
    name = new_name,
    fast_replace = true,
    create_build_effect_smoke = false,
    position = old.position,
    direction = old.direction,
    force = old.force,
    type = old.loader_type,
    quality = quality,
    spill = false,
  }
  if old.name == "entity-ghost" then
    new.name = "entity-ghost"
    new.inner_name = new_name
  end

  local surface = old.surface
  local new_entity = surface.create_entity(new)
  if not new_entity then
    return
  end
  new_entity.last_user = player
  return new_entity
end

---on_init handler
loader_modernized.on_init = function()
  storage = {
    players = {},
    fast_replace_split = {}
  }
  for i, player in pairs(game.players) do
    storage.players[i] = {
      name = player.name
    }
  end
end

---Event handlers
loader_modernized.events = {
  [defines.events.on_built_entity] = on_entity_built,
  [defines.events.on_entity_cloned] = on_entity_built,
  [defines.events.on_robot_built_entity] = on_entity_built,
  [defines.events.script_raised_built] = on_entity_built,
  [defines.events.script_raised_revive] = on_entity_built,
  [defines.events.on_player_joined_game] = on_player_joined,
  [defines.events.on_pre_build] = on_pre_build,
}

return loader_modernized