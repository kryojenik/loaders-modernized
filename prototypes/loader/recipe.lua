local utils = require("__loaders-modernized__.scripts.utils")
local cfg   = require("__loaders-modernized__.prototypes.settings-cache")

---Create recipe prototypes
---@param template LMLoaderTemplate
local function update_or_create_recipe(template)
  local rd = template.recipe_data

  if not rd then
    return {}
  end

  ---@type data.RecipePrototype
  local recipe = data.raw["recipe"][template.name]
  local new = false
  if not recipe then
    new = true
    recipe = {
      type = "recipe",
      name = template.name,
      enabled = false,
      energy_required = 1,
      results = {{type = "item", name = template.name, amount = 1}},
      category = data.raw["recipe"][template.underground_name].category
    }
  end

  recipe.energy_required = rd.energy_required or recipe.energy_required
  recipe.category = rd.category or recipe.category
  recipe.results = rd.results or recipe.results

  if not (rd.enabled == nil) then
    recipe.enabled = rd.enabled
  end

  if feature_flags.space_travel then
    recipe.surface_conditions = rd.surface_conditions or recipe.surface_conditions
  end


  local ingredients = rd.ingredients
  if ingredients then
    if cfg.cheap_stacking ~= true
    and utils.stack(template) then
      if rd.stack_ingredients then
        ingredients = rd.stack_ingredients
      else
        for i, ingredient in ipairs(ingredients) do
          if ingredient.type == "item" and data.raw["inserter"][ingredient.name] then
            -- TODO: Make this a setting
            ingredients[i].amount = ingredients[i].amount + 2
          end
        end
      end
    end

    -- Double recipe to consume undergrounds evenly
    ---@cast ingredients -?
    if cfg.double_recipe then
      for _, i in ipairs(ingredients) do
        i.amount = i.amount * 2
      end

      if new then
        for _, r in ipairs(recipe.results) do
          r.amount = r.amount * 2
        end
      end
    end

    recipe.ingredients = ingredients
  end

  data:extend{recipe}
end -- update_or_create_recipe()

return update_or_create_recipe
