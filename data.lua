local entities = require("__loader_modernized__/prototypes/entity")
local items = require("__loader_modernized__/prototypes/item")
local templates = require("__loader_modernized__/prototypes/loader_templates")
require("__loader_modernized__/prototypes/recipe")


for prefix, loader_data in pairs(templates) do
  entities.create_entity(prefix, "underground-belt", loader_data.next_prefix, loader_data.tint)
  items.create_item(prefix, "underground-belt", loader_data.tint)
  table.insert(data.raw.technology[loader_data.unlock_tech].effects, {
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