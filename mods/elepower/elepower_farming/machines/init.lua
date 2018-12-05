
local mp = elefarm.modpath.."/machines/"

dofile(mp.."planter.lua")
dofile(mp.."harvester.lua")
dofile(mp.."tree_extractor.lua")
dofile(mp.."tree_processor.lua")
dofile(mp.."composter.lua")

-- Mobs Redo support
if minetest.get_modpath("mobs") ~= nil and mobs.mod and mobs.mod == "redo" then
	dofile(mp.."spawner.lua")
end
