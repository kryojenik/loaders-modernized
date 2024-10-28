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
    order = "sc",
    setting_type = "startup",
    default_value = false,
  },
  {
    type = "string-setting",
    name = "mdrn-enable-stacking",
    order = "sd",
    setting_type = "startup",
    default_value = "none",
    allowed_values = { "none", "turbo-and-above", "all" }
  },
  {
    type = "bool-setting",
    name = "mdrn-migrate-from-miniloaders",
    order = "se",
    setting_type = "startup",
    default_value = false,
  },
})
