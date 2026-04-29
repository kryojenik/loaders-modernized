local utils = require("__loaders-modernized__.scripts.utils")

---Make a loader subgroup
data:extend{
  {
      type = "item-subgroup",
      name = "belt-loader",
      group = "logistics",
      order = "b[belt-loader]"
  }
}

---Create the Item prototypes
---@param template LMLoaderTemplate Template for loader tier
local function update_or_create_item(template)
  ---@type data.ItemPrototype
  local item = data.raw["item"][template.name]
  if not item then
    item = {
      type = "item",
      stack_size = 50,

      name = template.name,
      place_result = template.name,

      icons = utils.create_icons(template.tint, template.dark_frame),
      group = "logistics",
      subgroup = "belt-loader",
      order = string.format("e[mdrn-loader]-%s[%s]", template.order, template.name),
    }
  end

  local ug_item = data.raw["item"][template.underground_name]
  if ug_item then
    item.color_hint = ug_item.color_hint
    item.inventory_move_sound = ug_item.inventory_move_sound
    item.pick_sound = ug_item.pick_sound
    item.drop_sound = ug_item.pick_sound

    -- space-age
    item.weight = ug_item.weight or (20*kg)
    item.default_import_location = ug_item.default_import_location or nil
  end

  item.order = template.order
    and string.format("e[mdrn-loader]-%s[%s]", template.order, template.name)
    or item.order
  item.group = template.group or item.group
  item.subgroup = template.subgroup or item.subgroup
  if template.tint then
    item.icons = utils.create_icons(template.tint, template.dark_frame)
  end


  data:extend{item}
end -- update_or_create_item()

return update_or_create_item
