--- @meta

---Shared constants for loaders-modernized.
---Safe to require in both prototype (data) stage and runtime (control) stage.
local constants = {}

-- ─── Entity names ─────────────────────────────────────────────────────────────

---Always-first mod prefix for all loader entity/item/recipe names.
constants.LOADER_PREFIX = "mdrn-"

---The base word appended after the prefix and tier. Name formula: PREFIX .. tier .. BASE.
---  e.g. "" tier   → "mdrn-loader"
---  e.g. "fast-"   → "mdrn-fast-loader"
constants.LOADER_BASE = "loader"

---Lua find/match pattern that matches any entity name starting with "mdrn-".
---Anchored so it only matches our entities and not other mods that contain "mdrn-" elsewhere.
constants.LOADER_PATTERN = "^mdrn%-"

---Lua find/match pattern that identifies chute-tier loader base names (mdrn-chute-*).
constants.CHUTE_LOADER_PATTERN = "^mdrn%-chute%-"

---Suffix appended to entity names for the split-lane variant (per_lane_filters).
constants.SPLIT_SUFFIX = "-split"

---Lua pattern that matches the split-lane suffix anywhere in a name.
constants.SPLIT_PATTERN = "%-split"

---Suffix for the wait-for-full-stack variant (wait_for_full_stack = true).
constants.WFS_SUFFIX = "-wfs"

---Lua pattern that matches the wfs suffix anywhere in a name.
constants.WFS_PATTERN = "%-wfs"

---Suffix for the fill variant (respect_insert_limits = false — fills machine slots unconditionally).
constants.FILL_SUFFIX = "-fill"

---Lua pattern that matches the fill suffix anywhere in a name.
constants.FILL_PATTERN = "%-fill"

---All suffix permutations in canonical order (split → wfs → fill).
---Includes "" so callers can update the base entity and all variants in one loop.
constants.VARIANT_SUFFIXES = {
  "",
  constants.SPLIT_SUFFIX,
  constants.FILL_SUFFIX,
  constants.SPLIT_SUFFIX .. constants.FILL_SUFFIX,
  constants.WFS_SUFFIX,
  constants.SPLIT_SUFFIX .. constants.WFS_SUFFIX,
  constants.WFS_SUFFIX .. constants.FILL_SUFFIX,
  constants.SPLIT_SUFFIX .. constants.WFS_SUFFIX .. constants.FILL_SUFFIX,
}

---Belt tier prefixes in ascending order (used by data-updates and template files).
constants.TIERS = { "", "fast-", "express-", "turbo-" }

-- ─── Setting names ────────────────────────────────────────────────────────────

constants.SETTINGS = {
  USE_ELECTRICITY       = "mdrn-use-electricity",
  OPLP                  = "mdrn-oplp",
  CHUTE_MODE            = "mdrn-chute-mode",
  DOUBLE_RECIPE         = "mdrn-double-recipe",
  UNLOCK_TECHNOLOGY     = "mdrn-unlock-technology",
  EMBIGGEN_ASSEMBLERS   = "mdrn-embiggen-assemblers",
  ENABLE_STACKING       = "mdrn-enable-stacking",
  CHEAP_STACKING        = "mdrn-cheap-stacking",
  USE_AAI_GRAPHICS      = "mdrn-use-aai-graphics",
  USE_AAI_RECIPES       = "mdrn-use-aai-recipes",
  RESPECT_INSERT_LIMITS         = "mdrn-respect-insert-limits",
  WAIT_FOR_FULL_STACK           = "mdrn-wait-for-full-stack",
  DEFAULT_RESPECT_INSERT_LIMITS = "mdrn-default-respect-insert-limits",
  DEFAULT_WAIT_FOR_FULL_STACK   = "mdrn-default-wait-for-full-stack",
  CHUTE_DIRECTION               = "mdrn-chute-direction",
  AAI_FAST_REPLACE              = "mdrn-aai-fast-replace",
}

