-- Elepower Mod
-- Copyright 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

ele = rawget(_G, "ele") or {}
ele.modpath = modpath

-- Constants
ele.unit = "EpU"
ele.unit_description = "Elepower Unit"

-- APIs
dofile(modpath..'/helpers.lua')
dofile(modpath..'/network.lua')
dofile(modpath..'/formspec.lua')
dofile(modpath..'/machine.lua')
dofile(modpath..'/conductor.lua')
dofile(modpath..'/tool.lua')
