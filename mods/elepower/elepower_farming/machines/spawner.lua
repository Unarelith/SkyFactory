
-- How many seconds there are between runs
local SPAWNER_TICK = 10

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("src")
end

local function spawn(pos, mob)
	-- get meta and command
	local meta = minetest.get_meta(pos)

	-- TODO: ways to configure
	local mlig = 0  -- min light
	local xlig = 15 -- max light
	local num  = 4  -- max number
	local pla  = 24 -- player radius
	local yof  = 0  -- Y offset to spawn mob

	-- if amount is 0 then do nothing
	if num == 0 then
		return
	end

	-- are we spawning a registered mob?
	if not mobs.spawning_mobs[mob] then
		return
	end

	-- check objects inside 9x9 area around spawner
	local objs = minetest.get_objects_inside_radius(pos, 9)
	local count = 0
	local ent = nil

	-- count mob objects of same type in area
	for k, obj in ipairs(objs) do
		ent = obj:get_luaentity()

		if ent and ent.name and ent.name == mob then
			count = count + 1
		end
	end

	-- is there too many of same type?
	if count >= num then
		return
	end

	-- spawn mob if player detected and in range
	if pla > 0 then
		local in_range = 0
		local objs = minetest.get_objects_inside_radius(pos, pla)

		for _,oir in pairs(objs) do
			if oir:is_player() then
				in_range = 1
				break
			end
		end

		-- player not found
		if in_range == 0 then
			return
		end
	end

	-- find air blocks within 5 nodes of spawner
	local air = minetest.find_nodes_in_area(
		{x = pos.x - 5, y = pos.y + yof, z = pos.z - 5},
		{x = pos.x + 5, y = pos.y + yof, z = pos.z + 5},
		{"air"})

	-- spawn in random air block
	if air and #air > 0 then
		local pos2 = air[math.random(#air)]
		local lig = minetest.get_node_light(pos2) or 0

		pos2.y = pos2.y + 0.5

		-- only if light levels are within range
		if lig >= mlig and lig <= xlig and minetest.registered_entities[mob] then
			minetest.add_entity(pos2, mob)
			return true
		end
	end

	return
end

local function get_formspec(timer, power, state)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		ele.formspec.state_switcher(7, 0, state)..
		ele.formspec.create_bar(1, 0, 100 - timer, "#00ff11", true)..
		"list[context;src;3.5,1.5;1,1;]"..
		"image[3.5,1.5;1,1;elefarming_egg_silhouette.png]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function on_timer(pos, elapsed)
	local refresh = false
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
	local usage    = ele.helpers.get_node_property(meta, pos, "usage")
	local storage  = ele.helpers.get_node_property(meta, pos, "storage")

	local work = meta:get_int("src_time")

	local state = meta:get_int("state")
	local is_enabled = ele.helpers.state_enabled(meta, pos, state)

	local egg_slot = inv:get_stack("src", 1)
	local egg_name = egg_slot:get_name()
	local mob_desc = "None"
	local active   = "Active"

	local pow_buffer = {capacity = capacity, storage = storage, usage = 0}

	if pow_buffer.storage > usage and not egg_slot:is_empty() and
		ele.helpers.get_item_group(egg_name, "spawn_egg") and is_enabled then
		local mob_name = egg_name:gsub("_set", "")

		if work == SPAWNER_TICK then
			local spawned = 0
			
			-- Spawn
			if spawn(pos, mob_name) then
				spawned = spawned + 1
			end

			work = 0
			if spawned > 0 then
				pow_buffer.storage = pow_buffer.storage - usage
			end
		else
			work = work + 1
		end

		refresh = true
		mob_desc = minetest.registered_items[mob_name].description
		pow_buffer.usage = usage
	elseif not is_enabled then
		active = "Off"
	else
		work = 0
		active = "Inactive"
	end

	meta:set_string("infotext", ("Powered Mob Spawner %s\nMob: %s\n%s"):format(
		active, mob_desc, ele.capacity_text(capacity, pow_buffer.storage)))

	local work_percent  = math.floor((work / SPAWNER_TICK)*100)

	meta:set_string("formspec", get_formspec(work_percent, pow_buffer, state))
	meta:set_int("storage", pow_buffer.storage)
	meta:set_int("src_time", work)

	return refresh
end

ele.register_machine("elepower_farming:spawner", {
	description  = "Powered Mob Spawner",
	ele_capacity = 64000,
	ele_inrush   = 800,
	ele_usage    = 800,
	ele_no_automatic_ports = true,
	tiles = {
		"elefarming_machine_spawner_top.png", "elefarming_machine_base.png", "elefarming_machine_side.png",
		"elefarming_machine_side.png", "elefarming_machine_side.png", "elefarming_machine_side.png",
	},
	groups = {
		oddly_breakable_by_hand = 1,
		ele_machine = 1,
		ele_user = 1,
		cracky = 1,
		tubedevice = 1,
		tubedevice_receiver = 1,
	},
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()
		inv:set_size("src", 1)

		meta:set_int("src_time", 0)

		local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
		meta:set_string("formspec", get_formspec(0, {capacity = capacity, storage = 0}))
	end,
	can_dig  = can_dig,
	on_timer = on_timer,
})
