--local templates = require("__loader_modernized__/prototypes/loader_templates")

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

  if mods["space-age"] then
    recipe.surface_conditions = template.surface_conditions
  end

  data:extend{
    recipe
  }
end

return {
  create_recipe = create_recipe
}