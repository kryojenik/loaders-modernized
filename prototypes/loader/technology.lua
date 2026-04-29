local utils = require("__loaders-modernized__.scripts.utils")
local C     = require("__loaders-modernized__.constants")
local cfg   = require("__loaders-modernized__.prototypes.settings-cache")

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
  end -- compare()

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
  if cfg.unlock_technology == C.UNLOCK_TECH.BELT then
    specified_unlock_tech = template.prerequisite_techs and data.raw["technology"][template.prerequisite_techs[1]] or nil
    modify_tech = false
  end

  local existing_unlock_tech = find_existing_unlock(template.name, specified_unlock_tech)
  if template.tech_data == false then
    if existing_unlock_tech then
      utils.remove_recipe_from_effects(template.name, existing_unlock_tech.name)
    end

    return {}
  end

  local tech = specified_unlock_tech
  if existing_unlock_tech then
    if tech then
      if tech.name ~= existing_unlock_tech.name then
        utils.remove_recipe_from_effects(template.name, existing_unlock_tech.name)
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
    if template.tint and template.tech_tint ~= false then
      tech.icons = utils.create_tech_icons(template.tint, template.dark_frame)
    end

    tech.order = template.order or tech.order
    tech.prerequisites = template.prerequisite_techs or tech.prerequisites
    tech.unit = template.unit or tech.unit
  end

  data:extend{tech}
end -- update_or_create_technology()

return update_or_create_technology
