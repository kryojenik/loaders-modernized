if not mods["aai-industry"] then
  return false
end

local loader_templates = {
  [""] = {
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "transport-belt", amount = 1},
          {type = "item", name = "iron-gear-wheel", amount = 10},
          {type = "item", name = "electronic-circuit", amount = 5}
        },
        stack = {
          {type = "item", name = "transport-belt", amount = 1},
          {type = "item", name = "iron-gear-wheel", amount = 20},
          {type = "item", name = "electronic-circuit", amount = 10}
        }
      }
    }
  },
  ["fast-"] = {
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "mdrn-loader", amount = 1},
          {type = "item", name = "electric-motor", amount = 5},
          {type = "item", name = "advanced-circuit", amount = 5}
        },
        stack = {
          {type = "item", name = "mdrn-loader", amount = 1},
          {type = "item", name = "electric-motor", amount = 10},
          {type = "item", name = "advanced-circuit", amount = 10}
        }
      }
    }
  },
  ["express-"] = {
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "fast-mdrn-loader", amount = 1},
          {type = "item", name = "electric-engine-unit", amount = 5},
          {type = "item", name = "processing-unit", amount = 5},
          {type = "fluid", name = "lubricant", amount = 50}
        },
        stack = {
          {type = "item", name = "fast-mdrn-loader", amount = 1},
          {type = "item", name = "electric-engine-unit", amount = 10},
          {type = "item", name = "processing-unit", amount = 10},
          {type = "fluid", name = "lubricant", amount = 100}
        }
      }
    }
  },
}

if mods["space-age"] then
  loader_templates["turbo-"] = {
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "express-mdrn-loader", amount = 1},
          {type = "item", name = "tungsten-plate", amount = 30},
          {type = "item", name = "processing-unit", amount = 5},
          {type = "fluid", name = "lubricant", amount = 50}
        },
        stack = {
          {type = "item", name = "express-mdrn-loader", amount = 1},
          {type = "item", name = "tungsten-plate", amount = 60},
          {type = "item", name = "processing-unit", amount = 10},
          {type = "fluid", name = "lubricant", amount = 100}
        }
      }
    }
  }
end

return loader_templates