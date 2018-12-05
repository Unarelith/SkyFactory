facade = {}

local wehavechisels =  minetest.get_modpath("mychisel")

--------------
--Bannerstones
--------------

--Node will be called facade:<subname>_bannerstone
function facade.register_bannerstone(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_bannerstone" , {
		description = desc .. " Bannerstone",
		drawtype = "nodebox",
		tiles = {
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png^facade_bannerstone.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
				{-0.5, 0.25, -0.5625, 0.5, 0.375, -0.5},
				{-0.5, -0.375, -0.5625, 0.5, -0.25, -0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			}
		},
	})
end

--Node will be called facade:<subname>_bannerstone_corner
function facade.register_bannerstone_corner(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_bannerstone_corner", {
		description = desc .. " Bannerstone Corner",
		drawtype = "nodebox",
		tiles = {
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png^facade_bannerstone.png",
		"" .. modname.. "_" .. subname .. ".png^facade_bannerstone.png",
		"" .. modname.. "_" .. subname .. ".png^facade_bannerstone.png",
		"" .. modname.. "_" .. subname .. ".png^facade_bannerstone.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
				{-0.5625, 0.25, -0.5625, 0.5625, 0.375, 0.5625},
				{-0.5625, -0.375, -0.5625, 0.5625, -0.25, 0.5625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			}
		},
	})
end

--------------
--Centerstones
--------------

--Node will be called facade:<subname>_centerstone
function facade.register_centerstone(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_centerstone", {
		description = desc .. " Centerstone",
		drawtype = "nodebox",
		tiles = {"" .. modname.. "_" .. subname .. ".png^facade_centerstone.png"},
		paramtype = "light",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375},
				{-0.5, -0.25, 0.0625, 0.5, 0.25, 0.25},
				{-0.5, -0.25, -0.25, 0.5, 0.25, -0.0625},
				{-0.25, -0.25, -0.5, -0.0625, 0.25, 0.5},
				{0.0625, -0.25, -0.5, 0.25, 0.25, 0.5},
				{-0.5, 0.0625, -0.25, 0.5, 0.25, 0.25},
				{-0.5, -0.25, -0.25, 0.5, -0.0625, 0.25},
				{-0.25, -0.25, -0.5, 0.25, -0.0625, 0.5},
				{-0.25, 0.0625, -0.5, 0.25, 0.25, 0.5},
				{-0.25, -0.5, -0.25, 0.25, 0.5, -0.0625},
				{-0.25, -0.5, 0.0625, 0.25, 0.5, 0.25},
				{0.0625, -0.5, -0.1875, 0.25, 0.5, 0.1875},
				{-0.25, -0.5, -0.1875, -0.0625, 0.5, 0.1875},
				{-0.5, 0.3125, 0.3125, 0.5, 0.5, 0.5},
				{-0.5, 0.3125, -0.5, 0.5, 0.5, -0.3125},
				{0.3125, 0.3125, -0.5, 0.5, 0.5, 0.5},
				{-0.5, 0.3125, -0.5, -0.3125, 0.5, 0.5},
				{-0.5, -0.5, -0.5, -0.3125, -0.3125, 0.5},
				{0.3125, -0.5, -0.5, 0.5, -0.3125, 0.5},
				{-0.5, -0.5, -0.5, 0.5, -0.3125, -0.3125},
				{-0.5, -0.5, 0.3125, 0.5, -0.3125, 0.5},
				{0.3125, -0.5, -0.5, 0.5, 0.5, -0.3125},
				{0.3125, -0.5, 0.3125, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0.3125, -0.3125, 0.5, 0.5},
				{-0.5, -0.5, -0.5, -0.3125, 0.5, -0.3125},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			}
		},
	})
end

---------
--Columns
---------

--Node will be called facade:<subname>_column
function facade.register_column(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_column" , {
		description = desc .. " Column",
		drawtype = "nodebox",
		tiles = {
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png^facade_column.png",
		"" .. modname.. "_" .. subname .. ".png^facade_column.png"
		},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.4375},
				{-0.5, -0.5, -0.5, -0.3125, 0.5, 0.5},
				{0.3125, -0.5, -0.5, 0.5, 0.5, 0.5},
				{0.0625, -0.5, -0.5, 0.1875, 0.5, 0.5},
				{-0.1875, -0.5, -0.5, -0.0625, 0.5, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			}
		},
	})

end


--Node will be called facade:<subname>_column_corner
function facade.register_column_corner(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_column_corner", {
		description = desc .. " Column Corner",
		drawtype = "nodebox",
		tiles = {
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png^facade_column.png",
		"" .. modname.. "_" .. subname .. ".png^facade_column.png",
		"" .. modname.. "_" .. subname .. ".png^facade_column.png",
		"" .. modname.. "_" .. subname .. ".png^facade_column.png"
		},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.5, -0.4375, 0.4375, 0.5, 0.4375},
				{-0.5, -0.5, 0.3125, -0.3125, 0.5, 0.5},
				{0.3125, -0.5, -0.5, 0.5, 0.5, -0.3125},
				{0.0625, -0.5, -0.5, 0.1875, 0.5, 0.5},
				{-0.1875, -0.5, -0.5, -0.0625, 0.5, 0.5},
				{0.3125, -0.5, 0.3125, 0.5, 0.5, 0.5},
				{-0.5, -0.5, -0.5, -0.3125, 0.5, -0.3125},
				{-0.5, -0.5, 0.0625, 0.5, 0.5, 0.1875},
				{-0.5, -0.5, -0.1875, 0.5, 0.5, -0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			}
		},
	})
