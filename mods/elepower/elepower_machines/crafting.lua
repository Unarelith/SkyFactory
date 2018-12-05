
--*****************--
-- MACHINE RECIPES --
--*****************--

--------------
-- Alloying --
--------------

local alloy_recipes = {
	{
		recipe = { "elepower_dynamics:iron_ingot", "elepower_dynamics:coal_dust 4" },
		output = "default:steel_ingot",
		time   = 6,
	},
	{
		recipe = { "default:copper_ingot 2", "default:tin_ingot" },
		output = "default:bronze_ingot 3",
	},
	{
		recipe = { "elepower_dynamics:iron_ingot 3", "elepower_dynamics:nickel_ingot" },
		output = "elepower_dynamics:invar_ingot 4",
	},
	{
		recipe = { "default:gold_ingot 2", "elepower_dynamics:invar_ingot" },
		output = "elepower_dynamics:electrum_ingot 3",
	},
	{
		recipe = { "elepower_dynamics:silicon", "elepower_dynamics:coal_dust 2" },
		output = "elepower_dynamics:silicon_wafer",
	},
	{
		recipe = { "default:coal_lump", "elepower_dynamics:coal_dust 4" },
		output = "elepower_dynamics:graphite_ingot",
	},
	{
		recipe = { "elepower_dynamics:silicon_wafer", "elepower_dynamics:gold_dust 4" },
		output = "elepower_dynamics:silicon_wafer_doped",
		time   = 8,
	},
}

-- Register alloy furnace recipes
for _,i in pairs(alloy_recipes) do
	elepm.register_craft({
		type   = "alloy",
		recipe = i.recipe,
		output = i.output,
		time   = i.time or 4
	})
end

--------------
-- Grinding --
--------------

local keywords  = { _ingot = 1, _lump = 2, _block = 9, block = 9 }
local ingot_map = {}
local block_map = {}
for mat, data in pairs(elepd.registered_dusts) do
	local kwfound = nil
	for keyword,count in pairs(keywords) do
		local found = ele.helpers.scan_item_list(mat .. keyword)
		if found then
			if keyword == "_ingot" and not kwfound then
				kwfound = found
			elseif keyword == "_block" or keyword == "block" and not block_map[mat] then
				block_map[mat] = found
			end

			-- Grind recipe for material
			elepm.register_craft({
				type   = "grind",
				recipe = { found },
				output = data.item .. " " .. count,
				time   = count + 4,
			})
		end
	end

	-- Add dust -> ingot smelting
	if kwfound then
		ingot_map[mat] = kwfound
		minetest.register_craft({
			type   = "cooking",
			recipe = data.item,
			output = kwfound
		})
	end
end

-- Other recipes

local grinding_recipes = {
	{
		recipe = { "farming:wheat" },
		output = "farming:flour 2",
		time   = 4,
	},
	{
		recipe = { "default:desert_sand 4" },
		output = "elepower_dynamics:silicon",
	},
	{
		recipe = { "default:sand 4" },
		output = "elepower_dynamics:silicon",
	},
	{
		recipe = { "default:cobble" },
		output = "default:gravel 4",
	},
	{
		recipe = { "default:gravel" },
		output = "default:sand 4",
	},
	{
		recipe = { "default:mese" },
		output = "default:mese_crystal 9",
	},
	{
		recipe = { "default:mese_crystal" },
		output = "default:mese_crystal_fragment 9",
	}
}

-- Register solderer recipes
for _,i in pairs(grinding_recipes) do
	elepm.register_craft({
		type   = "grind",
		recipe = i.recipe,
		output = i.output,
		time   = i.time or 8,
	})
end

-----------------
-- Compressing --
-----------------

for mat, ingot in pairs(ingot_map) do
	local plate = elepd.registered_plates[mat]
	local dust  = elepd.registered_dusts[mat]

	if plate then
		elepm.register_craft({
			type   = "compress",
			recipe = { ingot .. " 2" },
			output = plate.item,
			time   = 4,
		})

		if dust then
			elepm.register_craft({
				type   = "grind",
				recipe = { plate.item },
				output = dust.item .. " 2",
				time   = 6,
			})
		end
	end
end

