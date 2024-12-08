---@type table<string, LMLoaderTemplate>
local loader_templates = {
  [""] = {
    next_upgrade = "fast-mdrn-loader",
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
    next_upgrade = "express-mdrn-loader",
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

-- Chute
if settings.startup["mdrn-enable-chute"].value then
  loader_templates["chute-"] = {
    next_upgrade = "mdrn-loader",
    underground_name = "underground-belt",
    tint = util.color("808080d1"),
    recipe_data = {
      ingredients = {
        -- This mod will not enable belt_stacking for chutes
        standard = {
          {type = "item", name = "iron-plate", amount = 4},
        }
      }
    }
  }
end

-- Space Age!
if data.raw["transport-belt"]["turbo-transport-belt"] then
  loader_templates["turbo-"] = {
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
          {type = "item", name = "bulk-inserter", amount = 8},
          {type = "item", name = "express-mdrn-loader", amount = 1},
        }
      }
    }
  }
  loader_templates["express-"].next_upgrade = "turbo-mdrn-loader"
end

-- Stack Loader
if settings.startup["mdrn-enable-stack-loader"].value then
  loader_templates["stack-"] = {
    underground_name = "turbo-underground-belt",
    tint = util.color("f5f5f5d1"),
    prerequisite_techs = { "turbo-mdrn-loader", "stack-inserter" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "processing-unit", amount = 1},
          {type = "item", name = "stack-inserter", amount = 4},
          {type = "item", name = "turbo-mdrn-loader", amount = 1},
        },
        stack = {
          {type = "item", name = "processing-unit", amount = 1},
          {type = "item", name = "stack-inserter", amount = 4},
          {type = "item", name = "turbo-mdrn-loader", amount = 1},
        }
      }
    }
  }
  loader_templates["turbo-"].next_upgrade = "stack-mdrn-loader"
end


return loader_templates
