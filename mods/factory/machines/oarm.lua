local S = factory.S
local insert = factory.insert_object_item
local count_index = factory.count_index

function oarm_handle (a, b, target, stack, obj)
	--throws anything that is already in the inventory (more than one stack) out
	if target.name:find("default:chest") then
		local meta = minetest.env:get_meta(b)
		local inv = meta:get_inventory()
		local inv_index = count_index(inv:get_list("main"))

		if inv_index[stack:get_name()]~=nil and inv_index[stack:get_name()]>=99 then
			local pos = vector.subtract(b, a)
			local dir_right = {x = a.z, y = a.y + 0.25, z = -a.x}
			obj:moveto(vector.add(pos,dir_right), false)
		else
			if not insert(inv,"main", stack, obj) then
				local pos = vector.subtract(b, a)
				local dir_right = {x = a.z, y = a.y + 0.25, z = -a.x}
				obj:moveto(vector.add(pos,dir_right), false)
			end
		end
	end
	if target.name == "factory:swapper" then
		local meta = minetest.env:get_meta(b)
		local inv = meta:get_inventory()
		local inv_index = count_index(inv:get_list("input"))

		if inv_index[stack:get_name()]~=nil and inv_index[stack:get_name()]>=99 then
			local pos = vector.subtract(b, a)
			local dir_right = {x = a.z, y = a.y + 0.25, z = -a.x}
			obj:moveto(vector.add(pos,dir_right), false)
		else
			if not insert(inv,"input", stack, obj) then
				local pos = vector.subtract(b, a)
				local dir_right = {x = a.z, y = a.y + 0.25, z = -a.x}
				obj:moveto(vector.add(pos,dir_right), false)
			end
		end
	end
	if factory.has_fuel_input(target) then
		if minetest.dir_to_facedir({x = -a.x, y = -a.y, z = -a.z}) == minetest.get_node(b).param2 then
			local meta = minetest.env:get_meta(b)
			local inv = meta:get_inventory()
			-- back, fuel
			local inv_index = count_index(inv:get_list("fuel"))

			if inv_index[stack:get_name()]~=nil and inv_index[stack:get_name()]>=99 then
				local pos = vector.subtract(b, a)
				local dir_right = {x = a.z, y = a.y + 0.25, z = -a.x}
				obj:moveto(vector.add(pos,dir_right), false)
			else
				if not insert(inv,"fuel", stack, obj) then
					local pos = vector.subtract(b, a)
					local dir_right = {x = a.z, y = a.y + 0.25, z = -a.x}
					obj:moveto(vector.add(pos,dir_right), false)
				end
			end
			return
		end
	end
	if factory.has_src_input(target) then
		local meta = minetest.env:get_meta(b)
		local inv = meta:get_inventory()
		local inv_index = count_index(inv:get_list("src"))

		if inv_index[stack:get_name()]~=nil and inv_index[stack:get_name()]>=99 then
			local pos = vector.subtract(b, a)
			local dir_right = {x = a.z, y = a.y + 0.25, z = -a.x}
			obj:moveto(vector.add(pos,dir_right), false)
		else
			if not insert(inv,"src", stack, obj) then
				local pos = vector.subtract(b, a)
				local dir_right = {x = a.z, y = a.y + 0.25, z = -a.x}
				obj:moveto(vector.add(pos,dir_right), false)
			end
		end
	end
end

minetest.register_node("factory:overflowarm",{
	drawtype = "nodebox",
	tiles = {"factory_steel_noise.png"},
	paramtype = "light",
	description = S("Overflowing Pneumatic Mover"),
	groups = {cracky=3},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.5,0.5,-0.4375,0.5}, --baseplate
			{-0.125,-0.5,-0.375,0.125,0.0625,0.375}, --center
			{-0.125,0.25,-0.5,0.125,0.3125,0.375}, --tube top
			{-0.375,-0.5,-0.0625,0.375,0.0625,0.0625}, --base support
			{-0.125,-0.125,0.375,0.125,0.125,0.5}, --port
			{-0.125,0.0625,0.3125,0.125,0.25,0.375}, --tube end
			{-0.125,0.0625,-0.5,-0.0625,0.25,0.3125}, --tube left side
			{0.0625,0.0625,-0.5,0.125,0.25,0.3125}, --tube right side
			{-0.0625,0.0625,-0.5,0.0625,0.125,0.3125}, --tube bottom
			{0.125,0.25,-0.125,0.5,0.3125,0.125}, --overflow tube top
			{0.125,0.0625,-0.125,0.5,0.25,-0.0625}, --overflow tube left side
			{0.125,0.0625,0.0625,0.5,0.25,0.125}, --overflow tube right side
			{-0.125,0.0625,-0.0625,0.5,0.125,0.0625}, --overflow tube bottom
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
	nodenames = {"factory:overflowarm"},
	neighbors = nil,
	interval = 1,
	chance = 1,
	action = function(pos)
		local all_objects = minetest.get_objects_inside_radius(pos, 0.8)
		local a = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		local b = {x = pos.x + a.x, y = pos.y + a.y, z = pos.z + a.z,}
		local target = minetest.get_node(b)
		for _,obj in ipairs(all_objects) do
			if not obj:is_player()
			and obj:get_luaentity()
			and (obj:get_luaentity().name == "__builtin:item" or obj:get_luaentity().name == "factory:moving_item") then
				local objStack = ItemStack(obj:get_luaentity().itemstring)
				oarm_handle(a, b, target, objStack, obj)
			end
		end
	end,
})