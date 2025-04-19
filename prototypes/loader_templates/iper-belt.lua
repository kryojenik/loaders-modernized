if not mods["iper-belt"] then
  return false
end

--local startup_settings = settings.startup

local blacklist = {}

---@type table<string, LMLoaderTemplate>
local loader_templates = {
  ["iper-"] = {
    order = "d-iper",
    tint = util.color("4a5ad2d1"),
    prerequisite_techs = { "iper-transport-belts", "express-mdrn-loader" },
    recipe_data = {
      ingredients = {
        standard = {
          {type = "item", name = "iper-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 3},
          {type = "item", name = "express-mdrn-loader", amount = 1},
        },
        stack = {
          {type = "item", name = "iper-underground-belt", amount = 1},
          {type = "item", name = "bulk-inserter", amount = 6},
          {type = "item", name = "express-mdrn-loader", amount = 1},
        }
      }
    }
  },
}

-- Iper belts upgrade from Express and skip turbo
---@diagnostic disable-next-line: missing-fields
loader_templates["express-"] = {
  next_upgrade = "iper-mdrn-loader"
}
if settings.startup["mdrn-enable-stacking"].value == "stack-tier" then
  loader_templates["iper-"].next_upgrade = "stack-mdrn-loader"
end

loader_templates.blacklist = blacklist
return loader_templates
