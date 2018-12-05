-- This is a crafter type machine base.
-- It accepts a recipe type registered beforehand.

-- Specialized formspec for crafters
function ele.formspec.get_crafter_formspec(craft_type, power, percent, pos, state)
	local craftstats  = elepm.craft.types[craft_type]
	local input_size  = craftstats.inputs

	local gui_name = "gui_furnace_arrow"
	if craftstats.gui_name then
		gui_name = craftstats.gui_name
	end

	local bar = "image[4,1.5;1,1;"..gui_name.."_bg.png^[transformR270]"

	if percent ~= nil then
		bar = "image[4,1.5;1,1;"..gui_name.."_bg.png^[lowpart:"..
			  (percent)..":"..gui_name.."_fg.png^[transformR270]"
	end

	local in_width  = input_size
	local in_height = 1

	for n = 2, 4 do
		if input_size % n == 0 and input_size ~= n then
			in_width  = input_size / n
			in_height = input_size / n
		end
	end

	local y = 1.5
	local x = 1.5
	if in_height == 2 then
		y = 1
	elseif in_height >= 3 then
		y = 0.5
	end

	if in_width >= 2 then
		x = 1
	end

	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		ele.formspec.state_switcher(7, 0, state)..
		"list[context;src;"..x..","..y..";"..in_width..","..in_height..";]"..
		bar..
		"list[context;dst;5,1;2,2;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

function elepm.register_crafter(nodename, nodedef)
	local craft_type = nodedef.craft_type
	if not craft_type or not elepm.craft.types[craft_type] then
		return nil
	end

	if not nodedef.groups then
		nodedef.groups = {}
	end

	nodedef.groups["ele_machine"] = 1
	nodedef.groups["ele_user"]    = 1
	nodedef.groups["tubedevice"]  = 1
	nodedef.groups["tubedevice_receiver"] = 1

	-- Allow for custom formspec
	local get_formspec = ele.formspec.get_crafter_formspec
	if nodedef.get_formspec then
		get_formspec = nodedef.get_formspec
		nodedef.get_formspec = nil
	end

	nodedef.on_timer = function (pos, elapsed)
		local refresh = false
		local meta    = minetest.get_meta(pos)
		local inv     = meta:get_inventory()

		local machine_node  = nodename
		local machine_speed = nodedef.craft_speed or 1

		local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
		local usage    = ele.helpers.get_node_property(meta, pos, "usage")
		local storage  = ele.helpers.get_node_property(meta, pos, "storage")
		local time     = meta:get_int("src_time")
		local state    = meta:get_int("state")
		local status   = "Idle"

		local is_enabled = ele.helpers.state_enabled(meta, pos, state)
		local res_time = 0

		local pow_buffer = {capacity = capacity, storage = storage, usage = 0}

		while true do
			if not is_enabled then
				time = 0
				status = "Off"
				break
			end

			local result  = elepm.get_recipe(craft_type, inv:get_list("src"))
			local power_operation = false

			-- Determine if there is enough power for this action
			res_time = result.time
			if result.time ~= 0 and pow_buffer.storage >= usage then
				power_operation = true
				pow_buffer.usage = usage
			end

			if result.time == 0 or not power_operation then
				ele.helpers.swap_node(pos, machine_node)
				
				if result.time == 0 then
					time = 0
					status = "Idle"
				else
					status = "Out of Power!"
				end

				break
			end

			refresh = true
			status = "Active"

			-- One step
			pow_buffer.storage = pow_buffer.storage - usage
			time = time + ele.helpers.round(machine_speed * 10)

			if nodedef.ele_active_node then
				local active_node = nodename.."_active"
				if nodedef.ele_active_node ~= true then
					active_node = nodedef.ele_active_node
				end

				ele.helpers.swap_node(pos, active_node)
			end

			if time <= ele.helpers.round(result.time * 10) then
				break
			end

			local output = result.output
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
				ele.helpers.swap_node(pos, machine_node)
				time = ele.helpers.round(res_time*10)
				status = "Output Full!"
				break
			end

			time = 0
			inv:set_list("src", result.new_input)
			inv:set_list("dst", inv:get_list("dst_tmp"))
			break
		end

		local pct = 0
		if res_time > 0 and time > 0 then
			pct = math.floor((time / ele.helpers.round(res_time * 10)) * 100)
		end

		meta:set_string("formspec", get_formspec(craft_type, pow_buffer, pct, pos, state))
		meta:set_string("infotext", ("%s %s"):format(nodedef.description, status) ..
			"\n" .. ele.capacity_text(capacity, storage))

		meta:set_int("src_time", time)
		meta:set_int("storage", pow_buffer.storage)

		return refresh
	end

	local sizes = elepm.craft.types[craft_type]
	nodedef.on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()
		inv:set_size("src", sizes.inputs)
		inv:set_size("dst", 4)

		local storage  = ele.helpers.get_node_property(meta, pos, "storage")
		local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
		local pow_buffer = {capacity = capacity, storage = storage, usage = 0}
		meta:set_string("formspec", get_formspec(craft_type, pow_buffer, nil, pos))
	end

	ele.register_machine(nodename, nodedef)
end
