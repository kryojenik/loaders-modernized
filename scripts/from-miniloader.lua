local flib_gui = require("__flib__.gui")
local table = require("__flib__.table")

local warning_notice =
[[*** BACKUP ***  BACKUP *** BACKUP ***

Migrating Miniloaders from the miniloader mod is experimental, but I think I have it mostly working well enough to serve your purposes.

Please make sure you have a backup of your game save before you save this migrated save.  There is no path back or undo!

If you notice loaders from a belt set that did not migrate, please let me know and I will try to incorporate them.

After your migration is complete, please disable the startup setting to migrate Miniloaders.

Game engine limitations:
- Any loader that had a blacklist filter will now be a whitelist filter.
- Any "input" loader will ignore filter that are set.

*Note: All Miniloader and Filter Miniloader items in inventories and Contianer are gone.  This is a one time loss - sorry.  Assemblers creating miniloaders will now be idle and need to manually be configured for a new recipe.

-Kryojenik

*** BACKUP *** BACKUP *** BACKUP ***]]

local not_migrated_notice =
[[The following loaders were not migrated.  If you save now and KEEP the Migrate Miniloaders setting enabled this list will be maintained.

The only way to remove these dummy / non-functional loader is via this window or disabling the Migrate Miniloader setting.

You can reopen this list with the command /mdrn-migrations.

Please report any belt packs that result in miniloaders not migrating and I may be able to add support.

-Kryojenik]]

