local flib_gui = require("__flib__.gui")
local table = require("__flib__.table")

-- Get out of here as quickly as possible if we're not trying to migrate from Miniloaders.
if not settings.startup["mdrn-migrate-from-miniloaders"].value then
  return {}
end

local warning_notice =
[[*** BACKUP ***  BACKUP *** BACKUP ***

Migrating Miniloaders from the miniloader mod is experimental, but I think I have it mostly working well enough to serve your purposes.

Please make sure you have a backup of your game save before you save this migrated save.  There is no path back or undo!

If you notice loaders from a belt set that did not migrate, please let me know and I will try to incorporate them.

After your migration is complete, please disable the startup setting to migrate Miniloaders.

Game engine limitations:
- Any loader that had a blacklist filter will now be a whitelist filter.
- Any "input" loader will ignore filter that are set.

*Note: All Miniloader and Filter Miniloader items in inventories and Container are gone.  This is a one time loss - sorry.  Assemblers creating miniloaders will now be idle and need to manually be configured for a new recipe.

-Kryojenik

*** BACKUP *** BACKUP *** BACKUP ***]]

local not_migrated_notice =
[[The following loaders were not migrated.  If you save now and KEEP the Migrate Miniloaders setting enabled this list will be maintained.

The only way to remove these dummy / non-functional loader is via this window or disabling the Migrate Miniloader setting.

You can reopen this list with the command /mdrn-migrations.

Please report any belt packs that result in miniloaders not migrating and I may be able to add support.

-Kryojenik]]

local filter_notice =
[[The following loaders either had a filter set as an "input" (filling container) loader or they had a filter set as a blacklist filtered.  Both of these are not allowed due to game engine limitations.  These filters have been removed.

I am currently working on enhancing the migration to migrate blacklists and split lanes.  This will take a little more time.

You can return to this list with the command /mdrn-migrations.]]

-- Forward declaration
local create_filter_list

---Replace the Miniloader with a Loader modernized
---@param old_ldr LuaEntity
---@return boolean
local function replace_miniloader(old_ldr)
  local name = string.gsub(old_ldr.name, "miniloader", "mdrn")
  name = string.gsub(name, "filter%-", "")
  if not prototypes.entity[name] then
    return false
  end

  ---@type LuaEntity[]
  local inserters = old_ldr.surface.find_entities_filtered{type = "inserter", position = old_ldr.position}
  local blacklist = (inserters[1].inserter_filter_mode == "blacklist")
  local filters = {}

  for i=1,inserters[1].prototype.filter_count do
    filters[i] = inserters[1].get_filter(i) or nil
    if filters[i] then
      filters[i].index = i
    end
  end

  local new_ldr_proto = {
    name = name,
    position= old_ldr.position,
    direction = old_ldr.direction,
    force = old_ldr.force,
    player = inserters[1].last_user,
    type = old_ldr.loader_type,
    create_build_effect_smoke = false,
  }
  if not blacklist and old_ldr.loader_type == "output" then
    new_ldr_proto.filters = filters
  end

  -- Save the control behavior details
  local old_cb = inserters[1].get_control_behavior() --[[@as LuaInserterControlBehavior]]
  local circuit_set_filters
  local circuit_read_transfers
  local circuit_enable_disable
  local circuit_condition
  if old_cb then
    circuit_set_filters = old_cb.circuit_set_filters and (old_ldr.type == "output")
    circuit_read_transfers = old_cb.circuit_read_hand_contents and (old_cb.circuit_hand_read_mode == defines.control_behavior.inserter.hand_read_mode.pulse)
    circuit_enable_disable = old_cb.circuit_enable_disable
    circuit_condition = old_cb.circuit_condition
  end

  -- Save details about connected wires
  local wires = {}
  for _,w in pairs(inserters[1].get_wire_connectors(false)) do
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

  -- Destroy / remove old combo-entities
  local surface = old_ldr.surface
  old_ldr.destroy()
  for _,i in pairs(inserters) do
    i.destroy()
  end

  new_ldr = surface.create_entity(new_ldr_proto)
  if blacklist and new_ldr.loader_type == "output" then
    storage.no_blacklist[new_ldr.unit_number] = new_ldr
  end

  if new_ldr.loader_type == "input" and next(filters) then
    storage.no_input_filter[new_ldr.unit_number] = new_ldr
  end

  if old_cb then
    local new_cb = new_ldr.get_or_create_control_behavior() --[[@as LuaLoaderControlBehavior]]
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
  end
  return true
end

