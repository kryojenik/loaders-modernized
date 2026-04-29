local C        = require("__loaders-modernized__.constants")
local flib_gui = require("__flib__.gui")
local loader   = require("scripts.loaders-modernized")

local upgrade_planner = {}

local TOOLBAR_NAME    = "mdrn-upgrade-planner-toolbar"
local ADD_BUTTON_NAME = "mdrn-upg-add"
local REM_BUTTON_NAME = "mdrn-upg-remove"

-- Variant-only suffixes (no "" — the base entity is not a variant).
-- Distinct from C.VARIANT_SUFFIXES which includes "" for full-entity iteration.
-- Canonical order within each group: -split → -wfs → -fill.
local VARIANT_SUFFIXES = {
  C.SPLIT_SUFFIX,
  C.FILL_SUFFIX,
  C.SPLIT_SUFFIX .. C.FILL_SUFFIX,
  C.WFS_SUFFIX,
  C.SPLIT_SUFFIX .. C.WFS_SUFFIX,
  C.WFS_SUFFIX .. C.FILL_SUFFIX,
  C.SPLIT_SUFFIX .. C.WFS_SUFFIX .. C.FILL_SUFFIX,
}

---@param name string
---@return boolean
local function is_base_mdrn_loader(name)
  if not string.find(name, C.LOADER_PATTERN) then
    return false
  end
  if string.find(name, C.SPLIT_PATTERN) then
    return false
  end
  if string.find(name, C.WFS_PATTERN) then
    return false
  end
  if string.find(name, C.FILL_PATTERN) then
    return false
  end
  return true
end -- is_base_mdrn_loader()

---@param name string
---@return boolean
local function is_variant_mdrn_loader(name)
  if not string.find(name, C.LOADER_PATTERN) then
    return false
  end
  return string.find(name, C.SPLIT_PATTERN) ~= nil
      or string.find(name, C.WFS_PATTERN)   ~= nil
      or string.find(name, C.FILL_PATTERN)  ~= nil
end -- is_variant_mdrn_loader()

---Resolve the writable upgrade planner currently effective on the player's cursor.
---Handles four source cases:
---  (1) cursor_stack is an upgrade item (inventory planner)
---  (2) cursor_stack is a blueprint book whose active item is an upgrade item
---  (3) cursor_record is an "upgrade-planner" LuaRecord (library planner)
---  (4) cursor_record is a "blueprint-book" LuaRecord whose selected record is an upgrade-planner
---Returns nil when no writable upgrade planner is active.
---@param player LuaPlayer
---@return (LuaItemStack|LuaRecord)?
local function get_cursor_upgrade_planner(player)
  local record = player.cursor_record
  if record and record.valid then
    if record.type == "upgrade-planner" then
      return record.valid_for_write and record or nil
    elseif record.type == "blueprint-book" then
      local sel = record.get_selected_record(player)
      if sel and sel.valid and sel.type == "upgrade-planner" and sel.valid_for_write then
        return sel
      end
    end

    return nil
  end

  local stack = player.cursor_stack
  if not (stack and stack.valid_for_read) then return nil end

  while stack.is_blueprint_book and stack.active_index do
    local inv = stack.get_inventory(defines.inventory.item_main)
    if inv then
      stack = inv[stack.active_index]
    end
  end

  return stack.is_upgrade_item and stack or nil
end -- get_cursor_upgrade_planner()

-- ─── Planner operations ───────────────────────────────────────────────────────

---Call fn(i, from, to) for every mapper slot where both sides are base mdrn-loader entities.
---@param planner LuaItemStack|LuaRecord
---@param fn fun(i: integer, from: UpgradeMapperSource, to: UpgradeMapperDestination)
local function for_base_loader_pairs(planner, fn)
  for i = 1, planner.mapper_count do
    local from = planner.get_mapper(i, "from")
    local to   = planner.get_mapper(i, "to")
    if from and from.name and to and to.name
    and from.type == "entity" and to.type == "entity"
    and is_base_mdrn_loader(from.name)
    and is_base_mdrn_loader(to.name) then
      fn(i, from, to)
    end
  end
end -- for_base_loader_pairs()

---Return true when the planner contains at least one base-loader entity upgrade pair.
---@param planner LuaItemStack|LuaRecord
---@return boolean
local function planner_has_loader_pair(planner)
  local found = false
  for_base_loader_pairs(planner, function() found = true end)
  return found
end -- planner_has_loader_pair()

---Add variant loader mappings to the upgrade planner on the player's cursor.
---@param player LuaPlayer
local function add_loader_variants(player)
  local planner = get_cursor_upgrade_planner(player)
  if not planner then return end

  local count = planner.mapper_count

  -- Collect base-loader entity pairs already in the planner, and all existing keys.
  ---@type {from: UpgradeMapperSource, to: UpgradeMapperDestination}[]
  local loader_pairs = {}
  local existing     = {}  -- key: "from_name\0to_name"

  for i = 1, count do
    local from = planner.get_mapper(i, "from")
    local to   = planner.get_mapper(i, "to")
    if from and from.name and to and to.name then
      existing[from.name .. "\0" .. to.name] = true
      if from.type == "entity" and to.type == "entity"
      and is_base_mdrn_loader(from.name)
      and is_base_mdrn_loader(to.name) then
        table.insert(loader_pairs, { from = from, to = to })
      end
    end
  end

  if #loader_pairs == 0 then return end

  local next_slot = count + 1
  for _, pair in ipairs(loader_pairs) do
    for _, suffix in ipairs(VARIANT_SUFFIXES) do
      local from_name = pair.from.name .. suffix
      local to_name   = pair.to.name   .. suffix
      local key       = from_name .. "\0" .. to_name
      if storage.variants[from_name]
      and storage.variants[to_name]
      and not existing[key] then
        planner.set_mapper(next_slot, "from", { type = "entity", name = from_name, quality = pair.from.quality, comparator = "=" })
        planner.set_mapper(next_slot, "to",   { type = "entity", name = to_name,   quality = pair.to.quality,  comparator = "=" })
        existing[key] = true
        next_slot     = next_slot + 1
      end
    end
  end
