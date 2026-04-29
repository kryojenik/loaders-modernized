-- Schall Belt Configuration makes belt speed changes in data_updates
if mods["SchallBeltConfiguration"] then
  local C    = require("__loaders-modernized__.constants")
  local cfg  = require("__loaders-modernized__.prototypes.settings-cache")
  local tiers = { "", "fast-", "express-" }
  if cfg.has_space_age then
    tiers[#tiers + 1] = "turbo-"
  end

  for _, tier in ipairs(tiers) do
    local belt_speed = data.raw["transport-belt"][tier .. "transport-belt"].speed
    local base_name  = C.LOADER_PREFIX .. tier .. C.LOADER_BASE
    for _, sfx in ipairs(C.VARIANT_SUFFIXES) do
      local e = data.raw["loader-1x1"][base_name .. sfx]
      if e then e.speed = belt_speed end
    end
  end
end
