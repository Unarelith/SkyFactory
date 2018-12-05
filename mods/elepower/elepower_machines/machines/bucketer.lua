
local function get_formspec(mode, buffer, state)
	if not mode then
		mode = 0
	end

	local rot = "^\\[transformR90"
	if mode == 1 then
		rot = "^\\[transformR270"
	end

	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.state_switcher(0, 0, state)..
		ele.formspec.fluid_bar(7, 0.75, buffer)..
		"list[context;src;3.5,1;1,1;]"..
		"list[context;dst;3.5,2;1,1;]"..
		"image_button[5.25,1;1,1;gui_furnace_arrow_bg.png" .. rot .. ";flip;]"..
		"tooltip[flip;Toggle Extract/Insert]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function on_timer(pos, elapsed)
	local refresh = false
	local meta    = minetest.get_meta(pos)
	local inv     = meta:get_inventory()

	local buffer = fluid_lib.get_buffer_data(pos, "input")
	local mode   = meta:get_int("mode")
	local state  = meta:get_int("state")

	local is_enabled = ele.helpers.state_enabled(meta, pos, state)

	local bucket_slot = inv:get_stack("src", 1)
	local bucket_name = bucket_slot:get_name()

	if is_enabled then
		if mode == 0 and (bucket_name == "bucket:bucket_empty" or
			bucket_name == "elepower_dynamics:gas_container") and buffer.amount >= 1000 then
			-- Fill bucket
			local bitem
			if minetest.get_item_group(buffer.fluid, "gas") > 0 then
				bitem = ele.gases[buffer.fluid]
				if bucket_name ~= "elepower_dynamics:gas_container" then
					bitem = nil
				end
			else
				bitem = bucket.liquids[buffer.fluid]
				if bucket_name ~= "bucket:bucket_empty" then
					bitem = nil
				end
			end

			if bitem and bitem.itemname then
				local bstack = ItemStack(bitem.itemname)
				if inv:room_for_item("dst", bstack) then
					inv:add_item("dst", bstack)
					buffer.amount = buffer.amount - 1000

					bucket_slot:take_item()
					inv:set_stack("src", 1, bucket_slot)

					refresh = true
				end
			end
		elseif mode == 1 and (bucket.get_liquid_for_bucket(bucket_name) or ele.get_gas_for_container(bucket_name)) then
			-- Empty bucket
			local fluid
			local gas = false

			if minetest.get_item_group(bucket_name, "gas_container") > 0 then
				gas = true
				fluid = ele.get_gas_for_container(bucket_name)
			else
				fluid = bucket.get_liquid_for_bucket(bucket_name)
			end
			
			if buffer.fluid == fluid or buffer.fluid == "" then
				local bitem = ItemStack("bucket:bucket_empty")
				if gas then
					bitem = ItemStack("elepower_dynamics:gas_container")
				end

				if inv:room_for_item("dst", bitem) and buffer.amount + 1000 <= buffer.capacity then
					buffer.amount = buffer.amount + 1000
					buffer.fluid  = fluid
					inv:add_item("dst", bitem)

					bucket_slot:take_item()
					inv:set_stack("src", 1, bucket_slot)

					refresh = true
				end
			end
		end
	end

	if buffer.amount <= 0 then
		buffer.amount = 0
		buffer.fluid  = ""
	end

	meta:set_int("input_fluid_storage", buffer.amount)
	meta:set_string("input_fluid", buffer.fluid)
	meta:set_string("formspec", get_formspec(mode, buffer))

	return refresh
end

local function get_fields(pos, formname, fields, sender)
	if sender and sender ~= "" and minetest.is_protected(pos, sender:get_player_name()) then
		return
	end

	if fields["quit"] then return end
	local meta = minetest.get_meta(pos)

	if fields["flip"] then
		local fint = meta:get_int("mode")
		if fint == 0 then
			fint = 1
		else
			fint = 0
		end
		meta:set_int("mode", fint)
	end

	minetest.get_node_timer(pos):start(1.0)
end

ele.register_base_device("elepower_machines:bucketer", {
	description = "Bucketer",
	groups = {oddly_breakable_by_hand = 1, cracky = 1, fluid_container = 1, tube = 1},
	fluid_buffers = {
		input = {
			capacity  = 8000,
			accepts   = true,
		},
	},
	paramtype2 = "facedir",
	on_timer = on_timer,
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()

		inv:set_size("src", 1)
		inv:set_size("dst", 1)

		meta:set_string("formspec", get_formspec())
	end,
	tiles = {
		"elepower_machine_top.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_machine_side.png", "elepower_bucketer.png",
	},
	on_receive_fields = get_fields,

	allow_metadata_inventory_put  = ele.default.allow_metadata_inventory_put,
	allow_metadata_inventory_move = ele.default.allow_metadata_inventory_move,
	allow_metadata_inventory_take = ele.default.allow_metadata_inventory_take,

	on_metadata_inventory_move = ele.default.metadata_inventory_changed,
	on_metadata_inventory_put  = ele.default.metadata_inventory_changed,
	on_metadata_inventory_take = ele.default.metadata_inventory_changed,
})
