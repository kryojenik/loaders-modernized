local C   = require("__loaders-modernized__.constants")
local cfg = require("__loaders-modernized__.prototypes.settings-cache")

if cfg.embiggen_assemblers == C.EMBIGGEN.ZERO then
  return
end

local multiplier = {
  [C.EMBIGGEN.EIGHT]    = 1.08,
  [C.EMBIGGEN.SIXTEEN]  = 1.16,
}

for _, prototype in pairs(data.raw["assembling-machine"]) do
  if string.find(prototype.name, "assembling%-machine") then
    for _, layer in pairs(prototype.graphics_set.animation.layers) do
      layer.scale = (layer.scale or 1) * multiplier[cfg.embiggen_assemblers]
    end
  end
end
