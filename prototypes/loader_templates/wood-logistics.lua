if not mods["wood-logistics"] then
  return false
end

log("\nWood Logistics found, implement additional loaders.")
---@type table<string, LMLoaderTemplate>
local loader_templates = {}
local startup_settings = settings.startup
local blacklist = {
  ["below_turbo"] = {
    ["wood-"] = true
  },
  ["filter"] = {
    ["wood-"] = true
  }
}

loader_templates["wood-"] = {
  tint = util.color("a47f6de1"),
  prerequisite_techs = {"wood-logistics"},
  underground_name = "wood-underground-belt",
  next_upgrade = "mdrn-loader",
  order = "a-wood",
  recipe_data = {
    ingredients = {
      standard = {
        {type = "item", name = "wood-underground-belt", amount = 1},
        {type = "item", name = "inserter", amount = 2},
        {type = "item", name = "lumber", amount = 2}
      },
    }
  }
}

if startup_settings["mdrn-enable-chute"].value then
  loader_templates["chute-"] = {
    next_upgrade = "wood-mdrn-loader",
    underground_name = "wood-underground-belt"
  }

  loader_templates[""] = {
    prerequisite_techs = { "logistics", "wood-mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          { type = "item", name = "underground-belt", amount = 1 },
          { type = "item", name = "inserter", amount = 6 },
          { type = "item", name = "steel-plate", amount = 4 },
          { type = "item", name = "wood-mdrn-loader", amount = 1 },
        },
        stack = {
          { type = "item", name = "underground-belt", amount = 1 },
          { type = "item", name = "inserter", amount = 10 },
          { type = "item", name = "steel-plate", amount = 4 },
          { type = "item", name = "wood-mdrn-loader", amount = 1 },
        }
      }
    }
  }
end

loader_templates.blacklist = blacklist
return loader_templates
