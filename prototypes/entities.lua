local utils = require("scripts.utils")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size
local startup_settings = settings.startup

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

local function create_structure(tint)
  if startup_settings["mdrn-use-aai-graphics"] and startup_settings["mdrn-use-aai-graphics"].value then
    local shadow_shift = { 0.4, 0.15 }
    local sprite_shift = { 0, -0.15 }
    return {
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

  return {
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
  }
end

---@type data.Loader1x1Prototype[]
local entities = {}

---Create a copy of the loader that only has to filter slots and set them to operate per_lane
---@param entity data.Loader1x1Prototype
---@return data.Loader1x1Prototype
function create_split_entity(entity)
  local split_entity = table.deepcopy(entity)
  split_entity.name = entity.name .. "-split"
  split_entity.filter_count = 2
  split_entity.per_lane_filters = true
  split_entity.factoriopedia_alternative = entity.name
  split_entity.deconstruction_alternative = entity.name
  split_entity.next_upgrade = entity.next_upgrade and entity.next_upgrade .. "-split" or nil
  table.insert(
    split_entity.icons,
    {
      icon = "__loaders-modernized__/graphics/icon/split-lane-out.png",
      icon_size = 64,
      scale = 0.18,
      shift = { -9, 9 }
    }
  )
  return split_entity
end

---Create the loader entities
---@param tier string Tier identifier
---@param template LMLoaderTemplate Template for the loader
---@param blacklist table
local function create_entity(tier, template, blacklist)
  local name = template.name or tier .. "mdrn-loader"
  local underground_name = template.underground_name or tier .. "underground-belt"
  local ug_entity = data.raw["underground-belt"][underground_name]

  ---@type data.Loader1x1Prototype
  local entity = {
    type = "loader-1x1",
    name = name,
    placeable_by = { item = name, count = 1 },
    minable = { mining_time = 0.1, result = name },
    next_upgrade = template.next_upgrade,
    localised_name = template.localised_name or { "entity-name." .. name },
    localised_description = {"" , { "entity-description.common" }},
    flags = {"placeable-player", "placeable-neutral", "player-creation"},
    max_health = 170,
    filter_count = blacklist.filter[tier] and 0 or 5,
    corpse = "small-remnants",
    dying_explosion = ug_entity.dying_explosion or "underground-belt-explosion",
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
    icons = create_icons(template.tint),
    structure = create_structure(template.tint),
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

  if startup_settings["mdrn-use-electricity"].value then
    entity.energy_source = {type = "electric", usage_priority = "secondary-input", drain = "2kW"}
    entity.energy_per_item = "4kJ"
  end

  -- Chute specific settings.
  if entity.name == "chute-mdrn-loader" then
    entity.localised_description = { "entity-description." .. entity.name }
    entity.speed = entity.speed / 2
    entity.circuit_wire_max_distance = 0
    entity.energy_source = { type = "void" }
    entity.energy_per_item = ".0000001J"
  end

  -- space-age
  -- May not exactly be working correctly
  -- https://forums.factorio.com/viewtopic.php?f=65&t=117803
  if feature_flags.space_travel then
    entity.heating_energy = ug_entity.heating_energy
    entity.max_belt_stack_size =  template.max_belt_stack_size or utils.stack(tier, blacklist) and max_belt_stack_size or 1
    if entity.max_belt_stack_size > 1 then
      entity.localised_description[#entity.localised_description+1] = { "entity-description.stack" }
      entity.adjustable_belt_stack_size = true
    end
  end

  entities[#entities+1] = entity
  if not blacklist.split[tier] then
    entities[#entities+1] = create_split_entity(entity)
  end

  return entities

end -- create_entity()

return {
  create_entity = create_entity
}
