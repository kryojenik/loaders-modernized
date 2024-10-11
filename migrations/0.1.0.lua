local unlocks = {
  ["logistics"] = "mdrn-loader",
  ["logistics-2"] = "fast-mdrn-loader",
  ["logistics-3"] = "express-mdrn-loader",
  ["tungsten-transport-belt"] = "tungsten-mdrn-loader"
}

for tech, recipe in pairs(unlocks) do
  for _, force in pairs(game.forces) do
    if force.technologies[tech] ~= nil and force.technologies[tech].researched then
      force.recipes[recipe].enabled = true
    end
  end
end