-- Detect sands
for name in pairs(minetest.registered_nodes) do
	if name:match("sand") and not name:match("sandstone") then
		local sand      = name
		local sandstone = name .. "stone"
		if minetest.registered_nodes[sandstone] then
			elepm.register_craft({
				type   = "compress",
				recipe = { sand .. " 4" },
				output = sandstone,
				time   = 1,
			})

			-- Also give a grinding recipe to get the sand back
			elepm.register_craft({
				type   = "grind",
				recipe = { sandstone },
				output = sand .. " 4",
				time   = 5,
			})

			-- Find block as well
			local ssblock = sandstone .. "_block"
			if minetest.registered_nodes[ssblock] then
				elepm.register_craft({
					type   = "compress",
					recipe = { sandstone .. " 4" },
					output = ssblock,
					time   = 1,
				})
			end
		end
	end
end

local compressor_recipes = {
	{
		recipe = { "elepower_dynamics:viridisium_block 9" },
		output = "elepower_dynamics:xycrone_lump",
		time   = 20,
	},
	{
		recipe = { "default:mese_crystal_fragment 9" },
		output = "default:mese_crystal",
	},
	{
		recipe = { "default:mese_crystal 9" },
		output = "default:mese",
	}
}

-- Register compressor recipes
for _,i in pairs(compressor_recipes) do
	elepm.register_craft({
		type   = "compress",
		recipe = i.recipe,
		output = i.output,
		time   = i.time or 1
	})
end

-------------
-- Sawmill --
-------------

-- Register all logs as sawable, if we can find a planks version
minetest.after(0.2, function ()
	local wood_nodes = {}
	for name in pairs(minetest.registered_nodes) do
		if ele.helpers.get_item_group(name, "wood") then
			wood_nodes[#wood_nodes + 1] = name
		end
	end

	-- Begin making associations
	-- Get crafting recipe for all woods
	local assoc = {}
	for _,wood in ipairs(wood_nodes) do
		local recipes = minetest.get_all_craft_recipes(wood)
		for _, recipe in ipairs(recipes) do
			if recipe.items and #recipe.items == 1 then
				assoc[recipe.items[1]] = wood
			end
		end
	end

	-- Register sawmill craft
	for tree, wood in pairs(assoc) do
		elepm.register_craft({
			type   = "saw",
			recipe = { tree },
			output = {wood .. " 6", "elepower_dynamics:wood_dust"},
			time   = 8,
		})
	end
end)

---------------
-- Soldering --
---------------

local soldering_recipes = {
	{
		recipe = { "elepower_dynamics:silicon_wafer_doped", "elepower_dynamics:chip 4", "elepower_dynamics:lead_ingot 2" },
		output = "elepower_dynamics:microcontroller",
		time   = 8,
	},
	{
		recipe = { "default:copper_ingot 4", "elepower_dynamics:microcontroller 4", "elepower_dynamics:electrum_ingot 2" },
		output = "elepower_dynamics:soc",
		time   = 28,
	},
	{
		recipe = { "elepower_dynamics:microcontroller", "elepower_dynamics:control_circuit", "elepower_dynamics:capacitor 5" },
		output = "elepower_dynamics:micro_circuit",
		time   = 18,
	},
	{
		recipe = { "elepower_dynamics:chip 8", "elepower_dynamics:integrated_circuit 2", "elepower_dynamics:capacitor 4" },
		output = "elepower_dynamics:control_circuit",
		time   = 20,
	},
	{
		recipe = { "elepower_dynamics:wound_copper_coil 4", "elepower_dynamics:wound_silver_coil 2", "elepower_dynamics:copper_wire" },
		output = "elepower_dynamics:induction_coil",
		time   = 16,
	},
	{
		recipe = { "elepower_dynamics:induction_coil 4", "elepower_dynamics:copper_wire", "elepower_dynamics:zinc_dust 2" },
		output = "elepower_dynamics:induction_coil_advanced",
		time   = 18,
	}
}

-- Register solderer recipes
for _,i in pairs(soldering_recipes) do
	elepm.register_craft({
		type   = "solder",
		recipe = i.recipe,
		output = i.output,
		time   = i.time or 4
	})
end

-------------
-- Canning --
-------------

--******************--
-- CRAFTING RECIPES --
--******************--

-- Coal-fired Alloy Furnace
minetest.register_craft({
	output = "elepower_machines:coal_alloy_furnace",
	recipe = {
		{"default:brick", "default:brick", "default:brick"},
		{"default:furnace", "", "default:furnace"},
		{"default:brick", "default:brick", "default:brick"},
	}
})

-- Grindstone
minetest.register_craft({
	output = "elepower_machines:grindstone",
	recipe = {
		{"group:stone", "group:stone", "group:stone"},
		{"default:flint", "default:flint", "default:flint"},
		{"default:cobble", "default:cobble", "default:cobble"},
	}
})

minetest.register_craft({
	output = "elepower_machines:crank",
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"", "", "group:stick"},
		{"", "", "group:stick"},
	}
})

