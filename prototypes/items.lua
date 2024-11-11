---Create the Item prototypes
---@param tier string Loader tier prefix
---@param t LMLoaderTemplate Template for loader tier
local function create_item(tier, t)
  local name = t.name or tier .. "mdrn-loader"
  local underground_name = t.underground_name or tier .. "underground-belt"
  local ug_item = data.raw["item"][underground_name]

  ---@type data.ItemPrototype
  local item = {
    type = "item",
    name = name,
    icons = {
      {
        icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-base.png",
      },
      {
        icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-mask.png",
        tint = t.tint
      }
    },
    subgroup = "belt",
    colorblind_aid = ug_item.color_hint,
    order = string.gsub(ug_item.order, "^b%[underground%-belt%]", "e[mdrn-loader]"),
    inventory_move_sound = ug_item.inventory_move_sound,
    pick_sound = ug_item.pick_sound,
    drop_sound = ug_item.pick_sound,
    place_result = name,
    stack_size = 50,
    -- space-age
    weight = ug_item.weight or (20*kg),
    default_import_location = (ug_item.default_import_location or nil)
  }

  local setting_use_aai_graphics = settings.startup["mdrn-use-aai-graphics"]
  if setting_use_aai_graphics and setting_use_aai_graphics.value then
    item.icons = {
      {
        icon = "__aai-loaders__/graphics/icons/loader.png",
      },
      {
        icon = "__aai-loaders__/graphics/icons/loader_mask.png",
        tint = t.tint
      }
    }
  end

  data:extend{
    item
  }
end

return {
  create_item = create_item
}