local utils = require("__loaders-modernized__.scripts.utils")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size
local startup_settings = settings.startup
local energy_per_item = startup_settings["mdrn-oplp"].value and "4kW" or "4kJ"


---Make a loader subgroup
data:extend{
  {
      type = "item-subgroup",
      name = "belt-loader",
      group = "logistics",
      order = "b[belt-loader]"
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

      icons = utils.create_icons(template.tint, template.dark_frame),
      group = "logistics",
      subgroup = "belt-loader",
      order = string.format("e[mdrn-loader]-%s[%s]", template.order, template.name),
    }
  end

  local ug_item = data.raw["item"][template.underground_name]
  if ug_item then
    item.color_hint = ug_item.color_hint
    item.inventory_move_sound = ug_item.inventory_move_sound
    item.pick_sound = ug_item.pick_sound
    item.drop_sound = ug_item.pick_sound

    -- space-age
    item.weight = ug_item.weight or (20*kg)
    item.default_import_location = ug_item.default_import_location or nil
  end

  item.order = template.order
    and string.format("e[mdrn-loader]-%s[%s]", template.order, template.name)
    or item.order
  item.group = template.group or item.group
  item.subgroup = template.subgroup or item.subgroup
  if template.tint then
    item.icons = utils.create_icons(template.tint, template.dark_frame)
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

---Find an existing technology that unlocks the specified recipe.  If a hint is provided it will
---first see if that technology exists and unlocks the recipe.  If not, the full technology table will
---be walked for the first matching technology that unlocks the recipe.
---@param recipe string
---@param hint (string|data.TechnologyPrototype)? --A "known" technology that may already exist.
---@return data.TechnologyPrototype? --Technology that already has this recipe in an unlock effect.
local function find_existing_unlock(recipe, hint)
  local function compare(t, r)
    if t and t.effects then
      for _, effect in pairs(t.effects) do
        if effect.type == "unlock-recipe" and effect.recipe == r then
          return t
        end
      end
    end
  end

  local tech = compare(type(hint) == "string" and data.raw["technology"][hint] or hint, recipe)

  if not tech then
    for _, t in pairs(data.raw["technology"]) do
      tech = compare(t, recipe)
      if tech then
        break
      end
    end
  end

  return tech
end -- find_existing_unlock()

---Create technology prototype for loaders
---@param template LMLoaderTemplate Loader tier template
local function update_or_create_technology(template)
  local specified_unlock_tech = data.raw["technology"][template.unlocked_by]
  local modify_tech = true
  if startup_settings["mdrn-unlock-technology"].value == "belt" then
    specified_unlock_tech = template.prerequisite_techs and data.raw["technology"][template.prerequisite_techs[1]] or nil
    modify_tech = false
  end

  local existing_unlock_tech = find_existing_unlock(template.name, specified_unlock_tech)
  if template.no_tech then
    if existing_unlock_tech then
      utils.remove_recipe_from_effects(existing_unlock_tech, template.name)
    end

    return {}
  end

  local tech = specified_unlock_tech
  if existing_unlock_tech then
    if tech then
      if tech.name ~= existing_unlock_tech.name then
        utils.remove_recipe_from_effects(existing_unlock_tech, template.name)
        utils.add_recipe_to_effects(tech, template.name)
      end
    else
      tech = existing_unlock_tech
    end
  else
    tech = tech or data.raw["technology"][template.unlocked_by]
    if tech then
      utils.add_recipe_to_effects(tech, template.name)
    else
      --- Existing technology wasn't found.  Create one by duplicating the first pre-req tech.
      --- Should usually be the belt / logistics tech.
      local unit
      local first_prereq_tech = data.raw["technology"][template.prerequisite_techs[1]]
      if first_prereq_tech then
        unit = util.table.deepcopy(first_prereq_tech.unit)
      end

      tech = {
        type = "technology",
        name = template.unlocked_by or template.name --[[@as string]],
        localised_description = { "technology-description.common" },
        icons = utils.create_tech_icons(template.tint, template.dark_frame),
        effects = {{ type = "unlock-recipe", recipe = template.name }},
        order = first_prereq_tech.order,
        prerequisites = template.prerequisite_techs,
        unit = template.unit or unit
      }
    end
  end

  if modify_tech then
    if template.tint then
      tech.icons = utils.create_tech_icons(template.tint, template.dark_frame)
    end

    tech.order = template.order or tech.order
    tech.prerequisites = template.prerequisite_techs or tech.prerequisites
    tech.unit = template.unit or tech.unit
  end

  data:extend{tech}
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
      icons = utils.create_icons(template.tint, template.dark_frame),
      collision_box = { {-0.4, -0.45}	, {0.4, 0.45} },
      structure = utils.create_entity_structure(template.tint, template.dark_frame),
      structure_render_layer = "object",
    }
  end

  entity.localised_name = template.localised_name or entity.localised_name
  entity.next_upgrade = template.next_upgrade or entity.next_upgrade

  if template.tint then
    entity.icons = utils.create_icons(template.tint, template.dark_frame)
    entity.structure = utils.create_entity_structure(template.tint, template.dark_frame)
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
    update_or_create_technology(template)
  end
end
