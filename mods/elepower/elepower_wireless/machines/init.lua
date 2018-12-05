
local mp = elewi.modpath .. "/machines/"

elewi.slab_nodebox = {
	type = "fixed",
	fixed = {
		{-0.5000, -0.5000, -0.5000, 0.5000, -0.4375, 0.5000}
	}
}

dofile(mp .. "matter_receiver.lua")
dofile(mp .. "matter_transmitter.lua")
dofile(mp .. "dialler.lua")
