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

---Should the loader allow stacking.  If mdrn-enable-stacking is set and prefix not on the blacklist
---allow the loader to stack when tech is researched.
---@param prefix string Belt tier prefix the loader is part of.
---@return boolean
local function stack(prefix)
  local belt_stacking = settings.startup["mdrn-enable-stacking"]
  if not belt_stacking or belt_stacking.value == "none" then
    return false
  end

  if blacklist[belt_stacking.value][prefix] then
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