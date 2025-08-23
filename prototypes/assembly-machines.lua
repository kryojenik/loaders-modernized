local embiggen = settings.startup["mdrn-embiggen-assemblers"].value
if embiggen == "zero" then
  return
end

local multiplier = {
  ["eight"] = 1.08,
  ["sixteen"] = 1.16
}

for _, prototype in pairs(data.raw["assembling-machine"]) do
  if string.find(prototype.name, "assembling%-machine") then
    for _, layer in pairs(prototype.graphics_set.animation.layers) do
      layer.scale = (layer.scale or 1) * multiplier[settings.startup["mdrn-embiggen-assemblers"].value]
    end
  end
end
