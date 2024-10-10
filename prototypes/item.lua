--local flib = require("__flib__/data-util")

-- local item = flib.copy_prototype(data.raw["item"]["underground-belt"], "miniloader")

local function create_miniloader_item(prefix, base_underground_name, tint)
  local underground_name = prefix .. base_underground_name
  local ug_item = data.raw["item"][underground_name]
  local item = {
    type = "item",
    name = prefix .. "miniloader",
    icons = {
      {
        icon = "__miniloader_modernized__/graphics/item/icon-base.png",
      },
      {
        icon = "__miniloader_modernized__/graphics/item/icon-mask.png",
        tint = tint
      }
    },
    subgroup = "belt",
    colorblind_aid = ug_item.colorblind_aid,
    order = string.gsub(ug_item.order, "^b%[underground%-belt%]", "e[miniloader]"),
    inventory_move_sound = ug_item.inventory_move_sound,
    pick_sound = ug_item.pick_sound,
    drop_sound = ug_item.pick_sound,
    place_result = prefix .. "miniloader",
    stack_size = 50
}

  data:extend{
    item
  }
end

return {
  create_miniloader_item = create_miniloader_item
}