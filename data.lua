local loaders = require("prototypes.mdrn-loader")
local C = require("constants")

require("prototypes.loader_templates.base")
require("prototypes.loader_templates.aai-industry")
require("prototypes.assembly-machines")

if mods['loader-utils'] then
  error("\n\nLoaders Modernized is not compatible with Loader Utilities. Please remove Loader Utilities from your game.\n\n")
end

if mods["loaders-modernized-integrations"] then
  for _, addon in pairs(C.DEPRECATED_ADDONS) do
    if mods[addon] then
      local message = "\n\nThe mod 'loaders-modernized-integrations' is already installed and supersedes '" .. addon .. "', which is deprecated."
      message = message .. "Please remove '" .. addon .. "' from your game.\n\n"
      error(message)
    end
  end
end
