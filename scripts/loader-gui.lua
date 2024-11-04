local flib_gui = require("__flib__.gui")

local gui = {}

local function on_split_lane_state_changed(e)
  local pd = storage.loader_modernized.players[e.player_index]

  if not pd.open_loader.entity or not pd.open_loader.entity.valid then
    pd.open_loader = nil
    return
  end

  local old = pd.open_loader.entity
  local proto = old.prototype
  if old.name == "entity-ghost" then
    proto = old.ghost_prototype
  end

  -- Save the ControlBehavior
  local cb = {}
  local old_cb = old.get_control_behavior()
  if old_cb then
    cb = {
      circuit_set_filters = old_cb.circuit_set_filters,
      circuit_read_transfers = old_cb.circuit_read_transfers,
      circuit_enable_disable = old_cb.circuit_enable_disable,
      circuit_condition = old_cb.circuit_condition,
    }
  end

  -- Save the wires
  local wires = {}
  for _,w in pairs(old.get_wire_connectors()) do
    if w.connection_count > 0 then
      wires[w.wire_connector_id] = (function()
        return w.connections
      end)()
    end
  end

  -- Save any filters
  local loader_filter_mode = old.loader_filter_mode
  local filters = {}
  for i=1, proto.filter_count do
    local filter = old.get_filter(i)
    if filter then
      filters[#filters+1] = filter
      filters[#filters].index = #filters
    end
  end


  local split = (string.match(proto.name, "%-split"))
  local base_name = string.match(proto.name, "^(.*%-?mdrn%-loader)")
  local new_name = split and base_name or base_name .. "-split"

  local new = {
    create_build_effect_smoke = false,
    name = split and base_name or base_name .. "-split",
    position = old.position,
    direction = old.direction,
    force = old.force,
    player = old.last_user,
    type = old.loader_type,
    filters = filters,
  }
  if old.name == "entity-ghost" then
    new.name = "entity-ghost"
    new.inner_name = new_name
  end

  local surface = old.surface
  old.destroy()
  local new_entity = surface.create_entity(new)
  new_entity.loader_filter_mode = loader_filter_mode
  if old_cb then
    local new_cb = new_entity.get_or_create_control_behavior()
    new_cb.circuit_set_filters = cb.circuit_set_filters
    new_cb.circuit_read_transfers = cb.circuit_read_transfers
    new_cb.circuit_enable_disable = cb.circuit_enable_disable
    new_cb.circuit_condition = cb.circuit_condition
    if wires then
      for wire_id, connections in pairs(wires) do
        local wire = new_entity.get_wire_connector(wire_id, true)
        for _, c in pairs(connections) do
          if c.target.owner.valid then
            wire.connect_to(c.target, true, c.origin)
          end
        end
      end
    end
  end
  game.get_player(e.player_index).opened = new_entity
end

gui.on_gui_opened = function(e)
  local entity = e.entity
  if not entity or not entity.valid then
    return
  end

  local name = entity.name ~= "entity-ghost" and entity.name or entity.ghost_name
  if not string.match(name, "mdrn%-loader") then
    return
  end

  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  if player.gui.relative.split_lane then
    player.gui.relative.split_lane.destroy()
  end

  if string.match(name, "^chute") then
    return
  end

  local pd = storage.loader_modernized.players[player.index]
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
    { type = "label", caption = {"strings.mdrn-use-split-lanes"}},
    {
      type = "checkbox",
      state = string.match(entity.name, "%-split$") and true or false,
      name = "cb_state",
      handler = {
        [defines.events.on_gui_checked_state_changed] = on_split_lane_state_changed
      }
    }
  })
end

flib_gui.add_handlers{
  on_split_lane_state_changed = on_split_lane_state_changed,
}

return gui