local utils = require("scripts.utils")
local startup_settings = settings.startup

---Create recipe prototypes
---@param tier string
---@param t LMLoaderTemplate
---@param blacklist table
local function create_recipe(tier, t, blacklist)
  local name = t.name or tier .. "mdrn-loader"
  local rd = t.recipe_data
  local ug_name = t.underground_name or tier .. "underground-belt"

  if not rd then
    return {}
  end

  -- Determine which recipe to set for the tiers loader
  local base_recipe = "standard"
  if utils.stack(tier, blacklist) and not startup_settings["mdrn-cheap-stacking"].value then
    base_recipe = "stack"
  end

  local recipes = {}
  ---@type data.RecipePrototype
  local recipe = {
    type = "recipe",
    name = name,
    enabled = false,
    energy_required = rd.energy_required or 1,
    ingredients = rd.ingredients[base_recipe] or rd.ingredients["standard"],
    results = {{type = "item", name = name, amount = 1}},
    category = rd.category or data.raw["recipe"][ug_name].category
  }

  if tier == "chute-" then
    recipe.enabled = true
  end

  if feature_flags.space_travel then
    recipe.surface_conditions = rd.surface_conditions
  end

  -- Double recipe to consume undergrounds evenly
  if startup_settings["mdrn-double-recipe"].value then
    for _, i in pairs(recipe.ingredients) do
      i.amount = i.amount * 2
    end

    for _, r in pairs(recipe.results) do
      r.amount = r.amount * 2
    end
  end

  recipes[#recipes+1] = recipe
  --[[
  -- If stack loaders are separate entities we need to make a stack recipe
  if settings.startup["mdrn-enable-stacking"].value == "turbo-and-above"
  and not blacklist.below_turbo[tier] then
    local stack_name = string.gsub(name, "mdrn%-loader", "stack-mdrn-loader")
    local stack_recipe = table.deepcopy(recipe)
    stack_recipe.name = stack_name
    stack_recipe.ingredients = rd.ingredients["stack"]
    stack_recipe.results = {{type = "item", name = stack_name, amount = 1}}
    recipes[#recipes+1] = stack_recipe
  end
  ]]

  return recipes
end

return {
  create_recipe = create_recipe
}