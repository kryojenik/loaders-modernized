local C                       = require("__loaders-modernized__.constants")
local cfg                     = require("__loaders-modernized__.prototypes.settings-cache")
local update_or_create_item       = require("__loaders-modernized__.prototypes.loader.item")
local update_or_create_recipe     = require("__loaders-modernized__.prototypes.loader.recipe")
local update_or_create_entity     = require("__loaders-modernized__.prototypes.loader.entity")
local update_or_create_technology = require("__loaders-modernized__.prototypes.loader.technology")

MdrnLoaders = MdrnLoaders or {}

---Add one or more loader tiers.
---
---Each key in `loaders` is the belt-speed tier prefix (e.g. `""` for yellow,
---`"fast-"` for red, `"express-"` for blue).  The value is an `LMLoaderTemplate`
---describing the tier.  The entity/item/recipe name is derived automatically as
---`C.LOADER_PREFIX .. tier .. C.LOADER_BASE` unless `template.name` is set
---explicitly.  The matching underground belt is `tier .. "underground-belt"` unless
---`template.underground_name` is overridden.
---
---Example (external mod usage):
---```lua
---local MdrnLoaders = MdrnLoaders or {}
---MdrnLoaders.add_loaders{
---  ["nuclear-"] = {
---    tint = util.color("00ff00d1"),
---    underground_name = "nuclear-underground-belt",
---    recipe_data = { ingredients = { … } },
---  },
---}
---```
---@param loaders table<string, LMLoaderTemplate>
function MdrnLoaders.add_loaders(loaders)
  if not next(loaders) then return end

  for tier, template in pairs(loaders) do
    template.name = template.name or C.LOADER_PREFIX .. tier .. C.LOADER_BASE
    template.underground_name = template.underground_name or tier .. "underground-belt"

    if template.above_express == nil then
      local express_ug = data.raw["underground-belt"]["express-underground-belt"]
      local my_ug      = data.raw["underground-belt"][template.underground_name]
      if express_ug and my_ug then
        template.above_express = my_ug.speed * (template.speed_multiplier or 1) > express_ug.speed
      else
        template.above_express = false
      end
    end

    if template.below_base == nil then
      local base_ug = data.raw["underground-belt"]["underground-belt"]
      local my_ug   = data.raw["underground-belt"][template.underground_name]
      if base_ug and my_ug then
        template.below_base = my_ug.speed * (template.speed_multiplier or 1) < base_ug.speed
      else
        template.below_base = false
      end
    end

    if template.below_base then
      template.stacking = false
      if cfg.chute_mode == C.CHUTE.BASIC then
        template.filter    = false
        template.fill_base = true
      elseif cfg.chute_mode == C.CHUTE.BASIC_LIMITED then
        template.filter = false
      elseif cfg.chute_mode == C.CHUTE.FILTERED then
        if template.filter ~= false then
          template.filter = true
        end
      end
    end

    update_or_create_item(template)
    update_or_create_recipe(template)
    update_or_create_entity(template)
    update_or_create_technology(template)
  end
end -- MdrnLoaders.add_loaders()

---Backward-compatible alias for `MdrnLoaders.add_loaders`.
---@deprecated Use `MdrnLoaders.add_loaders(loaders)` and pass the loaders table directly.
---@param templates { loaders: table<string, LMLoaderTemplate> }
function MdrnLoaders.make_modern_loaders(templates)
  MdrnLoaders.add_loaders(templates.loaders)
end -- MdrnLoaders.make_modern_loaders()
