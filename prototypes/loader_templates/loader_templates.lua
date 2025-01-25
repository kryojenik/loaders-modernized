local meld = require("meld")

local loader_templates = require("base")

-- AAI-Industry
local addon = require("aai-industry")
if addon then
  meld.meld(loader_templates, addon)
end

-- Ultimate Belts Space Age!
addon = require("ultimatebeltsspaceage")
if addon and not mods["5dim_transport"] then
  meld.meld(loader_templates, addon)
end

-- 5 Dim New Transport
addon = require("5dim_transport")
if addon then
  meld.meld(loader_templates, addon)
end

-- Iper belt
addon = require("iper-belt")
if addon then
  meld.meld(loader_templates, addon)
end

return loader_templates