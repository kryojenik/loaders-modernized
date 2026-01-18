utils = {}
local startup_settings = settings.startup

---Loader icons
---@param tint Color
---@param dark boolean?
---@return table
function utils.create_icons(tint, dark)
  if startup_settings["mdrn-use-aai-graphics"] and startup_settings["mdrn-use-aai-graphics"].value then
    return {
      {
        icon = dark and "__aai-loaders__/graphics/icons/loader_dark.png"
                    or "__aai-loaders__/graphics/icons/loader.png"
      },
      {
        icon = dark and "__aai-loaders__/graphics/icons/loader_mask_dark.png"
                    or "__aai-loaders__/graphics/icons/loader_mask.png",
        tint = tint
      }
    }
  end

  return {
    { icon = dark and "__loaders-modernized__/graphics/item/mdrn-loader-icon-base-dark.png"
                  or "__loaders-modernized__/graphics/item/mdrn-loader-icon-base.png"
    },
    {
      icon = "__loaders-modernized__/graphics/item/mdrn-loader-icon-mask.png",
      tint = tint
    }
  }
end

---Technology icon
---@param tint Color
---@param dark boolean?
---@return table
function utils.create_tech_icons(tint, dark)
  if startup_settings["mdrn-use-aai-graphics"] and startup_settings["mdrn-use-aai-graphics"].value then
    return {
      {
        icon = dark
          and "__aai-loaders__/graphics/technology/loader-tech-icon_dark.png"
          or "__aai-loaders__/graphics/technology/loader-tech-icon.png",
        icon_size = 256
      },
      {
        icon = dark
          and "__aai-loaders__/graphics/technology/loader-tech-icon_mask_dark.png"
          or "__aai-loaders__/graphics/technology/loader-tech-icon_mask.png",
        icon_size = 256,
        tint = tint
      }
    }
  end

  return {
    {
      icon = dark
        and "__loaders-modernized__/graphics/technology/mdrn-loader-technology-base-dark.png"
        or "__loaders-modernized__/graphics/technology/mdrn-loader-technology-base.png",
      icon_size = 128
    },
    {
      icon = "__loaders-modernized__/graphics/technology/mdrn-loader-technology-mask.png",
      icon_size = 128,
      tint = tint
    }
  }
end

---Loader structure sprite sheets
---@param tint Color
---@param dark boolean?
---@return data.LoaderStructure
function utils.create_entity_structure(tint, dark)
  if startup_settings["mdrn-use-aai-graphics"] and startup_settings["mdrn-use-aai-graphics"].value then
    local shadow_shift = { 0.4, 0.15 }
    local sprite_shift = { 0, -0.15 }
    return {
      direction_in = {
        sheets = {
          {
            filename = "__aai-loaders__/graphics/entity/loader/loader_shadows.png",
            priority = "extra-high",
            shift = shadow_shift,
            width = 138,
            height = 79,
            scale = 0.5,
            draw_as_shadow = true
          },
          {
            filename = dark and "__aai-loaders__/graphics/entity/loader/loader_dark.png"
                            or "__aai-loaders__/graphics/entity/loader/loader.png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            scale = 0.5,
          },
          {
            filename = dark and "__aai-loaders__/graphics/entity/loader/loader_tint_dark.png"
                            or "__aai-loaders__/graphics/entity/loader/loader_tint.png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            scale = 0.5,
            tint = tint
          }
        }
      },
      direction_out = {
        sheets = {
          {
            filename = "__aai-loaders__/graphics/entity/loader/loader_shadows.png",
            priority = "extra-high",
            shift = shadow_shift,
            width = 138,
            height = 79,
            y = 79,
            scale = 0.5,
            draw_as_shadow = true
          },
          {
            filename = dark and "__aai-loaders__/graphics/entity/loader/loader_dark.png"
                            or "__aai-loaders__/graphics/entity/loader/loader.png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            y = 117,
            scale = 0.5,
          },
          {
            filename = dark and "__aai-loaders__/graphics/entity/loader/loader_tint_dark.png"
                            or "__aai-loaders__/graphics/entity/loader/loader_tint.png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            scale = 0.5,
            y = 117,
            tint = tint
          }
        }
      },
      frozen_patch_in = {
        sheet = {
          filename = "__aai-loaders__/graphics/entity/loader/frozen/loader.png",
          priority = "extra-high",
          shift = sprite_shift,
          width = 99,
          height = 117,
          scale = 0.5
        }
      },
      frozen_patch_out = {
        sheet = {
          filename = "__aai-loaders__/graphics/entity/loader/frozen/loader.png",
          priority = "extra-high",
          shift = sprite_shift,
          width = 99,
          height = 117,
          y = 117,
          scale = 0.5
        }
      }
    }
  end

  return {
    direction_in = {
      sheets = {
        {
          filename = dark and "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base-dark.png"
                          or "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5,
        },
        {
          filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-mask.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5,
          tint = tint
        },
        {
          filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-shadow.png",
          draw_as_shadow = true,
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5,
        }
      }
    },
    direction_out = {
      sheets = {
        {
          filename = dark and "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base-dark.png"
                          or "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5,
          y = 192
        },
        {
          filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-mask.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5,
          y = 192,
          tint = tint
        },
        {
          filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-shadow.png",
          draw_as_shadow = true,
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5,
          y = 192
        },
      }
    },
    back_patch =
    {
      sheet =
      {
        filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-back-patch.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        scale = 0.5
      }
    },
    front_patch =
    {
      sheet =
      {
        filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-front-patch.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        scale = 0.5
      }
    }
  }
end

---Add an unlock recipe effect to the supplied technology
---@param tech data.TechnologyPrototype
---@param recipe string
utils.add_recipe_to_effects = function(tech, recipe)
  for _, effect in ipairs(tech.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == recipe then
      return
    end
  end

  tech.effects[#tech.effects+1] = { type = "unlock-recipe", recipe = recipe }
end -- add_unlock_effect()

---Removes the unlock recipe effect from the supplied technology
---@param tech data.TechnologyPrototype
---@param recipe string
utils.remove_recipe_from_effects = function(tech, recipe)
  local effects = tech and tech.effects
  if not effects then
    return
  end
  
  local j = 1
  for i=1, #effects do
    if effects[i].type == "unlock-recipe" and effects[i].recipe == recipe then
      effects[i] = nil
    else
      if i ~= j then
        effects[j] = effects[i]
        effects[i] = nil
      end
      j = j + 1
    end
    i = i + 1
  end
end -- remove_recipe_from_effects()

utils.stack =  function(template)
  -- If a loader can't filter, don't allow it to stack either.
  if template.no_stack or template.no_filter then
    return false
  end

  if startup_settings["mdrn-enable-stacking"].value == "none"
  or startup_settings["mdrn-enable-stacking"].value == "stack-tier" then
    return false
  end

  if startup_settings["mdrn-enable-stacking"].value == "turbo-and-above"
  and template.below_turbo then
    return false
  end

  return true
end


return utils