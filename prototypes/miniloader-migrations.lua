-- Only load this file if the player is trying to migrate from a 1.1 save with Miniloaders.
-- Some of the stuff in here is cursed, but we also don't want conditional requires.
-- So, check the setting and get out if we don't need it!
if not settings.startup["mdrn-migrate-from-miniloaders"].value then
  return {}
end

-- A list of belt tiers and alternative belt tiers that Miniloaders supported that may need to be
-- migrated or removed.
local miniloader_migrations = {
  "chute-",
  "",
  "fast-",
  "express-",
  -- bobs
  "basic-",
  "turbo-",
  "ultimate-",
  -- FactorioExtended-Plus
  "rapid-mk1-",
  "rapid-mk2-",
  -- Krastorio2
  "kr-advanced-",
  "kr-superior-",
  -- RandomFactorioThings
  "nuclear-",
  "plutonium-",
  -- UltimateBelts
  "ub-ultra-fast-",
  "ub-extreme-fast-",
  "ub-ultra-express-",
  "ub-extreme-express-",
  "ub-ultimate-",
  -- space-exploration
  "space-",
  "deep-space-",
}

--- Lifted from Editor Extensions
local function is_sprite_def(array)
  return array.icon or array.width and array.height and (array.filename or array.stripes or array.filenames)
end

--- Lifted from Editor Extensions
--- Recursively tint all sprite definitions in the given table.
--- @generic T
--- @param array T
--- @param tint Color|boolean? Set to `false` to remove tints.
--- @return T
function recursive_tint(array, tint)
  for _, v in pairs(array) do
    if type(v) == "table" then
      if is_sprite_def(v) then
        if tint == false then
          v.tint = nil
        else
          v.tint = tint
        end
      end

      v = recursive_tint(v, tint)
    end
  end

  return array
end

--- Lifted from Editor Extensions
--- Copy and optionally tint a prototype.
--- @generic T
--- @param base T
--- @param mods table<string, any>
--- @param tint Color|boolean? Infinity tint by default, set to `false` to perform no tinting.
--- @return T
function copy_prototype(base, mods, tint)
  local base = table.deepcopy(base)
  for key, value in pairs(mods) do
    if key == "icons" and value == "CONVERT" then
      base.icons = { { icon = base.icon, icon_size = base.icon_size, icon_mipmaps = base.icon_mipmaps } }
      base.icon = nil
      base.icon_size = nil
      base.icon_mipmaps = nil
    elseif value == "NIL" then
      base[key] = nil
    else
      base[key] = value
    end
  end

  if tint ~= false then
    recursive_tint(base, tint)
  end

  return base
end

---Create dummy entities to be a place holder for old Miniloader entities so that we can pull
---configuration from them before replacing them.
---@param prefix string Loader tier prefix
local function create_dummy_entities(prefix)
  local inserter = copy_prototype(data.raw["inserter"]["inserter"], {
    name = prefix .. "miniloader-inserter",
    localised_name = "Loader (" .. prefix .. ") migration dummy",
    icon = "NIL",
    platform_picture = "NIL",
    hand_base_picture = "NIL",
    hand_open_picture = "NIL",
    hand_closed_picture = "NIL",
    hand_base_shadow = "NIL",
    hand_open_shadow = "NIL",
    hand_closed_shadow = "NIL",
    energy_source = { type = "void" },
    minable = "NIL",
    draw_held_item = false,
    placeable_by = "NIL",
    flags = { "not-upgradable", "player-creation" },
    next_upgrade = "NIL",
  }, { r = 0.8, g = 0.8, b = 0.8 })

  local filter_inserter = table.deepcopy(inserter)
  filter_inserter.name = prefix .. "filter-miniloader-inserter"
  local loader = copy_prototype(data.raw["loader-1x1"]["loader-1x1"], {
    name = prefix .. "miniloader-loader",
    localised_name = "Loader (" .. prefix .. ") migration dummy",
    minable = "NIL",
    placeable_by = "NIL",
    icon = "NIL",
    structure = {
      direction_in = {
        sheets = {{
          filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base.png",
          width = 192,
          height = 192,
          scale = 0.5,
        }}
      },
      direction_out = {
        sheets = {{
          filename = "__loaders-modernized__/graphics/entity/mdrn-loader-structure-base.png",
          width = 192,
          height = 192,
          scale = 0.5,
          y = 192
        }}
      }
    },
    flags = { "not-upgradable", "player-creation" },
    next_upgrade = "NIL",
  }, { r = 0.8, g = 0.8, b = 0.8 })
  local filter_loader = table.deepcopy(loader)
  filter_loader.name = prefix .. "filter-miniloader-loader"

  data:extend{
    inserter,
    filter_inserter,
    loader,
    filter_loader,
  }
end

for _,v in pairs(miniloader_migrations) do
  create_dummy_entities(v)
end