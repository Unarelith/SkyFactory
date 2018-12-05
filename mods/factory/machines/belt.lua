local S = factory.S
minetest.register_node("factory:belt_center", {
	description = S("centering Conveyor Belt"),
	tiles = {{name="factory_belt_top_animation.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.4}}, "factory_belt_bottom.png",
		"factory_belt_side.png", "factory_belt_side.png", "factory_belt_side.png", "factory_belt_side.png"},
	groups = {cracky=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = true,
	legacy_facedir_simple = true,
	node_box = {
			type = "fixed",
			fixed = {{-0.5,-0.5,-0.5,0.5,0.0625,0.5},}
		},
})

minetest.register_node("factory:belt", {
	description = S("Conveyor Belt"),
	tiles = {{name="factory_belt_st_top_animation.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.4}}, "factory_belt_bottom.png",
		"factory_belt_side.png", "factory_belt_side.png", "factory_belt_side.png", "factory_belt_side.png"},
	groups = {cracky=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = true,
	legacy_facedir_simple = true,
	node_box = {
			type = "fixed",
			fixed = {{-0.5,-0.5,-0.5,0.5,0.0625,0.5},}
		},
})

minetest.register_alias("factory:belt_straight","factory:belt")

minetest.register_abm({
	nodenames = {"factory:belt_center", "factory:belt"},
	neighbors = nil,
	interval = 1,
	chance = 1,
	action = function(pos)
		local all_objects = minetest.get_objects_inside_radius(pos, 0.75)
		for _,obj in ipairs(all_objects) do
			if not obj:is_player() and obj:get_luaentity() and obj:get_luaentity().name == "__builtin:item" then
				factory.do_moving_item({x = pos.x, y = pos.y + 0.15, z = pos.z}, obj:get_luaentity().itemstring)
				obj:get_luaentity().itemstring = ""
				obj:remove()
			end
		end
	end,
})
