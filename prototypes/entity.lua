local hit_effects = require("__base__/prototypes/entity/hit-effects")


local function create_entity(prefix, base_underground_name, tint)
  local name = prefix .. "mdrn-loader"
  local underground_name = prefix .. base_underground_name
  local ug_entity = data.raw["underground-belt"][underground_name]

  local entity = {
    type = "loader-1x1",
    name = name,
    icons = {
      { icon = "__loader_modernized__/graphics/item/mdrn-loader-icon-base.png" },
      { icon = "__loader_modernized__/graphics/item/mdrn-loader-icon-mask.png", tint = tint }
    },
    flags = {"placeable-neutral", "player-creation"},
    minable = { mining_time = 0.1, result = prefix .. "mdrn-loader" },
    max_health = 170,
    filter_count = 5,
    corpse = underground_name .. "-remnants",
    dying_explosion = underground_name .. "-explosion",
    open_sound = { filename = "__base__/sound/open-close/inserter-open.ogg" },
    close_sound = { filename = "__base__/sound/open-close/inserter-close.ogg" },
    resistances = ug_entity.resistances,
    collision_box = ug_entity.collision_box,
    selection_box = ug_entity.selection_box,
    damaged_trigger_effect = hit_effects.entity(),
    animation_speed_coefficient = 32,
    energy_source = {type = "electric", usage_priority = "secondary-input", drain = "2kW"},
    energy_per_item = "4kJ",
    belt_animation_set = ug_entity.belt_animation_set,
    -- TODO: Allow fast replace on all belt entities
    fast_replaceable_group = "loader",
    container_distance = 1;
    speed = ug_entity.speed,
    structure = {
      direction_in = {
        sheets = {
          {
            filename = "__loader_modernized__/graphics/entity/mdrn-loader-structure-base.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
          },
          {
            filename = "__loader_modernized__/graphics/entity/mdrn-loader-structure-mask.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            tint = tint
          },
          {
            filename = "__loader_modernized__/graphics/entity/mdrn-loader-structure-shadow.png",
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
            filename = "__loader_modernized__/graphics/entity/mdrn-loader-structure-base.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            y = 192
          },
          {
            filename = "__loader_modernized__/graphics/entity/mdrn-loader-structure-mask.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            y = 192,
            tint = tint
          },
          {
            filename = "__loader_modernized__/graphics/entity/mdrn-loader-structure-shadow.png",
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
    ),
    -- space-age
    heating_energy = ug_entity.heating_energy,
  }
  data:extend{
    entity
  }
end -- create_entity()

return {
  create_entity = create_entity
}
