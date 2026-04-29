local flib_direction = require("__flib__.direction")
local flib_position = require("__flib__.position")
local flib_table = require("__flib__.table")

local snapping = {}

-- ─── Entity type lists ────────────────────────────────────────────────────────

---All entity types that connect to belts. Used in find_entities_filtered calls
---and exported so callers can reuse them as event filter type lists.
---@type string[]
snapping.belt_connectable_types = {
  "transport-belt",
  "underground-belt",
  "splitter",
  "loader",
  "loader-1x1",
  "linked-belt",
  "lane-splitter",
}

---Like belt_connectable_types but also includes corpse entities, used to detect
---non-belt obstacles when orienting a loader away from inventory containers.
---Copy is required so that appending "corpse" does not mutate the exported
---belt_connectable_types array, which callers use as event filter lists.
---@type string[]
local belts_and_corpses = flib_table.array_copy(snapping.belt_connectable_types)
belts_and_corpses[#belts_and_corpses + 1] = "corpse"

-- ─── Private helpers ──────────────────────────────────────────────────────────

---Compute the front (belt-side) and back (container-side) world positions for a loader.
---For an "output" loader the front faces the entity direction; for "input" it is flipped.
---@param entity LuaEntity
---@return MapPosition front_pos, MapPosition back_pos
local function loader_facing(entity)
  local front_dir = entity.direction
  if entity.loader_type == "input" then
    front_dir = flib_direction.opposite(front_dir)
  end
  local back_dir = flib_direction.opposite(front_dir)
  return
    flib_position.add(entity.position, flib_direction.to_vector(front_dir)),
    flib_position.add(entity.position, flib_direction.to_vector(back_dir))
end -- loader_facing()

---Search one tile position for a belt-connectable entity (real or ghost).
---@param surface LuaSurface
---@param position MapPosition
---@param belt_types string[]
---@return LuaEntity?
local function find_belt(surface, position, belt_types)
  return surface.find_entities_filtered({position = position, type = belt_types})[1]
    or surface.find_entities_filtered({position = position, ghost_type = belt_types})[1]
end -- find_belt()

---Look for an adjacent belt and snap the loader to connect to it.
---Checks the front tile first; if no belt is found there, checks the back tile and
---flips the loader direction so it faces the belt found there.
---@param entity LuaEntity
---@return boolean snapped True when a belt was found and the loader was oriented toward it.
local function snap_to_belt(entity)
  local front_pos, back_pos = loader_facing(entity)
  local belt = find_belt(entity.surface, front_pos, snapping.belt_connectable_types)
  local from_front = belt ~= nil

  if not belt then
    belt = find_belt(entity.surface, back_pos, snapping.belt_connectable_types)
  end

  if not belt then
    return false
  end

  if not from_front then
    entity.direction = flib_direction.opposite(entity.direction)
  end

  -- Orient loader type to match belt direction
  if belt.direction == flib_direction.opposite(entity.direction) then
    entity.loader_type = entity.loader_type == "output" and "input" or "output"
  elseif belt.direction ~= entity.direction then
    entity.loader_type = "output"
  end

  return true
end -- snap_to_belt()

---If no adjacent belt was found, orient the loader away from any non-belt entity.
---No-op when neither adjacent tile has a non-belt entity (loader in empty space).
---@param entity LuaEntity
local function snap_away_from_non_belt(entity)
  local front_pos, back_pos = loader_facing(entity)

  local function find_non_belt(position)
    return entity.surface.find_entities_filtered({
      position = position,
      type = belts_and_corpses,
      ghost_type = snapping.belt_connectable_types,
      invert = true,
    })[1]
  end -- find_non_belt()

  -- Back tile has a non-belt entity — loader is already oriented correctly
  if find_non_belt(back_pos) then return end

  -- Front tile has a non-belt entity — flip so it becomes the back
  if find_non_belt(front_pos) then
    entity.direction = flib_direction.opposite(entity.direction)
    entity.loader_type = entity.loader_type == "output" and "input" or "output"
  end
end -- snap_away_from_non_belt()

-- ─── Public API ───────────────────────────────────────────────────────────────

---Snap `entity` to any adjacent belt, or orient it away from non-belt entities.
---@param entity LuaEntity
function snapping.snap(entity)
  if not snap_to_belt(entity) then
    snap_away_from_non_belt(entity)
  end
end -- snapping.snap()

return snapping
