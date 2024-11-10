-- Ultimate Belts Space Age adjusts logistics-3 tech cost in data-updates.
-- Adjust to unlock at same science tier
if mods["UltimateBeltsSpaceAge"] then
  data.raw["technology"]["express-mdrn-loader"].unit = data.raw["technology"]["logistics-3"].unit
end