local S = factory.S
minetest.register_alias("factory:compressor", "factory:ind_squeezer")

function factory.ind_squeezer_active(percent, item_percent)
    local formspec =
	"size[8,8.5]"..
	factory_gui_bg..
	factory_gui_bg_img..
	factory_gui_slots..
	"list[current_name;src;2.75,0.5;1,1;]"..
	"list[current_name;fuel;2.75,2.5;1,1;]"..
	"image[2.75,1.5;1,1;factory_compressor_drop_bg.png^[lowpart:"..
	(100-percent)..":factory_compressor_drop_fg.png]"..
        "image[3.75,1.5;1,1;gui_ind_furnace_arrow_bg.png^[lowpart:"..
        (item_percent*100)..":gui_ind_furnace_arrow_fg.png^[transformR270]"..
	"list[current_name;dst;4.75,0.5;2,2;]"..
	"list[current_player;main;0,4.25;8,1;]"..
	"list[current_player;main;0,5.5;8,3;8]"..
	factory.get_hotbar_bg(0,4.25)..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_player;main]"..
	"listring[current_name;dst]"
    return formspec
  end

function factory.ind_squeezer_active_formspec(pos, percent)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local srclist = inv:get_list("src")
	local result = nil
	if srclist then
		result = factory.get_recipe("ind_squeezer",srclist)
	end
	local item_percent = 0
	if result then
		item_percent = meta:get_float("src_time")/result.time
	end

        return factory.ind_squeezer_active(percent, item_percent)
end

factory.ind_squeezer_inactive_formspec =
	"size[8,8.5]"..
	factory_gui_bg..
	factory_gui_bg_img..
	factory_gui_slots..
	"list[current_name;src;2.75,0.5;1,1;]"..
	"list[current_name;fuel;2.75,2.5;1,1;]"..
	"image[2.75,1.5;1,1;factory_compressor_drop_bg.png]"..
	"image[3.75,1.5;1,1;gui_ind_furnace_arrow_bg.png^[transformR270]"..
	"list[current_name;dst;4.75,0.5;2,2;]"..
	"list[current_player;main;0,4.25;8,1;]"..
	"list[current_player;main;0,5.5;8,3;8]"..
	factory.get_hotbar_bg(0,4.25)..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_player;main]"..
	"listring[current_name;dst]"

minetest.register_node("factory:ind_squeezer", {
	description = S("Industrial Squeezer"),
	tiles = {"factory_machine_brick_1.png", "factory_machine_brick_2.png", "factory_machine_side_1.png",
		"factory_machine_side_1.png", "factory_machine_side_1.png", "factory_compressor_front.png"},
	paramtype2 = "facedir",
	groups = {cracky=3,factory_src_input=1,factory_fuel_input=1,factory_dst_output=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", factory.ind_squeezer_inactive_formspec)
		meta:set_string("infotext", S("Industrial Squeezer"))
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 4)
	end,
	can_dig = function(pos)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return false
		elseif not inv:is_empty("dst") then
			return false
		elseif not inv:is_empty("src") then
			return false
		end
		return true
	end,
	allow_metadata_inventory_put = function(pos, listname, _, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext",S("@1 is empty", S("Industrial Squeezer")))
				end
				return stack:get_count()
			else
				return 0
			end
		elseif listname == "src" then
			return stack:get_count()
		elseif listname == "dst" then
			return 0
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, _, count)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if to_list == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext",S("@1 is empty", S("Industrial Squeezer")))
				end
				return count
			else
				return 0
			end
		elseif to_list == "src" then
			return count
		elseif to_list == "dst" then
			return 0
		end
	end,
})

