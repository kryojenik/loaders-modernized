local C   = require("__loaders-modernized__.constants")
local cfg = require("__loaders-modernized__.prototypes.settings-cache")

local utils = {}

-- ─── Private helpers ──────────────────────────────────────────────────────────

---Build a two-layer icon array (base sheet + tinted mask sheet).
---@param base_path string     Path to the base/dark base sprite.
---@param mask_path string     Path to the mask sprite to be tinted.
---@param tint Color
---@param icon_size integer?   Optional icon_size field added to both layers.
---@return data.IconData[]
local function icon_layers(base_path, mask_path, tint, icon_size)
  local base  = { icon = base_path }
  local mask  = { icon = mask_path, tint = tint }
  if icon_size then
    base.icon_size = icon_size
    mask.icon_size = icon_size
  end
  return { base, mask }
end -- icon_layers()

-- ─── Public API ───────────────────────────────────────────────────────────────

---Item icons (two layers: base + tinted mask).
---@param tint Color
---@param dark boolean?
---@return data.IconData[]
function utils.create_icons(tint, dark)
  if cfg.use_aai_graphics then
    local G = C.AAI_GRAPHICS
    return icon_layers(
      dark and G.ITEM_BASE_DARK or G.ITEM_BASE,
      dark and G.ITEM_MASK_DARK or G.ITEM_MASK,
      tint
    )
  end

  local G = C.GRAPHICS
  return icon_layers(
    dark and G.ITEM_BASE_DARK or G.ITEM_BASE,
    dark and G.ITEM_MASK_DARK or G.ITEM_MASK,
    tint
  )
end -- utils.create_icons()

---Technology icons (two layers: base + tinted mask).
---@param tint Color
---@param dark boolean?
---@return data.IconData[]
function utils.create_tech_icons(tint, dark)
  if cfg.use_aai_graphics then
    local G = C.AAI_GRAPHICS
    return icon_layers(
      dark and G.TECH_BASE_DARK or G.TECH_BASE,
      dark and G.TECH_MASK_DARK or G.TECH_MASK,
      tint,
      256
    )
  end

  local G = C.GRAPHICS
  return icon_layers(
    dark and G.TECH_BASE_DARK or G.TECH_BASE,
    dark and G.TECH_MASK_DARK or G.TECH_MASK,
    tint,
    128
  )
end -- utils.create_tech_icons()

