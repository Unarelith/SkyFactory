local S = factory.S

minetest.register_node("factory:factory_brick", {
	description = S("Factory Brick"),
	tiles = {"factory_brick.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1}
})

if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("factory", "factory_brick", "factory:factory_brick", {
		description = S("Factory Brick"),
		tiles = {"factory_brick.png"},
		groups = {cracky=3, stone=1},
	})
end