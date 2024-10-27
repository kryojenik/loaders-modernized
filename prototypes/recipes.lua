--- @param prefix string
---@param template table
local function create_recipe(prefix, template)
  local item_name = prefix .. "mdrn-loader"
  local recipe= {
    type = "recipe",
    name = prefix .. "mdrn-loader",
    enabled = false,
    energy_required = template.energy_required or 1,
    ingredients = template.ingredients,
    results = {{type = "item", name = item_name, amount = 1}},
    category = template.category
  }

  if prefix == "chute-" then
    recipe.enabled = true
  end
  
  if mods["space-age"] then
    recipe.surface_conditions = template.surface_conditions
  end

  if settings.startup["mdrn-double-recipe"].value then
    for _, i in pairs(recipe.ingredients) do
      i.amount = i.amount * 2
    end

    for _, r in pairs(recipe.results) do
      r.amount = r.amount * 2
    end
  end

  data:extend{
    recipe
  }
end

return {
  create_recipe = create_recipe
}