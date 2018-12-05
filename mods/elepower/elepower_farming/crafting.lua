
-----------
-- Nodes --
-----------

-- Device Frame
minetest.register_craft({
	output = "elepower_farming:device_frame",
	recipe = {
		{"homedecor:plastic_sheeting", "default:glass", "homedecor:plastic_sheeting"},
		{"default:glass", "default:mese_crystal", "default:glass"},
		{"homedecor:plastic_sheeting", "default:glass", "homedecor:plastic_sheeting"},
	}
})

-- Planter
minetest.register_craft({
	output = "elepower_farming:planter",
	recipe = {
		{"elepower_dynamics:nickel_ingot", "elepower_dynamics:control_circuit", "elepower_dynamics:nickel_ingot"},
		{"farming:hoe_steel", "elepower_farming:device_frame", "farming:hoe_steel"},
		{"elepower_dynamics:wound_copper_coil", "elepower_dynamics:motor", "elepower_dynamics:wound_copper_coil"},
	}
})

-- Harvester
minetest.register_craft({
	output = "elepower_farming:harvester",
	recipe = {
		{"elepower_dynamics:nickel_ingot", "elepower_dynamics:control_circuit", "elepower_dynamics:nickel_ingot"},
		{"default:axe_steel", "elepower_farming:device_frame", "farming:hoe_steel"},
		{"elepower_dynamics:motor", "elepower_dynamics:diamond_gear", "elepower_dynamics:motor"},
	}
})

-- Tree Extractor
minetest.register_craft({
	output = "elepower_farming:tree_extractor",
	recipe = {
		{"elepower_dynamics:motor", "bucket:bucket_empty", "elepower_dynamics:motor"},
		{"elepower_dynamics:tree_tap", "elepower_farming:device_frame", "elepower_dynamics:tree_tap"},
		{"elepower_dynamics:copper_gear", "elepower_dynamics:servo_valve", "elepower_dynamics:copper_gear"},
	}
})

-- Composter
minetest.register_craft({
	output = "elepower_farming:composter",
	recipe = {
		{"elepower_dynamics:motor", "bucket:bucket_empty", "elepower_dynamics:motor"},
		{"elepower_dynamics:electrum_gear", "elepower_farming:device_frame", "elepower_dynamics:electrum_gear"},
		{"elepower_dynamics:copper_gear", "elepower_dynamics:servo_valve", "elepower_dynamics:copper_gear"},
	}
})
