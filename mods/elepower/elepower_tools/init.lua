-- A Elepower Mod
-- Copyright 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

eletool = rawget(_G, "eletool") or {}
eletool.modpath = modpath

dofile(modpath .. "/tools.lua")
dofile(modpath .. "/craftitems.lua")
dofile(modpath .. "/crafting.lua")
