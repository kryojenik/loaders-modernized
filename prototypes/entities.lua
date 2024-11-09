local hit_effects = require("__base__.prototypes.entity.hit-effects")
local max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size

-- These loaders will not use split lanes
local split_lane_blacklist = {
  ["chute-"] = true
}

---Create the loader entities
---@param prefix string Loader tier prefix
---@param stack boolean Is stacking enabled for this loader
---@param next_prefix string Prefix of next tier upgrade
---@param tint Color Color used for belt tier
local function create_entity(prefix, stack, next_prefix, tint)
  local base_underground_name = "underground-belt"
  local name = prefix .. "mdrn-loader"
  local underground_name = prefix ~= "chute-" and (prefix .. base_underground_name) or base_underground_name
  local ug_entity = data.raw["underground-belt"][underground_name]

  local entity = {
    type = "loader-1x1",
    name = name,
    flags = {"placeable-player", "placeable-neutral", "player-creation"},
    placeable_by = { item = name, count = 1 },
    minable = { mining_time = 0.1, result = prefix .. "mdrn-loader" },
    max_health = 170,
    filter_count = 5,
    next_upgrade = next_prefix and next_prefix .. "mdrn-loader" or nil,
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
    icons = {
      { icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-base.png" },
      { icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-mask.png", tint = tint }
    },
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

  local setting_use_aai_graphics = settings.startup["mdrn-use-aai-graphics"]
  if setting_use_aai_graphics and setting_use_aai_graphics.value then
    local shadow_shift = { 0.4, 0.15 }
    local sprite_shift = { 0, -0.15 }
    entity.icons = {
      {
        icon = "__aai-loaders__/graphics/icons/loader.png",
        icon_size = 64
      },
      {
        icon = "__aai-loaders__/graphics/icons/loader_mask.png",
        icon_size = 64,
        tint = tint
      }
    }
    entity.structure = {
      direction_in = {
        sheets = {
          {
            filename = "__aai-loaders__/graphics/entity/loader/loader_shadows.png",
            priority = "extra-high",
            shift = shadow_shift,
            width = 138,
            height = 79,
            scale = 0.5,
            draw_as_shadow = true
          },
          {
            filename = "__aai-loaders__/graphics/entity/loader/loader.png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            scale = 0.5,
          },
          {
            filename = "__aai-loaders__/graphics/entity/loader/loader_tint.png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            scale = 0.5,
            tint = tint
          }
        }
      },
      direction_out = {
        sheets = {
          {
            filename = "__aai-loaders__/graphics/entity/loader/loader_shadows.png",
            priority = "extra-high",
            shift = shadow_shift,
            width = 138,
            height = 79,
            y = 79,
            scale = 0.5,
            draw_as_shadow = true
          },
          {
            filename = "__aai-loaders__/graphics/entity/loader/loader.png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            y = 117,
            scale = 0.5,
          },
          {
            filename = "__aai-loaders__/graphics/entity/loader/loader_tint.png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            scale = 0.5,
            y = 117,
            tint = tint
          }
        }
      },
      frozen_patch_in = {
        sheet = {
          filename = "__aai-loaders__/graphics/entity/loader/frozen/loader.png",
          priority = "extra-high",
          shift = sprite_shift,
          width = 99,
          height = 117,
          scale = 0.5
        }
      },
      frozen_patch_out = {
        sheet = {
          filename = "__aai-loaders__/graphics/entity/loader/frozen/loader.png",
          priority = "extra-high",
          shift = sprite_shift,
          width = 99,
          height = 117,
          y = 117,
          scale = 0.5
        }
      }
    }
  end

  if settings.startup["mdrn-use-electricity"].value then
    entity.energy_source = {type = "electric", usage_priority = "secondary-input", drain = "2kW"}
    entity.energy_per_item = "4kJ"
  end

  -- Chute specific settings.  Will also be basic- when supporting Bob's
  if entity.name == "chute-mdrn-loader" then
    entity.filter_count = 0
    entity.speed = entity.speed / 4
    entity.circuit_wire_max_distance = 0
    entity.energy_source = { type = "void" }
    entity.energy_per_item = ".0000001J"
  end

  -- space-age
  -- May not exactly be working correctly
  -- https://forums.factorio.com/viewtopic.php?f=65&t=117803
  if mods["space-age"] then
    entity.heating_energy = ug_entity.heating_energy
  end

  data:extend{
    entity
  }

  if not split_lane_blacklist[prefix] then
    local split_entity = table.deepcopy(entity)
    split_entity.name = name .. "-split"
    split_entity.filter_count = 2
    split_entity.per_lane_filters = true
    split_entity.factoriopedia_alternative = name
    split_entity.deconstruction_alternative = name
    split_entity.next_upgrade = entity.next_upgrade and entity.next_upgrade .. "-split" or nil
    data:extend{
      split_entity
    }
  end

end -- create_entity()

return {
  create_entity = create_entity
}
