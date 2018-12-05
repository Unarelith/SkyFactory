minetest.register_node("factory:sieve_stack", {
	drawtype = "nodebox",
	tiles = {"factory_brick.png"},
	paramtype = "light",
	description = factory.S("stack sieve"),
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5,  0.5, -0.3},
			{-0.5, -0.5,  0.5,  0.5,  0.5,  0.3},
			{-0.5, -0.5, -0.5, -0.3,  0.5,  0.5},
			{ 0.5, -0.5, -0.5,  0.3,  0.5,  0.5},
		}
	},
})
minetest.register_node("factory:half_sieve_stack", {
	drawtype = "nodebox",
	tiles = {"factory_brick.png"},
	paramtype = "light",
	description = factory.S("half stack sieve"),
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5,  0, -0.31},
			{-0.5, -0.5,  0.5,  0.5,  0,  0.31},
			{-0.5, -0.5, -0.5, -0.31,  0,  0.5},
			{ 0.5, -0.5, -0.5,  0.31,  0,  0.5},
		}
	},
})

minetest.register_node("factory:sieve_single", {
	drawtype = "nodebox",
	tiles = {"factory_brick.png"},
	paramtype = "light",
	description = factory.S("item sieve"),
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5,  0.5, -0.21},
			{-0.5, -0.5,  0.5,  0.5,  0.5,  0.21},
			{-0.5, -0.5, -0.5, -0.21,  0.5,  0.5},
			{ 0.5, -0.5, -0.5,  0.21,  0.5,  0.5},
		}
	},
})
minetest.register_node("factory:half_sieve_single", {
	drawtype = "nodebox",
	tiles = {"factory_brick.png"},
	paramtype = "light",
	description = factory.S("half item sieve"),
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5,  0, -0.21},
			{-0.5, -0.5,  0.5,  0.5,  0,  0.21},
			{-0.5, -0.5, -0.5, -0.21,  0,  0.5},
			{ 0.5, -0.5, -0.5,  0.21,  0,  0.5},
		}
	},
})