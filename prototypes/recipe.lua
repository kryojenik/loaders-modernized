data:extend({
  {
    type = "recipe",
    name = "mdrn-loader",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {type = "item", name = "underground-belt", amount = 1},
      {type = "item", name = "fast-inserter", amount = 6},
      {type = "item", name = "steel-plate", amount = 6},
    },
    results = {{type = "item", name = "mdrn-loader", amount = 1}}
  },
  {
    type = "recipe",
    name = "fast-mdrn-loader",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {type = "item", name = "fast-underground-belt", amount = 1},
      {type = "item", name = "fast-inserter", amount = 4},
      {type = "item", name = "mdrn-loader", amount = 1},
    },
    results = {{type = "item", name = "fast-mdrn-loader", amount = 1}}
  },
  -- TODO: Consider requiring lube for express
  {
    type = "recipe",
    name = "express-mdrn-loader",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {type = "item", name = "express-underground-belt", amount = 1},
      {type = "item", name = "bulk-inserter", amount = 2},
      {type = "item", name = "fast-mdrn-loader", amount = 1},
    },
    results = {{type = "item", name = "express-mdrn-loader", amount = 1}}
  },
  -- space-age
  {
    type = "recipe",
    name = "tungsten-mdrn-loader",
    energy_required = 2,
    category = "metallurgy",
    surface_conditions =
    {
      {
        property = "pressure",
        min = 4000,
        max = 4000
      }
    },
    enabled = false,
    ingredients =
    {
      {type = "item", name = "tungsten-underground-belt", amount = 1},
      {type = "item", name = "stack-inserter", amount = 4},
      {type = "item", name = "express-mdrn-loader", amount = 1},
    },
    results = {{type = "item", name = "tungsten-mdrn-loader", amount = 1}}
  }
})