-- Elepower Mod
-- Copyright 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

elewi = rawget(_G, "elewi") or {}
elewi.modpath = modpath

-- Items
dofile(modpath .. "/craftitems.lua")
dofile(modpath .. "/nodes.lua")

-- Machines
dofile(modpath .. "/machines/init.lua")

-- Crafting
dofile(modpath .. "/crafting.lua")
