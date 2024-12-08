---Create recipe prototypes
---@param tier string
---@param t LMLoaderTemplate
---@param stack boolean
local function create_recipe(tier, t, stack)
  local item_name = t.name or tier .. "mdrn-loader"
  local rd = t.recipe_data
  local ug_name = t.underground_name or tier .. "underground-belt"
  local cheap_stacking = settings.startup["mdrn-cheap-stacking"]
  if cheap_stacking and cheap_stacking.value then
    -- Use the standard recipe
    stack = false
  end

  ---@type data.RecipePrototype
  local recipe= {
    type = "recipe",
    name = item_name,
    enabled = false,
    energy_required = rd.energy_required or 1,
    ingredients = stack and rd.ingredients.stack or rd.ingredients.standard,
    results = {{type = "item", name = item_name, amount = 1}},
    category = rd.category or data.raw["recipe"][ug_name].category
  }

  if tier == "chute-" then
    recipe.enabled = true
  end

    if tier == "stack-" then
    recipe.enabled = true
  end

  if mods["space-age"] then
    recipe.surface_conditions = rd.surface_conditions
  end

  if settings.startup["mdrn-double-recipe"].value then
    for _, i in pairs(recipe.ingredients) do
      i.amount = i.amount * 2
    end

    for _, r in pairs(recipe.results) do
      r.amount = r.amount * 2
    end
  end

  return recipe
  --[[
  data:extend{
    recipe
  }
  ]]
end

return {
  create_recipe = create_recipe
}