
elepm.register_craft_type("grind", {
	description = "Grinding",
	inputs      = 1,
})

elepm.register_crafter("elepower_machines:pulverizer", {
	description = "Pulverizer",
	craft_type = "grind",
	ele_active_node = true,
	ele_usage = 32,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_grinder.png",
	},
	ele_active_nodedef = {
		tiles = {
			"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
			"elepower_machine_side.png", "elepower_machine_side.png", "elepower_grinder_active.png",
		},
	},
	groups = {oddly_breakable_by_hand = 1}
})
