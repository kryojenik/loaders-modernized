local loader = require("__loaders-modernized__.scripts.loaders-modernized")
local flib_gui = require("__flib__.gui")

---Handle on_split_lane_state_changed.
---@param e EventData.on_gui_checked_state_changed
local function on_split_lane_state_changed(e)
  local pd = storage.players[e.player_index]

  if not pd.open_loader.entity or not pd.open_loader.entity.valid then
    pd.open_loader = nil
    return
  end

  local new = loader.swap_split(pd.open_loader.entity)
  game.get_player(e.player_index).opened = new
end

---Create and display a relative GUI attached to the in-game Loader UI
---@param e EventData.on_gui_opened
local function on_gui_opened(e)
  local entity = e.entity
  if not entity or not entity.valid then
    return
  end

  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  if player.gui.relative.split_lane then
    player.gui.relative.split_lane.destroy()
  end

  local name = entity.name ~= "entity-ghost" and entity.name or entity.ghost_name
  if not string.match(name, "mdrn%-loader") then
    return
  end

  if string.match(name, "^chute") then
    return
  end

  local pd = storage.players[player.index]
  pd.open_loader = {}
  pd.open_loader.entity = entity
  pd.open_loader.gui = flib_gui.add(player.gui.relative, {
    type = "frame",
    name = "split_lane",
    direction = "horizontal",
    anchor = {
      gui = defines.relative_gui_type.loader_gui,
      position = defines.relative_gui_position.bottom,
    },
    {
      type = "checkbox",
      caption = {"strings.mdrn-use-split-lanes"},
      state = string.match(name, "%-split$") and true or false,
      name = "cb_state",
      handler = {
        [defines.events.on_gui_checked_state_changed] = on_split_lane_state_changed
      }
    }
  })
end

-- GUI handlers
flib_gui.add_handlers{
  on_split_lane_state_changed = on_split_lane_state_changed,
}

local gui = {}

gui.events = {
  [defines.events.on_gui_opened] = on_gui_opened,
}

return gui