-- Machine block
minetest.register_craft({
	output = "elepower_machines:machine_block",
	recipe = {
		{"elepower_dynamics:electrum_ingot", "default:steel_ingot", "elepower_dynamics:electrum_ingot"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
		{"elepower_dynamics:electrum_ingot", "elepower_dynamics:motor", "elepower_dynamics:electrum_ingot"},
	}
})

-- Generator
minetest.register_craft({
	output = "elepower_machines:generator",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "elepower_machines:machine_block", "default:steel_ingot"},
		{"elepower_dynamics:wound_copper_coil", "default:furnace", "elepower_dynamics:wound_copper_coil"}
	}
})

-- Liquid Fuel Combustion Generator
minetest.register_craft({
	output = "elepower_machines:fuel_burner",
	recipe = {
		{"elepower_dynamics:wound_copper_coil", "elepower_dynamics:integrated_circuit", "elepower_dynamics:wound_copper_coil"},
		{"default:brick", "elepower_dynamics:portable_tank", "default:brick"},
		{"elepower_dynamics:servo_valve", "elepower_machines:generator", "elepower_dynamics:servo_valve"},
	}
})

-- Alloy Furnace
minetest.register_craft({
	output = "elepower_machines:alloy_furnace",
	recipe = {
		{"", "elepower_dynamics:integrated_circuit", ""},
		{"default:brick", "elepower_machines:machine_block", "default:brick"},
		{
			"elepower_dynamics:wound_copper_coil",
			"elepower_machines:coal_alloy_furnace",
			"elepower_dynamics:wound_copper_coil"
		},
	}
})

-- Solderer
minetest.register_craft({
	output = "elepower_machines:solderer",
	recipe = {
		{"", "elepower_dynamics:integrated_circuit", ""},
		{"elepower_dynamics:chip", "elepower_machines:machine_block", "elepower_dynamics:chip"},
		{
			"elepower_dynamics:invar_gear",
			"elepower_dynamics:wound_copper_coil",
			"elepower_dynamics:invar_gear"
		},
	}
})

-- Furnace
minetest.register_craft({
	output = "elepower_machines:furnace",
	recipe = {
		{"", "elepower_dynamics:integrated_circuit", ""},
		{"default:clay_brick", "elepower_machines:machine_block", "default:clay_brick"},
		{"elepower_dynamics:wound_copper_coil", "default:furnace", "elepower_dynamics:wound_copper_coil"},
	}
})

-- Pulverizer
minetest.register_craft({
	output = "elepower_machines:pulverizer",
	recipe = {
		{"", "elepower_dynamics:integrated_circuit", ""},
		{"default:flint", "elepower_machines:machine_block", "default:flint"},
		{"elepower_dynamics:wound_copper_coil", "elepower_dynamics:lead_gear", "elepower_dynamics:wound_copper_coil"},
	}
})

-- Sawmill
minetest.register_craft({
	output = "elepower_machines:sawmill",
	recipe = {
		{"", "elepower_dynamics:integrated_circuit", ""},
		{"elepower_dynamics:steel_gear", "elepower_machines:machine_block", "elepower_dynamics:steel_gear"},
		{"elepower_dynamics:lead_ingot", "elepower_dynamics:diamond_gear", "elepower_dynamics:lead_ingot"},
	}
})

-- Power Cell
minetest.register_craft({
	output = "elepower_machines:power_cell_0",
	recipe = {
		{"elepower_dynamics:lead_ingot", "elepower_dynamics:control_circuit", "elepower_dynamics:lead_ingot"},
		{"elepower_dynamics:wound_copper_coil", "elepower_machines:machine_block", "elepower_dynamics:wound_copper_coil"},
		{"elepower_dynamics:lead_ingot", "elepower_dynamics:battery", "elepower_dynamics:lead_ingot"},
	}
})

-- Water Accumulator
minetest.register_craft({
	output = "elepower_machines:accumulator",
	recipe = {
		{"", "elepower_dynamics:fluid_duct", ""},
		{"default:glass", "elepower_machines:machine_block", "default:glass"},
		{"elepower_dynamics:steel_gear", "elepower_dynamics:servo_valve", "elepower_dynamics:steel_gear"},
	}
})