end -- add_loader_variants()

---@param player LuaPlayer
local function remove_loader_variants(player)
  local planner = get_cursor_upgrade_planner(player)
  if not planner then return end

  local count = planner.mapper_count
  if count == 0 then return end

  -- Collect base-tier upgrade pairs present in the planner.
  local base_pairs = {}
  for_base_loader_pairs(planner, function(_, from, to)
    base_pairs[from.name .. "\0" .. to.name] = true
  end)

  -- Nil out variant entries that meet all three conditions; leave slot gaps in place.
  for i = 1, count do
    local from = planner.get_mapper(i, "from")
    local to   = planner.get_mapper(i, "to")
    if from and from.name and to and to.name
    and from.type == "entity" and to.type == "entity"
    and is_variant_mdrn_loader(from.name) then
      local from_base = loader.variant_base(from.name)
      local to_base   = loader.variant_base(to.name)
      -- Both sides must carry the same variant suffix.
      local from_sfx  = from.name:sub(#from_base + 1)
      local to_sfx    = to.name:sub(#to_base + 1)
      -- A matching base-tier upgrade must exist in the planner.
      if from_sfx == to_sfx and base_pairs[from_base .. "\0" .. to_base] then
        planner.set_mapper(i, "from", nil)
        planner.set_mapper(i, "to",   nil)
      end
    end
  end
end -- remove_loader_variants()

-- ─── GUI event handlers (declared before create_toolbar uses them) ────────────

---@param e EventData.on_gui_click
local function on_add_clicked(e)
  local player = game.get_player(e.player_index)
  if player then add_loader_variants(player) end
end -- on_add_clicked()

---@param e EventData.on_gui_click
local function on_remove_clicked(e)
  local player = game.get_player(e.player_index)
  if player then remove_loader_variants(player) end
end -- on_remove_clicked()

-- ─── Toolbar GUI ──────────────────────────────────────────────────────────────

---@param player LuaPlayer
local function destroy_toolbar(player)
  local existing = player.gui.screen[TOOLBAR_NAME]
  if existing then existing.destroy() end
end -- destroy_toolbar()

---@param player LuaPlayer
local function create_toolbar(player)
  destroy_toolbar(player)
  -- Prefer the all-flags variant icon; fall back when WFS variants aren't built.
  local sprite = storage.variants["mdrn-loader-split-wfs-fill"]
    and "entity/mdrn-loader-split-wfs-fill"
    or  "entity/mdrn-loader-split-fill"
  local frame = player.gui.screen.add{
    type      = "frame",
    style     = "slot_window_frame",
    name      = TOOLBAR_NAME,
    direction = "horizontal",
  }
  frame.location = { x = 15, y = 400 }
  flib_gui.add(frame, {
    {
      type     = "frame",
      style    = "inside_deep_frame",
      children = {
        {
          type    = "sprite-button",
          name    = ADD_BUTTON_NAME,
          sprite  = sprite,
          tooltip = { "strings.mdrn-add-loader-variants-tooltip" },
          style   = "flib_tool_button_light_green",
          handler = { [defines.events.on_gui_click] = on_add_clicked },
        },
        {
          type    = "sprite-button",
          name    = REM_BUTTON_NAME,
          sprite  = sprite,
          tooltip = { "strings.mdrn-remove-loader-variants-tooltip" },
          style   = "flib_tool_button_dark_red",
          handler = { [defines.events.on_gui_click] = on_remove_clicked },
        },
      },
    },
  })
end -- create_toolbar()

-- ─── Cursor event handler ─────────────────────────────────────────────────────

---@param e EventData.on_player_cursor_stack_changed
local function on_cursor_stack_changed(e)
  local player = game.get_player(e.player_index)
  if not player then return end
  local planner = get_cursor_upgrade_planner(player)
  if planner and planner_has_loader_pair(planner) then
    create_toolbar(player)
  else
    destroy_toolbar(player)
  end
end -- on_cursor_stack_changed()

---Destroy stale toolbar frames from all players (run on init/config-change).
local function destroy_all_toolbars()
  for _, player in pairs(game.players) do
    destroy_toolbar(player)
  end
end -- destroy_all_toolbars()

-- ─── Module setup ─────────────────────────────────────────────────────────────

flib_gui.add_handlers{
  on_add_clicked    = on_add_clicked,
  on_remove_clicked = on_remove_clicked,
}

upgrade_planner.on_init = function()
  destroy_all_toolbars()
end -- upgrade_planner.on_init()

upgrade_planner.on_load = function() end -- upgrade_planner.on_load()

upgrade_planner.on_configuration_changed = function()
  destroy_all_toolbars()
end -- upgrade_planner.on_configuration_changed()

upgrade_planner.events = {
  [defines.events.on_player_cursor_stack_changed] = on_cursor_stack_changed,
}

return upgrade_planner
