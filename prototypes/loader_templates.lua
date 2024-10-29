local loader_templates = {
  [""] = {
    next_prefix = "fast-",
    tint = util.color("ffd955d1"),
    prerequisite_techs = { "logistics" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "underground-belt", amount = 1},
          {type = "item", name = "inserter", amount = 8},
          {type = "item", name = "steel-plate", amount = 6},
        },
        stack = {
          {type = "item", name = "underground-belt", amount = 1},
          {type = "item", name = "inserter", amount = 12},
          {type = "item", name = "steel-plate", amount = 6},
        }
      }
    }
  },
  ["fast-"] = {
    previous_prefix = "",
    next_prefix = "express-",
    tint = util.color("ff1838d1"),
    prerequisite_techs = { "logistics-2", "mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "fast-underground-belt", amount = 1},
          {type = "item", name = "fast-inserter", amount = 4},
          {type = "item", name = "mdrn-loader", amount = 1},
        },
        stack = {
          {type = "item", name = "fast-underground-belt", amount = 1},
          {type = "item", name = "fast-inserter", amount = 6},
          {type = "item", name = "mdrn-loader", amount = 1},
        }
      }
    }
  },
  ["express-"] = {
    previous_prefix = "fast-",
    tint = util.color("5abeffd1"),
    prerequisite_techs = { "logistics-3", "fast-mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "express-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 2},
          {type = "item", name = "fast-mdrn-loader", amount = 1},
        },
        stack = {
          {type = "item", name = "express-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 4},
          {type = "item", name = "fast-mdrn-loader", amount = 1},
        }
      }
    }
  }
}

-- chute
if settings.startup["mdrn-enable-chute"].value then
  loader_templates["chute-"] = {
    next_prefix = "",
    tint = util.color("808080d1"),
    recipe_data = {
      ingredients = {
        -- Chutes will never stack
        standard = {
          {type = "item", name = "iron-plate", amount = 4},
        }
      }
    }
  }
end

-- space-age
if data.raw["transport-belt"]["turbo-transport-belt"] then
  loader_templates["turbo-"] = {
    previous_prefix = "express-",
    tint = util.color("9bb600d1"),
    prerequisite_techs = { "turbo-transport-belt", "express-mdrn-loader" },
    recipe_data = {
      surface_conditions = data.raw["transport-belt"]["turbo-transport-belt"].surface_conditions,
      ingredients = {
        standard = {
          {type = "item", name = "turbo-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 6},
          {type = "item", name = "express-mdrn-loader", amount = 1},
        },
        stack = {
          {type = "item", name = "turbo-underground-belt", amount = 1},
          {type = "item", name = "stack-inserter", amount = 4},
          {type = "item", name = "express-mdrn-loader", amount = 1},
        }
      }
    }
  }
  loader_templates["express-"].next_prefix = "turbo-"
end

return loader_templates