local meld = require("meld")

---@class LMRecipeData
---@field surface_conditions? SurfaceCondition[]
---@field ingredients? table<string, Ingredient[]>
---@field energy_required? double
---@field category? string

---@class LMLoaderTemplate
---@field next_upgrade? string
---@field tint? Color
---@field prerequisite_techs? TechnologyID[]
---@field recipe_data LMRecipeData
---@field name? string
---@field underground_name? string
---@field unlocked_by? string
---@field group? string
---@field subgroup? string
---@field order? string


local loader_templates = require("base")

-- Ultimate Belts Space Age!
local addon = require("ultimatebeltsspaceage")
if addon then
  meld.meld(loader_templates, addon)
end

-- 5 Dim New Transport
addon = require("5DimNewTransport")
if addon then
  meld.meld(loader_templates, addon)
  loader_templates[""] = nil
  loader_templates["fast-"] = nil
  loader_templates["express-"] = nil
  loader_templates["turbo-"] = nil
  if settings.startup["mdrn-enable-chute"].value then
    loader_templates["chute-"].group = "transport"
    loader_templates["chute-"].subgroup = "transport-misc"
    loader_templates["chute-"].order = "z"
    loader_templates["chute-"].next_upgrade = "mdrn-loader-01"
  end
end

return loader_templates