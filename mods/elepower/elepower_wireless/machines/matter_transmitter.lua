
elewi.loaded_transmitters = {}

local function get_formspec(power, name, player)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		"field[1.5,0.5;5,1;name;Transmitter Name;".. name .."]"..
		"field_close_on_enter[name;false]"..
		"label[0,3.75;Owned by " .. player .. "]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function matter_transmitter_timer(pos)
	local meta   = minetest.get_meta(pos)
	local name   = meta:get_string("name")
	local player = meta:get_string("player")
	local target = meta:get_string("target")

	if name == "" then
		name = "Matter Transmitter"
	end

	local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
	local storage  = ele.helpers.get_node_property(meta, pos, "storage")
	local usage    = ele.helpers.get_node_property(meta, pos, "usage")

	local pow_buffer = {capacity = capacity, storage = storage, usage = usage}
	local tpos = minetest.string_to_pos(target)

	if storage >= usage and tpos then
		ele.helpers.swap_node(pos, "elepower_wireless:matter_transmitter_active")
	else
		ele.helpers.swap_node(pos, "elepower_wireless:matter_transmitter")
	end

	local extra = ""
	if target ~= "" then
		extra = "\nDialled to " .. target
	end

	meta:set_string("formspec", get_formspec(pow_buffer, name, player, target))
	meta:set_string("infotext", name .. "\n" .. ele.capacity_text(capacity, storage) .. extra)

	return false
end

local function save_transmitter(pos)
	local strname = minetest.pos_to_string(pos)

	if elewi.loaded_transmitters[strname] then return end

	local meta   = minetest.get_meta(pos)
	local name   = meta:get_string("name")
	local player = meta:get_string("player")

	if name == "" then
		name = "Matter Transmitter"
	end

	elewi.loaded_transmitters[strname] = {
		name   = name,
		player = player,
	}
end

ele.register_machine("elepower_wireless:matter_transmitter", {
	description = "Matter Transmitter",
	tiles = {
		"elewireless_teleport_top.png", "elewireless_device_side.png^elepower_power_port.png", "elewireless_device_side.png",
		"elewireless_device_side.png", "elewireless_device_side.png", "elewireless_device_side.png"
	},
	drawtype = "nodebox",
	node_box = elewi.slab_nodebox,
	ele_active_node = true,
	ele_active_nodedef = {
		tiles = {
			{
				name = "elewireless_transmitter_top_animated.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					speed = 5,
				},
			},
			"elewireless_device_side.png^elepower_power_port.png", "elewireless_device_side.png",
			"elewireless_device_side.png", "elewireless_device_side.png", "elewireless_device_side.png"
		},
	},
	groups = {cracky = 1, ele_user = 1, matter_transmitter = 1},
	ele_capacity = 8000,
	ele_usage    = 120,
	ele_inrush   = 240,
	ele_no_automatic_ports = true,
	on_timer = matter_transmitter_timer,
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		if not placer or placer:get_player_name() == "" then return false end

		meta:set_string("player", placer:get_player_name())
		save_transmitter(pos)
	end,
	on_receive_fields = function (pos, formname, fields, sender)
		if sender and sender ~= "" and minetest.is_protected(pos, sender:get_player_name()) then
			return
		end

		-- Set Name
		local meta = minetest.get_meta(pos)
		if fields["name"] and fields["key_enter"] == "true" then
			meta:set_string("name", fields["name"])
			minetest.get_node_timer(pos):start(0.2)

			local strname = minetest.pos_to_string(pos)
			if not elewi.loaded_transmitters[strname] then return end
			elewi.loaded_transmitters[strname].name = fields["name"]
		end
	end,
	after_destruct = function (pos)
		local strname = minetest.pos_to_string(pos)
		if not elewi.loaded_transmitters[strname] then return end
		elewi.loaded_transmitters[strname] = nil
	end,
})

minetest.register_lbm({
    label = "Load Transmitter into memory",
    name = "elepower_wireless:matter_transmitter",
    nodenames = {"group:matter_transmitter"},
    run_at_every_load = true,
    action = save_transmitter,
})

minetest.register_abm({
	nodenames = {"group:matter_transmitter"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.get_objects_inside_radius(pos, 1)
		for k, player in pairs(objs) do
			if player:get_player_name() ~= nil then 
				local meta = minetest.get_meta(pos)
				local tpos = minetest.string_to_pos(meta:get_string("target"))

				if tpos then
					local tnode = minetest.get_node_or_nil(tpos)
					if tnode and ele.helpers.get_item_group(tnode.name, "matter_receiver") then
						local storage  = ele.helpers.get_node_property(meta, pos, "storage")
						local usage    = ele.helpers.get_node_property(meta, pos, "usage")

						if storage >= usage then
							local top     = vector.add(tpos, {x = 0, y = 1, z = 0})
							local topnode = minetest.get_node_or_nil(top)

							if not topnode or topnode.name == "air" then
								player:set_pos(top)
								meta:set_int("storage", storage - usage)
								-- TODO: Sound
								break
							end
						end
					else
						meta:set_string("target", "")
						minetest.get_node_timer(pos):start(0.2)
					end
				end
			end
		end
	end	
})