---Handle on_next_clicked
---@param e EventData.on_gui_click
local function on_next_clicked(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  local window = player.gui.screen.mdrn_loader_list_window
  if not window then
    return
  end

  window.destroy()
  create_filter_list(e)
end

---Handle on_closed_clicked
---@param e EventData.on_gui_click
local function on_closed_clicked(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  local window = player.gui.screen.mdrn_loader_filter_window
  if not window then
    return
  end

  window.destroy()
end

---Print a ping to the loader in the players chat
---@param e EventData.on_gui_click
local function on_ping_miniloader_clicked(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  player.print(e.element.name)
end

---Remove an un-migrated miniloader from the game.
---@param i_ml integer
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

---Remove loader from the blacklist filter list
---@param i_ml integer
local function clear_blacklist(i_ml)
  storage.no_blacklist[i_ml] = nil
end

---Handle on_clear_blacklist_clicked
---@param e EventData.on_gui_click
local function on_clear_blacklist_clicked(e)
  local i_ml = tonumber(e.element.name)
  if not i_ml then
    return
  end
  
  clear_blacklist(i_ml)
  e.element.enabled = false
end

---Remove a loader from the input loader with filter list
---@param i_ml integer
local function clear_input(i_ml)
  storage.no_input_filter[i_ml] = nil
end

---Handle on_clear_input_clicked
---@param e EventData.on_gui_click
local function on_clear_input_clicked(e)
  local i_ml = tonumber(e.element.name)
  if not i_ml then
    return
  end

  clear_input(i_ml)
  e.element.enabled = false
end

---Handle on_clear_all_clicked
---@param e EventData.on_gui_click
local function on_clear_all_clicked(e)
  if storage.no_input_filter and next(storage.no_input_filter) then
    for k,_ in pairs(storage.no_input_filter) do
      clear_input(k)
    end
  end

  if storage.no_blacklist and next(storage.no_blacklist) then
    for k,_ in pairs(storage.no_blacklist) do
      clear_blacklist(k)
    end
  end

  on_closed_clicked(e)
end

---Handle on_remove_clicked
---@param e EventData.on_gui_click
local function on_remove_clicked(e)
  local i_ml = tonumber(e.element.name)
  if not i_ml then
    return
  end

  remove_miniloader(i_ml)
  e.element.enabled = false
end

---Handle on_remove_all_clicked
---@param e EventData.on_gui_click
local function on_remove_all_clicked(e)
  if storage.miniloaders_to_migrate and next(storage.miniloaders_to_migrate) then
    for k,_ in pairs(storage.miniloaders_to_migrate) do
      remove_miniloader(k)
    end

    local player = game.get_player(e.player_index)
    if not player then
      return
    end

    storage.miniloaders_to_migrate = nil
  end
  on_next_clicked(e)
end

---Generate the content list of loaders that were input loaders with filters
---@return flib.GuiElemDef
local function input_loaders()
  if not storage.no_input_filter or not next(storage.no_input_filter) then
    return {{type = "label", caption = "No input loader filter issues found. "}}
  end

  local elems = {}
  for k, v in pairs(storage.no_input_filter) do
    elems = table.array_merge{elems, {
      { type = "label", caption = v.name },
      { type = "label", caption = "Location: " .. v.position.x .. ", " .. v.position.y .. ", " .. v.surface.name },
      {
        type = "button",
        name = k,
        caption = "Clear",
        tooltip = "Clear from tracking list.",
        style = "red_button",
        style_mods = { height = 24 },
        handler = { [defines.events.on_gui_click] = on_clear_input_clicked },
      },
      {
        type = "button",
        name = v.gps_tag,
        caption = "Ping",
        tooltip = "Print a gps link in chat.",
        style_mods = { height = 24 },
        handler = { [defines.events.on_gui_click] = on_ping_miniloader_clicked },
      },
    }}
  end
  return elems
end

---Generate the content list of loaders with blacklist filters
---@return flib.GuiElemDef
local function loaders_with_blacklist_filter()
  if not storage.no_blacklist or not next(storage.no_blacklist) then
    return {{type = "label", caption = "No blacklist filter issues found. "}}
  end

  local elems = {}
  for k, v in pairs(storage.no_blacklist) do
    elems = table.array_merge{elems, {
      { type = "label", caption = v.name },
      { type = "label", caption = "Location: " .. v.position.x .. ", " .. v.position.y .. ", " .. v.surface.name },
      {
        type = "button",
        name = k,
        caption = "Clear",
        tooltip = "Clear from tracking list.",
        style = "red_button",
        style_mods = { height = 24 },
        handler = { [defines.events.on_gui_click] = on_clear_blacklist_clicked },
      },
      {
        type = "button",
        name = v.gps_tag,
        caption = "Ping",
        tooltip = "Print a gps link in chat.",
        style_mods = { height = 24 },
        handler = { [defines.events.on_gui_click] = on_ping_miniloader_clicked },
      },
    }}
  end
  return elems
end

---Generate the content for the list of loaders that were not migrated
---@return flib.GuiElemDef[]
local function non_migrated_loaders()
  if not storage.miniloaders_to_migrate or not next(storage.miniloaders_to_migrate) then
    return {{ type = "label", caption = "No more Miniloaders left to migrate!" }}
  end

  local elems = {}
  for k, v in pairs(storage.miniloaders_to_migrate) do
    elems = table.array_merge{elems, {
      { type = "label", caption = v.name },
      { type = "label", caption = "Location: " .. v.position.x .. ", " .. v.position.y .. ", " .. v.surface.name },
      {
        type = "button",
        name = k,
        caption = "Remove",
        tooltip = "Remove entity from surface.",
        style = "red_button",
        style_mods = { height = 24 },
        handler = { [defines.events.on_gui_click] = on_remove_clicked },
      },
      {
        type = "button",
        name = v.gps_tag,
        caption = "Ping",
        tooltip = "Print a gps link in chat.",
        style_mods = { height = 24 },
        handler = { [defines.events.on_gui_click] = on_ping_miniloader_clicked },
      },
    }}
  end
  return elems
end

---Display the list of Miniloaders that had filters that could not be processed
---Filters configured as blacklist filters
---Filters that were configured on loaders of type input
---@param e EventData.on_gui_click
create_filter_list = function(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end

  if player.gui.screen.mdrn_loader_filter_window then
    return
  end

  flib_gui.add(player.gui.screen, {
    type = "frame",
    name = "mdrn_loader_filter_window",
    direction = "vertical",
    caption = "Loaders Modernized - Filters altered",
    elem_mods = { auto_center = true },
    {
      type = "frame",
      style = "inside_shallow_frame_with_padding",
      { type = "label", style_mods = { single_line = false }, caption = filter_notice },
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
          children = input_loaders()
        },
      },
      {
        type = "frame",
        style = "inside_shallow_frame_with_padding",
        {
          type = "table",
          name = "mdrn_loader_table",
          column_count = 4,
          children = loaders_with_blacklist_filter()
        },
      },
      {
        type = "flow",
        style = "dialog_buttons_horizontal_flow",
        drag_target = "mdrn_loader_filter_window",
        {
          type = "button",
          style = "red_button",
          caption = "Clear all!",
          tooltip = "Clear all loaders from tracking lists.",
          handler = {
            [defines.events.on_gui_click] = on_clear_all_clicked
          },
        },
        { type = "empty-widget", style = "flib_dialog_footer_drag_handle", ignored_by_interaction = true },
        {
          type = "button",
          style = "confirm_button",
          caption = "Close",
          handler = {
            [defines.events.on_gui_click] = on_closed_clicked
          },
        }
      }
    }
  })
end

---Display a list of Miniloaders that were not migrated
---@param pi integer
local function create_not_migrated_list(pi)
  local player = game.get_player(pi)
  if not player then
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
          children = non_migrated_loaders()
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
          caption = "Next",
          handler = {
            [defines.events.on_gui_click] = on_next_clicked
          },
        }
      }
    }
  })
