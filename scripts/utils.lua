utils = {}
local startup_settings = settings.startup

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

utils.stack =  function(tier, blacklist)
  if startup_settings["mdrn-enable-stacking"].value == "none"
  or startup_settings["mdrn-enable-stacking"].value == "stack-tier" then
    return false
  end

  if startup_settings["mdrn-enable-stacking"].value == "turbo-and-above"
  and blacklist.below_turbo[tier] then
    return false
  end

  -- If a loader can't filter, don't allow it to stack either.
  if startup_settings["mdrn-enable-stacking"].value == "all"
  and blacklist.filter[tier] then
    return false
  end

  return true
end


return utils