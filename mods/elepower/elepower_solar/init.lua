-- A Elepower Mod
-- Copyright 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

elesolar = rawget(_G, "elesolar") or {}
elesolar.modpath = modpath

dofile(modpath.."/generator.lua")
dofile(modpath.."/register.lua")
dofile(modpath.."/crafting.lua")
