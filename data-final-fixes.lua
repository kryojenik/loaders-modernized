utils = require("__loaders-modernized__.scripts.utils")

-- The 5Dim's 1x2 loaders are messier since the first 3 tiers use the base game name format
-- and in data_final_fixes they move stuff around.
if mods["5dim_transport"] and settings.startup["mdrn-keep-5d-loaders"].value == "none" then
  for name, tech in pairs({
    ["loader"] = "logistics",
    ["fast-loader"] = "logistics-2",
    ["express-loader"] = "logistics-3",
    ["turbo-loader"] = "turbo-transport-belt"
  }) do
    data.raw["loader"][name].next_upgrade = nil
    data.raw["loader"][name].hidden = true
    data.raw["recipe"][name] = nil
    data.raw["item"][name].hidden = true
    local effects = data.raw["technology"][tech].effects
    utils.remove_recipe_from_effects(effects, name)
  end
end