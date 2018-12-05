
elepm.register_craft_type("can", {
	description = "Canning",
	inputs      = 2,
})

elepm.register_crafter("elepower_machines:canning_machine", {
	description = "Canning Machine",
	craft_type = "can",
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_canning_machine.png",
	},
	groups = {ele_user = 1, oddly_breakable_by_hand = 1},
})
