
-- Drill
minetest.register_craft({
	output = "elepower_tools:drill_bit",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "elepower_tools:hand_drill",
	recipe = {
		{"", "elepower_dynamics:wound_copper_coil", "elepower_tools:drill_bit"},
		{"default:steel_ingot", "elepower_dynamics:battery", "default:steel_ingot"},
		{"elepower_dynamics:motor", "elepower_dynamics:capacitor", ""},
	}
})

-- Chainsaw
minetest.register_craft({
	output = "elepower_tools:chain",
	recipe = {
		{"", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "elepower_dynamics:steel_plate", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", ""},
	}
})

minetest.register_craft({
	output = "elepower_tools:chainsaw",
	recipe = {
		{"", "elepower_dynamics:wound_copper_coil", "elepower_tools:chain"},
		{"default:steel_ingot", "elepower_dynamics:battery", "default:steel_ingot"},
		{"elepower_dynamics:motor", "elepower_dynamics:capacitor", ""},
	}
})