end

---Replace found Miniloaders
---@param e EventData.on_gui_click
local function replace_miniloaders(e)
  storage.no_blacklist = storage.no_blacklist or {}
  storage.no_input_filter = storage.no_input_filter or {}
  for i_ml, ml in pairs(storage.miniloaders_to_migrate) do
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

  for _, p in pairs(game.players) do
    local window = p.gui.screen.mdrn_loader_warning_window
    if window then
      window.destroy()
    end
  end

  create_not_migrated_list(e.player_index)
end

---Display migration notification
---@param player LuaPlayer
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
        tooltip = "Migrate Miniloaders that we can migrate, GO! GO! GO!",
        handler = {
          [defines.events.on_gui_click] = replace_miniloaders
        },
      }
    }
  })
end

---Gui handlers
flib_gui.add_handlers{
  replace_miniloaders = replace_miniloaders,
  on_ping_miniloaders_clicked = on_ping_miniloader_clicked,
  on_remove_clicked = on_remove_clicked,
  on_next_clicked = on_next_clicked,
  on_remove_all_clicked = on_remove_all_clicked,
  on_clear_all_clicked = on_clear_all_clicked,
  on_clear_input_clicked = on_clear_input_clicked,
  on_clear_blacklist_clicked = on_clear_blacklist_clicked,
  on_closed_clicked = on_closed_clicked,
}

---Find all miniloaders and disable their operation
local function find_and_disable_all_miniloaders()
  if storage.miniloaders_to_migrate then
    return
  end

  ---@type table<integer, string>
  local miniloader_parts = {}
  for _,v in pairs(prototypes.entity) do
    if string.find(v.name, ".*miniloader.*") then
      miniloader_parts[#miniloader_parts+1] = v.name
    end
  end


  ---@type table<integer, LuaEntity>
  local to_migrate = {}
  for _, surface in pairs(game.surfaces) do
    local miniloaders = surface.find_entities_filtered{type = {"loader-1x1", "inserter"}, name = miniloader_parts}
    for _, m in pairs(miniloaders) do
      m.active = false
      m.operable = false
      if m.type == "loader-1x1" then
        to_migrate[m.unit_number] = m
      end
    end
  end

  storage.miniloaders_to_migrate = to_migrate
end

---Entry point to start the migration process
local function migrate()
  find_and_disable_all_miniloaders()
  for _, player in pairs(game.players) do
    create_notification(player)
  end
end

local from_miniloader = {}
---Process on_configuration_changed events
from_miniloader.on_configuration_changed = function()
  migrate()
end

---Console command to reopen migration window
---@param cd CustomCommandData
commands.add_command("mdrn-migrations", nil, function(cd)
  create_not_migrated_list(cd.player_index)
end)

return from_miniloader