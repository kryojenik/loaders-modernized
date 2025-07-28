if not mods["aai-industry"] then
  return
end

if settings.startup["mdrn-use-aai-recipes"].value == false then
  return
end

local templates = {}

---@type table<string, LMLoaderTemplate>
templates.loaders = {
  [""] = {
    recipe_data = {
      ingredients = {
        {type = "item", name = "transport-belt", amount = 1},
        {type = "item", name = "iron-gear-wheel", amount = 10},
        {type = "item", name = "electronic-circuit", amount = 5}
      },
      stack_ingredients = {
        {type = "item", name = "transport-belt", amount = 1},
        {type = "item", name = "iron-gear-wheel", amount = 20},
        {type = "item", name = "electronic-circuit", amount = 10}
      }
    }
  },
  ["fast-"] = {
    recipe_data = {
      ingredients = {
        {type = "item", name = "mdrn-loader", amount = 1},
        {type = "item", name = "electric-motor", amount = 5},
        {type = "item", name = "advanced-circuit", amount = 5}
      },
      stack_ingredients = {
        {type = "item", name = "mdrn-loader", amount = 1},
        {type = "item", name = "electric-motor", amount = 10},
        {type = "item", name = "advanced-circuit", amount = 10}
      }
    }
  },
  ["express-"] = {
    recipe_data = {
      ingredients = {
        {type = "item", name = "fast-mdrn-loader", amount = 1},
        {type = "item", name = "electric-engine-unit", amount = 5},
        {type = "item", name = "processing-unit", amount = 5},
        {type = "fluid", name = "lubricant", amount = 50}
      },
      stack_ingredients = {
        {type = "item", name = "fast-mdrn-loader", amount = 1},
        {type = "item", name = "electric-engine-unit", amount = 10},
        {type = "item", name = "processing-unit", amount = 10},
        {type = "fluid", name = "lubricant", amount = 100}
      }
    }
  },
}

if mods["space-age"] then
  templates.loaders["turbo-"] = {
    recipe_data = {
      ingredients = {
        {type = "item", name = "express-mdrn-loader", amount = 1},
        {type = "item", name = "tungsten-plate", amount = 30},
        {type = "item", name = "processing-unit", amount = 5},
        {type = "fluid", name = "lubricant", amount = 50}
      },
      stack_ingredients = {
        {type = "item", name = "express-mdrn-loader", amount = 1},
        {type = "item", name = "tungsten-plate", amount = 60},
        {type = "item", name = "processing-unit", amount = 10},
        {type = "fluid", name = "lubricant", amount = 100}
      }
    }
  }
end

MdrnLoaders.make_modern_loaders(templates)