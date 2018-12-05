
----------------------
-- Power Generation --
----------------------

elepm.register_fuel_generator("elepower_machines:generator", {
	description = "Coal-fired Generator",
	ele_active_node = true,
	ele_capacity = 6400,
	ele_usage = 16,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_generator.png",
	},
	ele_active_nodedef = {
		tiles = {
			"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
			"elepower_machine_side.png", "elepower_machine_side.png", "elepower_generator_active.png",
		}
	},
	groups = {oddly_breakable_by_hand = 1}
})
