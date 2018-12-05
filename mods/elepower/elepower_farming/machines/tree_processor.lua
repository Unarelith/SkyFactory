
local tree_fluid_recipes = {
	["elepower_farming:tree_sap_source"] = {
		water  = 1000,
		amount = 1000,
		time   = 5,
		output = {
			fluid  = "elepower_farming:biomass_source",
			amount = 40,
		},
	},
	["elepower_farming:resin_source"] = {
		water  = 1000,
		amount = 1000,
		time   = 5,
		output = {
			fluid  = "elepower_farming:biomass_source",
			amount = 20,
			item   = "elepower_farming:resin"
		},
	},
}

local function get_formspec(timer, power, fluid_buffer, water_buffer, output_buffer, state)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		ele.formspec.create_bar(1, 0, 100 - timer, "#00ff11", true)..
		ele.formspec.fluid_bar(2, 0, fluid_buffer)..
		ele.formspec.fluid_bar(3, 0, water_buffer)..
		ele.formspec.fluid_bar(7, 0, output_buffer)..
		ele.formspec.state_switcher(7, 2.5, state)..
		"list[context;dst;5,1;1,1;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function on_timer(pos, elapsed)
	local refresh = false
	local meta    = minetest.get_meta(pos)
	local inv     = meta:get_inventory()

	local tree_buffer  = fluid_lib.get_buffer_data(pos, "tree")
	local water_buffer = fluid_lib.get_buffer_data(pos, "water")
	local out_buffer   = fluid_lib.get_buffer_data(pos, "output")

	local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
	local storage  = ele.helpers.get_node_property(meta, pos, "storage")
	local usage    = ele.helpers.get_node_property(meta, pos, "usage")

	local time     = meta:get_int("src_time")
	local time_max = meta:get_int("src_time_max")

	local recipe = tree_fluid_recipes[tree_buffer.fluid]
	local pow_buffer = {capacity = capacity, storage = storage, usage = 0}

	local state = meta:get_int("state")
	local is_enabled = ele.helpers.state_enabled(meta, pos, state)
	local active = "Idle"

	while true do
		if not is_enabled then
			active = "Off"
			break
		end

		if not recipe then
			break
		end

		local conditions = water_buffer.amount >= recipe.water and
			tree_buffer.amount >= recipe.amount and
			out_buffer.amount + recipe.output.amount < out_buffer.capacity and
			pow_buffer.storage > usage and
			(out_buffer.fluid == "" or out_buffer.fluid == recipe.output.fluid)

		if not conditions then
			break
		end

		if time_max == 0 then
			time_max = recipe.time
			meta:set_int("src_time_max", time_max)
			refresh = true
			break
		end

		pow_buffer.storage = pow_buffer.storage - usage
		pow_buffer.usage = usage
		active = "Active"

		if time < time_max then
			time = time + 1
			meta:set_int("src_time", time)
			refresh = true
		end

		if time ~= time_max then
			break
		end

		if recipe.output.item then
			local room_for_output = true
			local stack = ItemStack(recipe.output.item)
			inv:set_size("dst_tmp", inv:get_size("dst"))
			inv:set_list("dst_tmp", inv:get_list("dst"))

			if not inv:room_for_item("dst_tmp", stack) then
				room_for_output = false
			else
				inv:add_item("dst_tmp", stack)
			end

			if not room_for_output then
				active = "Output Full!"
				break
			end

			inv:set_list("dst", inv:get_list("dst_tmp"))
		end

		local new_tree_amount = tree_buffer.amount - recipe.amount
		meta:set_int("tree_fluid_storage", new_tree_amount)
		meta:set_int("output_fluid_storage", out_buffer.amount + recipe.output.amount)
		meta:set_int("water_fluid_storage", water_buffer.amount - recipe.water)

		if new_tree_amount == 0 then
			tree_buffer.fluid = ""
		end

		meta:set_string("tree_fluid", tree_buffer.fluid)
		meta:set_string("output_fluid", recipe.output.fluid)

		meta:set_int("src_time", 0)
		meta:set_int("src_time_max", 0)

		refresh = true
		break
	end

	local timer = 0
	if time_max > 0 then
		timer = math.floor(100 * time / time_max)
	end

	meta:set_string("formspec", get_formspec(timer, pow_buffer, tree_buffer,
		water_buffer, out_buffer, state))
	meta:set_string("infotext", ("Tree Processor %s\n%s"):format(active,
		ele.capacity_text(capacity, pow_buffer.storage)))
	meta:set_int("storage", pow_buffer.storage)

	return refresh
end

ele.register_machine("elepower_farming:tree_processor", {
	description = "Tree Fluid Processor",
	ele_usage   = 8,
	ele_no_automatic_ports = true,
	groups = {ele_user = 1, oddly_breakable_by_hand = 1, cracky = 1, fluid_container = 1},
	fluid_buffers = {
		tree = {
			capacity  = 8000,
			accepts   = {"group:tree_fluid"},
			drainable = false,
		},
		water = {
			capacity  = 8000,
			accepts   = {"default:water_source"},
			drainable = false,
		},
		output = {
			capacity = 8000
		}
	},
	on_timer = on_timer,
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()

		inv:set_size("dst", 1)
		
		local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
		meta:set_string("formspec", get_formspec(0, {capacity = capacity, storage = 0}))
	end,
	tiles = {
		"elefarming_machine_tree_processor.png", "elefarming_machine_base.png", "elefarming_machine_side.png",
		"elefarming_machine_side.png", "elefarming_machine_side.png", "elefarming_machine_side.png",
	},
})
