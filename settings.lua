data:extend({
  -- STARTUP SETTINGS
  {
    type = "bool-setting",
    name = "mdrn-use-electricity",
    order = "sa",
    setting_type = "startup",
    default_value = true,
  },
  {
    type = "bool-setting",
    name = "mdrn-oplp",
    order = "saa",
    setting_type = "startup",
    default_value = false,
  },
  {
    type = "string-setting",
    name = "mdrn-chute-mode",
    order = "sb",
    setting_type = "startup",
    default_value = "basic",
    allowed_values = { "none", "basic", "filtered" },
  },
  {
    type = "string-setting",
    name = "mdrn-chute-direction",
    order = "sba",
    setting_type = "runtime-global",
    default_value = "input",
    allowed_values = { "input", "input-output" },
  },
  {
    type = "bool-setting",
    name = "mdrn-double-recipe",
    order = "sd",
    setting_type = "startup",
    default_value = false,
  },
  {
    type = "string-setting",
    name = "mdrn-unlock-technology",
    order = "sc",
    setting_type = "startup",
    default_value = "separate",
    allowed_values = { "separate", "belt" }
  },
  {
    type = "string-setting",
    name = "mdrn-embiggen-assemblers",
    order = "sg",
    setting_type = "startup",
    default_value = "zero",
    allowed_values = { "zero", "eight", "sixteen" },
  },
  {
    type = "bool-setting",
    name = "mdrn-default-respect-insert-limits",
    order = "sfb",
    setting_type = "runtime-global",
    default_value = true,
  },
})

-- If the AAI Loaders mod is found, assume the player wants to use the AAI graphics
-- with this mod providing the entities.  This can be disabled to allow both mods to provide
-- loaders, but that seems like the non-typical use case.
if mods["aai-loaders"] then
  data:extend({
    {
      type = "bool-setting",
      name = "mdrn-use-aai-graphics",
      order = "sx",
      setting_type = "startup",
      default_value = true,
    },
  })
end

if mods["aai-industry"] then
  data:extend({
    {
      type = "bool-setting",
      name = "mdrn-use-aai-recipes",
      order = "sy",
      setting_type = "startup",
      default_value = true,
    }
  })
end

-- Belt stacking settings (stacking is possible with Space Age, Stack Inserters, or pycoalprocessing)
data:extend({
  {
    type = "string-setting",
    name = "mdrn-enable-stacking",
    order = "se",
    setting_type = "startup",
    default_value = "stack-tier",
    allowed_values = { "none", "turbo-and-above", "all", "stack-tier" }
  },
  {
    type = "bool-setting",
    name = "mdrn-cheap-stacking",
    order = "sea",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "mdrn-default-wait-for-full-stack",
    order = "sfc",
    setting_type = "runtime-global",
    default_value = false,
  },
})

  -- Legacy settings that have been replaced by global values, but we need to read them on migration to convert to the new format.
data:extend({
  {
    type = "bool-setting",
    name = "mdrn-wait-for-full-stack",
    order = "sfb",
    setting_type = "startup",
    default_value = false,
    hidden = true,
  },
  {
    type = "bool-setting",
    name = "mdrn-respect-insert-limits",
    order = "sf",
    setting_type = "startup",
    default_value = true,
    hidden = true,
  },
})

local stacking = data.raw["string-setting"]["mdrn-enable-stacking"]
if not feature_flags.space_travel then
  stacking.allowed_values = { "none" }
  stacking.default_value = "none"
  stacking.hidden = true

  local cheap_stack = data.raw["bool-setting"]["mdrn-cheap-stacking"]
  cheap_stack.forced_value = false
  cheap_stack.hidden = true
  local default_wfs = data.raw["bool-setting"]["mdrn-default-wait-for-full-stack"]
  default_wfs.hidden = true

  -- Mods known to provide a stack inserter
elseif not (mods["space-age"]
  or mods["stack-inserters"]
  or mods["pycoalprocessing"]) then
  stacking.allowed_values = { "none", "all" }
  stacking.default_value = "none"
end
