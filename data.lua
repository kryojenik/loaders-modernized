local templates = require("__loaders-modernized__.prototypes.loader_templates")
local entities = require("__loaders-modernized__.prototypes.entities")
local items = require("__loaders-modernized__.prototypes.items")
local recipes = require("__loaders-modernized__.prototypes.recipes")


for prefix, loader_t in pairs(templates) do
  entities.create_entity(prefix, "underground-belt", loader_t.next_prefix, loader_t.tint)
  items.create_item(prefix, "underground-belt", loader_t.tint)
  recipes.create_recipe(prefix, loader_t.recipe_data)
  table.insert(data.raw.technology[loader_t.unlock_tech].effects, {
    type = "unlock-recipe",
    recipe = prefix .. "mdrn-loader"
  })
end