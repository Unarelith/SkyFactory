
---------------
-- Overrides --
---------------

-- Remove iron_lump -> steel_ingot, because dynamics adds iron ingot
minetest.clear_craft({type = "cooking", output = "default:steel_ingot"})

-----------
-- Tools --
-----------

-- Pickaxes

minetest.register_craft({
	output = 'elepower_dynamics:pick_iron',
	recipe = {
		{'elepower_dynamics:iron_ingot', 'elepower_dynamics:iron_ingot', 'elepower_dynamics:iron_ingot'},
		{'', 'group:stick', ''},
		{'', 'group:stick', ''},
	}
})

minetest.register_craft({
	output = 'elepower_dynamics:pick_lead',
	recipe = {
		{'elepower_dynamics:lead_ingot', 'elepower_dynamics:lead_ingot', 'elepower_dynamics:lead_ingot'},
		{'', 'group:stick', ''},
		{'', 'group:stick', ''},
	}
})

-- Shovels

minetest.register_craft({
	output = 'elepower_dynamics:shovel_iron',
	recipe = {
		{'elepower_dynamics:iron_ingot'},
		{'group:stick'},
		{'group:stick'},
	}
})

minetest.register_craft({
	output = 'elepower_dynamics:shovel_lead',
	recipe = {
		{'elepower_dynamics:lead_ingot'},
		{'group:stick'},
		{'group:stick'},
	}
})

-- Axes

minetest.register_craft({
	output = 'elepower_dynamics:axe_iron',
	recipe = {
		{'elepower_dynamics:iron_ingot', 'elepower_dynamics:iron_ingot'},
		{'elepower_dynamics:iron_ingot', 'group:stick'},
		{'', 'group:stick'},
	}
})

minetest.register_craft({
	output = 'elepower_dynamics:axe_lead',
	recipe = {
		{'elepower_dynamics:lead_ingot', 'elepower_dynamics:lead_ingot'},
		{'elepower_dynamics:lead_ingot', 'group:stick'},
		{'', 'group:stick'},
	}
})

-- Swords

minetest.register_craft({
	output = 'elepower_dynamics:sword_iron',
	recipe = {
		{'elepower_dynamics:iron_ingot'},
		{'elepower_dynamics:iron_ingot'},
		{'group:stick'},
	}
})

minetest.register_craft({
	output = 'elepower_dynamics:sword_lead',
	recipe = {
		{'elepower_dynamics:lead_ingot'},
		{'elepower_dynamics:lead_ingot'},
		{'group:stick'},
	}
})

-- Bucket

minetest.register_craft({
	output = 'bucket:bucket_empty',
	recipe = {
		{'elepower_dynamics:iron_ingot', '', 'elepower_dynamics:iron_ingot'},
		{'', 'elepower_dynamics:iron_ingot', ''},
	}
})

-----------
-- Nodes --
-----------

minetest.register_craft({
	type   = "shapeless",
	output = "elepower_dynamics:particle_board",
	recipe = {
		"elepower_dynamics:wood_dust",
		"elepower_dynamics:wood_dust",
		"elepower_dynamics:wood_dust",
		"elepower_dynamics:wood_dust",
	}
})

-- Conduit
minetest.register_craft({
	output = "elepower_dynamics:conduit 8",
	recipe = {
		{"elepower_dynamics:lead_ingot",  "elepower_dynamics:lead_ingot",  "elepower_dynamics:lead_ingot"},
		{"elepower_dynamics:copper_wire", "elepower_dynamics:copper_wire", "elepower_dynamics:copper_wire"},
		{"elepower_dynamics:lead_ingot",  "elepower_dynamics:lead_ingot",  "elepower_dynamics:lead_ingot"},
	}
})

-- Duct
minetest.register_craft({
	output = "elepower_dynamics:fluid_duct 8",
	recipe = {
		{"default:glass",  "default:glass",  "default:glass"},
		{"elepower_dynamics:lead_ingot", "elepower_dynamics:lead_ingot", "elepower_dynamics:lead_ingot"},
		{"default:glass",  "default:glass",  "default:glass"},
	}
})

