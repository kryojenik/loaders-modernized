local templates = require("__loaders-modernized__.prototypes.loader_templates")
local entities = require("__loaders-modernized__.prototypes.entities")
local items = require("__loaders-modernized__.prototypes.items")
local recipes = require("__loaders-modernized__.prototypes.recipes")
local technologies = require("__loaders-modernized__.prototypes.technologies")

local below_turbo = {
  ["chute-"] = true,
  ["basic-"] = true,
  [""] = true,
  ["fast-"] = true,
  ["express-"] = true,
}
local never = {
  ["chute-"] = true,
  ["basic-"] = true,
}

local function stack(prefix)
  local belt_stacking = settings.startup["mdrn-enable-stacking"].value
  if belt_stacking == "none" then
    return false
  end

  if belt_stacking == "turbo-and-above"
  and below_turbo[prefix] then
    return false
  end

  if belt_stacking == "all"
  and never[prefix] then
    return false
  end

  return true
end


for prefix, loader_t in pairs(templates) do
  entities.create_entity(prefix, stack(prefix), loader_t.next_prefix, loader_t.tint)
  items.create_item(prefix, loader_t.tint)
  recipes.create_recipe(prefix, stack(prefix), loader_t.recipe_data)
  technologies.create_technology(prefix, loader_t.prerequisite_techs, loader_t.tint)
end

require("__loaders-modernized__.prototypes.miniloader-migrations")