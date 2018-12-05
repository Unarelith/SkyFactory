
ele.register_fluid_generator("elepower_machines:fuel_burner", {
	description = "Liquid Fuel Combustion Generator",
	ele_usage = 8,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_fuel_generator.png",
	},
	ele_active_node = true,
	ele_active_nodedef = {
		tiles = {
			"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
			"elepower_machine_side.png", "elepower_machine_side.png", "elepower_fuel_generator_active.png",
		},
	},
	fluid_buffers = {
		steam = {
			capacity  = 8000,
			drainable = false,
			accepts   = {
				"elepower_farming:biofuel_source",
			},
		}
	},
	fuel_burn_time = 8,
	fuel_usage = 100,
})
