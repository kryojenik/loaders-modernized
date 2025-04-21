local startup_settings = settings.startup

local blacklist = {
  ["filter"] = {
    ["chute-"] = true
  },
  ["split"] = {
    ["chute-"] = true
  },
  ["below_turbo"] = {
    ["chute-"] = true,
    [""] = true,
    ["fast-"] = true,
    ["express-"] = true
  }
}
---@type table<string, LMLoaderTemplate>
local loader_templates = {
  [""] = {
    next_upgrade = "fast-mdrn-loader",
    order = "b",
    tint = util.color("ffd955d1"),
    prerequisite_techs = { "logistics" },
    recipe_data = {
      ingredients = {
        standard = {
          { type = "item", name = "underground-belt", amount = 1 },
          { type = "item", name = "inserter", amount = 8 },
          { type = "item", name = "steel-plate", amount = 6 },
        },
        stack = {
          { type = "item", name = "underground-belt", amount = 1 },
          { type = "item", name = "inserter", amount = 12 },
          { type = "item", name = "steel-plate", amount = 6 },
        }
      }
    }
  },
  ["fast-"] = {
    next_upgrade = "express-mdrn-loader",
    order = "c",
    tint = util.color("ff1838d1"),
    prerequisite_techs = { "logistics-2", "mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          { type = "item", name = "fast-underground-belt", amount = 1 },
          { type = "item", name = "fast-inserter", amount = 4 },
          { type = "item", name = "mdrn-loader", amount = 1 },
        },
        stack = {
          { type = "item", name = "fast-underground-belt", amount = 1 },
          { type = "item", name = "fast-inserter", amount = 6 },
          { type = "item", name = "mdrn-loader", amount = 1 },
        }
      }
    }
  },
  ["express-"] = {
    order = "d",
    tint = util.color("5abeffd1"),
    prerequisite_techs = { "logistics-3", "fast-mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          { type = "item", name = "express-underground-belt", amount = 1 },
          { type = "item", name = "bulk-inserter", amount = 2 },
          { type = "item", name = "fast-mdrn-loader", amount = 1 },
        },
        stack = {
          { type = "item", name = "express-underground-belt", amount = 1 },
          { type = "item", name = "bulk-inserter", amount = 4 },
          { type = "item", name = "fast-mdrn-loader", amount = 1 },
        }
      }
    }
  }
}

-- Chute
if startup_settings["mdrn-enable-chute"].value then
  loader_templates["chute-"] = {
    next_upgrade = "mdrn-loader",
    order = "a",
    underground_name = "underground-belt",
    tint = util.color("808080d1"),
    recipe_data = {
      ingredients = {
        -- This mod will not enable belt_stacking for chutes
        standard = {
          { type = "item", name = "iron-plate", amount = 4 },
        }
      }
    }
  }
end

local space_age = mods["space-age"]
-- Space Age!
if space_age then
  loader_templates["turbo-"] = {
    order = "e",
    tint = util.color("9bb600d1"),
    prerequisite_techs = { "turbo-transport-belt", "express-mdrn-loader" },
    recipe_data = {
      surface_conditions = data.raw["recipe"]["turbo-underground-belt"].surface_conditions,
      ingredients = {
        standard = {
          { type = "item", name = "turbo-underground-belt", amount = 1 },
          { type = "item", name = "bulk-inserter", amount = 6 },
          { type = "item", name = "express-mdrn-loader", amount = 1 },
        },
        stack = {
          { type = "item", name = "turbo-underground-belt", amount = 1 },
          { type = "item", name = "bulk-inserter", amount = 8 },
          { type = "item", name = "express-mdrn-loader", amount = 1 },
        },
      }
    }
  }

  -- Express loader can upgrade to the turbo loader
  loader_templates["express-"].next_upgrade = "turbo-mdrn-loader"
end

-- Separate stack tier
if startup_settings["mdrn-enable-stacking"].value == "stack-tier" then
  loader_templates["stack-"] = {
    order = "z",
    tint = util.color("f5f5f5d1"),
    underground_name = "turbo-underground-belt",
    prerequisite_techs = { "stack-inserter", "fast-mdrn-loader" },
    max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size,
    recipe_data = {
      ingredients = {
        standard = {
          { type = "item", name = "processing-unit", amount = 1 },
          { type = "item", name = "stack-inserter", amount = 4 },
          { type = "item", name = "fast-mdrn-loader", amount = 1 },
        }
      }
    }
  }

  if space_age then
    loader_templates["turbo-"].next_upgrade = "stack-mdrn-loader"
  else
    loader_templates["stack-"].underground_name = "express-underground-belt"
    loader_templates["express-"].next_upgrade = "stack-mdrn-loader"
  end
end

loader_templates.blacklist = blacklist
return loader_templates
