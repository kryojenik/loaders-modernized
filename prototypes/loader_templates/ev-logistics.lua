-- Ensure the ev-logistics mod is active
if not mods["ev-logistics"] then
    return false
end

-- Define the loader template for the tier 5 turbo belt
local loader_templates = {
  ["hyper-"] = {
    tint = util.color("8c48dbd1"),                               -- Purple tint for hyper tier
    prerequisite_techs = { "hyper-logistics", "turbo-mdrn-loader" }, -- Link to hyper-logistics technology
    recipe_data = {
      ingredients = {
        standard = {
          { type = "item", name = "hyper-underground-belt", amount = 1 },
          { type = "item", name = "turbo-mdrn-loader",      amount = 1 },
          { type = "item", name = "bulk-inserter",          amount = 3 }
        },
        stack = {
          { type = "item", name = "hyper-underground-belt", amount = 1 },
          { type = "item", name = "turbo-mdrn-loader",      amount = 1 },
          { type = "item", name = "bulk-inserter",          amount = 6 }
        }
      }
    }
  }
}

-- Upgrade the turbo-loader to hyper-loader
loader_templates["turbo-"] = {
  next_upgrade = "hyper-mdrn-loader"
}
if settings.startup["mdrn-enable-stacking"].value == "stack-tier" then
  loader_templates["hyper-"].next_upgrade = "stack-mdrn-loader"
end

return loader_templates
