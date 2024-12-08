local templates = require("__loaders-modernized__.prototypes.loader_templates.loader_templates")
local entities = require("__loaders-modernized__.prototypes.entities")
local items = require("__loaders-modernized__.prototypes.items")
local recipes = require("__loaders-modernized__.prototypes.recipes")
local technologies = require("__loaders-modernized__.prototypes.technologies")

-- Loaders that will not allow belt stacking based on mod settings
local blacklist = {
  ["turbo-and-above"] = {
    ["chute-"] = true,
    ["basic-"] = true,
    [""] = true,
    ["fast-"] = true,
    ["express-"] = true,
  },
  ["all"] = {
    ["chute-"] = true,
    ["basic-"] = true,
  },
}
-- Loaders that will always allow belt stacking irrelevant of mdrn-enable-stacking setting
local whitelist = {
  ["none"] = {
    ["stack-"] = true,
  },
}

---Should the loader allow stacking.  If mdrn-enable-stacking is set and prefix not on the blacklist
---allow the loader to stack when tech is researched.
---@param tier string Belt tier prefix the loader is part of.
---@return boolean
local function stack(tier)
  local belt_stacking = settings.startup["mdrn-enable-stacking"]

  if whitelist[belt_stacking.value][tier] then
    return true
  end

  if not belt_stacking or belt_stacking.value == "none" then
    return false
  end

  if blacklist[belt_stacking.value][tier] then
    return false
  end

  return true
end

---@type data.Loader1x1Prototype[]
local entity_prototypes = {}
---@type data.ItemPrototype[]
local item_prototypes = {}
---@type data.RecipePrototype[]
local recipe_prototypes = {}
---@type data.TechnologyPrototype[]
local technology_prototypes = {}

for tier, loader_t in pairs(templates) do
  for _, entity in ipairs(entities.create_entity(tier, loader_t, stack(tier))) do
    if entity then
      entity_prototypes[#entity_prototypes+1] = entity
    end
  end

  local item = items.create_item(tier, loader_t)
  if item then
    item_prototypes[#item_prototypes+1] = item
  end

  local recipe = recipes.create_recipe(tier, loader_t, stack(tier))
  if recipe then
    recipe_prototypes[#recipe_prototypes+1] = recipe
  end

  local technology = technologies.create_technology(tier, loader_t)
  if technology then
    technology_prototypes[#technology_prototypes+1] = technology
  end
end

data:extend(entity_prototypes)
data:extend(item_prototypes)
data:extend(recipe_prototypes)
if next(technology_prototypes) then
  data:extend(technology_prototypes)
end

require("__loaders-modernized__.prototypes.miniloader-migrations")