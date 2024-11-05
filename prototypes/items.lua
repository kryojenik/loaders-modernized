---Create the Item prototypes
---@param prefix string Loader tier prefix
---@param tint Color Color used for belt tier
local function create_item(prefix, tint)
  local base_underground_name = "underground-belt"
  local underground_name = prefix ~= "chute-" and (prefix .. base_underground_name) or base_underground_name
  local ug_item = data.raw["item"][underground_name]
  local item = {
    type = "item",
    name = prefix .. "mdrn-loader",
    icons = {
      {
        icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-base.png",
      },
      {
        icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-mask.png",
        tint = tint
      }
    },
    subgroup = "belt",
    colorblind_aid = ug_item.color_hint,
    order = string.gsub(ug_item.order, "^b%[underground%-belt%]", "e[mdrn-loader]"),
    inventory_move_sound = ug_item.inventory_move_sound,
    pick_sound = ug_item.pick_sound,
    drop_sound = ug_item.pick_sound,
    place_result = prefix .. "mdrn-loader",
    stack_size = 50,
    -- space-age
    weight = (ug_item.weight or (20*kg) ),
    default_import_location = (ug_item.default_import_location or nil)
  }
  data:extend{
    item
  }
end

return {
  create_item = create_item
}