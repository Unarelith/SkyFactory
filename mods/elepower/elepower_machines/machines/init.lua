
local mp = elepm.modpath .. "/machines/"

-- Bases
dofile(mp .. "bases/init.lua")

-- Generation
dofile(mp .. "generator.lua")
dofile(mp .. "lava_generator.lua")
dofile(mp .. "steam_turbine.lua")
dofile(mp .. "fuel_burner.lua")

-- Storage
dofile(mp .. "storage.lua")

-- Processing
dofile(mp .. "furnace.lua")
dofile(mp .. "sawmill.lua")
dofile(mp .. "pulverizer.lua")
dofile(mp .. "grindstone.lua")

-- Crafter
dofile(mp .. "alloy_furnace.lua")
dofile(mp .. "coal_alloy_furnace.lua")
dofile(mp .. "solderer.lua")
dofile(mp .. "compressor.lua")
dofile(mp .. "canning_machine.lua")
dofile(mp .. "electrolyzer.lua")

-- Other
dofile(mp .. "accumulator.lua")
dofile(mp .. "lava_cooler.lua")
dofile(mp .. "bucketer.lua")
