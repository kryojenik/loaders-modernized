-- Ensure the ev-logistics mod is active
if not mods["ev-logistics"] then
    return false
end

-- Define the loader template for the tier 5 turbo belt
local loader_templates = {
    ["hyper-"] = {
        tint = util.color("800080d1"),                               -- Purple tint for hyper tier
        prerequisite_techs = { "hyper-logistics", "turbo-mdrn-loader" }, -- Link to hyper-logistics technology
        recipe_data = {
            ingredients = {
                standard = {
                    { type = "item", name = "hyper-underground-belt", amount = 1 },
                    { type = "item", name = "turbo-mdrn-loader",      amount = 1 },
                    { type = "item", name = "bulk-inserter",          amount = 16 }
                }
            }
        }
    }
}

return loader_templates
