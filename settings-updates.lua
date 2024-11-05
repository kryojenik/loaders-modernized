if mods["aai-loaders"] and data.raw["bool-setting"]["mdrn-use-aai-graphics"].value then
  data.raw["string-setting"]["aai-loaders-mode"].hidden = true
  data.raw["string-setting"]["aai-loaders-mode"].allowed_values = {"graphics-only"}
  data.raw["string-setting"]["aai-loaders-mode"].default_value = "graphics-only"
  data.raw["string-setting"]["aai-loaders-lubricant-recipe"].hidden = true
  data.raw["bool-setting"]["aai-loaders-fit-assemblers"].hidden = true
end