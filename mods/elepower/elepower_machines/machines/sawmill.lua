
elepm.register_craft_type("saw", {
	description = "Sawmilling",
	inputs      = 1,
	gui_name    = "elepower_saw",
})

elepm.register_crafter("elepower_machines:sawmill", {
	description = "Sawmill",
	craft_type = "saw",
	ele_usage = 32,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_sawmill.png",
	},
	groups = {oddly_breakable_by_hand = 1}
})
