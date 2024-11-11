---Create technology prototype for loaders
---@param tier string Loader tier prefix
---@param t LMLoaderTemplate Loader tier template
local function create_technology(tier, t)
  if tier == "chute-" then
    return
  end

  local name = t.name or tier .. "mdrn-loader"
  local unlocked_by = data.raw["technology"][t.unlocked_by]
  if unlocked_by then
    unlocked_by.effects[#unlocked_by.effects+1] = {type = "unlock-recipe", recipe = name}
    return
  end

  local technology = {
    type = "technology",
    name = name,
    icons = {
      {
        icon = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-base.png",
        icon_size = 128,
      },
      {
        icon = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-base.png",
        icon_size = 128,
        tint = t.tint,
      }
    },
    effects = {{type = "unlock-recipe", recipe = name }},
    order = t.prerequisite_techs[1].order,
    prerequisites = t.prerequisite_techs,
    unit = util.table.deepcopy(data.raw["technology"][t.prerequisite_techs[1]].unit)
  }
  local setting_use_aai_graphics = settings.startup["mdrn-use-aai-graphics"]
  if setting_use_aai_graphics and setting_use_aai_graphics.value then
    technology.icons = {
      {
        icon = "__aai-loaders__/graphics/technology/loader-tech-icon.png",
        icon_size = 256,
      },
      {
        icon = "__aai-loaders__/graphics/technology/loader-tech-icon_mask.png",
        icon_size = 256,
        tint = t.tint,
      },
    }
  end

  data:extend{technology}
end

return {
  create_technology = create_technology
}