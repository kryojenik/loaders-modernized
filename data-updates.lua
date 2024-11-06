-- If prismatic-belst is installed, adjust the belt-animation-sets
--[[
if mods["prismatic-belts"] then
  for name, proto in pairs(data.raw["loader-1x1"]) do
    local a, _, prefix = string.find(name, "^([%a%-]*)mdrn%-loader")
    if a then
      if prefix ~= "chute-" then
        data.raw["loader-1x1"][name].belt_animation_set = data.raw["underground-belt"][prefix .. "underground-belt"].belt_animation_set
      end
    end
  end
end
]]