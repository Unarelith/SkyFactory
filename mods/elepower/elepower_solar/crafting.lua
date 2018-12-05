
-- Solar Generator
minetest.register_craft({
	output = "elepower_solar:solar_generator",
	recipe = {
		{"default:glass", "elepower_dynamics:pv_cell", "default:glass"},
		{"elepower_dynamics:pv_cell", "default:glass", "elepower_dynamics:pv_cell"},
		{"default:steel_ingot", "elepower_dynamics:battery", "default:steel_ingot"},
	}
})
