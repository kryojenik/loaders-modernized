local utils = require("scripts.utils")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size
local startup_settings = settings.startup

---Make a loader subgroup
data:extend{
  {
      type = "item-subgroup",
      name = "belt-loader",
      group = "logistics",
      order = "b-loader"
  }
}

---Loader icons
---@param tint Color
---@return table
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

local function create_tech_icons(tint)
  if startup_settings["mdrn-use-aai-graphics"] and startup_settings["mdrn-use-aai-graphics"].value then
    return {
      { icon = "__aai-loaders__/graphics/technology/loader-tech-icon.png", icon_size = 256 },
      { icon = "__aai-loaders__/graphics/technology/loader-tech-icon_mask.png", icon_size = 256, tint = tint }
    }
  end

  return {
    { icon = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-base.png", icon_size = 128 },
    { icon = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-mask.png", icon_size = 128, tint = tint }
  }
end

---Loader structure sprite sheets
---@param tint Color
---@return data.LoaderStructure
local function create_entity_structure(tint)
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

---Create the Item prototypes
---@param template LMLoaderTemplate Template for loader tier
local function create_item(template)
  local ug_item = data.raw["item"][template.underground_name]

  ---@type data.ItemPrototype
  local item = {
    type = "item",
    name = template.name,
    icons = create_icons(template.tint),
    --group = template.group or "logistics",
    subgroup = template.subgroup or "belt-loader",
    color_hint = ug_item.color_hint,
    order = template.order or string.gsub(ug_item.order, "^b%[underground%-belt%]", "e[mdrn-loader]"),
    inventory_move_sound = ug_item.inventory_move_sound,
    pick_sound = ug_item.pick_sound,
    drop_sound = ug_item.pick_sound,
    place_result = template.name,
    stack_size = 50,

    -- space-age
    weight = ug_item.weight or (20*kg),
    default_import_location = ug_item.default_import_location or nil
  }

  data:extend{item}
end

---Create recipe prototypes
---@param template LMLoaderTemplate
local function create_recipe(template)
  local rd = template.recipe_data

  if not rd then
    return {}
  end

  -- Determine which recipe to set for the tiers loader
  local ingredients = rd.ingredients
  if not ingredients then
    return {}
  end

  if startup_settings["mdrn-cheap-stacking"].value == false
  and utils.stack(template) then
    if rd.stack_ingredients then
      ingredients = rd.stack_ingredients
    else
      for i, ingredient in ipairs(ingredients) do
        if ingredient.type == "item" and data.raw["inserter"][ingredient.name] then
          -- TODO: Make this a setting
          ingredients[i].amount = ingredients[i].amount + 2
        end
      end
    end
  end

  ---@type data.RecipePrototype
  local recipe = {
    type = "recipe",
    name = template.name,
    enabled = rd.enabled or false,
    energy_required = rd.energy_required or 1,
    ingredients = ingredients,
    results = {{type = "item", name = template.name, amount = 1}},
    category = rd.category or data.raw["recipe"][template.underground_name].category
  }

  if feature_flags.space_travel then
    recipe.surface_conditions = rd.surface_conditions
  end

  -- Double recipe to consume undergrounds evenly
  if startup_settings["mdrn-double-recipe"].value then
    for _, i in pairs(recipe.ingredients) do
      i.amount = i.amount * 2
    end

    for _, r in pairs(recipe.results) do
      r.amount = r.amount * 2
    end
  end

  data:extend{recipe}
end

---Create technology prototype for loaders
---@param template LMLoaderTemplate Loader tier template
local function create_technology(template)
  if template.no_tech then
    return {}
  end

  --- Are we going to unlock by an existing technology?
  local unlocked_by = data.raw["technology"][template.unlocked_by]
  if not unlocked_by and startup_settings["mdrn-unlock-technology"].value == "belt" then
    unlocked_by = data.raw["technology"][template.prerequisite_techs[1]]
  end

  if unlocked_by then
    unlocked_by.effects[#unlocked_by.effects+1] = { type = "unlock-recipe", recipe = template.name }
    return {}
  end

  --- Existing wasn't found.  Create one by duplicating the first pre-req tech.  Should usually
  --- be the belt / logistics tech.
  ---@type data.TechnologyUnit
  local unit = nil
  if data.raw["technology"][template.prerequisite_techs[1]] then
    unit = util.table.deepcopy(data.raw["technology"][template.prerequisite_techs[1]].unit)
  end

  ---@type data.TechnologyPrototype
  local technology = {
    type = "technology",
    name = template.name,
    localised_description = { "technology-description.common" },
    icons = create_tech_icons(template.tint),
    effects = {{ type = "unlock-recipe", recipe = template.name }},
    order = template.prerequisite_techs[1].order,
    prerequisites = template.prerequisite_techs,
    unit = template.unit or unit
  }

  data:extend{technology}
end

---Create a copy of the loader that only has two filter slots and set them to operate per_lane
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
  split_entity.localised_name = { "", entity.localised_name, " ", { "strings.mdrn-split-suffix" } }
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
---@param template LMLoaderTemplate Template for the loader
local function create_entity(template)
  local ug_entity = data.raw["underground-belt"][template.underground_name]

  ---@type data.Loader1x1Prototype
  local entity = {
    type = "loader-1x1",
    name = template.name,
    localised_name = template.localised_name or { "entity-name." .. template.name },
    localised_description = template.localised_description or {"" , { "entity-description.common" }},
    next_upgrade = template.next_upgrade,

    speed = ug_entity.speed,
    placeable_by = { item = template.name, count = 1 },
    minable = { mining_time = 0.1, result = template.name },
    flags = {"placeable-player", "placeable-neutral", "player-creation"},
    fast_replaceable_group = "loader",
    container_distance = 1;
    collision_box = ug_entity.collision_box,
    selection_box = ug_entity.selection_box,
    filter_count = 5,
    open_sound = { filename = "__base__/sound/open-close/inserter-open.ogg" },
    close_sound = { filename = "__base__/sound/open-close/inserter-close.ogg" },

    resistances = ug_entity.resistances,
    max_health = 170,
    corpse = "small-remnants",
    dying_explosion = ug_entity.dying_explosion or "underground-belt-explosion",
    damaged_trigger_effect = hit_effects.entity(),

    icons = create_icons(template.tint),
    structure = create_entity_structure(template.tint),
    animation_speed_coefficient = 32,
    belt_animation_set = ug_entity.belt_animation_set,

    circuit_wire_max_distance = transport_belt_circuit_wire_max_distance or 0,
    circuit_connector = circuit_connector_definitions.create_vector(
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

  -- If the entity can't filter it can't do advanced things.
  if template.no_filter then
    entity.filter_count = 0
    entity.circuit_wire_max_distance = 0
    entity.circuit_connector = nil
  end

  -- Chute specific settings.
  if entity.name == "chute-mdrn-loader" then
    entity.localised_description = { "entity-description." .. entity.name }
    entity.speed = entity.speed / 2
    entity.energy_source = { type = "void" }
    entity.energy_per_item = ".0000001J"
  end

  -- space-age
  -- May not exactly be working correctly
  -- https://forums.factorio.com/viewtopic.php?f=65&t=117803
  if feature_flags.space_travel then
    entity.heating_energy = ug_entity.heating_energy
    entity.max_belt_stack_size =  template.max_belt_stack_size or utils.stack(template) and max_belt_stack_size or 1
    if entity.max_belt_stack_size > 1 then
      entity.localised_description = { "", entity.localised_description, { "entity-description.stack" } }
      entity.adjustable_belt_stack_size = true
    end
  end

  data:extend{entity}

  if template.previous_prefix then
    local prev_name = template.previous_prefix .. "mdrn-loader"
    local prev_ldr = data.raw["loader-1x1"][prev_name]
    if prev_ldr then
      prev_ldr.next_upgrade = entity.name
    end
  end

  if not template.no_filter then
    data:extend{create_split_entity(entity)}
  end

end -- create_entity()

MdrnLoaders = MdrnLoaders or {}
---Make tier of loaders
---@param templates table
function MdrnLoaders.make_modern_loaders(templates)
  for tier, template in pairs(templates.loaders) do
    template.name = template.name or tier .. "mdrn-loader"
    template.underground_name = template.underground_name or tier .. "underground-belt"

    create_item(template)
    create_recipe(template)
    create_entity(template)
    create_technology(template)
  end
end