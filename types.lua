--- @meta

-- ─── Event aliases ────────────────────────────────────────────────────────────

--- @alias BuiltEvent EventData.on_built_entity|EventData.on_robot_built_entity|EventData.on_entity_cloned|EventData.script_raised_built|EventData.script_raised_revive
--- @alias DestroyedEvent EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.on_entity_died|EventData.script_raised_destroy

-- ─── Setting value enums ──────────────────────────────────────────────────────

---Allowed values for the mdrn-enable-stacking setting.
---@alias LMStackingMode "none"|"turbo-and-above"|"all"|"stack-tier"

---Allowed values for the mdrn-chute-mode setting.
---@alias LMChuteMode "none"|"basic"|"filtered"

---Allowed values for the mdrn-unlock-technology setting.
---@alias LMUnlockMode "separate"|"belt"

---Allowed values for the mdrn-embiggen-assemblers setting.
---@alias LMEmbiggenMode "zero"|"eight"|"sixteen"

-- ─── Variant flags ───────────────────────────────────────────────────────────

---Describes which variant properties are active on a loader entity.
---Canonical suffix order in entity names: -split → -wfs → -fill.
---@class LMVariantFlags
---@field split boolean   per_lane_filters variant (suffix: -split)
---@field wfs   boolean   wait_for_full_stack variant (suffix: -wfs); stacking-capable tiers only
---@field fill  boolean   fill variant: respect_insert_limits=false (suffix: -fill)

-- ─── Storage types ────────────────────────────────────────────────────────────

---Per-player runtime data stored in `storage.players`.
---@class LMPlayerData
---@field name string                 Player display name.
---@field open_loader? LMOpenLoaderData  Non-nil while the player has a loader GUI open.

---State captured when the player opens a loader's GUI.
---@class LMOpenLoaderData
---@field entity LuaEntity       The loader entity whose GUI is open.
---@field gui LuaGuiElement      The split-lane checkbox frame.

---Shape of the mod's global `storage` table.
---@class LMStorage
---@field players table<integer, LMPlayerData>                         Indexed by player_index.
---@field fast_replace_variant table<int, table<string, LMVariantFlags>>  surface_index → pos_key → flags.
---@field variants table<string, true>                                 All known mdrn-loader variant entity names.
---@field slow_loaders table<string, true>                             Base names of loaders slower than mdrn-loader.

-- ─── Settings cache type (prototype stage only) ───────────────────────────────

---Settings resolved once at prototype load time. See prototypes/settings-cache.lua.
---@class LMSettingsCache
---@field use_electricity boolean
---@field oplp boolean
---@field chute_mode LMChuteMode
---@field double_recipe boolean
---@field unlock_technology LMUnlockMode
---@field embiggen_assemblers LMEmbiggenMode
---@field stacking LMStackingMode
---@field cheap_stacking boolean
---@field use_aai_graphics boolean
---@field use_aai_recipes boolean
---@field energy_per_item string
---@field has_space_age boolean
---@field has_aai_loaders boolean
---@field has_aai_industry boolean
---@field has_stack_inserters boolean

-- ─── Loader template ──────────────────────────────────────────────────────────

---Defines a single loader tier. Passed to MdrnLoaders.add_loaders().
---@class LMLoaderTemplate
---@field dark_frame? boolean              Use the dark-frame variant of graphics.
---@field tech_data? false                 Set to false to skip technology creation for this tier.
---@field filter? boolean                  false = no item filter (e.g. chute); nil/true = filterable.
---@field stacking? boolean                false = never stack regardless of global setting; nil/true = follow setting.
---@field name? string                     Overrides the derived entity/item/recipe name.
---@field localised_name? data.LocalisedString
---@field localised_description? data.LocalisedString
---@field underground_name? string         Name of the matching underground-belt prototype.
---@field tint? Color                      Tint applied to the icon mask and entity structure.
---@field next_upgrade? string             Name of the next-tier loader entity.
---@field upgrade_from_tier? string      Prefix of the existing loader tier whose next_upgrade should point at this one.
---@field max_belt_stack_size? int         Override for the belt stack size (Space Age).
---@field speed_multiplier? double         Applied on top of the matched underground belt speed.
---@field energy_type? string              Override energy source type (default: "electric").
---@field energy_drain? string             Override idle drain (default: "2kW").
---@field energy_per_item? string          Override energy consumed per item moved.
---@field order? string                    Sort order string for item/tech ordering.
---@field group? string                    Item group override.
---@field subgroup? string                 Item subgroup override.
---@field recipe_data? LMRecipeData        Recipe definition for this tier.
---@field prerequisite_techs? string[]     Technologies that must precede this tier's tech.
---@field unlocked_by? string              Name of the technology that unlocks this loader.
---@field unit? data.TechnologyUnit        Override research unit for the created technology.
---@field tech_tint? boolean               false = do not apply tint to the technology icon; nil/true = apply tint.
---@field above_express? boolean           Internal. Auto-derived by add_loaders(): true if effective speed > express belt.
---@field below_base? boolean              Internal. Auto-derived by add_loaders(): true if effective speed < mdrn-loader speed.
---@field fill_base? boolean               Internal. Set by add_loaders() for basic-mode slow loaders: forces respect_insert_limits=false on base entity.

-- ─── Recipe data ─────────────────────────────────────────────────────────────

---Recipe definition embedded in an LMLoaderTemplate.
---@class LMRecipeData
---@field surface_conditions? SurfaceCondition[]
---@field ingredients? data.IngredientPrototype[]
---@field stack_ingredients? data.IngredientPrototype[]   Alternate ingredient list when belt stacking is active.
---@field results? Product[]
---@field energy_required? double
---@field category? string
---@field enabled? boolean
