
local function escape_comma(str)
	return str:gsub(",","\\,")
end

local function get_formspec(power, player, transmitters, receivers)
	local list_tr  = {}
	local tr_selct = nil
	local list_re  = {}
	local re_selct = nil

	if transmitters then
		for _,trn in pairs(transmitters) do
			local indx = #list_tr + 1
			if trn.select then
				tr_selct = indx
			end
			list_tr[indx] = trn.name .. " " .. escape_comma(trn.pos)
		end
	end

	if receivers then
		for _,rec in pairs(receivers) do
			local indx = #list_re + 1
			if rec.select then
				re_selct = indx
			end
			list_re[indx] = rec.name .. " " .. escape_comma(rec.pos)
		end
	end

	local tr_spc = ""
	if tr_selct then tr_spc = ";" .. tr_selct end

	local re_spc = ""
	if re_selct then re_spc = ";" .. re_selct end

	return "size[8,10.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		"textlist[1,0;6.8,2.5;transmitter;" .. table.concat(list_tr, ",") .. tr_spc .. "]"..
		"textlist[1,3;6.8,2.5;receiver;" .. table.concat(list_re, ",") .. re_spc .. "]"..
		"button[6,5.75;2,0.25;refresh;Refresh]"..
		"label[0,5.75;Owned by " .. player .. "]"..
		"list[current_player;main;0,6.25;8,1;]"..
		"list[current_player;main;0,7.5;8,3;8]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 6.25)
end

local function get_is_active_node(meta, pos)
	local storage = ele.helpers.get_node_property(meta, pos, "storage")
	local usage   = ele.helpers.get_node_property(meta, pos, "usage")
	return storage >= usage
end

local function get_transmitters_in_range(pos, player, selected, range)
	local transmitters = {}
	for spos, data in pairs(elewi.loaded_transmitters) do
		local npos = minetest.string_to_pos(spos)
		local node = minetest.get_node_or_nil(npos)
		if node and ele.helpers.get_item_group(node.name, "matter_transmitter") then
			if data.player == player and vector.distance(pos, npos) <= range then
				local meta = minetest.get_meta(npos)
				if get_is_active_node(meta, npos) then
					transmitters[#transmitters + 1] = {
						name   = data.name,
						player = player,
						pos    = spos,
						select = npos == selected,
					}
				end
			end
		end
	end
	return transmitters
end

local function get_player_receivers(player)
	local receivers = {}
	for spos, data in pairs(elewi.loaded_receivers) do
		local npos = minetest.string_to_pos(spos)
		local node = minetest.get_node_or_nil(npos)
		if node and ele.helpers.get_item_group(node.name, "matter_receiver") then
			if data.player == player then
				local meta   = minetest.get_meta(npos)
				local target = minetest.string_to_pos(meta:get_string("target"))
				if get_is_active_node(meta, npos) then
					receivers[#receivers + 1] = {
						name   = data.name,
						player = player,
						pos    = spos,
						select = target == npos,
					}
				end
			end
		end
	end
	return receivers
end

local function dialler_timer(pos)
	local meta   = minetest.get_meta(pos)
	local player = meta:get_string("player")

	local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
	local storage  = ele.helpers.get_node_property(meta, pos, "storage")
	local usage    = ele.helpers.get_node_property(meta, pos, "usage")

	local transmitter = minetest.string_to_pos(meta:get_string("transmitter"))
	local pow_buffer = {capacity = capacity, storage = storage, usage = usage}

	if storage >= usage then
		ele.helpers.swap_node(pos, "elepower_wireless:dialler_active")
	else
		ele.helpers.swap_node(pos, "elepower_wireless:dialler")
	end

	local transmitters = get_transmitters_in_range(pos, player, transmitter, 8)
	local receivers    = {}
	if transmitter then
		receivers = get_player_receivers(player)
	end

	meta:set_string("formspec", get_formspec(pow_buffer, player, transmitters, receivers))
	meta:set_string("infotext", "Dialler\n" .. ele.capacity_text(capacity, storage))

	return false
end

ele.register_machine("elepower_wireless:dialler", {
	description = "Dialler",
	tiles = {
		"elewireless_device_side.png", "elewireless_device_side.png", "elewireless_device_side.png",
		"elewireless_device_side.png", "elewireless_device_side.png", "elewireless_dialler_inactive.png"
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5000, -0.5000, 0.4375, 0.5000, 0.5000, 0.5000}
		}
	},
	ele_active_node = true,
	ele_active_nodedef = {
		tiles = {
			"elewireless_device_side.png", "elewireless_device_side.png", "elewireless_device_side.png",
			"elewireless_device_side.png", "elewireless_device_side.png", "elewireless_dialler.png"
		},
	},
	groups = {cracky = 1, ele_user = 1, dialler = 1},
	ele_capacity = 8000,
	ele_usage    = 120,
	ele_inrush   = 240,
	on_timer = dialler_timer,
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		if not placer or placer:get_player_name() == "" then return false end

		meta:set_string("player", placer:get_player_name())
	end,
	on_receive_fields = function (pos, formname, fields, sender)
		if sender and sender ~= "" and minetest.is_protected(pos, sender:get_player_name()) then
			return
		end

		if fields["refresh"] then
			minetest.get_node_timer(pos):start(0.2)
			return
		end

		if not fields["transmitter"] and not fields["receiver"] then
			return
		end

		local meta = minetest.get_meta(pos)
		local trans = minetest.string_to_pos(meta:get_string("transmitter"))

		local player = sender:get_player_name()
		local transmitters = get_transmitters_in_range(pos, player, trans, 8)
		local receivers = {}
		if trans then
			receivers = get_player_receivers(player)
		end

		if fields["transmitter"] then
			if fields.transmitter:match("DCL:") then
				local pinx = tonumber(fields.transmitter:sub(5))
				if pinx and transmitters[pinx] then
					meta:set_string("transmitter", transmitters[pinx].pos)
					minetest.get_node_timer(pos):start(0.2)
					return
				end
			end
		end

		if fields["receiver"] and #receivers > 0 then
			if fields.receiver:match("DCL:") then
				local pinx = tonumber(fields.receiver:sub(5))
				if pinx and receivers[pinx] then
					local meta = minetest.get_meta(trans)

					meta:set_string("target", receivers[pinx].pos)

					minetest.get_node_timer(trans):start(0.2)
					minetest.get_node_timer(pos):start(0.2)
				end
			end
		end
	end,
})
