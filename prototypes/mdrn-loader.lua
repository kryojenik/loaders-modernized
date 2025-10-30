local utils = require("scripts.utils")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size
local startup_settings = settings.startup
-- energy_per_item should be in Joules, not Watts.  I initially typo'd the kJ to kW in the initial
-- version and it was that way for a long time.  Leaving it as a non-default option for those that
-- wish to keep the original power consumption value.
local energy_per_item = startup_settings["mdrn-oplp"].value and "4kW" or "4kJ"


---Make a loader subgroup
data:extend{
  {
      type = "item-subgroup",
      name = "belt-loader",
      group = "logistics",
      order = "b-loader"
  }
}

---Create the Item prototypes
---@param template LMLoaderTemplate Template for loader tier
local function update_or_create_item(template)
  ---@type data.ItemPrototype
  local item = data.raw["item"][template.name]
  if not item then
    item = {
      type = "item",
      stack_size = 50,

      name = template.name,
      place_result = template.name,

      icons = utils.create_icons(template.tint),
      group = "logistics",
      subgroup = "belt-loader",
    }
  end

  local ug_item = data.raw["item"][template.underground_name]
  if ug_item then
    item.order = string.gsub(ug_item.order, "^b%[underground%-belt%]", "e[mdrn-loader]")
    item.color_hint = ug_item.color_hint
    item.inventory_move_sound = ug_item.inventory_move_sound
    item.pick_sound = ug_item.pick_sound
    item.drop_sound = ug_item.pick_sound

    -- space-age
    item.weight = ug_item.weight or (20*kg)
    item.default_import_location = ug_item.default_import_location or nil
  end

  item.order = template.order or item.order
  item.group = template.group or item.group
  item.subgroup = template.subgroup or item.subgroup
  if template.tint then
    item.icons = utils.create_icons(template.tint)
  end


  data:extend{item}
end

---Create recipe prototypes
---@param template LMLoaderTemplate
local function update_or_create_recipe(template)
  local rd = template.recipe_data

  if not rd then
    return {}
  end

  ---@type data.RecipePrototype
  local recipe = data.raw["recipe"][template.name]
  local new = false
  if not recipe then
    new = true
    recipe = {
      type = "recipe",
      name = template.name,
      enabled = false,
      energy_required = 1,
      results = {{type = "item", name = template.name, amount = 1}},
      category = data.raw["recipe"][template.underground_name].category
    }
  end

  recipe.energy_required = rd.energy_required or recipe.energy_required
  recipe.category = rd.category or recipe.category
  recipe.results = rd.results or recipe.results

  if not (rd.enabled == nil) then
    recipe.enabled = rd.enabled
  end

  if feature_flags.space_travel then
    recipe.surface_conditions = rd.surface_conditions or recipe.surface_conditions
  end


  local ingredients = rd.ingredients
  if ingredients then
    if not startup_settings["mdrn-cheap-stacking"].value == true
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

    -- Double recipe to consume undergrounds evenly
    ---@cast ingredients -?
    if startup_settings["mdrn-double-recipe"].value then
      for _, i in ipairs(ingredients) do
        i.amount = i.amount * 2
      end

      if new then
        for _, r in ipairs(recipe.results) do
          r.amount = r.amount * 2
        end
      end
    end

    recipe.ingredients = ingredients
  end

  data:extend{recipe}
end

