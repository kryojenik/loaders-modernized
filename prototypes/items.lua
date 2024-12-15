local startup_settings = settings.startup

data:extend{
  {
      type = "item-subgroup",
      name = "belt-loader",
      group = "logistics",
      order = "b-loader"
  }
}

local function create_icons(tint)
  if startup_settings["mdrn-use-aai-graphics"] and startup_settings["mdrn-use-aai-graphics"].value then
    return {
      { icon = "__aai-loaders__/graphics/icons/loader.png" },
      { icon = "__aai-loaders__/graphics/icons/loader_mask.png", tint = tint }
    }
  end

  return {
    { icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-base.png" },
    { icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-mask.png", tint = tint }
  }
end

---Create the Item prototypes
---@param tier string Loader tier prefix
---@param template LMLoaderTemplate Template for loader tier
---@param blacklist table
local function create_item(tier, template, blacklist)
  local name = template.name or tier .. "mdrn-loader"
  local underground_name = template.underground_name or tier .. "underground-belt"
  local ug_item = data.raw["item"][underground_name]

  local items = {}
  ---@type data.ItemPrototype
  local item = {
    type = "item",
    name = name,
    icons = create_icons(template.tint),
    group = template.group or "logistics",
    subgroup = template.subgroup or "belt-loader",
    colorblind_aid = ug_item.color_hint,
    order = template.order or string.gsub(ug_item.order, "^b%[underground%-belt%]", "e[mdrn-loader]"),
    inventory_move_sound = ug_item.inventory_move_sound,
    pick_sound = ug_item.pick_sound,
    drop_sound = ug_item.pick_sound,
    place_result = name,
    stack_size = 50,
    -- space-age
    weight = ug_item.weight or (20*kg),
    default_import_location = (ug_item.default_import_location or nil)
  }

  items[#items+1] = item
  -- If stack loaders are separate entities we need a separate item for them
  --[[
  if startup_settings["mdrn-enable-stacking"].value == "turbo-and-above"
  and not blacklist.below_turbo[tier] then
    local stack_name = string.gsub(name, "mdrn%-loader", "stack-mdrn-loader")
    local stack_item = table.deepcopy(item)
    stack_item.name = stack_name
    stack_item.place_result = stack_name
    items[#items+1] = stack_item
    if not startup_settings["mdrn-use-stack-sticker"].value then
      stack_item.icons = create_icons(template.stack_tint)
    end
  end
  ]]

  return items
end

return {
  create_item = create_item
}