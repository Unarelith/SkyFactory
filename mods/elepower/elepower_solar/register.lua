
elesolar.register_solar_generator("elepower_solar:solar_generator", {
	description = "Solar Generator",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5000, -0.5000, -0.5000, 0.5000, -0.4375, 0.5000}
		}
	},
	tiles = {
		"elesolar_simple_top.png", "elepower_machine_top.png^elepower_power_port.png", "elepower_machine_top.png"
	}
})
