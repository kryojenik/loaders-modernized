local templates = require("__loaders-modernized__.prototypes.loader_templates.loader_templates")
local entities = require("__loaders-modernized__.prototypes.entities")
local items = require("__loaders-modernized__.prototypes.items")
local recipes = require("__loaders-modernized__.prototypes.recipes")
local technologies = require("__loaders-modernized__.prototypes.technologies")

---@type data.Loader1x1Prototype[]
local entity_prototypes = {}
---@type data.ItemPrototype[]
local item_prototypes = {}
---@type data.RecipePrototype[]
local recipe_prototypes = {}
---@type data.TechnologyPrototype[]
local technology_prototypes = {}

local blacklist = templates.blacklist
templates.blacklist = nil

for tier, loader_t in pairs(templates) do
  for _, entity in ipairs(entities.create_entity(tier, loader_t, blacklist)) do
    if entity then
      entity_prototypes[#entity_prototypes+1] = entity
    end
  end

  for _, item in ipairs(items.create_item(tier, loader_t, blacklist)) do
    if item then
      item_prototypes[#item_prototypes+1] = item
    end
  end

  for _, recipe in ipairs(recipes.create_recipe(tier, loader_t, blacklist)) do
    if recipe then
      recipe_prototypes[#recipe_prototypes+1] = recipe
    end
  end

  for _, technology in ipairs(technologies.create_technology(tier, loader_t, blacklist)) do
    if technology then
      technology_prototypes[#technology_prototypes+1] = technology
    end
  end
end

data:extend(entity_prototypes)
data:extend(item_prototypes)
data:extend(recipe_prototypes)
if next(technology_prototypes) then
  data:extend(technology_prototypes)
end

require("__loaders-modernized__.prototypes.miniloader-migrations")