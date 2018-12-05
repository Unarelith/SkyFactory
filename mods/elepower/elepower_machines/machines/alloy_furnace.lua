
elepm.register_craft_type("alloy", {
	description = "Alloying",
	inputs      = 2,
})

elepm.register_crafter("elepower_machines:alloy_furnace", {
	description = "Alloy Furnace",
	craft_type = "alloy",
	ele_active_node = true,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_alloy_furnace.png",
	},
	ele_active_nodedef = {
		tiles = {
			"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
			"elepower_machine_side.png", "elepower_machine_side.png", "elepower_alloy_furnace_active.png",
		},
	},
	groups = {oddly_breakable_by_hand = 1}
})
