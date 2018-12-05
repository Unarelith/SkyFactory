
local function get_formspec(timer, biomass_buffer, output_buffer)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.fluid_bar(0, 0.75, biomass_buffer)..
		ele.formspec.fluid_bar(7, 0.75, output_buffer)..
		"list[context;src;1,0.5;3,3;]"..
		"image[5,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
			(timer)..":gui_furnace_arrow_fg.png^[transformR270]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function is_plant(itemname)
	if ele.helpers.get_item_group(itemname, "seed") or ele.helpers.get_item_group(itemname, "plant") then
		return true
	end

	local node = itemname .. "_1"
	if minetest.registered_nodes[node] then
		if ele.helpers.get_item_group(node, "plant") then
			return true
		end
	end

	return false
end

local function get_biomass(list)
	local list_new = {}
	local amnt     = 0

	for i,stack in pairs(list) do
		local sname = stack:get_name()
		if is_plant(sname) then
			stack:take_item(1)
			list_new[i] = stack
			amnt = amnt + 1
		else
			list_new[i] = stack
		end
	end

	return amnt, list_new
end

local function on_timer(pos, elapsed)
	local refresh = false
	local meta    = minetest.get_meta(pos)
	local inv     = meta:get_inventory()

	local in_buffer  = fluid_lib.get_buffer_data(pos, "input")
	local out_buffer = fluid_lib.get_buffer_data(pos, "output")

	local time     = meta:get_int("src_time")
	local time_max = meta:get_int("src_time_max")

	while true do
		local amount,list_new = get_biomass(inv:get_list("src"))

		if (amount == 0 and in_buffer.amount == 0) or out_buffer.amount == out_buffer.capacity then
			break
		end

		if time_max == 0 then
			time_max = 10
			refresh = true
			break
		end

		if time < time_max then
			time = time + 1
			refresh = true
		end

		if time ~= time_max then
			break
		end

		local amount_fluid = 0
		if amount > 0 then
			amount_fluid = amount_fluid + (amount * 100)
		end

		if in_buffer.amount > 0 then
			local rm = math.min(in_buffer.amount, 1000)

			-- Remove 20% from sludge
			if in_buffer.fluid == "elepower_farming:sludge_source" then
				local pcr = math.floor(rm * 0.2)
				rm = rm - pcr
			end

			amount_fluid = amount_fluid + rm
			in_buffer.amount = in_buffer.amount - rm

			if in_buffer.amount <= 0 then
				in_buffer.amount = 0
				in_buffer.fluid = ""
			end
		end

		out_buffer.amount = out_buffer.amount + amount_fluid
		if out_buffer.amount > out_buffer.capacity then
			out_buffer.amount = out_buffer.capacity
		end

		inv:set_list("src", list_new)

		meta:set_int("input_fluid_storage", in_buffer.amount)
		meta:set_string("input_fluid", in_buffer.fluid)

		meta:set_int("output_fluid_storage", out_buffer.amount)
		meta:set_string("output_fluid", "elepower_farming:biofuel_source")

		time = 0
		time_max = 0

		refresh = true
		break
	end

	local timer = 0
	if time_max > 0 then
		timer = math.floor(100 * time / time_max)
	end
	
	meta:set_int("src_time", time)
	meta:set_int("src_time_max", time_max)

	meta:set_string("formspec", get_formspec(timer, in_buffer, out_buffer))

	return refresh
end

ele.register_base_device("elepower_farming:composter", {
	description = "Composter\nConvert organic matter to Biofuel",
	groups = {oddly_breakable_by_hand = 1, cracky = 1, fluid_container = 1, tube = 1},
	fluid_buffers = {
		output = {
			capacity  = 8000,
			drainable = true,
		},
		input = {
			capacity  = 8000,
			drainable = false,
			accepts   = {
				"group:raw_bio",
				"elepower_farming:biomass_source",
				"elepower_farming:tree_sap_source",
				"elepower_farming:sludge_source",
			}
		},
	},
	on_timer = on_timer,
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()

		inv:set_size("src", 9)

		meta:set_string("formspec", get_formspec(0))
	end,
	tiles = {
		"elefarming_machine_top.png", "elefarming_machine_base.png", "elefarming_machine_side.png",
		"elefarming_machine_side.png", "elefarming_machine_side.png", "elefarming_machine_side.png",
	},

	allow_metadata_inventory_put  = ele.default.allow_metadata_inventory_put,
	allow_metadata_inventory_move = ele.default.allow_metadata_inventory_move,
	allow_metadata_inventory_take = ele.default.allow_metadata_inventory_take,

	on_metadata_inventory_move = ele.default.metadata_inventory_changed,
	on_metadata_inventory_put  = ele.default.metadata_inventory_changed,
	on_metadata_inventory_take = ele.default.metadata_inventory_changed,
})
