local function create_item(prefix, base_underground_name, tint)
  local underground_name = prefix .. base_underground_name
  local ug_item = data.raw["item"][underground_name]
  local item = {
    type = "item",
    name = prefix .. "mdrn-loader",
    icons = {
      {
        icon = "__loaders-modernized__.graphics.item.mdrn-loader-icon-base.png",
      },
      {
        icon = "__loaders-modernized__.graphics.item.mdrn-loader-icon-mask.png",
        tint = tint
      }
    },
    subgroup = "belt",
    colorblind_aid = ug_item.colorblind_aid,
    order = string.gsub(ug_item.order, "^b%[underground%-belt%]", "e[mdrn-loader]"),
    inventory_move_sound = ug_item.inventory_move_sound,
    pick_sound = ug_item.pick_sound,
    drop_sound = ug_item.pick_sound,
    place_result = prefix .. "mdrn-loader",
    stack_size = 50,
    -- space-age
    weight = (ug_item.weight or (20*kg) ),
    default_import_location = (ug_item.default_import_locaton or nil)
  }
  data:extend{
    item
  }
end

return {
  create_item = create_item
}