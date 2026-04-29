local C   = require("__loaders-modernized__.constants")
local cfg = require("__loaders-modernized__.prototypes.settings-cache")

---@type table<string, LMLoaderTemplate>
local loaders = {
  [""] = {
    next_upgrade = "mdrn-fast-loader",
    order = "01",
    tint = util.color("ffd955d1"),
    prerequisite_techs = { "logistics" },
    recipe_data = {
      ingredients = {
        { type = "item", name = "underground-belt", amount = 1 },
        { type = "item", name = "inserter", amount = 8 },
        { type = "item", name = "steel-plate", amount = 6 },
      },
    }
  },
  ["fast-"] = {
    next_upgrade = "mdrn-express-loader",
    order = "02",
    tint = util.color("ff1838d1"),
    prerequisite_techs = { "logistics-2", "mdrn-loader", "fast-inserter" },
    recipe_data = {
      ingredients = {
        { type = "item", name = "fast-underground-belt", amount = 1 },
        { type = "item", name = "fast-inserter", amount = 4 },
        { type = "item", name = "mdrn-loader", amount = 1 },
      },
    }
  },
  ["express-"] = {
    order = "03",
    tint = util.color("5abeffd1"),
    prerequisite_techs = { "logistics-3", "mdrn-fast-loader", "bulk-inserter" },
    recipe_data = {
      ingredients = {
        { type = "item", name = "express-underground-belt", amount = 1 },
        { type = "item", name = "bulk-inserter", amount = 2 },
        { type = "item", name = "mdrn-fast-loader", amount = 1 },
      },
    }
  }
}

-- Chute
if cfg.chute_mode ~= C.CHUTE.NONE then
  loaders["chute-"] = {
    stacking = false,
    filter = cfg.chute_mode == C.CHUTE.FILTERED,
    tech_data = false,
    localised_description = { "entity-description.mdrn-chute-loader" },
    energy_type = "void",
    energy_drain = "0kW",
    energy_per_item = ".0000001J",
    next_upgrade = "mdrn-loader",
    order = "00",
    underground_name = "underground-belt",
    speed_multiplier = .5,
    tint = util.color("808080d1"),
    recipe_data = {
      enabled = true,
      ingredients = {
        { type = "item", name = "iron-plate", amount = 4 },
      }
    }
  }
end

-- Space Age!
if cfg.has_space_age then
  loaders["turbo-"] = {
    order = "04",
    tint = util.color("9bb600d1"),
    upgrade_from_tier = "express-",
    prerequisite_techs = { "turbo-transport-belt", "mdrn-express-loader" },
    recipe_data = {
      surface_conditions = data.raw["recipe"]["turbo-underground-belt"].surface_conditions,
      ingredients = {
        { type = "item", name = "turbo-underground-belt", amount = 1 },
        { type = "item", name = "bulk-inserter", amount = 6 },
        { type = "item", name = "mdrn-express-loader", amount = 1 },
      },
    }
  }
end

-- Separate stack tier
if cfg.stacking == C.STACKING.STACK_TIER
and data.raw["inserter"]["stack-inserter"] then
  local fast_loader_tech = data.raw["technology"]["aai-fast-loader"] and "aai-fast-loader" or "mdrn-fast-loader"
  loaders["stack-"] = {
    order = "99",
    tint = util.color("f5f5f5d1"),
    underground_name = "turbo-underground-belt",
    prerequisite_techs = { "stack-inserter", fast_loader_tech },
    max_belt_stack_size = data.raw["utility-constants"].default.max_belt_stack_size,
    recipe_data = {
      ingredients = {
        { type = "item", name = "processing-unit", amount = 1 },
        { type = "item", name = "stack-inserter", amount = 6 },
        { type = "item", name = "mdrn-fast-loader", amount = 1 },
      }
    }
  }

  -- Wire the stack tier into the upgrade chain. Space Age: turbo → stack.
  -- Without Space Age, turbo-underground-belt may not exist, so express → stack.
  if cfg.has_space_age then
    loaders["turbo-"].next_upgrade = "mdrn-stack-loader"
  else
    loaders["stack-"].underground_name = "express-underground-belt"
    loaders["express-"].next_upgrade = "mdrn-stack-loader"
  end
end

MdrnLoaders.add_loaders(loaders)
