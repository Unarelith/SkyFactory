
elepm.register_craft_type("compress", {
	description = "Compressing",
	inputs      = 1,
})

elepm.register_crafter("elepower_machines:compressor", {
	description = "Compressor",
	craft_type = "compress",
	ele_usage = 32,
	tiles = {
		"elepower_machine_top.png^elepower_power_port.png", "elepower_machine_base.png^elepower_power_port.png",
		"elepower_compressor.png", "elepower_compressor.png", "elepower_compressor.png", "elepower_compressor.png",
	},
	ele_no_automatic_ports = true,
	groups = {oddly_breakable_by_hand = 1}
})
