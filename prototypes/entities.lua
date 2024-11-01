local hit_effects = require("__base__.prototypes.entity.hit-effects")
local max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size

local function create_entity(prefix, stack, next, tint)
  local base_underground_name = "underground-belt"
  local name = prefix .. "mdrn-loader"
  local underground_name = prefix ~= "chute-" and (prefix .. base_underground_name) or base_underground_name
  local ug_entity = data.raw["underground-belt"][underground_name]

  local entity = {
    type = "loader-1x1",
    name = name,
    icons = {
      { icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-base.png" },
      { icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-mask.png", tint = tint }
    },
    flags = {"placeable-player", "placeable-neutral", "player-creation"},
    minable = { mining_time = 0.1, result = prefix .. "mdrn-loader" },
    max_health = 170,
    filter_count = 5,
    next_upgrade = next and next .. "mdrn-loader" or nil,
    corpse = "small-remnants",
    dying_explosion = base_underground_name .. "-explosion",
    open_sound = { filename = "__base__/sound/open-close/inserter-open.ogg" },
    close_sound = { filename = "__base__/sound/open-close/inserter-close.ogg" },
    resistances = ug_entity.resistances,
    collision_box = ug_entity.collision_box,
    selection_box = ug_entity.selection_box,
    damaged_trigger_effect = hit_effects.entity(),
    animation_speed_coefficient = 32,
    belt_animation_set = ug_entity.belt_animation_set,
    fast_replaceable_group = "loader",
    container_distance = 1;
    speed = ug_entity.speed,
    max_belt_stack_size = stack and max_belt_stack_size or 1,
    structure = {
      direction_in = {
        sheets = {
          {
            filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
          },
          {
            filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-mask.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            tint = tint
          },
          {
            filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-shadow.png",
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
            filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            y = 192
          },
          {
            filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-mask.png",
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            y = 192,
            tint = tint
          },
          {
            filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-shadow.png",
            draw_as_shadow = true,
            priority = "extra-high",
            width = 192,
            height = 192,
            scale = 0.5,
            y = 192
          },
        }
      },
      back_patch =
      {
        sheet =
        {
          filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-back-patch.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5
        }
      },
      front_patch =
      {
        sheet =
        {
          filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-front-patch.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5
        }
      }
    },
    circuit_wire_max_distance = transport_belt_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        -- Output
        { -- North
          variation = 0,
          main_offset = util.by_pixel(11, -1),
          shadow_offset = util.by_pixel(10, -0.5),
          show_shadow = false
        },
        { -- East
          variation = 6,
          main_offset = util.by_pixel(-5, 3),
          shadow_offset = util.by_pixel(7.5, 7.5),
          show_shadow = false
        },
        { -- South
          variation = 4,
          main_offset = util.by_pixel(-11, -8),
          shadow_offset = util.by_pixel(7.5, 7.5),
          show_shadow = false
        },
        { -- West
          variation = 2,
          main_offset = util.by_pixel(5, -17),
          shadow_offset = util.by_pixel(7.5, 7.5),
          show_shadow = false
        },

        -- Input
        { -- North
          variation = 4,
          main_offset = util.by_pixel(-11, -8),
          shadow_offset = util.by_pixel(7.5, 7.5),
          show_shadow = false
        },
        { -- East
          variation = 2,
          main_offset = util.by_pixel(5, -17),
          shadow_offset = util.by_pixel(7.5, 7.5),
          show_shadow = false
        },
        { -- South
          variation = 0,
          main_offset = util.by_pixel(11, -1),
          shadow_offset = util.by_pixel(10, -0.5),
          show_shadow = false
        },
        { -- West
          variation = 6,
          main_offset = util.by_pixel(-5, 3),
          shadow_offset = util.by_pixel(7.5, 7.5),
          show_shadow = false
        },
      }
    ),
  }

  if settings.startup["mdrn-use-electricity"].value then
    entity.energy_source = {type = "electric", usage_priority = "secondary-input", drain = "2kW"}
    entity.energy_per_item = "4kJ"
  end

  -- chute
  if entity.name == "chute-mdrn-loader" then
    entity.filter_count = 0
    entity.speed = entity.speed / 4
    entity.circuit_wire_max_distance = 0
    entity.energy_source = { type = "void" }
    entity.energy_per_item = ".0000001J"
  end

  -- space-age
  if mods["space-age"] then
    entity.heating_energy = ug_entity.heating_energy
  end

  data:extend{
    entity
  }

  if entity.name ~= "chute-mdrn-loader" then
    local split_entity = table.deepcopy(entity)
    split_entity.name = entity.name .. "-split"
    split_entity.filter_count = 2
    split_entity.per_lane_filters = true
    data:extend{
      split_entity
    }
  end

end -- create_entity()

return {
  create_entity = create_entity
}
