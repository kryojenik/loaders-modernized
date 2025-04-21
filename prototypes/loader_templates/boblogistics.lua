if not mods["boblogistics"] then
  return false
end

log("\nBob Logistics found, implement additional loaders.")
---@type table<string, LMLoaderTemplate>
local loader_templates = {}

if settings.startup["bobmods-logistics-beltoverhaul"].value == true then
  loader_templates["basic-"] = {
    next_upgrade = "mdrn-loader",
    underground_name = "bob-basic-underground-belt",
    tint = util.color("808080d1"),
    subgroup = "bob-logistic-tier-0",
    order = "f[loader]-1[basic-mdrn-loader]",
    prerequisite_techs = {"logistics-0"},
    unit = {
      count = 10,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
      },
      time = 20,
    },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "bob-basic-underground-belt", amount = 1},
          {type = "item", name = "burner-inserter", amount = 3}
        },
        stack = {
          {type = "item", name = "bob-basic-underground-belt", amount = 1},
          {type = "item", name = "burner-inserter", amount = 6}
        }
      }
    }
  }

  ---@diagnostic disable-next-line: missing-fields
  loader_templates["chute-"] = {
    next_upgrade = "basic-mdrn-loader",
    tint = util.color("000000d1")
  }

  loader_templates[""] = {
    subgroup = "bob-logistic-tier-1",
    order = "f[loader]-1[mdrn-loader]",
    prerequisite_techs = {"logistics", "basic-mdrn-loader"},
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "underground-belt", amount = 1},
          {type = "item", name = "inserter", amount = 6},
          {type = "item", name = "basic-mdrn-loader", amount = 1}
        },
        stack = {
          {type = "item", name = "underground-belt", amount = 1},
          {type = "item", name = "inserter", amount = 8},
          {type = "item", name = "basic-mdrn-loader", amount = 6}
        }
      }
    }
  }
end

loader_templates["ultimate-"] = {
  tint = util.color("26d160e1"),
  prerequisite_techs = {"logistics-5", "turbo-mdrn-loader"},
  underground_name = "bob-ultimate-underground-belt",
  subgroup = "bob-logistic-tier-5",
  order = "f[loader]-1[ultimate-mdrn-loader]",
  recipe_data = {
    ingredients = {
      standard = {
        {type = "item", name = "bob-ultimate-underground-belt", amount = 1},
        {type = "item", name = "bob-express-inserter", amount = 6},
        {type = "item", name = "turbo-mdrn-loader", amount = 1}
      },
      stack = {
        {type = "item", name = "bob-ultimate-underground-belt", amount = 1},
        {type = "item", name = "bob-express-bulk-inserter", amount = 8},
        {type = "item", name = "turbo-mdrn-loader", amount = 1}
      }
    }
  }
}

loader_templates["fast-"] = {
  subgroup = "bob-logistic-tier-2",
  order = "f[loader]-1[fast-mdrn-loader]",
  recipe_data = {
    surface_conditions = data.raw["recipe"]["fast-underground-belt"].surface_conditions,
    ingredients = {
      standard = {
        {type = "item", name = "fast-underground-belt", amount = 1},
        {type = "item", name = "long-handed-inserter", amount = 6},
        {type = "item", name = "mdrn-loader", amount = 1}
      },
      stack = {
        {type = "item", name = "fast-underground-belt", amount = 1},
        {type = "item", name = "bob-red-bulk-inserter", amount = 8},
        {type = "item", name = "mdrn-loader", amount = 1}
      }
    }
  }
}
loader_templates["express-"] = {
  next_upgrade = "turbo-mdrn-loader",
  subgroup = "bob-logistic-tier-3",
  order = "f[loader]-1[express-mdrn-loader]",
  recipe_data = {
    surface_conditions = data.raw["recipe"]["express-underground-belt"].surface_conditions,
    ingredients = {
      standard = {
        {type = "item", name = "express-underground-belt", amount = 1},
        {type = "item", name = "fast-inserter", amount = 6},
        {type = "item", name = "fast-mdrn-loader", amount = 1}
      },
      stack = {
        {type = "item", name = "express-underground-belt", amount = 1},
        {type = "item", name = "bulk-inserter", amount = 8},
        {type = "item", name = "fast-mdrn-loader", amount = 1}
      }
    }
  }
}
loader_templates["turbo-"] = {
  next_upgrade = "ultimate-mdrn-loader",
  subgroup = "bob-logistic-tier-4",
  order = "f[loader]-1[turbo-mdrn-loader]",
  underground_name = "bob-turbo-underground-belt",
  tint = util.color("9926d3e1"),
  prerequisite_techs = { "logistics-4", "express-mdrn-loader" },
  recipe_data = {
    surface_conditions = data.raw["recipe"]["bob-turbo-underground-belt"].surface_conditions,
    ingredients = {
      standard = {
        {type = "item", name = "bob-turbo-underground-belt", amount = 1},
        {type = "item", name = "bob-turbo-inserter", amount = 6},
        {type = "item", name = "express-mdrn-loader", amount = 1}
      },
      stack = {
        {type = "item", name = "bob-turbo-underground-belt", amount = 1},
        {type = "item", name = "bob-turbo-bulk-inserter", amount = 8},
        {type = "item", name = "express-mdrn-loader", amount = 1}
      }
    }
  }
}
-- Express loader can upgrade to the turbo loader
loader_templates["express-"].next_upgrade = "turbo-mdrn-loader"

return loader_templates
