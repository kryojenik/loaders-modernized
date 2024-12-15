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
    name = "mdrn-enable-chute",
    order = "sb",
    setting_type = "startup",
    default_value = true,
  },
  {
    type = "bool-setting",
    name = "mdrn-double-recipe",
    order = "sd",
    setting_type = "startup",
    default_value = false,
  },
  {
    type = "bool-setting",
    name = "mdrn-migrate-from-miniloaders",
    order = "sz",
    setting_type = "startup",
    default_value = false,
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
    },
  })
end

-- If space-age is enabled we can do belt_stacking
-- TODO: Can stacking be done on 2.0 without the DLC being purchased?
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
  })

if not mods["space-age"] then
  local stacking = data.raw["string-setting"]["mdrn-enable-stacking"]
  stacking.default_value = "none"
  stacking.allowed_values = { "none" }
  stacking.hidden = true

  local cost = data.raw["bool-setting"]["mdrn-cheap-stacking"]
  cost.forced_value = false
  cost.hidden = true
end

-- Settings if 5Dim's New Transport is loaded
if mods["5dim_transport"] then
  data:extend({
    {
      type = "string-setting",
      name = "mdrn-keep-5d-loaders",
      order = "sg",
      setting_type = "startup",
      default_value = "none",
      allowed_values = {"none", "1x2", "all"}
    },
  })
  if mods["space-age"] then
    data:extend({
      {
        type = "bool-setting",
        name = "mdrn-keep-turbo-loader",
        order = "sga",
        setting_type = "startup",
        default_value = false
      },
    })
  end
end
