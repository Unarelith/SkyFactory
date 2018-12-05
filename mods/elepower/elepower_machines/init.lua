-- Elepower Mod
-- Copyright 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

elepm = rawget(_G, "elepm") or {}
elepm.modpath = modpath

-- Utility
dofile(modpath.."/craft.lua")

-- Machines
dofile(modpath.."/machines/init.lua")

-- Other
dofile(modpath.."/nodes.lua")
dofile(modpath.."/craftitems.lua")

-- Crafting recipes
dofile(modpath.."/crafting.lua")
