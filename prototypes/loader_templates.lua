-- Vanilla
local loader_templates = {
  [""] = {
    next_prefix = "fast-",
    tint = util.color("ffc340d1"),
    unlock_tech = "logistics",
    --prerequisite_techs = {"logistics"}
  },
  ["fast-"] = {
    previous_prefix = "",
    next_prefix = "express-",
    tint = util.color("e31717d1"),
    unlock_tech = "logistics-2"
    --prerequisite_techs = {"logistics-2"}
  },
  ["express-"] = {
    previous_prefix = "fast-",
    tint = util.color("43c0fad1"),
    unlock_tech = "logistics-3"
    --prerequisite_techs = {"logistics-2"}
  }
}

-- space-age
if data.raw["transport-belt"]["tungsten-transport-belt"] then
    loader_templates["tungsten-"] = {
      previous_prefix = "express-",
      tint = util.color("16f263d1"),
      unlock_tech = "tungsten-transport-belt"
  }
  loader_templates["express-"].next_prefix = "tungsten-"
end

return loader_templates