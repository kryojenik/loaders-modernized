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
    name = "mdrn-double-recipe",
    order = "sb",
    setting_type = "startup",
    default_value = false,
  },
  {
    type = "bool-setting",
    name = "mdrn-migrate-from-miniloaders",
    order = "sc",
    setting_type = "startup",
    default_value = false,
  },
  {
    type = "bool-setting",
    name = "mdrn-enable-chute",
    order = "sd",
    setting_type = "startup",
    default_value = true,
  }
})
