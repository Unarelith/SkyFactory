
-- Electric power
ele.register_conduit("elepower_dynamics:conduit", {
	description = "Power Conduit",
	tiles = {"elepower_conduit.png"},
	groups = {oddly_breakable_by_hand = 1, cracky = 1}
})

-- Fluids
elefluid.register_transfer_node("elepower_dynamics:fluid_transfer_node", {
	description = "Fluid Transfer Node\nPunch to start pumping",
	tiles = {"elepower_fluid_transporter.png"},
	drawtype = "mesh",
	mesh = "elepower_transport_node.obj",
	groups = {oddly_breakable_by_hand = 1, cracky = 1},
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.4375, -0.5000, 0.4375, 0.4375, 0.000},
			{-0.1875, -0.1875, 0.000, 0.1875, 0.1875, 0.5000}
		}
	}
})

elefluid.register_transfer_duct("elepower_dynamics:fluid_duct", {
	description = "Fluid Duct",
	tiles = {"elepower_duct.png"},
	groups = {oddly_breakable_by_hand = 1, cracky = 1}
})