---Create technology prototype for loaders
---@param template LMLoaderTemplate Loader tier template
local function create_technology(template)
  if template.no_tech
  or not (template.unlocked_by or template.prerequisite_techs) then
    return {}
  end

  --- Are we going to unlock by an existing technology?
  local unlocked_by = data.raw["technology"][template.unlocked_by]
  if not unlocked_by and startup_settings["mdrn-unlock-technology"].value == "belt" then
    unlocked_by = data.raw["technology"][template.prerequisite_techs[1]]
  end

  if unlocked_by then
    for _, e in pairs(unlocked_by.effects) do
      if e.type == "unlock-recipe" and e.recipe == template.name then
        return {}
      end
    end

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
    icons = utils.create_tech_icons(template.tint),
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
---@param template LMLoaderTemplate
local function update_or_create_entity(template)
  ---@type data.Loader1x1Prototype
  local entity = data.raw["loader-1x1"][template.name]
  if not entity then
    ---@diagnostic disable-next-line:missing-fields
    entity = {
      type = "loader-1x1",
      flags = {"placeable-neutral", "player-creation"},
      filter_count = 5,
      localised_name = template.localised_name or { "entity-name." .. template.name },
      localised_description = template.localised_description or { "", { "entity-description.common" }},
      open_sound = { filename = "__base__/sound/open-close/inserter-open.ogg" },
      close_sound = { filename = "__base__/sound/open-close/inserter-close.ogg" },
      fast_replaceable_group = "transport-belt",
      container_distance = 1;
      max_health = 170,
      corpse = "small-remnants",
      damaged_trigger_effect = hit_effects.entity(),
      animation_speed_coefficient = 32,
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

      name = template.name,
      placeable_by = { item = template.name, count = 1 },
      minable = { mining_time = 0.1, result = template.name },
      icons = utils.create_icons(template.tint),
      collision_box = { {-0.4, -0.45}	, {0.4, 0.45} },
      structure = utils.create_entity_structure(template.tint),
      structure_render_layer = "object",
    }
  end

  entity.localised_name = template.localised_name or entity.localised_name
  entity.next_upgrade = template.next_upgrade or entity.next_upgrade

  if template.tint then
    entity.icons = utils.create_icons(template.tint)
    entity.structure = utils.create_entity_structure(template.tint)
  end

  local ug_entity = data.raw["underground-belt"][template.underground_name]
  if ug_entity then
    entity.speed = ug_entity.speed * (template.speed_multiplier or 1)
    entity.selection_box = ug_entity.selection_box
    entity.resistances = ug_entity.resistances
    entity.dying_explosion = ug_entity.dying_explosion or "underground-belt-explosion"
    entity.belt_animation_set = ug_entity.belt_animation_set
  end

  -- Stacking
  if feature_flags.space_travel then
    entity.max_belt_stack_size =  template.max_belt_stack_size or entity.max_belt_stack_size or (utils.stack(template) and max_belt_stack_size) or 1
    if entity.max_belt_stack_size > 1 then
      entity.localised_description = {
        "",
        template.localised_description or { "entity-description.common" },
        { "entity-description.stack" }
      }
      entity.adjustable_belt_stack_size = true
    end

    if ug_entity then
      entity.heating_energy = ug_entity.heating_energy or entity.heating_energy
    end
  end

  if startup_settings["mdrn-use-electricity"].value then
    if not entity.energy_source then
      entity.energy_source = {
        type = template.energy_type or "electric",
        drain = template.energy_drain or "2kW",
        usage_priority = "secondary-input"
      }
      entity.energy_per_item = template.energy_per_item or energy_per_item
    else
      entity.energy_source.type = template.energy_type or entity.energy_source.type
      entity.energy_source.drain = template.energy_drain or entity.energy_source.drain
      entity.energy_per_item = template.energy_per_item or entity.energy_per_item
    end
  end

  if startup_settings["mdrn-respect-insert-limits"].value then
    entity.respect_insert_limits = true
  end

  -- If the entity can't filter it can't do other advanced things.
  if template.no_filter then
    entity.filter_count = 0
    entity.circuit_wire_max_distance = 0
    entity.circuit_connector = nil
  end


  data:extend{entity}
  if not template.no_filter then
    data:extend{create_split_entity(entity)}
  end

  if template.previous_prefix then
    local prev_name = template.previous_prefix .. "mdrn-loader"
    local prev_ldr = data.raw["loader-1x1"][prev_name]
    if prev_ldr then
      prev_ldr.next_upgrade = entity.name
    end

    local prev_ldr_split = data.raw["loader-1x1"][prev_name .. "-split"]
    if prev_ldr_split then
      prev_ldr_split.next_upgrade = entity.name .. "-split"
    end
  end
end

MdrnLoaders = MdrnLoaders or {}
---Make tier of loaders
---@param templates table
function MdrnLoaders.make_modern_loaders(templates)
  if not next(templates) then
    return
  end

  for tier, template in pairs(templates.loaders) do
    template.name = template.name or tier .. "mdrn-loader"
    template.underground_name = template.underground_name or tier .. "underground-belt"

    update_or_create_item(template)
    update_or_create_recipe(template)
    update_or_create_entity(template)
    create_technology(template)
  end
end
