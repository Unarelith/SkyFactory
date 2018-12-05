-- A Elepower Mod
-- Copyright 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

elenuclear = rawget(_G, "elenuclear") or {}
elenuclear.modpath = modpath

dofile(modpath.."/craftitems.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/fluids.lua")
dofile(modpath.."/crafting.lua")
dofile(modpath.."/worldgen.lua")
