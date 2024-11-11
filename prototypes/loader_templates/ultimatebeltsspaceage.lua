-- Ultimate Belts Space Age!
if not mods["UltimateBeltsSpaceAge"] then
  return false
end

---@type table<string, LMLoaderTemplate>
local loader_templates = {
  ["ultra-fast-"] = {
    --previous_prefix = space and "turbo" or "express-",
    --Ultimate belts move on passes express and ignore Space Age! Turbo belts
    previous_prefix = "express-",
    next_prefix = "extreme-fast-",
    tint = util.color("00ac08d1"),
    prerequisite_techs = {
      "ultra-fast-logistics",
      --space and "turbo-mdrn-loader" or "express-mdrn-loader"
      "express-mdrn-loader"
    },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "ultra-fast-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 3},
          {
            type = "item",
            --name = space and "turbo-mdrn-loader" or "express-mdrn-loader",
            name = "express-mdrn-loader",
            amount = 1
          },
        },
        stack = {
          {type = "item", name = "ultra-fast-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 6},
          {
            type = "item",
            --name = space and "turbo-mdrn-loader" or "express-mdrn-loader",
            name = "express-mdrn-loader",
            amount = 1
          },
        }
      }
    }
  },
  ["extreme-fast-"] = {
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
  },
  ["ultra-express-"] = {
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
  },
  ["extreme-express-"] = {
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
  },
  ["original-ultimate-"] = {
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
  },
}

-- Ultimate Belts progress from Express to Ultra-fast and skip turbo
---@diagnostic disable-next-line: missing-fields
loader_templates["express-"] = {
  next_prefix = "ultra-fast-"
}

return loader_templates