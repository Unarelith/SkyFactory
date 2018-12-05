-- A Elepower Mod
-- Copyright 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

elefarm = rawget(_G, "elefarm") or {}
elefarm.modpath = modpath

dofile(modpath.."/treecutter.lua")
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/fluids.lua")
dofile(modpath.."/machines/init.lua")
dofile(modpath.."/crafting.lua")
