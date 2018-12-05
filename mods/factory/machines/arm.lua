local S = factory.S
minetest.register_node("factory:arm",{
	drawtype = "nodebox",
	tiles = {"factory_steel_noise.png"},
	paramtype = "light",
	description = S("Pneumatic Mover"),
	groups = {cracky=3},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.5,0.5,-0.4375,0.5}, --base1
			{-0.125,-0.5,-0.375,0.125,0.0625,0.375}, --base2
			{-0.125,0.25,-0.5,0.125,0.3125,0.375}, --tube
			{-0.375,-0.5,-0.0625,0.375,0.0625,0.0625}, --base3
			{-0.125,-0.125,0.375,0.125,0.125,0.5}, --tube2
			{-0.125,0.0625,0.3125,0.125,0.25,0.375}, --NodeBox6
			{-0.125,0.0625,-0.5,-0.0625,0.25,0.3125}, --NodeBox7
			{0.0625,0.0625,-0.5,0.125,0.25,0.3125}, --NodeBox8
			{-0.0625,0.0625,-0.5,0.0625,0.125,0.3125}, --NodeBox9
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.5,0.5,0.5,0.5},
		}
	},
})

minetest.register_abm({
	nodenames = {"factory:arm"},
	neighbors = nil,
	interval = 1,
	chance = 1,
	action = function(pos)
		local insert = factory.insert_object_item
		local all_objects = minetest.get_objects_inside_radius(pos, 0.8)
		for _,obj in ipairs(all_objects) do
			if not obj:is_player() and obj:get_luaentity()
			and (obj:get_luaentity().name == "__builtin:item" or obj:get_luaentity().name == "factory:moving_item") then
				local a = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				local b = vector.add(pos,a)
				local target = minetest.get_node(b)
				local stack = ItemStack(obj:get_luaentity().itemstring)

				if target.name == "default:chest" or target.name == "default:chest_locked" then
					local meta = minetest.env:get_meta(b)
					local inv = meta:get_inventory()
					if not insert(inv,"main", stack, obj) then
						obj:setvelocity({x=0,y=0,z=0})
						obj:moveto({x = b.x + a.x, y = pos.y + 0.5, z = b.z + a.z}, false)
					end
				end
				if factory.has_fuel_input(target) then
					if minetest.dir_to_facedir({x = -a.x, y = -a.y, z = -a.z}) == minetest.get_node(b).param2 then
						local meta = minetest.env:get_meta(b)
						local inv = meta:get_inventory()

						-- back, fuel
						if not insert(inv,"fuel", stack, obj) then
							obj:setvelocity({x=0,y=0,z=0})
							obj:moveto({x = b.x + a.x, y = pos.y + 0.5, z = b.z + a.z}, false)
						end
						return
					end
				end

				if factory.has_src_input(target) then
					local meta = minetest.env:get_meta(b)
					local inv = meta:get_inventory()

					if not insert(inv,"src", stack, obj) then
						obj:setvelocity({x=0,y=0,z=0})
						obj:moveto({x = b.x + a.x, y = pos.y + 0.5, z = b.z + a.z}, false)
					end
				end
			end
		end
	end,
})