end

---------
--Corbels
---------

--Node will be called facade:<subname>_corbel
function facade.register_corbel(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_corbel", {
		description = desc .. " Corbel",
		drawtype = "nodebox",
		tiles = {"" .. modname.. "_" .. subname .. ".png"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0, 0.5, 0.5, 0.5},
				{-0.1875, -0.3125, -0.3125, 0.1875, 0.5, 0},
			},
		},
	--  	selection_box = {
	--  		type = "fixed",
	--  		fixed = {
	--  			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	--  		}
	--  	},
	})
end

--Node will be called facade:<subname>_corbel_corner
function facade.register_corbel_corner(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_corbel_corner", {
		description = desc .. " Corbel Corner",
		drawtype = "nodebox",
		tiles = {"" .. modname.. "_" .. subname .. ".png"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0, 0, 0.5, 0.5},
				{0, -0.3125, -0.3125, 0.3125, 0.5, 0},
			},
		},
	--  	selection_box = {
	--  		type = "fixed",
	--  		fixed = {
	--  			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	--  		}
	--  	},
	})
end

--Node will be called facade:<subname>_corbel_corner_inner
function facade.register_corbel_corner_inner(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_corbel_corner_inner", {
		description = desc .. " Corbel Inner Corner",
		drawtype = "nodebox",
		tiles = {"" .. modname.. "_" .. subname .. ".png"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0, 0.5, 0.5, 0.5},
				{0, -0.3125, -0.3125, 0.3125, 0.5, 0},
				{-0.5, -0.5, -0.5, 0, 0.5, 0.5},
			},
		},
	--  	selection_box = {
	--  		type = "fixed",
	--  		fixed = {
	--  			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	--  		}
	--  	},
	})
end


--------------------------
--- Carved Stones
--------------------------

--Node will be called facade:<subname>_carved_stone_a
function facade.register_carved_stone_a(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_carved_stone_a", {
		description = desc .. " Carved Stone A",
		drawtype = "nodebox",
        tiles = {
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png^facade_carved_stone_a.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.5},
			{-0.5, 0.4375, -0.5, 0.5, 0.5, -0.4375},
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			{-0.4375, -0.375, -0.5, -0.3125, 0.375, -0.4375},
			{-0.5, -0.375, -0.5, -0.3125, -0.25, 0.5},
			{-0.4375, 0.25, -0.5, 0.4375, 0.375, 0.5},
			{0.3125, -0.125, -0.5, 0.4375, 0.25, 0.5},
			{-0.1875, -0.375, -0.5, 0.5, -0.25, 0.5},
			{-0.1875, -0.25, -0.5, -0.0625, 0.125, 0.5},
			{0.0625, -0.125, -0.5, 0.3125, 0, 0.5},
			{-0.0625, 0, -0.5, 0.1875, 0.125, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			},
		},
	})
end

--Node will be called facade:<subname>_carved_stone_a_corner
function facade.register_carved_stone_a_corner(modname, subname, recipeitem, desc)
	minetest.register_node("facade:" .. subname .. "_carved_stone_a_corner", {
		description = desc .. " Carved Stone A Corner",
		drawtype = "nodebox",
        tiles = {
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png^facade_carved_stone_a.png",
		"" .. modname.. "_" .. subname .. ".png",
		"" .. modname.. "_" .. subname .. ".png^facade_carved_stone_a.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.5, -0.4375, 0.5, 0.5, 0.5},
			{-0.5, 0.4375, -0.5, 0.5, 0.5, -0.4375},
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			{-0.4375, -0.375, -0.5, -0.3125, 0.375, -0.4375},
			{-0.5, -0.375, -0.5, -0.3125, -0.25, 0.1875},
			{-0.4375, 0.25, -0.5, 0.4375, 0.375, 0.5},
			{0.3125, -0.125, -0.5, 0.4375, 0.25, 0.5},
			{-0.1875, -0.375, -0.5, 0.5, -0.25, 0.5},
			{-0.1875, -0.25, -0.5, -0.0625, 0.125, 0.5},
			{0.0625, -0.125, -0.5, 0.3125, 0, 0.5},
			{-0.0625, 0, -0.5, 0.1875, 0.125, 0.5},
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.125, -0.4375, 0.5, 0.375, -0.3125},
			{-0.5, 0.25, -0.3125, 0.5, 0.375, 0.4375},
			{-0.5, -0.375, 0.3125, 0.4375, 0.375, 0.4375},
			{-0.5, -0.375, 0.3125, 0.4375, -0.25, 0.5},
			{-0.5, -0.125, -0.3125, 0.4375, 0, -0.0625},
			{-0.5, 0, -0.1875, 0.4375, 0.125, 0.1875},
			{-0.5, -0.25, 0.0625, 0.4375, 0.125, 0.1875},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			},
		},
	})
