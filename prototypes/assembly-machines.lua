if settings.startup["mdrn-embiggen-assemblers"].value then
  for _, prototype in pairs(data.raw["assembling-machine"]) do
    if string.find(prototype.name, "assembling%-machine") then
      for _, layer in pairs(prototype.graphics_set.animation.layers) do
        layer.scale = (layer.scale or 1) * 1.15
      end
    end
  end
end
