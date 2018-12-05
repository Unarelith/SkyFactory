
-- Machine definitions

local pw = minetest.get_modpath("pipeworks") ~= nil
local mc = minetest.get_modpath("mesecons") ~= nil
local tl = minetest.get_modpath("tubelib") ~= nil

--[[
	Groups:
		ele_machine			Any machine that does something with power
			ele_provider	Any machine that can provide power (generator, storage, etc)
			ele_user		Any machine that uses power
			ele_storage		Any machine that stores power
		ele_conductor		A node that is used to connect ele_machine nodes together

	Custom nodedef variables:
		ele_capacity = 12000
			Static capacitor for nodes.
			** Can be overridden by metadata: `capacity`

		ele_inrush = 32
			Decides how much power can be inserted into this machine's internal capacitor.
			** Can be overridden by metadata: `inrush`

		ele_output = 64
			Decides how much power a `ele_provider` node can output.
			** SHOULD be overridden by metadata: `output`

		ele_sides = nil
			All sides of providers currently output power. All sides of other nodes accept power.
			** SHOULD be overridden by metadata: `sides`

		ele_usage = 16
			How much power this machine uses or generates.
			** Can be overridden by metadata: `usage`

		ele_active_node = nil
			Set to true or a string to also register an active variant of this node.
			If the parameter is a boolean, "_active" will be appended to the `node_name`

		ele_active_nodedef = nil
			If set, the `ele_active_node` will have this table in its nodedef.
			Intended use: to set textures or light output.
]]

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end

ele.default = {}
function ele.default.allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	if listname == "dst" then
		return 0
	end

	return stack:get_count()
end

function ele.default.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return ele.default.allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

function ele.default.allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	return stack:get_count()
end

function ele.default.metadata_inventory_changed(pos)
	local t = minetest.get_node_timer(pos)

	if not t:is_started() then
		t:start(1.0)
	end
end

-- State machine descriptions
ele.default.states = {
	[0] = {s = "on", d = "Always on", e = "toggle"},
	{s = "off", d = "Always off", e = "toggle"},
	{s = "signal", d = "Enable by Mesecons signal", e = "mesecons"},
	{s = "interrupt", d = "Disable by Mesecons signal", e = "mesecons"},
}

-- Preserve power storage in the item stack dropped
local function preserve_metadata(pos, oldnode, oldmeta, drops)
	local meta     = minetest.get_meta(pos)
	local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
	local storage  = ele.helpers.get_node_property(meta, pos, "storage")

	local nodedesc  = minetest.registered_nodes[oldnode.name].description

	if storage == 0 then
		return drops
	end

	for i,stack in pairs(drops) do
		local stack_meta = stack:get_meta()
		stack_meta:set_int("storage", storage)
		stack_meta:set_string("description", nodedesc .. "\n" .. ele.capacity_text(capacity, storage))
		drops[i] = stack
	end

	return drops
end

-- Retrieve power storage from itemstack when placed
local function retrieve_metadata(pos, placer, itemstack, pointed_thing)
	local item_meta = itemstack:get_meta()
	local storage   = item_meta:get_int("storage")
	
	if storage and storage > 0 then
		local meta = minetest.get_meta(pos)
		meta:set_int("storage", storage)
		minetest.get_node_timer(pos):start(1.0)
	end

	return false
end

function ele.capacity_text(capacity, storage)
	return ("Charge: %s / %s %s"):format(ele.helpers.comma_value(storage),
		ele.helpers.comma_value(capacity), ele.unit)
end

-- API support
local tube = {
	insert_object = function(pos, node, stack, direction)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		minetest.get_node_timer(pos):start(1.0)
		return inv:add_item("src", stack)
	end,
	can_insert = function(pos, node, stack, direction)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if meta:get_int("splitstacks") == 1 then
			stack = stack:peek_item(1)
		end
		return inv:room_for_item("src", stack)
	end,
	input_inventory = "dst",

	connect_sides = {left = 1, right = 1, back = 1, top = 1, bottom = 1},
}

local tubelib_tube = {
	on_pull_item = function(pos, side, player_name)
		local meta = minetest.get_meta(pos)
		minetest.get_node_timer(pos):start(1.0)
		return tubelib.get_item(meta, "dst")
	end,
	on_push_item = function(pos, side, item, player_name)
		local meta = minetest.get_meta(pos)
		minetest.get_node_timer(pos):start(1.0)
		return tubelib.put_item(meta, "src", item)
	end,
	on_unpull_item = function(pos, side, item, player_name)
		local meta = minetest.get_meta(pos)
		minetest.get_node_timer(pos):start(1.0)
		return tubelib.put_item(meta, "dst", item)
	end,
}

