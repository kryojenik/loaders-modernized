local space = mods["space-age"]
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

-- UltimateBeltsSpaceAge
if mods["UltimateBeltsSpaceAge"] then
  loader_templates["ultra-fast-"] = {
    previous_prefix = space and "turbo" or "express-",
    next_prefix = "extreme-fast-",
    tint = util.color("00ac08d1"),
    prerequisite_techs = {
      "ultra-fast-logistics",
      space and "turbo-mdrn-loader" or "express-mdrn-loader"
    },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "ultra-fast-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 3},
          {
            type = "item",
            name = space and "turbo-mdrn-loader" or "express-mdrn-loader",
            amount = 1
          },
        },
        stack = {
          {type = "item", name = "ultra-fast-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 6},
          {
            type = "item",
            name = space and "turbo-mdrn-loader" or "express-mdrn-loader",
            amount = 1
          },
        }
      }
    }
  }

  loader_templates["extreme-fast-"] = {
    previous_prefix = "ultra-fast-",
    next_prefix = "ultra-express-",
    tint = util.color("db071fd1"),
    prerequisite_techs = { "extreme-fast-logistics", "ultra-fast-mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "extreme-fast-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 3},
          {
            type = "item",
            name = "ultra-fast-mdrn-loader",
            amount = 1
          },
        },
        stack = {
          {type = "item", name = "extreme-fast-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 6},
          {
            type = "item",
            name = "ultra-fast-mdrn-loader",
            amount = 1
          },
        }
      }
    }
  }

  loader_templates["ultra-express-"] = {
    previous_prefix = "extreme-fast-",
    next_prefix = "extreme-express-",
    tint = util.color("4a01d8d1"),
    prerequisite_techs = { "ultra-express-logistics", "extreme-fast-mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "ultra-express-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 3},
          {
            type = "item",
            name = "extreme-fast-mdrn-loader",
            amount = 1
          },
        },
        stack = {
          {type = "item", name = "ultra-express-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 6},
          {
            type = "item",
            name = "extreme-fast-mdrn-loader",
            amount = 1
          },
        }
      }
    }
  }

  loader_templates["extreme-express-"] = {
    previous_prefix = "ultra-express-",
    next_prefix = "original-ultimate-",
    tint = util.color("0620d6d1"),
    prerequisite_techs = { "extreme-express-logistics", "ultra-express-mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "extreme-express-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 3},
          {
            type = "item",
            name = "ultra-express-mdrn-loader",
            amount = 1
          },
        },
        stack = {
          {type = "item", name = "extreme-express-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 6},
          {
            type = "item",
            name = "ultra-express-mdrn-loader",
            amount = 1
          },
        }
      }
    }
  }

  loader_templates["original-ultimate-"] = {
    previous_prefix = "extreme-express-",
    tint = util.color("06d9c4d1"),
    prerequisite_techs = { "ultimate-logistics", "extreme-express-mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "original-ultimate-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 3},
          {
            type = "item",
            name = "extreme-express-mdrn-loader",
            amount = 1
          },
        },
        stack = {
          {type = "item", name = "original-ultimate-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 6},
          {
            type = "item",
            name = "extreme-express-mdrn-loader",
            amount = 1
          },
        }
      }
    }
  }

  if space then
    loader_templates["turbo-"].next_prefix = "ultra-fast-"
  else
    loader_templates["express-"].next_prefix = "ultra-fast-"
  end
end

return loader_templates