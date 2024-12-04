-- Ultimate Belts Space Age adjusts logistics-3 tech cost in data-updates.
-- Adjust to unlock at same science tier
if mods["UltimateBeltsSpaceAge"] and not mods["5dim_transport"] then
  data.raw["technology"]["express-mdrn-loader"].unit = data.raw["technology"]["logistics-3"].unit
end

-- Schall Belt Configuration makes belt speed changes in data_updates
if mods["SchallBeltConfiguration"] then
  local tiers = {"","fast-","express-"}
  if mods["space-age"] then
    tiers[#tiers+1] = "turbo-"
  end

  for _, tier in pairs(tiers) do
  data.raw["loader-1x1"][tier .. "mdrn-loader"].speed = data.raw["transport-belt"][tier .. "transport-belt"].speed
  end
end