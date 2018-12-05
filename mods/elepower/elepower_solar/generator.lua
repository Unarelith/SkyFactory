
local function get_formspec_default(power, percent, state)
	if not percent then percent = 0 end
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		ele.formspec.state_switcher(7, 0, state)..
		"image[3.5,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
		(percent)..":default_furnace_fire_fg.png]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		default.get_hotbar_bg(0, 4.25)
end

-- A generator that creates power using sunlight
function elesolar.register_solar_generator(nodename, nodedef)
	-- Enable de-dusting mechanics
	local dedust = nodedef.ele_solar_dust == nil or nodedef.ele_solar_dust ~= false

	-- Allow for custom formspec
	local get_formspec = get_formspec_default
	if nodedef.get_formspec then
		get_formspec = nodedef.get_formspec
		nodedef.get_formspec = nil
	end

	local defaults = {
		groups = {
			ele_provider = 1,
			oddly_breakable_by_hand = 1,
			ele_solar_generator = 1,
		},
		tube = false,
		ele_usage = 8,
		ele_capacity = 64,
		on_timer = function (pos, elapsed)
			local refresh  = true
			local meta     = minetest.get_meta(pos)
			local nodename = nodename
			
			local capacity   = ele.helpers.get_node_property(meta, pos, "capacity")
			local generation = ele.helpers.get_node_property(meta, pos, "usage")
			local storage    = ele.helpers.get_node_property(meta, pos, "storage")

			local state = meta:get_int("state")
			local is_enabled = ele.helpers.state_enabled(meta, pos, state)

			local pow_buffer = {capacity = capacity, storage = storage, usage = 0}
			local status = "Idle"
			local solarp = 0

			while true do
				if not is_enabled then
					status = "Off"
					break
				end

				if storage + generation > capacity then
					break
				end

				-- Raycasting: Make sure the solar generator is not obstructed
				-- The ray is only casted every 5 seconds instead of every second
				local raystep = meta:get_int("ray_timer")
				local rayokay = meta:get_int("ray_success")
				local pos1 = vector.add(pos, {x=0,y=1,z=0})
				local pos2 = vector.add(pos1, {x=0,y=8,z=0})

				if raystep == 5 then
					local ray = minetest.raycast(pos1, pos2, false, true)
					local found_obstruction = false

					-- Take 8 samples
					for i = 1, 8 do
						local pointed_thing = ray:next()
						if pointed_thing and pointed_thing.type ~= "nothing" then
							found_obstruction = true
							break
						end
					end

					if found_obstruction and rayokay == 1 then
						rayokay = 0
					elseif not found_obstruction and rayokay == 0 then
						rayokay = 1
					end

					meta:set_int("ray_timer", 0)
				else
					meta:set_int("ray_timer", raystep + 1)
				end

				meta:set_int("ray_success", rayokay)

				if rayokay == 0 then break end

				local light = minetest.get_node_light(pos1, nil) or 0
				local time_of_day = minetest.get_timeofday()

				-- turn on array only during day time and if sufficient light
				solarp = light / (minetest.LIGHT_MAX + 1)

				if light >= 12 and time_of_day >= 0.24 and time_of_day <= 0.76 then
					pow_buffer.usage = math.floor(solarp * generation)
					if pow_buffer.usage > 0 then
						pow_buffer.storage = pow_buffer.storage + pow_buffer.usage
						status = "Active"
					end
				end

				solarp = math.floor(100 * solarp)

				break
			end

			meta:set_string("formspec", get_formspec(pow_buffer, solarp, state))
			meta:set_string("infotext", ("%s %s\n%s\nLight: %s"):format(nodedef.description, status,
				ele.capacity_text(capacity, pow_buffer.storage), solarp .. " %"))

			meta:set_int("storage", pow_buffer.storage)

			return refresh
		end,
		on_construct = function (pos)
			local meta = minetest.get_meta(pos)

			local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
			local storage  = ele.helpers.get_node_property(meta, pos, "storage")

			meta:set_string("formspec", get_formspec({capacity = capacity, storage = storage, usage = 0}, 0))
		end
	}

	for key,val in pairs(defaults) do
		if not nodedef[key] then
			nodedef[key] = val
		end
	end
	
	ele.register_machine(nodename, nodedef)
end

minetest.register_lbm({
    label = "Enable Solar Generators on load",
    name = "elepower_solar:solar_generators",
    nodenames = {"group:ele_solar_generator"},
    run_at_every_load = true,
    action = function (pos)
    	local t = minetest.get_node_timer(pos)
    	if not t:is_started() then
    		t:start(1.0)
    	end
    end,
})
