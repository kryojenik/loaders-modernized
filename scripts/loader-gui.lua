local loader   = require("scripts.loaders-modernized")
local flib_gui = require("__flib__.gui")
local C        = require("__loaders-modernized__.constants")

-- ─── Checkbox handlers ────────────────────────────────────────────────────────

---Shared logic for any variant checkbox change.
---@param e EventData.on_gui_checked_state_changed
---@param flag_key "split"|"wfs"|"fill"
local function on_checkbox_changed(e, flag_key)
  local pd = storage.players[e.player_index]
  if not pd.open_loader then return end
  local entity = pd.open_loader.entity
  if not entity or not entity.valid then
    pd.open_loader = nil
    return
  end
  local flags = loader.flags_from_entity(entity)
  flags[flag_key] = e.element.state
  local new = loader.swap_variant(entity, flags, e.player_index)
  game.get_player(e.player_index).opened = new
end -- on_checkbox_changed()

---@param e EventData.on_gui_checked_state_changed
local function on_split_lane_state_changed(e)
  on_checkbox_changed(e, "split")
end -- on_split_lane_state_changed()

---@param e EventData.on_gui_checked_state_changed
local function on_wfs_state_changed(e)
  on_checkbox_changed(e, "wfs")
end -- on_wfs_state_changed()

---@param e EventData.on_gui_checked_state_changed
local function on_fill_state_changed(e)
  on_checkbox_changed(e, "fill")
end -- on_fill_state_changed()

-- ─── GUI open/close ───────────────────────────────────────────────────────────

---Create and display a relative GUI attached to the in-game Loader UI.
---@param e EventData.on_gui_opened
local function on_gui_opened(e)
  local entity = e.entity
  if not entity or not entity.valid then return end

  local player = game.get_player(e.player_index)
  if not player then return end

  if player.gui.relative.split_lane then
    player.gui.relative.split_lane.destroy()
  end

  local name = entity.name ~= "entity-ghost" and entity.name or entity.ghost_name
  if not string.match(name, C.LOADER_PATTERN) then return end

  local base      = loader.variant_base(name)
  local has_split = storage.variants[base .. C.SPLIT_SUFFIX] ~= nil
  local has_wfs   = storage.variants[base .. C.WFS_SUFFIX]   ~= nil
  local has_fill  = storage.variants[base .. C.FILL_SUFFIX]  ~= nil
  if not has_split and not has_wfs and not has_fill then return end

  local flags = loader.flags_from_entity(entity)

  -- Build the checkbox list dynamically.
  local children = {}
  if has_split then
    children[#children + 1] = {
      type    = "checkbox",
      caption = { "strings.mdrn-use-split-lanes" },
      state   = flags.split,
      name    = "cb_split",
      handler = {
        [defines.events.on_gui_checked_state_changed] = on_split_lane_state_changed,
      },
    }
  end
  if has_wfs then
    children[#children + 1] = {
      type    = "checkbox",
      caption = { "strings.mdrn-use-wfs" },
      state   = flags.wfs,
      name    = "cb_wfs",
      handler = {
        [defines.events.on_gui_checked_state_changed] = on_wfs_state_changed,
      },
    }
  end
  if has_fill then
    children[#children + 1] = {
      type    = "checkbox",
      caption = { "strings.mdrn-use-fill" },
      state   = flags.fill,
      name    = "cb_fill",
      handler = {
        [defines.events.on_gui_checked_state_changed] = on_fill_state_changed,
      },
    }
  end

  ---@type LMPlayerData
  local pd = storage.players[player.index]
  pd.open_loader = {
    entity = entity,
    gui    = flib_gui.add(player.gui.relative, {
      type      = "frame",
      name      = "split_lane",
      direction = "vertical",
      anchor    = {
        gui      = defines.relative_gui_type.loader_gui,
        position = defines.relative_gui_position.bottom,
      },
      table.unpack(children),
    }),
  }
end -- on_gui_opened()

-- ─── Module setup ─────────────────────────────────────────────────────────────

flib_gui.add_handlers{
  on_split_lane_state_changed = on_split_lane_state_changed,
  on_wfs_state_changed        = on_wfs_state_changed,
  on_fill_state_changed       = on_fill_state_changed,
}

local gui = {}

gui.events = {
  [defines.events.on_gui_opened] = on_gui_opened,
}

return gui
