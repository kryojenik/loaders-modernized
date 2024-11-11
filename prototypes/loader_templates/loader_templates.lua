local meld = require("meld")

---@class LMRecipeData
---@field surface_conditions? SurfaceCondition[]
---@field ingredients? table<string, Ingredient[]>
---@field energy_required? double
---@field category? string

---@class LMLoaderTemplate
---@field previous_prefix? string
---@field next_prefix? string
---@field tint? Color
---@field prerequisite_techs? TechnologyID[]
---@field recipe_data LMRecipeData
---@field name? string
---@field underground_name? string
---@field unlocked_by? string


local loader_templates = require("base")

-- Ultimate Belts Space Age!
local addon = require("ultimatebeltsspaceage")
if addon then
  meld.meld(loader_templates, addon)
end

return loader_templates