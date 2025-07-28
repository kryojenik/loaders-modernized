local startup_settings = settings.startup

-- Make sure the stack loader tier is at the fastest belt speed
if startup_settings["mdrn-enable-stacking"].value == "stack-tier"
and data.raw["loader-1x1"]["stack-mdrn-loader"] then
  local fastest_belt = 0
  for _, ug in pairs(data.raw["underground-belt"]) do
    if ug.speed > fastest_belt then
      fastest_belt = ug.speed
    end
  end

  data.raw["loader-1x1"]["stack-mdrn-loader"].speed = fastest_belt
  data.raw["loader-1x1"]["stack-mdrn-loader-split"].speed = fastest_belt
end
