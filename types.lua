--- @meta

--- @alias BuiltEvent EventData.on_built_entity|EventData.on_robot_built_entity|EventData.on_entity_cloned|EventData.script_raised_built|EventData.script_raised_revive
--- @alias DestroyedEvent EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.on_entity_died|EventData.script_raised_destroy

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
---@field localised_name? data.LocalisedString
---@field stack_tint? Color
---@field max_belt_stack_size? int
---@field unit? data.TechnologyUnit