-- Portable Tank
minetest.register_craft({
	output = "elepower_dynamics:portable_tank",
	recipe = {
		{"default:glass", "elepower_dynamics:fluid_duct", "default:glass"},
		{"default:glass", "default:glass", "default:glass"},
		{"default:bronze_ingot",  "default:bronze_ingot", "default:bronze_ingot"},
	}
})

-----------
-- Items --
-----------

minetest.register_craft({
	output = "elepower_dynamics:wound_copper_coil",
	recipe = {
		{"", "default:copper_ingot", ""},
		{"default:copper_ingot", "elepower_dynamics:iron_ingot", "default:copper_ingot"},
		{"", "default:copper_ingot", ""}
	}
})

minetest.register_craft({
	output = "elepower_dynamics:wound_silver_coil",
	recipe = {
		{"", "moreores:silver_ingot", ""},
		{"moreores:silver_ingot", "elepower_dynamics:zinc_ingot", "moreores:silver_ingot"},
		{"", "moreores:silver_ingot", ""}
	}
})

minetest.register_craft({
	output = "elepower_dynamics:copper_wire 8",
	recipe = {
		{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
		{"default:copper_ingot", "",                     "default:copper_ingot"},
		{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"}
	}
})

minetest.register_craft({
	output = "elepower_dynamics:servo_valve 3",
	recipe = {
		{"", "elepower_dynamics:wound_copper_coil", ""},
		{"elepower_dynamics:fluid_duct", "elepower_dynamics:fluid_duct", "elepower_dynamics:fluid_duct"},
	}
})

minetest.register_craft({
	output = "elepower_dynamics:tree_tap",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"", "", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "elepower_dynamics:chip 6",
	recipe = {
		{"homedecor:plastic_sheeting", "homedecor:plastic_sheeting", "homedecor:plastic_sheeting"},
		{"default:mese_crystal", "group:color_black", "default:mese_crystal"},
		{"default:copper_ingot", "moreores:silver_ingot", "default:copper_ingot"},
	}
})

minetest.register_craft({
	output = "elepower_dynamics:capacitor 6",
	recipe = {
		{"homedecor:plastic_sheeting", "homedecor:plastic_sheeting", "homedecor:plastic_sheeting"},
		{"moreores:silver_ingot", "default:mese_crystal", "moreores:silver_ingot"},
		{"default:copper_ingot", "group:color_violet", "default:copper_ingot"},
	}
})

	minetest.register_craft({
	output = "elepower_dynamics:pcb_blank",
	recipe = {
		{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
		{"default:copper_ingot", "default:mese_crystal", "default:copper_ingot"},
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "elepower_dynamics:acidic_compound",
	recipe = {
		"elepower_dynamics:copper_dust",
		"elepower_dynamics:copper_dust",
		"elepower_dynamics:copper_dust",
		"elepower_dynamics:copper_dust",
		"farming:seed_wheat",
	}
})

-- Fluid Transfer Node
minetest.register_craft({
	output = "elepower_dynamics:fluid_transfer_node 3",
	recipe = {
		{"group:stone",  "elepower_dynamics:control_circuit",  "group:stone"},
		{"elepower_dynamics:electrum_gear", "elepower_dynamics:servo_valve", "elepower_dynamics:electrum_gear"},
		{"group:stone",  "elepower_dynamics:fluid_duct",  "group:stone"},
	}
})

minetest.register_craft({
	output = "elepower_dynamics:battery 2",
	recipe = {
		{"elepower_dynamics:zinc_dust", "elepower_dynamics:wound_copper_coil", "elepower_dynamics:lead_dust"},
		{"elepower_dynamics:tin_plate", "default:mese_crystal_fragment", "elepower_dynamics:tin_plate"},
		{"elepower_dynamics:tin_plate", "default:mese_crystal_fragment", "elepower_dynamics:tin_plate"},
	}
})

minetest.register_craft({
	output = "elepower_dynamics:lcd_panel",
	recipe = {
		{"group:color_red", "group:color_green", "group:color_blue"},
		{"moreores:silver_ingot", "elepower_dynamics:wound_copper_coil", "moreores:silver_ingot"},
		{"", "default:meselamp", ""}
	}
})

minetest.register_craft({
	output = "elepower_dynamics:pv_cell",
	recipe = {
		{"default:glass", "default:glass", "default:glass"},
		{"group:color_blue", "elepower_dynamics:silicon_wafer_doped", "group:color_blue"},
		{"default:mese_crystal_fragment", "elepower_dynamics:wound_copper_coil", "default:mese_crystal_fragment"}
	}
})

minetest.register_craft({
	output = "elepower_dynamics:integrated_circuit",
	recipe = {
		{"elepower_dynamics:chip", "elepower_dynamics:chip", "elepower_dynamics:chip"},
		{"elepower_dynamics:capacitor", "elepower_dynamics:pcb", "elepower_dynamics:capacitor"},
		{"default:copper_ingot", "default:mese_crystal", "default:gold_ingot"},
	}
})

minetest.register_craft({
	output = "elepower_dynamics:motor 3",
	recipe = {
		{"default:steel_ingot", "elepower_dynamics:wound_copper_coil", "default:steel_ingot"},
		{"elepower_dynamics:copper_wire", "elepower_dynamics:wound_copper_coil", "elepower_dynamics:copper_wire"},
		{"default:steel_ingot", "elepower_dynamics:capacitor", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "elepower_dynamics:tin_can 8",
	recipe = {
		{"elepower_dynamics:tin_plate", ""},
		{"", "elepower_dynamics:tin_plate"}
	}
})

minetest.register_craft({
	output = "elepower_dynamics:gas_container 8",
	recipe = {
		{"elepower_dynamics:steel_plate", "", "elepower_dynamics:steel_plate"},
		{"elepower_dynamics:steel_plate", "", "elepower_dynamics:steel_plate"},
		{"", "elepower_dynamics:steel_plate", ""}
	}
})

--------------
-- Smelting --
--------------

minetest.register_craft({
	type   = "cooking",
	output = "elepower_dynamics:iron_ingot",
	recipe = "default:iron_lump"
})

minetest.register_craft({
	type   = "cooking",
	output = "elepower_dynamics:lead_ingot",
	recipe = "elepower_dynamics:lead_lump"
})

minetest.register_craft({
	type   = "cooking",
	output = "elepower_dynamics:nickel_ingot",
	recipe = "elepower_dynamics:nickel_lump"
})

minetest.register_craft({
	type   = "cooking",
	output = "elepower_dynamics:zinc_ingot",
	recipe = "elepower_dynamics:zinc_lump"
})

minetest.register_craft({
	type     = "cooking",
	output   = "elepower_dynamics:viridisium_ingot",
	recipe   = "elepower_dynamics:viridisium_lump",
	cooktime = 10,
})

-----------
-- Gears --
-----------

local keywords = { "_ingot", "" }
for mat, data in pairs(elepd.registered_gears) do
	for _,keyword in ipairs(keywords) do
		local found     = ele.helpers.scan_item_list(mat .. keyword)
		local immebreak = false

		if mat == "wood" then
			found = "group:stick"
			immebreak = true
		end

		if found then
			-- Gear recipe for material
			minetest.register_craft({
				recipe = {
					{ "",    found, "" },
					{ found, "",    found},
					{ "",    found, "" }
				},
				output = data.item
			})

			if immebreak then break end
		end
	end
end

-----------
-- Nodes --
-----------

local function blockcraft(mat)
	local ingot = "elepower_dynamics:" .. mat .. "_ingot"
	local block = "elepower_dynamics:" .. mat .. "_block"
	minetest.register_craft({
		type   = "shapeless",
		output = block,
		recipe = {
			ingot, ingot, ingot,
			ingot, ingot, ingot,
			ingot, ingot, ingot,
		}
	})

	minetest.register_craft({
		type   = "shapeless",
		output = ingot .. " 9",
		recipe = { block },
	})
end

blockcraft("viridisium")
blockcraft("nickel")
blockcraft("invar")
blockcraft("lead")
blockcraft("zinc")