minetest.register_node("factory:ind_squeezer_active", {
	description = "Industrial Squeezer",
	tiles = {
		"factory_machine_brick_1.png",
		"factory_machine_brick_2.png",
		"factory_machine_side_1.png",
		"factory_machine_side_1.png",
		"factory_machine_side_1.png",
		{
			image = "factory_compressor_front_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 4
			},
		}
	},
	paramtype2 = "facedir",
	light_source = 2,
	drop = "factory:ind_squeezer",
	groups = {cracky=3, not_in_creative_inventory=1,hot=1,factory_src_input=1,factory_fuel_input=1,factory_dst_output=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", factory.ind_squeezer_inactive_formspec)
		meta:set_string("infotext", S("Industrial Squeezer (working)"));
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 4)
	end,
	can_dig = function(pos)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return false
		elseif not inv:is_empty("dst") then
			return false
		elseif not inv:is_empty("src") then
			return false
		end
		return true
	end,
	allow_metadata_inventory_put = function(pos, listname, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext",S("@1 is empty", S("Industrial Squeezer")))
				end
				return stack:get_count()
			else
				return 0
			end
		elseif listname == "src" then
			return stack:get_count()
		elseif listname == "dst" then
			return 0
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, _, count)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if to_list == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext",S("@1 is empty", S("Industrial Squeezer")))
				end
				return count
			else
				return 0
			end
		elseif to_list == "src" then
			return count
		elseif to_list == "dst" then
			return 0
		end
	end,
})

minetest.register_abm({
	nodenames = {"factory:ind_squeezer","factory:ind_squeezer_active"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		for _, name in ipairs({
				"fuel_totaltime",
				"fuel_time",
				"src_totaltime",
				"src_time"
		}) do
			if meta:get_string(name) == "" then
				meta:set_float(name, 0.0)
			end
		end

		if not factory.smoke_on_tube(pos, node.name == "factory:ind_squeezer_active") then
			meta:set_string("infotext",S("@1 has no smoke tube", S("Industrial Squeezer")))
			return
		end

		local inv = meta:get_inventory()

		local srclist = inv:get_list("src")
		local result = nil

		if srclist then
			result = factory.get_recipe("ind_squeezer", srclist)
		end

		local was_active = false

		if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
			was_active = true
			meta:set_float("src_time", meta:get_float("src_time") + 0.2)
			meta:set_float("fuel_time", meta:get_float("fuel_time") + 0.9)
			local output = result and result.output
			if type(output) ~= "table" and output then output = { output } end
			local output_stacks = {}
			if output then
				for _, o in ipairs(output) do
					table.insert(output_stacks, ItemStack(o))
				end
			end
			if output_stacks and (result == nil or meta:get_float("src_time") >= result.time) then
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
					factory.log.info("Could not insert '"..result.item:to_string().."'")
				end
				meta:set_string("src_time", 0)
				if result then inv:set_list("src", result.new_input) end
				inv:set_list("dst", inv:get_list("dst_tmp"))
			end
		end

		if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
			local percent = math.floor(meta:get_float("fuel_time") /
					meta:get_float("fuel_totaltime") * 100)
			meta:set_string("infotext",S("Industrial Squeezer is working, fuel current used: @1%",percent))
			factory.swap_node(pos,"factory:ind_squeezer_active")
			meta:set_string("formspec",factory.ind_squeezer_active_formspec(pos, percent))
			return
		end

		local fuel = nil
		local afterfuel
		result = nil
		local fuellist = inv:get_list("fuel")
		srclist = inv:get_list("src")

		if srclist then
			result = factory.get_recipe("ind_squeezer", srclist)
		end
		if fuellist then
			fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
		end

		if not fuel or fuel.time <= 0 then
			meta:set_string("infotext",S("@1 has no fuel to burn",S("Industrial Squeezer")))
			factory.swap_node(pos,"factory:ind_squeezer")
			meta:set_string("formspec", factory.ind_squeezer_inactive_formspec)
			return
		end

		if not result then
			if was_active then
				meta:set_string("infotext",S("@1 is empty",S("Industrial Squeezer")))
				factory.swap_node(pos,"factory:ind_squeezer")
				meta:set_string("formspec", factory.ind_squeezer_inactive_formspec)
			end
			return
		end

		meta:set_string("fuel_totaltime", fuel.time)
		meta:set_string("fuel_time", 0)

		inv:set_stack("fuel", 1, afterfuel.items[1])
	end,
})