-- ─── Setting value enums ──────────────────────────────────────────────────────

constants.STACKING = {
  NONE            = "none",
  TURBO_AND_ABOVE = "turbo-and-above",
  ALL             = "all",
  STACK_TIER      = "stack-tier",
}

constants.UNLOCK_TECH = {
  SEPARATE = "separate",
  BELT     = "belt",
}

constants.EMBIGGEN = {
  ZERO    = "zero",
  EIGHT   = "eight",
  SIXTEEN = "sixteen",
}

constants.CHUTE = {
  NONE          = "none",
  BASIC         = "basic",
  BASIC_LIMITED = "basic-limited",
  FILTERED      = "filtered",
}

-- ─── Graphic paths (own mod) ──────────────────────────────────────────────────

constants.GRAPHICS = {
  -- Item icons
  ITEM_BASE      = "__loaders-modernized__/graphics/item/mdrn-loader-icon-base.png",
  ITEM_BASE_DARK = "__loaders-modernized__/graphics/item/mdrn-loader-icon-base-dark.png",
  ITEM_MASK      = "__loaders-modernized__/graphics/item/mdrn-loader-icon-mask.png",
  ITEM_MASK_DARK = "__loaders-modernized__/graphics/item/mdrn-loader-icon-mask-dark.png",

  -- Technology icons
  TECH_BASE      = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-base.png",
  TECH_BASE_DARK = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-base-dark.png",
  TECH_MASK      = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-mask.png",
  TECH_MASK_DARK = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-mask-dark.png",

  -- Entity sprite sheets
  ENTITY_BASE      = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base.png",
  ENTITY_BASE_DARK = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base-dark.png",
  ENTITY_MASK      = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-mask.png",
  ENTITY_MASK_DARK = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-mask-dark.png",
  ENTITY_SHADOW    = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-shadow.png",
  ENTITY_BACK      = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-back-patch.png",
  ENTITY_FRONT     = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-front-patch.png",

  -- Misc icons
  SPLIT_ICON = "__loaders-modernized__/graphics/icon/split-lane-out.png",
  WFS_ICON   = "__loaders-modernized__/graphics/icon/wait-stack.png",
  FILL_ICON  = "__loaders-modernized__/graphics/icon/fill.png",
}

-- ─── Graphic paths (AAI Loaders mod) ─────────────────────────────────────────

constants.AAI_GRAPHICS = {
  -- Item icons
  ITEM_BASE      = "__aai-loaders__/graphics/icons/loader.png",
  ITEM_BASE_DARK = "__aai-loaders__/graphics/icons/loader_dark.png",
  ITEM_MASK      = "__aai-loaders__/graphics/icons/loader_mask.png",
  ITEM_MASK_DARK = "__aai-loaders__/graphics/icons/loader_mask_dark.png",

  -- Technology icons
  TECH_BASE      = "__aai-loaders__/graphics/technology/loader-tech-icon.png",
  TECH_BASE_DARK = "__aai-loaders__/graphics/technology/loader-tech-icon_dark.png",
  TECH_MASK      = "__aai-loaders__/graphics/technology/loader-tech-icon_mask.png",
  TECH_MASK_DARK = "__aai-loaders__/graphics/technology/loader-tech-icon_mask_dark.png",

  -- Entity sprite sheets
  ENTITY_BASE      = "__aai-loaders__/graphics/entity/loader/loader.png",
  ENTITY_BASE_DARK = "__aai-loaders__/graphics/entity/loader/loader_dark.png",
  ENTITY_MASK      = "__aai-loaders__/graphics/entity/loader/loader_tint.png",
  ENTITY_MASK_DARK = "__aai-loaders__/graphics/entity/loader/loader_tint_dark.png",
  ENTITY_SHADOWS   = "__aai-loaders__/graphics/entity/loader/loader_shadows.png",
  FROZEN_PATCH     = "__aai-loaders__/graphics/entity/loader/frozen/loader.png",
}

return constants
