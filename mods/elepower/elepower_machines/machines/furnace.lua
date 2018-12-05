
-------------
-- Furnace --
-------------

elepm.register_crafter("elepower_machines:furnace", {
	description = "Powered Furnace",
	craft_type = "cooking",
	ele_active_node = true,
	ele_usage = 32,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_furnace.png",
	},
	ele_active_nodedef = {
		tiles = {
			"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
			"elepower_machine_side.png", "elepower_machine_side.png", "elepower_furnace_active.png",
		},
	},
	groups = {oddly_breakable_by_hand = 1}
})
