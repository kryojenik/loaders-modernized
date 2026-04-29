local utils = require("__loaders-modernized__.scripts.utils")
local C     = require("__loaders-modernized__.constants")
local cfg   = require("__loaders-modernized__.prototypes.settings-cache")
local hit_effects         = require("__base__.prototypes.entity.hit-effects")
local max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size
local math  = require("__flib__.math")

local prismatic_api = nil
if cfg.has_prismatic_belts then
  prismatic_api = require("__prismatic-belts__.prototypes.api")
end

---Create a variant of a base loader entity with specific property flags set.
---Variant entities share the base entity's item, recipe, and technology.
---Canonical suffix order: -split, -wfs, -fill.
---@param base data.Loader1x1Prototype  The un-suffixed base entity.
---@param flags LMVariantFlags
---@return data.Loader1x1Prototype
local function create_variant_entity(base, flags)
  local variant = table.deepcopy(base)
  local suffix = (flags.split and C.SPLIT_SUFFIX or "")
               .. (flags.wfs  and C.WFS_SUFFIX   or "")
               .. (flags.fill and C.FILL_SUFFIX  or "")

  variant.name = base.name .. suffix
  variant.factoriopedia_alternative  = base.name
  variant.deconstruction_alternative = base.name
  variant.next_upgrade = base.next_upgrade and base.next_upgrade .. suffix or nil

  if flags.split then
    variant.filter_count   = 2
    variant.per_lane_filters = true
    variant.localised_name = { "", base.localised_name, " ", { "strings.mdrn-split-suffix" } }
    table.insert(variant.icons, {
      icon = C.GRAPHICS.SPLIT_ICON,
      icon_size = 64,
      scale = 0.16,
      shift = { -11, 9 },
    })
  end
  if flags.wfs then
    variant.wait_for_full_stack = true
    variant.localised_name = { "", variant.localised_name or base.localised_name,
                               " ", { "strings.mdrn-wfs-suffix" } }
    table.insert(variant.icons, {
      icon = C.GRAPHICS.WFS_ICON,
      icon_size = 64,
      scale = 0.16,
      shift = { 0, 9 },
    })
  end
  if flags.fill then
    variant.respect_insert_limits = false
    variant.localised_name = { "", variant.localised_name or base.localised_name,
                               " ", { "strings.mdrn-fill-suffix" } }
    table.insert(variant.icons, {
      icon = C.GRAPHICS.FILL_ICON,
      icon_size = 64,
      scale = 0.16,
      shift = { 11, 9 },
    })
  end

  return variant
end -- create_variant_entity()

---Create the loader entities
---@param template LMLoaderTemplate
local function update_or_create_entity(template)
  ---@type data.Loader1x1Prototype
  local entity = data.raw["loader-1x1"][template.name]
  if entity and entity.filter_count < 1 then
    template.filter = false
  end

  if not entity then
    -- belt_animation_set, structure, and speed are populated below from the
    -- underground-belt prototype; suppress the false positive on the bare table.
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
      container_distance = 1,
      max_health = 170,
      corpse = "small-remnants",
      damaged_trigger_effect = hit_effects.entity(),
      animation_speed_coefficient = 32,
      respect_insert_limits = true,
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
      collision_box = { {-0.4, -0.45}, {0.4, 0.45} },
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
    if cfg.has_prismatic_belts and prismatic_api then
      entity.belt_animation_set = prismatic_api.get_transport_belt_animation_set(
        {
         mask_tint = template.tint,
         tint_mask_as_overlay = true,
         variant  = math.clamp((60 * 8 * entity.speed) / 15, 1, 3)
        }
      )
    else
      entity.belt_animation_set = ug_entity.belt_animation_set
    end
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

  -- Energy usage
  if cfg.use_electricity then
    if not entity.energy_source then
      entity.energy_source = {
        type = template.energy_type or "electric",
        drain = template.energy_drain or "2kW",
        usage_priority = "secondary-input"
      }
      entity.energy_per_item = template.energy_per_item or cfg.energy_per_item
    else
      entity.energy_source.type = template.energy_type or entity.energy_source.type
      entity.energy_source.drain = template.energy_drain or entity.energy_source.drain
      entity.energy_per_item = template.energy_per_item or entity.energy_per_item
    end
  end

  -- If the entity can't filter it can't do other advanced things.
  if template.filter == false then
    entity.filter_count = 0
    entity.circuit_wire_max_distance = 0
    entity.circuit_connector = nil
  end

  if template.fill_base then
    entity.respect_insert_limits = false
  end

  data:extend{entity}

  local can_stack = (entity.max_belt_stack_size or 1) > 1
  if template.filter ~= false then
    local variants = {
      create_variant_entity(entity, { split = true,  wfs = false, fill = false }),
      create_variant_entity(entity, { split = false, wfs = false, fill = true  }),
      create_variant_entity(entity, { split = true,  wfs = false, fill = true  }),
    }
    if can_stack then
      variants[#variants + 1] = create_variant_entity(entity, { split = false, wfs = true,  fill = false })
      variants[#variants + 1] = create_variant_entity(entity, { split = true,  wfs = true,  fill = false })
      variants[#variants + 1] = create_variant_entity(entity, { split = false, wfs = true,  fill = true  })
      variants[#variants + 1] = create_variant_entity(entity, { split = true,  wfs = true,  fill = true  })
    end
    data:extend(variants)
  end

  if template.upgrade_from_tier then
    local prev_name = C.LOADER_PREFIX .. template.upgrade_from_tier .. C.LOADER_BASE
    local function link_upgrade(suffix)
      local prev = data.raw["loader-1x1"][prev_name .. suffix]
      if prev then prev.next_upgrade = entity.name .. suffix end
    end -- link_upgrade()
    -- Wire up next_upgrade for every variant suffix that could exist.
    local suffixes = {
      "",
      C.SPLIT_SUFFIX,
      C.FILL_SUFFIX,
      C.SPLIT_SUFFIX .. C.FILL_SUFFIX,
    }
    if can_stack then
      suffixes[#suffixes + 1] = C.WFS_SUFFIX
      suffixes[#suffixes + 1] = C.SPLIT_SUFFIX .. C.WFS_SUFFIX
      suffixes[#suffixes + 1] = C.WFS_SUFFIX .. C.FILL_SUFFIX
      suffixes[#suffixes + 1] = C.SPLIT_SUFFIX .. C.WFS_SUFFIX .. C.FILL_SUFFIX
    end
    for _, sfx in ipairs(suffixes) do
      link_upgrade(sfx)
    end
  end
end -- update_or_create_entity()

return update_or_create_entity
