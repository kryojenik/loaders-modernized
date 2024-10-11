local items = require ("__loader_modernized__/prototypes/item")
local entities = require ("__loader_modernized__/prototypes/entity")
require ("__loader_modernized__/prototypes/recipe")

entities.create_entity("", "underground-belt", util.color("ffc340d1"))
entities.create_entity("fast-", "underground-belt", util.color("e31717d1"))
entities.create_entity("express-", "underground-belt", util.color("43c0fad1"))
entities.create_entity("tungsten-", "underground-belt", util.color("16f263d1"))

items.create_item("", "underground-belt", util.color("ffc340d1"))
items.create_item("fast-", "underground-belt", util.color("e31717d1"))
items.create_item("express-", "underground-belt", util.color("43c0fad1"))
items.create_item("tungsten-", "underground-belt", util.color("16f263d1"))

table.insert(data.raw.technology["logistics"].effects, {type = "unlock-recipe", recipe = "mdrn-loader"})
table.insert(data.raw.technology["logistics-2"].effects, {type = "unlock-recipe", recipe = "fast-mdrn-loader"})
table.insert(data.raw.technology["logistics-3"].effects, {type = "unlock-recipe", recipe = "express-mdrn-loader"})
-- space-age
table.insert(data.raw.technology["tungsten-transport-belt"].effects, {type = "unlock-recipe", recipe = "tungsten-mdrn-loader"})