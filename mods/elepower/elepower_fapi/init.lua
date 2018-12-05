-- A Elepower Mod
-- Copyright 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

elefluid = rawget(_G, "elefluid") or {}
elefluid.modpath = modpath

dofile(modpath.."/transfer.lua")
dofile(modpath.."/transfer_node.lua")
dofile(modpath.."/formspec.lua")
