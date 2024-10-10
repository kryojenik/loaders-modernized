local function create_miniloader_entity(prefix, base_underground_name, tint)
  local name = prefix .. "miniloader"
  local underground_name = prefix .. base_underground_name
  local ug_entity = data.raw["underground-belt"][underground_name]

  -- local entity = util.table.deepcopy(data.raw["loader-1x1"]["loader-1x1"])

  local entity = {
    type = "loader-1x1",
    name = name,
    icons = {
      { icon = "__miniloader_modernized__/graphics/item/icon-base.png" },
      { icon = "__miniloader_modernized__/graphics/item/icon-mask.png", tint = tint }
    },
    flags = {"placeable-neutral", "player-creation"},
    minable = { mining_time = 0.1, result = "miniloader" },
    max_health = 170,
    filter_count = 5,
    open_sound = { filename = "__base__/sound/open-close/inserter-open.ogg" },
    close_sound = { filename = "__base__/sound/open-close/inserter-close.ogg" },
    resistances = ug_entity.resistances,
    collision_box = ug_entity.collision_box,
    selection_box = ug_entity.selection_box,
    animation_speed_coefficient = 32,
    belt_animation_set = ug_entity.belt_animation_set,
    fast_replaceable_group = "transport-belt",
    container_distance = 1;
    speed = ug_entity.speed,
    structure = {
      direction_in = {
        sheets = {
          {
            filename = "__miniloader_modernized__/graphics/entity/miniloader-structure-base.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
          },
          {
            filename = "__miniloader_modernized__/graphics/entity/miniloader-structure-mask.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            tint = tint
          },
          {
            filename = "__miniloader_modernized__/graphics/entity/miniloader-structure-shadow.png",
            draw_as_shadow = true,
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
          }
        }
      },
      direction_out = {
        sheets = {
          {
            filename = "__miniloader_modernized__/graphics/entity/miniloader-structure-base.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            y = 192
          },
          {
            filename = "__miniloader_modernized__/graphics/entity/miniloader-structure-mask.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            y = 192,
            tint = tint
          },
          {
            filename = "__miniloader_modernized__/graphics/entity/miniloader-structure-shadow.png",
            draw_as_shadow = true,
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            y = 192
          },
        }
      }
    },
    circuit_wire_max_distance = transport_belt_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        -- Output
        { variation = 24, main_offset = util.by_pixel(-17, 0), shadow_offset = util.by_pixel(10, -0.5), show_shadow = false }, -- N
        { variation = 2, main_offset = util.by_pixel(0, -3), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- E
        { variation = 0, main_offset = util.by_pixel(3, 0), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- S
        { variation = 6, main_offset = util.by_pixel(0, 2), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- W

        -- Input
        { variation = 0, main_offset = util.by_pixel(3, 0), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- N
        { variation = 6, main_offset = util.by_pixel(0, 2), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- E
        { variation = 24, main_offset = util.by_pixel(-17, 0), shadow_offset = util.by_pixel(10, -0.5), show_shadow = false }, -- S
        { variation = 2, main_offset = util.by_pixel(0, -3), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- W
      }
    )
  }
  data:extend{
    entity
  }
end -- create_miniloader_entity()

return {
  create_miniloader_entity = create_miniloader_entity
}
