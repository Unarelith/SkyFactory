local S = factory.S
factory.vac_sorter_formspec =
	"size[8,5.5]"..
	factory_gui_bg..
	factory_gui_bg_img_2..
	factory_gui_slots..
	"list[current_name;sort;3.5,0;1,1;]"..
	"list[current_player;main;0,1.5;8,1;]"..
	"list[current_player;main;0,2.75;8,3;8]"..
	"listring[current_player;main]"..
	"listring[current_name;sort]"

minetest.register_node("factory:upward_vacuum_on", {
	description = S("Vacuum Sorter"),
	tiles = {"factory_machine_steel_dark.png^factory_vent_slates.png",
		"factory_machine_steel_dark.png^factory_ring_green.png", "factory_machine_steel_dark.png",
		"factory_machine_steel_dark.png", "factory_machine_steel_dark.png^factory_8x8_black_square_32x32.png",
		"factory_machine_steel_dark.png"},
	groups = {cracky=3, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	drop="factory:upward_vacuum_off",
	legacy_facedir_simple = true,
	is_ground_content = false,
	allow_metadata_inventory_put = function(pos, listname, index, stack)
		local inv = minetest.get_meta(pos):get_inventory()
		stack:set_count(1)
		inv:set_stack(listname, index, stack)
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index)
		local inv = minetest.get_meta(pos):get_inventory()
		inv:set_stack(listname, index, ItemStack(""))
		factory.swap_node(pos,"factory:upward_vacuum_off")
		return 0
	end,
})

minetest.register_node("factory:upward_vacuum_off", {
	description = S("Vacuum Sorter"),
	tiles = {"factory_machine_steel_dark.png^factory_vent_slates.png",
		"factory_machine_steel_dark.png^factory_ring_red.png", "factory_machine_steel_dark.png",
		"factory_machine_steel_dark.png", "factory_machine_steel_dark.png^factory_8x8_black_square_32x32.png",
		"factory_machine_steel_dark.png"},
	groups = {cracky=3},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", factory.vac_sorter_formspec)
		meta:set_string("infotext", factory.S("Vacuum Sorter"))
		local inv = meta:get_inventory()
		inv:set_size("sort", 1)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack)
		local inv = minetest.get_meta(pos):get_inventory()
		stack:set_count(1)
		inv:set_stack(listname, index, stack)
		factory.swap_node(pos,"factory:upward_vacuum_on")
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index)
		local inv = minetest.get_meta(pos):get_inventory()
		inv:set_stack(listname, index, ItemStack(""))
		return 0
	end,
})

minetest.register_abm({
	nodenames = {"factory:upward_vacuum_on"},
	neighbors = nil,
	interval = 1,
	chance = 1,
	action = function(pos)
		local all_objects = minetest.get_objects_inside_radius({x = pos.x, y = pos.y-1, z = pos.z}, 0.5)
		local inv = minetest.get_meta(pos):get_inventory()
		for _,obj in ipairs(all_objects) do
			if not obj:is_player() and obj:get_luaentity() and obj:get_luaentity().name == "__builtin:item" then
				if ItemStack(obj:get_luaentity().itemstring):get_name() == inv:get_list("sort")[1]:get_name() then
					factory.do_moving_item(obj:getpos(), obj:get_luaentity().itemstring)
					obj:get_luaentity().itemstring = ""
					obj:remove()
				end
			end
		end
	end,
})
