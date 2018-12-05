
local function get_formspec_default(power, percent, state)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		ele.formspec.state_switcher(7, 0, state)..
		"list[context;src;3,1.5;1,1;]"..
		"image[4,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
		percent..":default_furnace_fire_fg.png]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

function elepm.register_fuel_generator(nodename, nodedef)
	if not nodedef.groups then
		nodedef.groups = {}
	end

	nodedef.groups["ele_machine"]  = 1
	nodedef.groups["ele_provider"] = 1
	nodedef.groups["tubedevice"]   = 1
	nodedef.groups["tubedevice_receiver"] = 1

	-- Allow for custom formspec
	local get_formspec = get_formspec_default
	if nodedef.get_formspec then
		get_formspec = nodedef.get_formspec
		nodedef.get_formspec = nil
	end

	nodedef.on_timer = function (pos, elapsed)
		local refresh = false
		local meta = minetest.get_meta(pos)

		local burn_time      = meta:get_int("burn_time")
		local burn_totaltime = meta:get_int("burn_totaltime")
		
		local capacity   = ele.helpers.get_node_property(meta, pos, "capacity")
		local generation = ele.helpers.get_node_property(meta, pos, "usage")
		local storage    = ele.helpers.get_node_property(meta, pos, "storage")

		local state = meta:get_int("state")
		local is_enabled = ele.helpers.state_enabled(meta, pos, state)
		local status = "Idle"

		local pow_buffer = {capacity = capacity, storage = storage, usage = 0}

		while true do
			if not is_enabled then
				status = "Off"
				break
			end

			-- If more to burn and the energy produced was used: produce some more
			if burn_time > 0 then
				if storage + generation > capacity then
					break
				end

				pow_buffer.storage = pow_buffer.storage + generation
				pow_buffer.usage = generation

				burn_time = burn_time - 1
				meta:set_int("burn_time", burn_time)

				refresh = true
			end

			status = "Active"

			-- Burn another piece of fuel
			if burn_time == 0 then
				local inv = meta:get_inventory()
				if not inv:is_empty("src") then 
					local fuellist        = inv:get_list("src")
					local fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})

					if not fuel or fuel.time == 0 then
						ele.helpers.swap_node(pos, nodename)
						break
					end

					meta:set_int("burn_time", fuel.time)
					meta:set_int("burn_totaltime", fuel.time)
					inv:set_stack("src", 1, afterfuel.items[1])
					pow_buffer.usage = generation

					if nodedef.ele_active_node then
						local active_node = nodename.."_active"
						if nodedef.ele_active_node ~= true then
							active_node = nodedef.ele_active_node
						end

						ele.helpers.swap_node(pos, active_node)
					end

					refresh = true
				else
					status = "Idle"
					ele.helpers.swap_node(pos, nodename)

					refresh = false
				end
			end
			if burn_totaltime == 0 then burn_totaltime = 1 end
			break
		end

		local percent = math.floor((burn_time / burn_totaltime) * 100)
		meta:set_string("formspec", get_formspec(pow_buffer, percent, state))
		meta:set_string("infotext", ("%s %s"):format(nodedef.description, status) ..
			"\n" .. ele.capacity_text(capacity, pow_buffer.storage))

		meta:set_int("storage", pow_buffer.storage)

		return refresh
	end

	nodedef.on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()
		inv:set_size("src", 1)

		local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
		local storage  = ele.helpers.get_node_property(meta, pos, "storage")

		meta:set_string("formspec", get_formspec({capacity = capacity, storage = storage, usage = 0}, 0))
	end

	ele.register_machine(nodename, nodedef)
end