local mesecons_def = {
	effector = {
		action_on = function (pos, node)
			local meta = minetest.get_meta(pos)
			meta:set_int("signal_interrupt", 1)
		end,
		action_off = function (pos, node)
			local meta = minetest.get_meta(pos)
			meta:set_int("signal_interrupt", 0)
		end,
		action_change = function (pos, node)
			local t = minetest.get_node_timer(pos)
			if not t:is_started() then
				t:start(1.0)
			end
		end,
	}
}

-- Functions

local function switch_state(pos, state_def)
	local meta  = minetest.get_meta(pos)
	local state = meta:get_int("state")
	local states = {}
	for id,state in pairs(ele.default.states) do
		if state_def[state.e] then
			states[#states + 1] = id
		end
	end

	if #states == 0 then return end

	state = state + 1
	if state >= #states then
		state = 0
	end
	state = states[state + 1]
	meta:set_int("state", state)

	local t = minetest.get_node_timer(pos)
	if not t:is_started() then
		t:start(1.0)
	end
end

-- Register a base device
function ele.register_base_device(nodename, nodedef)
	local tlsupp = tl and nodedef.groups and (nodedef.groups["tubedevice"] or nodedef.groups["tube"])

	-- Override construct callback
	local original_on_construct = nodedef.on_construct
	nodedef.on_construct = function (pos)
		if nodedef.groups and nodedef.groups["ele_machine"] then
			local meta = minetest.get_meta(pos)
			meta:set_int("storage", 0)
		end
		
		ele.clear_networks(pos)

		if original_on_construct then
			original_on_construct(pos)
		end
	end

	-- Override destruct callback
	local original_after_destruct = nodedef.after_destruct
	nodedef.after_destruct = function (pos)
		ele.clear_networks(pos)

		if original_after_destruct then
			original_after_destruct(pos)
		end
	end

	-- Save storage amount when picked up
	local original_preserve_metadata = nodedef.preserve_metadata
	nodedef.preserve_metadata = function (pos, oldnode, oldmeta, drops)
		drops = preserve_metadata(pos, oldnode, oldmeta, drops)
		if original_preserve_metadata then
			drops = original_preserve_metadata(pos, oldnode, oldmeta, drops)
		end
		return drops
	end

	local original_after_place_node = nodedef.after_place_node
	nodedef.after_place_node = function(pos, placer, itemstack, pointed_thing)
		local ret = retrieve_metadata(pos, placer, itemstack, pointed_thing)

		if tlsupp then
			tubelib.add_node(pos, nodename)
		end

		if original_after_place_node then
			ret = original_after_place_node(pos, placer, itemstack, pointed_thing)
		end

		return ret
	end

	local original_after_dig_node = nodedef.after_dig_node
	nodedef.after_dig_node = function(pos, placer, itemstack, pointed_thing)
		if tlsupp then
			tubelib.remove_node(pos)
		end

		if original_after_dig_node then
			return original_after_dig_node(pos, placer, itemstack, pointed_thing)
		end
	end

	-- Prevent digging when there's items inside
	if not nodedef.can_dig then
		nodedef.can_dig = can_dig
	end

	-- Explicitly allow the disabling of the state machine
	if nodedef.groups["state_machine"] ~= 0 and not nodedef["states"] then
		nodedef.states = {toggle = true}
	end

	-- Pipeworks support
	if pw and nodedef.groups and (nodedef.groups["tubedevice"] or nodedef.groups["tube"]) then
		if nodedef['tube'] == false then
			nodedef['tube'] = nil
			nodedef.groups["tubedevice"] = 0
			nodedef.groups["tube"] = 0
		elseif nodedef['tube'] then
			for key,val in pairs(tube) do
				if not nodedef['tube'][key] then
					nodedef['tube'][key] = val
				end
			end
		else
			nodedef['tube'] = tube
		end
	end

	-- Node IO Support
	if nodedef.groups["tubedevice"] or nodedef.groups["tube"] then
		nodedef.node_io_can_put_item = function(pos, node, side) return true end
		nodedef.node_io_room_for_item = function(pos, node, side, itemstack, count)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local istack_real = ItemStack(itemstack)
			istack_real:set_count(count)
			return inv:room_for_item("src", istack_real)
		end
		nodedef.node_io_put_item = function(pos, node, side, putter, itemstack)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local t = minetest.get_node_timer(pos)
			if not t:is_started() then
				t:start(1.0)
			end
			return inv:add_item("src", itemstack)
		end
		nodedef.node_io_can_take_item = function(pos, node, side) return true end
		nodedef.node_io_get_item_size = function(pos, node, side)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:get_size("dst")
		end
		nodedef.node_io_get_item_name = function(pos, node, side, index)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:get_stack("dst", index):get_name()
		end
		nodedef.node_io_get_item_stack = function(pos, node, side, index)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:get_stack("dst", index)
		end
		nodedef.node_io_take_item = function(pos, node, side, taker, want_item, want_count)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local stack = ItemStack(want_item)
			stack:set_count(want_count)
			local t = minetest.get_node_timer(pos)
			if not t:is_started() then
				t:start(1.0)
			end
			return inv:take_item("dst", stack)
		end
	end

	-- Mesecons support
	if mc then
		nodedef["mesecons"] = mesecons_def
		if nodedef.groups["state_machine"] ~= 1 then
			nodedef.states["mesecons"] = true
		end
	end

	-- STATE MACHINE
	local original_on_receive_fields = nodedef.on_receive_fields
	nodedef.on_receive_fields = function (pos, formname, fields, sender)
		if sender and sender ~= "" and minetest.is_protected(pos, sender:get_player_name()) then
			return
		end

		if nodedef.states then
			if fields["cyclestate"] then
				switch_state(pos, nodedef.states)
			end
		end

		if original_on_receive_fields then
			return original_on_receive_fields(pos, formname, fields, sender)
		end
	end

	-- Finally, register the damn thing already
	minetest.register_node(nodename, nodedef)
	local active_name = nil

	-- Register an active variant if configured.
	if nodedef.ele_active_node then
		local active_nodedef = table.copy(nodedef)
		active_name = nodename.."_active"
		
		if nodedef.ele_active_node ~= true then
			active_name = nodedef.ele_active_node
		end

		if nodedef.ele_active_nodedef then
			for k,v in pairs(nodedef.ele_active_nodedef) do
				active_nodedef[k] = v
			end

			nodedef.ele_active_nodedef        = nil
			active_nodedef.ele_active_nodedef = nil
		end

		active_nodedef.groups["ele_active"] = 1
		active_nodedef.groups["not_in_creative_inventory"] = 1
		active_nodedef.drop = nodename
		minetest.register_node(active_name, active_nodedef)
	end

	-- tubelib support
	if tlsupp then
		local extras = {}

		if active_name then
			extras = {active_name}
		end

		tubelib.register_node(nodename, extras, tubelib_tube)
	end

	-- nodeio fluids
	if nodedef.groups and nodedef.groups['fluid_container'] then
		fluid_lib.register_node(nodename)
		if active_name then
			fluid_lib.register_node(active_name)
		end
	end
end

function ele.register_machine(nodename, nodedef)
	if not nodedef.groups then
		nodedef.groups = {}
	end

	-- Start cleaning up the nodedef
	local defaults = {
		ele_capacity = 1600,
		ele_inrush   = 64,
		ele_usage    = 64,
		ele_output   = 64,
		ele_sides    = nil,
		paramtype2   = "facedir"
	}

	-- Ensure everything that's required is present
	for k,v in pairs(defaults) do
		if not nodedef[k] then
			nodedef[k] = v
		end
	end

	-- Ensure machine group is used properly
	if not nodedef.groups["ele_conductor"] and not nodedef.groups["ele_machine"] then
		nodedef.groups["ele_machine"] = 1
	elseif nodedef.groups["ele_conductor"] and nodedef.groups["ele_machine"] then
		nodedef.groups["ele_machine"] = 0
	end

	if not nodedef.ele_no_automatic_ports then
		-- Add ports to the device's faces
		if nodedef.tiles and #nodedef.tiles == 6 then
			for i = 1, 5 do
				nodedef.tiles[i] = nodedef.tiles[i] .. "^elepower_power_port.png"
			end
		end

		-- Add ports to the device's active faces
		if nodedef.ele_active_nodedef and nodedef.ele_active_nodedef.tiles and #nodedef.ele_active_nodedef.tiles == 6 then
			for i = 1, 5 do
				nodedef.ele_active_nodedef.tiles[i] = nodedef.ele_active_nodedef.tiles[i] .. "^elepower_power_port.png"
			end
		end
	end
	nodedef.ele_no_automatic_ports = nil

	-- Default metadata handlers for "src" and "dst"
	if not nodedef.allow_metadata_inventory_put then
		nodedef.allow_metadata_inventory_put  = ele.default.allow_metadata_inventory_put
		nodedef.allow_metadata_inventory_move = ele.default.allow_metadata_inventory_move
	end

	if not nodedef.allow_metadata_inventory_take then
		nodedef.allow_metadata_inventory_take = ele.default.allow_metadata_inventory_take
	end

	-- Default metadata changed handlers for inventories
	-- Starts the timer on the node
	if not nodedef.on_metadata_inventory_move then
		nodedef.on_metadata_inventory_move = ele.default.metadata_inventory_changed
	end

	if not nodedef.on_metadata_inventory_put then
		nodedef.on_metadata_inventory_put  = ele.default.metadata_inventory_changed
	end

	if not nodedef.on_metadata_inventory_take then
		nodedef.on_metadata_inventory_take = ele.default.metadata_inventory_changed
	end

	ele.register_base_device(nodename, nodedef)
end
