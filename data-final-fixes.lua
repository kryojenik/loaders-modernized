local C   = require("__loaders-modernized__.constants")
local cfg = require("__loaders-modernized__.prototypes.settings-cache")

-- Make sure the stack loader tier runs at the fastest belt speed
local stack_name = C.LOADER_PREFIX .. "stack-" .. C.LOADER_BASE
if cfg.stacking == C.STACKING.STACK_TIER
and data.raw["loader-1x1"][stack_name] then
  local fastest_belt = 0
  for _, ug in pairs(data.raw["underground-belt"]) do
    if ug.speed > fastest_belt then fastest_belt = ug.speed end
  end

  for _, sfx in ipairs(C.VARIANT_SUFFIXES) do
    local e = data.raw["loader-1x1"][stack_name .. sfx]
    if e then e.speed = fastest_belt end
  end
end

local aai_fr = settings.startup[C.SETTINGS.AAI_FAST_REPLACE]
if cfg.has_aai_loaders and aai_fr and aai_fr.value then
  for _, entity in pairs(data.raw["loader-1x1"]) do
    if entity.name:match("^aai%-") then
      entity.fast_replaceable_group = "mdrn-loader"
    end
  end
end
