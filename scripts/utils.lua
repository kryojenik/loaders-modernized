utils = {}

utils.remove_recipe_from_effects = function(effects, recipe)
  local j = 1
  for i=1, #effects do
    if effects[i].type == "unlock-recipe" and effects[i].recipe == recipe then
      effects[i] = nil
    else
      if i ~= j then
        effects[j] = effects[i]
        effects[i] = nil
      end
      j = j + 1
    end
    i = i + 1
  end
end

return utils