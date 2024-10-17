local templates = require("__loaders-modernized__.prototypes.loader_templates")
local entities = require("__loaders-modernized__.prototypes.entities")
local items = require("__loaders-modernized__.prototypes.items")
local recipes = require("__loaders-modernized__.prototypes.recipes")
local technologies = require("__loaders-modernized__.prototypes.technologies")

for prefix, loader_t in pairs(templates) do
  entities.create_entity(prefix, "underground-belt", loader_t.next_prefix, loader_t.tint)
  items.create_item(prefix, "underground-belt", loader_t.tint)
  recipes.create_recipe(prefix, loader_t.recipe_data)
  technologies.create_technology(prefix, loader_t.prerequisite_techs, loader_t.tint)
end