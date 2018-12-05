dofile(factory.modpath.."/machines/crafting.lua")
dofile(factory.modpath.."/machines/belt.lua")
dofile(factory.modpath.."/machines/ind_furnace.lua")
dofile(factory.modpath.."/machines/ind_squeezer.lua")
dofile(factory.modpath.."/machines/wire_drawer.lua")
dofile(factory.modpath.."/machines/stp.lua")
dofile(factory.modpath.."/machines/swapper.lua")
dofile(factory.modpath.."/machines/arm.lua")
dofile(factory.modpath.."/machines/taker.lua")
dofile(factory.modpath.."/machines/qarm.lua")
dofile(factory.modpath.."/machines/oarm.lua")
dofile(factory.modpath.."/machines/autocrafter.lua")

if factory.enableFan then dofile(factory.modpath.."/machines/fan.lua") end
if factory.enableVacuum then
	dofile(factory.modpath.."/machines/vacuum.lua")
	dofile(factory.modpath.."/machines/upward_vacuum.lua")
end
if factory.enableMiner then dofile(factory.modpath.."/machines/miner.lua") end