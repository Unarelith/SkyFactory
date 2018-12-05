
ele.register_fluid_generator("elepower_machines:lava_generator", {
	description = "Lava Generator",
	ele_usage = 64,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_lava_generator.png",
	},
	ele_active_node = true,
	ele_active_nodedef = {
		tiles = {
			"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
			"elepower_machine_side.png", "elepower_machine_side.png", "elepower_lava_generator_active.png",
		},
	},
	fluid_buffers = {
		lava = {
			capacity  = 8000,
			accepts   = {"default:lava_source"},
			drainable = false
		}
	},
	tube = false,
})