local function replace_miniloader(ml)
  local name = string.gsub(ml.name, "miniloader", "mdrn")
  name = string.gsub(name, "filter%-", "")
  if not prototypes.entity[name] then
    return false
  end

  local old_ldr = ml.surface.find_entities_filtered{type = "loader-1x1", position = ml.position}[1]
  local inserters = ml.surface.find_entities_filtered{type = "inserter", position = ml.position}
  local filters = {}
  for i=1,inserters[1].prototype.filter_count do
    filters[i] = inserters[1].get_filter(i) or nil
    if filters[i] then
      filters[i].index = i
    end
  end

  local new_ldr = {
    name = name,
    position= ml.position,
    direction = old_ldr.direction,
    force = old_ldr.force,
    player = inserters[1].last_user,
    type = old_ldr.loader_type,
    create_build_effect_smoke = false,
    filters = filters
  }

  -- Save the control behavior details
  local old_cb = inserters[1].get_control_behavior()
  local circuit_set_filters = old_cb.circuit_set_filters
  local circuit_read_transfers = old_cb.circuit_read_hand_contents and (old_cb.circuit_hand_read_mode == defines.control_behavior.inserter.hand_read_mode.pulse)
  local circuit_enable_disable = old_cb.circuit_enable_disable
  local circuit_condition = old_cb.circuit_condition

  -- Save details about connected wires
  local wires = {}
  for _,w in pairs(inserters[1].get_wire_connectors()) do
    if w.connection_count > 0 then
      wires[w.wire_connector_id] = (function()
        local targets = {}
        for _,c in pairs(w.connections) do
          targets[#targets+1] = c.target.owner
        end
        return targets
      end)()
    end
  end

  -- Destroy / remve old combo-entities
  old_ldr.destroy()
  for _,i in pairs(inserters) do
    i.destroy()
  end

  new_ldr = ml.surface.create_entity(new_ldr)
  local new_cb = new_ldr.get_or_create_control_behavior()
  new_cb.circuit_set_filters = circuit_set_filters
  new_cb.circuit_read_transfers = circuit_read_transfers
  new_cb.circuit_enable_disable = circuit_enable_disable
  new_cb.circuit_condition = circuit_condition
  if wires then
    for wire_id, targets in pairs(wires) do
      local wire = new_ldr.get_wire_connector(wire_id, true)
      for _,t in pairs(targets) do
        if t.valid then
          wire.connect_to(t.get_wire_connector(wire_id))
        end
      end
    end
  end
  return true
end

local function on_close_window_clicked(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  local window = player.gui.screen.mdrn_loader_list_window
  if not window then
    return
  end

  window.destroy()
end

local function on_ping_miniloader_clicked(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  player.print(e.element.name)
end

local function remove_miniloader(i_ml)
  local ml = storage.miniloaders_to_migrate[i_ml]
  if not ml then
    return
  end

  local entities = ml.surface.find_entities_filtered{position = ml.position}
  for _, ldr in pairs(entities) do
    ldr.destroy()
  end

  storage.miniloaders_to_migrate[i_ml] = nil
end

local function on_remove_clicked(e)
  local i_ml = tonumber(e.element.name)
  if not i_ml then
    return
  end

  remove_miniloader(i_ml)
  e.element.enabled = false
end

local function on_remove_all_clicked(e)
  for k,_ in pairs(storage.miniloaders_to_migrate) do
    remove_miniloader(k)
  end

  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  storage.miniloaders_to_migrate = nil
  on_close_window_clicked(e)
end

local function unmigrated_loaders()
  if not next(storage.miniloaders_to_migrate) then
    return
  end

  local elems = {}
  for k, v in pairs(storage.miniloaders_to_migrate) do
    local x,y = string.match(v.gps_tag, "^%[gps=(%-?[%.%d]+),(%-?[%.%d]+)")
    elems = table.array_merge{elems, {
      { type = "label", caption = v.name },
      { type = "label", caption = "Locaton: " .. x .. ", " .. y .. ", " .. v.surface.name },
      {
        type = "button",
        name = k,
        caption = "remove",
        style = "red_button",
        style_mods = { height = 24 },
        handler = { [defines.events.on_gui_click] = on_remove_clicked },
      },
      {
        type = "button",
        name = v.gps_tag,
        caption = "ping",
        style_mods = { height = 24 },
        handler = { [defines.events.on_gui_click] = on_ping_miniloader_clicked },
      },
    }}
  end
  return elems
end

local function create_list(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  if not storage.miniloaders_to_migrate then
    player.print("No more miniloaders left to migrate!")
    return
  end

  if player.gui.screen.mdrn_loader_list_window then
    return
  end

  flib_gui.add(player.gui.screen, {
    type = "frame",
    name = "mdrn_loader_list_window",
    direction = "vertical",
    caption = "Loaders Modernized - Miniloaders not migrated",
    elem_mods = { auto_center = true },
    {
      type = "frame",
      style = "inside_shallow_frame_with_padding",
      { type = "label", style_mods = { single_line = false }, caption = not_migrated_notice },
    },
    {
      type = "scroll-pane",
      {
        type = "frame",
        style = "inside_shallow_frame_with_padding",
        {
          type = "table",
          name = "mdrn_loader_table",
          column_count = 4,
          children = unmigrated_loaders()
        },
      },
      {
        type = "flow",
        style = "dialog_buttons_horizontal_flow",
        drag_target = "mdrn_loader_list_window",
        {
          type = "button",
          style = "red_button",
          caption = "Remove all!",
          handler = {
            [defines.events.on_gui_click] = on_remove_all_clicked
          },
        },
        { type = "empty-widget", style = "flib_dialog_footer_drag_handle", ignored_by_interaction = true },
        {
          type = "button",
          style = "confirm_button",
          caption = "Close",
          handler = {
            [defines.events.on_gui_click] = on_close_window_clicked
          },
        }
      }
    }
  })
end

local function replace_miniloaders(e)
  local miniloaders = storage.miniloaders_to_migrate
  for i_ml, ml in pairs(miniloaders) do
    if replace_miniloader(ml) then
      storage.miniloaders_to_migrate[i_ml] = nil
    end
  end

  if not next(storage.miniloaders_to_migrate) then
    storage.miniloaders_to_migrate = nil
  end

  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  local window = player.gui.screen.mdrn_loader_warning_window
  if not window then
    return
  end

  window.destroy()
  create_list(e)
end

local function create_notification(player)
  if player.gui.screen.mdrn_loader_warning_window then
    return
  end

  flib_gui.add(player.gui.screen, {
    type = "frame",
    name = "mdrn_loader_warning_window",
    style_mods = { width = 500 },
    direction = "vertical",
    caption = "Loaders Modernized",
    elem_mods = { auto_center = true },
    {
      type = "frame",
      style = "inside_shallow_frame_with_padding",
      { type = "label", style_mods = { single_line = false }, caption = warning_notice },
    },
    {
      type = "flow",
      style = "dialog_buttons_horizontal_flow",
      drag_target = "mdrn_loader_warning_window",
      { type = "empty-widget", style = "flib_dialog_footer_drag_handle", ignored_by_interaction = true },
      {
        type = "button",
        style = "confirm_button",
        caption = "Migrate!",
        handler = {
          [defines.events.on_gui_click] = replace_miniloaders
        },
      }
    }
  })
end

flib_gui.add_handlers{
  replace_miniloaders,
  on_ping_miniloader_clicked,
  on_remove_clicked,
  on_close_window_clicked,
  on_remove_all_clicked,
}

local function find_and_disable_all_miniloaders()
  if storage.miniloaders_to_migrate then
    return
  end

  local miniloader_parts = {}
  for _,v in pairs(prototypes.entity) do
    if string.find(v.name, ".*miniloader.*") then
      miniloader_parts[#miniloader_parts+1] = v.name
    end
  end

  local to_migrate = {}
  for _, surface in pairs(game.surfaces) do
    local miniloaders = surface.find_entities_filtered{type = {"loader-1x1", "inserter"}, name = miniloader_parts}
    for _, m in pairs(miniloaders) do
      m.active = false
      m.operable = false
      if m.type == "loader-1x1" then
        to_migrate[m.unit_number] = {
          name = m.name,
          surface = m.surface,
          position = m.position,
          gps_tag = m.gps_tag
        }
      end
    end
  end

  storage.miniloaders_to_migrate = to_migrate
end

local function migrate()
  find_and_disable_all_miniloaders()
  for _, player in pairs(game.players) do
    create_notification(player)
  end
end

local from_miniloader = {}
from_miniloader.on_configuration_changed = function(e)
  migrate()
end

commands.add_command("mdrn-migrations", nil, function(e)
  create_list(e)
end)

return from_miniloader