---Loader structure sprite sheets.
---@param tint Color
---@param dark boolean?
---@return data.LoaderStructure
function utils.create_entity_structure(tint, dark)
  if cfg.use_aai_graphics then
    local G           = C.AAI_GRAPHICS
    local shadow_shift = { 0.4, 0.15 }
    local sprite_shift = { 0, -0.15 }
    local base_file    = dark and G.ENTITY_BASE_DARK or G.ENTITY_BASE
    local tint_file    = dark and G.ENTITY_MASK_DARK or G.ENTITY_MASK

    ---Build one direction's sheet array for the AAI sprite layout.
    ---@param y_offset integer  Row offset into the sprite sheet (0 for direction_in, 79/117 for direction_out).
    local function aai_sheets(y_offset)
      local shadow_sheet = {
        filename      = G.ENTITY_SHADOWS,
        priority      = "extra-high",
        shift         = shadow_shift,
        width         = 138,
        height        = 79,
        scale         = 0.5,
        draw_as_shadow = true,
      }
      local base_sheet = {
        filename = base_file,
        priority = "extra-high",
        shift    = sprite_shift,
        width    = 99,
        height   = 117,
        scale    = 0.5,
      }
      local tint_sheet = {
        filename = tint_file,
        priority = "extra-high",
        shift    = sprite_shift,
        width    = 99,
        height   = 117,
        scale    = 0.5,
        tint     = tint,
      }
      if y_offset > 0 then
        shadow_sheet.y = y_offset == 117 and 79 or y_offset  -- shadow uses 79px rows
        base_sheet.y   = y_offset
        tint_sheet.y   = y_offset
      end
      return { shadow_sheet, base_sheet, tint_sheet }
    end -- aai_sheets()

    return {
      direction_in  = { sheets = aai_sheets(0)   },
      direction_out = { sheets = aai_sheets(117)  },
      frozen_patch_in  = { sheet = {
        filename = G.FROZEN_PATCH, priority = "extra-high",
        shift = sprite_shift, width = 99, height = 117, scale = 0.5,
      }},
      frozen_patch_out = { sheet = {
        filename = G.FROZEN_PATCH, priority = "extra-high",
        shift = sprite_shift, width = 99, height = 117, y = 117, scale = 0.5,
      }},
    }
  end

  -- Own-mod sprite layout (192×192 tiles stacked vertically)
  local G        = C.GRAPHICS
  local base_file = dark and G.ENTITY_BASE_DARK or G.ENTITY_BASE

  ---Build one direction's sheet array for the base-mod sprite layout.
  ---@param y_offset integer  Row offset (0 for direction_in, 192 for direction_out).
  local function base_sheets(y_offset)
    local base_sheet = {
      filename = base_file,
      priority = "extra-high",
      width    = 192,
      height   = 192,
      scale    = 0.5,
    }
    local mask_sheet = {
      filename = G.ENTITY_MASK,
      priority = "extra-high",
      width    = 192,
      height   = 192,
      scale    = 0.5,
      tint     = tint,
    }
    local shadow_sheet = {
      filename       = G.ENTITY_SHADOW,
      draw_as_shadow = true,
      priority       = "extra-high",
      width          = 192,
      height         = 192,
      scale          = 0.5,
    }
    if y_offset > 0 then
      base_sheet.y   = y_offset
      mask_sheet.y   = y_offset
      shadow_sheet.y = y_offset
    end
    return { base_sheet, mask_sheet, shadow_sheet }
  end -- base_sheets()

  return {
    direction_in  = { sheets = base_sheets(0)   },
    direction_out = { sheets = base_sheets(192)  },
    back_patch  = { sheet = {
      filename = G.ENTITY_BACK,  priority = "extra-high",
      width = 192, height = 192, scale = 0.5,
    }},
    front_patch = { sheet = {
      filename = G.ENTITY_FRONT, priority = "extra-high",
      width = 192, height = 192, scale = 0.5,
    }},
  }
end -- utils.create_entity_structure()

---Add an unlock-recipe effect to a technology (no-op if the effect already exists).
---@param tech data.TechnologyPrototype|string
---@param recipe string
utils.add_recipe_to_effects = function(tech, recipe)
  if type(tech) == "string" then
    tech = data.raw.technology[tech]
  end

  if not tech then
    return
  end

  for _, effect in ipairs(tech.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == recipe then
      return
    end
  end

  tech.effects[#tech.effects + 1] = { type = "unlock-recipe", recipe = recipe }
end -- utils.add_recipe_to_effects()

---Remove an unlock-recipe effect from one or more technologies.
---If the technology was created by this mod and has no remaining effects, it is deleted.
---@param recipe string
---@param tech_names (string|string[])?  If nil, all technologies are searched.
utils.remove_recipe_from_effects = function(recipe, tech_names)
  if type(tech_names) == "string" then
    tech_names = { tech_names }
  end

  local techs = {}
  if tech_names then
    for _, name in pairs(tech_names) do
      techs[name] = data.raw["technology"][name]
    end
  else
    techs = data.raw["technology"]
  end

  for _, tech in pairs(techs) do
    if tech.effects then
      for i = #tech.effects, 1, -1 do
        if tech.effects[i].type == "unlock-recipe" and tech.effects[i].recipe == recipe then
          table.remove(tech.effects, i)
        end
      end

      if #tech.effects == 0 and string.find(tech.name, "mdrn") then
        data.raw["technology"][tech.name] = nil
      end
    end
  end
end -- utils.remove_recipe_from_effects()

---Return true if the loader described by `template` should use belt stacking.
---@param template LMLoaderTemplate
---@return boolean
utils.stack = function(template)
  if template.stacking == false or template.filter == false then
    return false
  end

  local mode = cfg.stacking
  if mode == C.STACKING.NONE or mode == C.STACKING.STACK_TIER then
    return false
  end

  if mode == C.STACKING.TURBO_AND_ABOVE and not template.above_express then
    return false
  end

  return true
end -- utils.stack()

return utils
