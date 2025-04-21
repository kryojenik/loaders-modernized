if not mods["boblogistics"] then
  return
end

if bobmods.tech and bobmods.tech.advanced_logistic_science then
  bobmods.lib.tech.replace_science_pack("turbo-mdrn-loader", "production-science-pack", "advanced-logistic-science-pack")

  bobmods.lib.tech.add_science_pack("ultimate-mdrn-loader", "advanced-logistic-science-pack", 1)
end

if mods['space-age'] then
  data.raw.recipe['turbo-mdrn-loader'].surface_conditions = nil
end