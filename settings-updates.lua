local alm = data.raw["string-setting"]["aai-loaders-mode"]
if mods["aai-loaders"] and not mods["aai-loaders-electric"] then
  alm.default_value = "graphics-only"
end
