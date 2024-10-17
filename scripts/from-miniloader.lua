
local from_miniloader = {}

from_miniloader.migrate = function(e)
  --__DebugAdapter.breakpoint()
  for _, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered({type = "inserter"})
    for k, entity in pairs(entities) do
      game.print(entity.unit_number .. ": " .. entity.name)
    end
  end
end

return from_miniloader