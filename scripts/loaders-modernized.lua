local flib_direction = require("__flib__.direction")
local position = require("__flib__.position")
local loader_gui = require("__loaders-modernized__.scripts.loader-gui")

local transport_belt_connectables = {
  "transport-belt",
  "underground-belt",
  "splitter",
  "loader",
  "loader-1x1",
  "linked-belt",
  "lane-splitter",
}

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

  local front_position = position.add(entity.position, flib_direction.to_vector(front_direction))
  local back_position = position.add(entity.position, flib_direction.to_vector(back_direction))
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

  local front_position = position.add(entity.position, flib_direction.to_vector(front_direction))
  local back_position = position.add(entity.position, flib_direction.to_vector(back_direction))
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
end -- on_entity_built()

---Handle on_player_joined
---@param e EventData.on_player_joined_game
local function on_player_joined(e)
  local players = storage.loader_modernized.players or {}
  players[e.player_index] = players[e.player_index] or {}
end

local loader_modernized = {}

---on_init handler
loader_modernized.on_init = function()
  storage.loader_modernized = {
    players = {}
  }
  for i, player in pairs(game.players) do
    storage.loader_modernized.players[i] = {}
  end
end

---Event handlers
loader_modernized.events = {
  [defines.events.on_built_entity] = on_entity_built,
  [defines.events.on_entity_cloned] = on_entity_built,
  [defines.events.on_robot_built_entity] = on_entity_built,
  [defines.events.script_raised_built] = on_entity_built,
  [defines.events.script_raised_revive] = on_entity_built,
  [defines.events.on_space_platform_built_entity] = on_entity_built,
  [defines.events.on_gui_opened] = loader_gui.on_gui_opened,
  [defines.events.on_player_joined_game] = on_player_joined,
}

return loader_modernized