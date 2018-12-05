
local SPEED = 3

local function get_formspec(item_percent)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[context;src;1.6,1;1,1;]"..
		"image[3.5,1;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
		(item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
		"list[context;dst;4.5,1;2,1;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) or listname == "dst" then
		return 0
	end
	
	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	return stack:get_count()
end

local function metadata_inventory_changed(pos)
	local t = minetest.get_node_timer(pos)

	if not t:is_started() then
		t:start(0.2)
	end
end

local function grindstone_timer(pos, elapsed)
	local refresh = false

	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	local recipe = elepm.get_recipe("grind", inv:get_list("src"))
	if not recipe or recipe.time == 0 then
		meta:set_int("src_time", 0)
		meta:set_int("src_time_max", 0)
		meta:set_string("formspec", get_formspec(0))
		meta:set_string("infotext", "No recipe")
		return
	end

	local target_time = ele.helpers.round(recipe.time * 18)
	local time        = meta:get_int("src_time")

	if time >= target_time then
		local output = recipe.output
		if type(output) ~= "table" then output = { output } end
		local output_stacks = {}
		for _, o in ipairs(output) do
			table.insert(output_stacks, ItemStack(o))
		end

		local room_for_output = true
		inv:set_size("dst_tmp", inv:get_size("dst"))
		inv:set_list("dst_tmp", inv:get_list("dst"))

		for _, o in ipairs(output_stacks) do
			if not inv:room_for_item("dst_tmp", o) then
				room_for_output = false
				break
			end
			inv:add_item("dst_tmp", o)
		end

		if not room_for_output then
			time = target_time - 1
		else
			inv:set_list("src", recipe.new_input)
			inv:set_list("dst", inv:get_list("dst_tmp"))
			time = 0
		end

		refresh = true
	end

	local percentile  = math.floor(100 * time / target_time)
	meta:set_string("formspec", get_formspec(percentile))
	meta:set_int("src_time", time)
	meta:set_int("src_time_max", target_time)
	meta:set_string("infotext", "Grindstone: ".. percentile .. "%")

	return refresh
end

ele.register_base_device("elepower_machines:grindstone", {
	description = "Grindstone\nA medieval pulverizer",
	tiles = {
		"elepower_grinder_top.png", "elepower_cfalloy_bottom.png", "elepower_grinder_side.png",
		"elepower_grinder_side.png", "elepower_grinder_side.png", "elepower_grinder_side.png"
	},
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()

		inv:set_size("src", 1)
		inv:set_size("dst", 2)

		meta:set_string("formspec", get_formspec(0))
	end,
	tube = false,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	on_metadata_inventory_move = metadata_inventory_changed,
	on_metadata_inventory_take = metadata_inventory_changed,
	on_metadata_inventory_put  = metadata_inventory_changed,
	can_dig = can_dig,
	on_timer = grindstone_timer,
	groups = {
		tubedevice = 1,
		cracky = 2,
	},
})

minetest.register_node("elepower_machines:crank", {
	description = "Hand Crank",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3750, -0.1250, -0.03125, 0.03125, -0.06250, 0.03125},
			{-0.03125, -0.5000, -0.03125, 0.03125, -0.1250, 0.03125}
		}
	},
	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		local gpos  = vector.add(pos, {x = 0, y = -1, z = 0})
		local gnode = minetest.get_node_or_nil(gpos)

		if not gnode or gnode.name ~= "elepower_machines:grindstone" then
			return itemstack
		end

		local gmeta = minetest.get_meta(gpos)

		-- Advance grindstone
		local stime = gmeta:get_int("src_time")
		local sttm  = gmeta:get_int("src_time_max")

		if sttm > 0 then
			gmeta:set_int("src_time", stime + SPEED)

			local t = minetest.get_node_timer(gpos)
			if not t:is_started() then
				t:start(0.2)
			end
		end

		return itemstack
	end
})
