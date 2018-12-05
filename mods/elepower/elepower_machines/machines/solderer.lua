
elepm.register_craft_type("solder", {
	description = "Soldering",
	inputs      = 3,
})

elepm.register_crafter("elepower_machines:solderer", {
	description = "Solderer",
	craft_type = "solder",
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_solderer.png",
	},
	groups = {oddly_breakable_by_hand = 1, cracky = 2},
	ele_usage = 128,
	ele_inrush = 128,
})