end


--------------------------
--Register Nodes/Materials
--------------------------
function facade.register_facade_nodes(modname, subname, recipeitem, desc)
	facade.register_bannerstone(modname, subname, recipeitem, desc)
	facade.register_bannerstone_corner(modname, subname, recipeitem, desc)
	facade.register_centerstone(modname, subname, recipeitem, desc)
	facade.register_column(modname, subname, recipeitem, desc)
	facade.register_column_corner(modname, subname, recipeitem, desc)
	facade.register_corbel(modname, subname, recipeitem, desc)
	facade.register_corbel_corner(modname, subname, recipeitem, desc)
	facade.register_corbel_corner_inner(modname, subname, recipeitem, desc)
	facade.register_carved_stone_a(modname, subname, recipeitem, desc)
	facade.register_carved_stone_a_corner(modname, subname, recipeitem, desc)
	if wehavechisels then                                                       -- register all nodes with mychisel mod to use them without creative priv
	    chisel.register_node("facade",subname, recipeitem, "bannerstone")
	    chisel.register_node("facade",subname, recipeitem, "bannerstone_corner")
	    chisel.register_node("facade",subname, recipeitem, "centerstone")
	    chisel.register_node("facade",subname, recipeitem, "column")
	    chisel.register_node("facade",subname, recipeitem, "column_corner")
	    chisel.register_node("facade",subname, recipeitem, "corbel")
	    chisel.register_node("facade",subname, recipeitem, "corbel_corner")
	    chisel.register_node("facade",subname, recipeitem, "corbel_corner_inner")
	    chisel.register_node("facade",subname, recipeitem, "carved_stone_a")
	    chisel.register_node("facade",subname, recipeitem, "carved_stone_a_corner")
	end
end

if wehavechisels then chisel.add_mod("facade",10) end                                -- register the total number of different designs in this mod with mychisel

facade.register_facade_nodes("default", "clay", "default:clay", "Clay")
facade.register_facade_nodes("default", "desert_sandstone", "default:desert_sandstone", "Desert Sandstone")
facade.register_facade_nodes("default", "desert_stone", "default:desert_stone", "Desert Stone")
facade.register_facade_nodes("default", "sandstone", "default:sandstone", "Sandstone")
facade.register_facade_nodes("default", "silver_sandstone", "default:silver_sandstone", "Silver Sandstone")
facade.register_facade_nodes("default", "stone", "default:stone", "Stone")
--facade.register_facade_nodes("default", "obsidian", "default:obsidian", "Obsidian")


if minetest.get_modpath( "bakedclay") then
   local clay = {
      {"white", "White"},
      {"grey", "Grey"},
      {"black", "Black"},
      {"red", "Red"},
      {"yellow", "Yellow"},
      {"green", "Green"},
      {"cyan", "Cyan"},
      {"blue", "Blue"},
      {"magenta", "Magenta"},
      {"orange", "Orange"},
      {"violet", "Violet"},
      {"brown", "Brown"},
      {"pink", "Pink"},
      {"dark_grey", "Dark Grey"},
      {"dark_green", "Dark Green"},
   }

   for _, clay in pairs(clay) do
      facade.register_facade_nodes("baked_clay", clay[1] , "bakedclay:" .. clay[1], clay[2] .. " Baked Clay")
   end
end


if minetest.get_modpath( "darkage") then
	facade.register_facade_nodes("darkage", "basalt", "darkage:basalt", "Basalt")
	facade.register_facade_nodes("darkage", "chalk", "darkage:chalk", "Chalk")
	facade.register_facade_nodes("darkage", "gneiss", "darkage:gneiss", "Gneiss")
	facade.register_facade_nodes("darkage", "marble", "darkage:marble", "Marble")
	facade.register_facade_nodes("darkage", "ors", "darkage:ors", "Ors")
	facade.register_facade_nodes("darkage", "schist", "darkage:schist", "Schist")
	facade.register_facade_nodes("darkage", "serpentine", "darkage:serpentine", "Serpentine")
	facade.register_facade_nodes("darkage", "shale", "darkage:shale", "Shale")
	facade.register_facade_nodes("darkage", "slate", "darkage:slate", "Slate")
end


if minetest.get_modpath( "nether") then
	facade.register_facade_nodes("nether", "rack", "nether:rack", "Netherrack")
end


--[[if minetest.get_modpath( "lapis") then
	facade.register_facade_nodes("lapis", "lapis_block", "lapis:lapis_block", "Lapis")
	facade.register_facade_nodes("lapis", "lapis_lazurite", "lapis:lazurite", "Lazurite")
end]]--
