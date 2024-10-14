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

table.insert(data.raw.technology["logistics"].effects, {type = "unlock-recipe", recipe = "mdrn-loader"})
table.insert(data.raw.technology["logistics-2"].effects, {type = "unlock-recipe", recipe = "fast-mdrn-loader"})
table.insert(data.raw.technology["logistics-3"].effects, {type = "unlock-recipe", recipe = "express-mdrn-loader"})
-- space-age
if data.raw.technology["tungsten-transport-belt"] then
  table.insert(data.raw.technology["tungsten-transport-belt"].effects, {type = "unlock-recipe", recipe = "tungsten-mdrn-loader"})
end