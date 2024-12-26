local utils = require("scripts.utils")
local startup_settings = settings.startup

-- The 5Dim's 1x2 loaders are messier since the first 3 tiers use the base game name format
-- and in data_final_fixes they move stuff around.
if mods["5dim_transport"] and startup_settings["mdrn-keep-5d-loaders"].value == "none" then
  for name, tech in pairs({
    ["loader"] = "logistics",
    ["fast-loader"] = "logistics-2",
    ["express-loader"] = "logistics-3",
  }) do
    data.raw["loader"][name].next_upgrade = nil
    data.raw["loader"][name].hidden = true
    data.raw["recipe"][name].hidden = true
    data.raw["item"][name].hidden = true
    local effects = data.raw["technology"][tech].effects
    utils.remove_recipe_from_effects(effects, name)
  end
end

-- Make sure the stack loader tier is at the fastest belt speed
if startup_settings["mdrn-enable-stacking"].value == "stack-tier" then
  local fastest_belt = 0
  for _, ug in pairs(data.raw["underground-belt"]) do
    if ug.speed > fastest_belt then
      fastest_belt = ug.speed
    end
  end

  data.raw["loader-1x1"]["stack-mdrn-loader"].speed = fastest_belt
  data.raw["loader-1x1"]["stack-mdrn-loader-split"].speed = fastest_belt
end