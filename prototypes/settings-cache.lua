---Settings resolved once at prototype load time.
---Only valid during the data/prototype stage.
local C = require("__loaders-modernized__.constants")
local S = C.SETTINGS
local ss = settings.startup

local cfg = {}

cfg.use_electricity       = ss[S.USE_ELECTRICITY].value       --[[@as boolean]]
cfg.oplp                  = ss[S.OPLP].value                  --[[@as boolean]]
cfg.chute_mode            = ss[S.CHUTE_MODE].value            --[[@as LMChuteMode]]
cfg.double_recipe         = ss[S.DOUBLE_RECIPE].value         --[[@as boolean]]
cfg.unlock_technology   = ss[S.UNLOCK_TECHNOLOGY].value   --[[@as LMUnlockMode]]
cfg.embiggen_assemblers = ss[S.EMBIGGEN_ASSEMBLERS].value --[[@as LMEmbiggenMode]]
cfg.stacking            = ss[S.ENABLE_STACKING].value     --[[@as LMStackingMode]]
cfg.cheap_stacking      = ss[S.CHEAP_STACKING].value      --[[@as boolean]]

-- Optional settings only present when their source mod is loaded
cfg.use_aai_graphics = (ss[S.USE_AAI_GRAPHICS] and ss[S.USE_AAI_GRAPHICS].value) --[[@as boolean]] or false
cfg.use_aai_recipes  = (ss[S.USE_AAI_RECIPES]  and ss[S.USE_AAI_RECIPES].value)  --[[@as boolean]] or false

-- Mod-compatibility booleans (use these instead of scattering mods[] checks)
cfg.has_space_age       = mods["space-age"] ~= nil
cfg.has_aai_loaders     = mods["aai-loaders"] ~= nil
cfg.has_aai_industry    = mods["aai-industry"] ~= nil
cfg.has_stack_inserters = mods["stack-inserters"] ~= nil
cfg.has_prismatic_belts = mods["prismatic-belts"] ~= nil

-- Derived value used by the entity factory
cfg.energy_per_item = cfg.oplp and "4kW" or "4kJ"

---@type LMSettingsCache
return cfg
