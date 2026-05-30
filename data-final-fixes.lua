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

if cfg.lu_migration then
  local lu_prefix_combos = {
    "lf-", "fs-", "rl-",
    "lf-fs-", "lf-rl-", "fs-rl-",
    "lf-fs-rl-",
  }
  for name, entity in pairs(data.raw["loader-1x1"]) do
    if string.find(name, C.LOADER_PATTERN) then
      for _, prefix in ipairs(lu_prefix_combos) do
        local dummy_name = prefix .. name
        if not data.raw["loader-1x1"][dummy_name] then
          local dummy                      = table.deepcopy(entity)
          dummy.name                       = dummy_name
          dummy.hidden                     = true
          dummy.hidden_in_factoriopedia    = true
          dummy.next_upgrade               = nil
          dummy.factoriopedia_alternative  = name
          dummy.deconstruction_alternative = name
          data:extend{dummy}
        end
      end
    end
  end
end

local aai_fr = settings.startup[C.SETTINGS.AAI_FAST_REPLACE]
if cfg.has_aai_loaders and aai_fr and aai_fr.value then
  for _, entity in pairs(data.raw["loader-1x1"]) do
    if string.match(entity.name, "^aai%-") then
      entity.fast_replaceable_group = "mdrn-loader"
    end
  end
end