-- Lava Cooler
minetest.register_craft({
	output = "elepower_machines:lava_cooler",
	recipe = {
		{"bucket:bucket_water", "elepower_dynamics:control_circuit", "bucket:bucket_lava"},
		{"elepower_dynamics:fluid_duct", "elepower_machines:machine_block", "elepower_dynamics:fluid_duct"},
		{"elepower_dynamics:servo_valve", "elepower_dynamics:tin_gear", "elepower_dynamics:servo_valve"},
	},
	replacements = {
		{"bucket:bucket_water", "bucket:bucket_empty"},
		{"bucket:bucket_lava", "bucket:bucket_empty"},
	}
})

-- Lava Generator
minetest.register_craft({
	output = "elepower_machines:lava_generator",
	recipe = {
		{"elepower_dynamics:wound_silver_coil", "elepower_dynamics:control_circuit", "elepower_dynamics:wound_silver_coil"},
		{"default:brick", "elepower_machines:machine_block", "default:brick"},
		{"elepower_dynamics:invar_gear", "elepower_dynamics:servo_valve", "elepower_dynamics:invar_gear"},
	},
})

-- Compressor Piston
minetest.register_craft({
	output = "elepower_machines:compressor_piston",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"", "default:steel_ingot", ""},
		{"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"},
	}
})

minetest.register_craft({
	output = "elepower_machines:compressor_piston",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"", "default:steel_ingot", ""},
		{"", "elepower_dynamics:bronze_plate", ""},
	}
})

-- Compressor
minetest.register_craft({
	output = "elepower_machines:compressor",
	recipe = {
		{"elepower_dynamics:integrated_circuit", "elepower_machines:compressor_piston", "elepower_dynamics:wound_copper_coil"},
		{"elepower_dynamics:steel_gear", "elepower_machines:machine_block", "elepower_dynamics:steel_gear"},
		{"default:steel_ingot", "elepower_machines:compressor_piston", "default:steel_ingot"},
	}
})

-- Turbine blades
minetest.register_craft({
	output = "elepower_machines:turbine_blades",
	recipe = {
		{"elepower_dynamics:steel_plate", "elepower_dynamics:steel_plate", "elepower_dynamics:steel_plate"},
		{"elepower_dynamics:steel_plate", "default:steel_ingot",           "elepower_dynamics:steel_plate"},
		{"elepower_dynamics:steel_plate", "elepower_dynamics:steel_plate", "elepower_dynamics:steel_plate"},
	}
})

-- Steam Turbine
minetest.register_craft({
	output = "elepower_machines:steam_turbine",
	recipe = {
		{"elepower_dynamics:induction_coil", "elepower_machines:turbine_blades", "elepower_dynamics:induction_coil"},
		{"elepower_dynamics:steel_plate", "elepower_machines:machine_block", "elepower_dynamics:steel_plate"},
		{"elepower_dynamics:invar_gear", "elepower_machines:turbine_blades", "elepower_dynamics:invar_gear"},
	}
})

-- Canning Machine
minetest.register_craft({
	output = "elepower_machines:canning_machine",
	recipe = {
		{"elepower_dynamics:wound_copper_coil", "elepower_machines:compressor_piston", "elepower_dynamics:wound_copper_coil"},
		{"elepower_dynamics:tin_can", "elepower_machines:machine_block", "elepower_dynamics:tin_can"},
		{"elepower_dynamics:steel_gear", "elepower_dynamics:tin_gear", "elepower_dynamics:steel_gear"},
	}
})

-- Bucketer
minetest.register_craft({
	output = "elepower_machines:bucketer",
	recipe = {
		{"", "elepower_dynamics:portable_tank", ""},
		{"elepower_dynamics:tin_can", "elepower_machines:machine_block", "elepower_dynamics:tin_can"},
		{"elepower_dynamics:servo_valve", "elepower_dynamics:tin_gear", "elepower_dynamics:servo_valve"},
	}
})

-- Electrolyzer
minetest.register_craft({
	output = "elepower_machines:electrolyzer",
	recipe = {
		{"elepower_dynamics:copper_plate", "elepower_dynamics:integrated_circuit", "elepower_dynamics:zinc_plate"},
		{"bucket:bucket_empty", "elepower_machines:machine_block", "elepower_dynamics:gas_container"},
		{"elepower_dynamics:servo_valve", "elepower_dynamics:wound_copper_coil", "elepower_dynamics:servo_valve"},
	}
})
