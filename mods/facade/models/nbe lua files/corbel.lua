-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node("test:node_1", {
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}, -- NodeBox2
			{-0.1875, -0.3125, -0.3125, 0.1875, 0.5, 0}, -- NodeBox3
		}
	}
})

