-- Start of migrations for Flib 17.0 release with Factorio 2.1 release
-- Flib deprecated migration.lua in 17.0

for _, player in pairs(game.players) do
  local relative_gui = player.gui.relative
  if relative_gui.split_lane then
    relative_gui.split_lane.destroy()
  end
end
