
-------------------
-- Power Storage --
-------------------

elepm.register_storage("elepower_machines:power_cell", {
	description = "Power Cell",
	ele_capacity = 16000,
	ele_inrush = 128,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_power_cell.png",
	},
	groups = {oddly_breakable_by_hand = 1}
})
