local startup_settings = settings.startup

local function create_icons(tint)
  if startup_settings["mdrn-use-aai-graphics"] and startup_settings["mdrn-use-aai-graphics"].value then
    return {
      { icon = "__aai-loaders__/graphics/technology/loader-tech-icon.png", icon_size = 256 },
      { icon = "__aai-loaders__/graphics/technology/loader-tech-icon_mask.png", icon_size = 256, tint = tint }
    }
  end

  return {
    { icon = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-base.png", icon_size = 128 },
    { icon = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-mask.png", icon_size = 128, tint = tint }
  }
end

---Create technology prototype for loaders
---@param tier string Loader tier prefix
---@param template LMLoaderTemplate Loader tier template
---@param blacklist table
local function create_technology(tier, template, blacklist)
  if tier == "chute-" then
    return {}
  end

  local name = template.name or tier .. "mdrn-loader"
  local unlocked_by = data.raw["technology"][template.unlocked_by]
  if unlocked_by then
    unlocked_by.effects[#unlocked_by.effects+1] = { type = "unlock-recipe", recipe = name }
    return {}
  end

  local unit = nil
  if data.raw["technology"][template.prerequisite_techs[1]] then
    unit = util.table.deepcopy(data.raw["technology"][template.prerequisite_techs[1]].unit)
  end

  ---@type data.TechnologyPrototype[]
  local technologies = {}

  ---@type data.TechnologyPrototype
  local technology = {
    type = "technology",
    name = name,
    localised_description = { "technology-description.common" },
    icons = create_icons(template.tint),
    effects = {{ type = "unlock-recipe", recipe = name }},
    order = template.prerequisite_techs[1].order,
    prerequisites = template.prerequisite_techs,
    unit = unit
  }

  technologies[#technologies+1] = technology
  --[[
  if startup_settings["mdrn-enable-stacking"].value == "turbo-and-above"
  and not blacklist.below_turbo[tier] then
    local stack_name = string.gsub(name, "mdrn%-loader", "stack-mdrn-loader")
    local stack_technology = table.deepcopy(technology)
    stack_technology.name = stack_name
    stack_technology.effects = {{ type = "unlock-recipe", recipe = stack_name }}
    stack_technology.prerequisites = { technology.name, "stack-inserter"}
    if not startup_settings["mdrn-use-stack-sticker"].value then
      stack_technology.icons = create_icons(template.stack_tint)
    end
    technologies[#technologies+1] = stack_technology
  end
  ]]

  return technologies
end

return {
  create_technology = create_technology
}