-- Network graphs are built eminating from provider nodes.
-- TODO: Caching

---------------------
-- Graph Functions --
---------------------

local function clear_networks_from_node(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("network_id", "")
end

local function add_node(nodes, pos, pnodeid)
	local node_id = minetest.hash_node_position(pos)
	if nodes[node_id] then
		return false
	end
	nodes[node_id] = pos
	return true
end

local function add_duct_node(nodes, pos, pnodeid, queue)
	if add_node(nodes, pos, pnodeid) then
		queue[#queue + 1] = pos
	end
end

local function check_node(targets, all_nodes, pos, p_pos, pnodeid, queue)
	ele.helpers.get_or_load_node(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local ndef = minetest.registered_nodes[node.name]

	if ele.helpers.get_item_group(node.name, "elefluid_transport") then
		add_duct_node(all_nodes, pos, pnodeid, queue)
		return
	end

	if not ndef['node_io_can_put_liquid'] or not ndef['node_io_can_put_liquid'](pos, node, "") then
		return
	end

	add_node(targets, pos, pnodeid)
end

local function traverse_network(targets, all_nodes, pos, p_pos, pnodeid, queue)
	local positions = {
		{x=pos.x+1, y=pos.y,   z=pos.z},
		{x=pos.x-1, y=pos.y,   z=pos.z},
		{x=pos.x,   y=pos.y+1, z=pos.z},
		{x=pos.x,   y=pos.y-1, z=pos.z},
		{x=pos.x,   y=pos.y,   z=pos.z+1},
		{x=pos.x,   y=pos.y,   z=pos.z-1}}
	for _, cur_pos in pairs(positions) do
		check_node(targets, all_nodes, cur_pos, p_pos, pnodeid, queue)
	end
end

local function fluid_targets(p_pos, pos)
	local provider = minetest.get_node(p_pos)
	local pnodeid  = minetest.pos_to_string(p_pos)

	local targets   = {}
	local queue     = {}
	local all_nodes = {}

	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if node and ele.helpers.get_item_group(node.name, "elefluid_transport") then
		add_duct_node(all_nodes, pos, pnodeid, queue)
	elseif node and ndef['node_io_can_put_liquid'] and ndef['node_io_can_put_liquid'](pos, node, "") then
		queue = {p_pos}
	end

	while next(queue) do
		local to_visit = {}
		for _, posi in ipairs(queue) do
			traverse_network(targets, all_nodes, posi, p_pos, pnodeid, to_visit)
		end
		queue = to_visit
	end

	targets   = ele.helpers.flatten(targets)
	all_nodes = ele.helpers.flatten(all_nodes)

	return targets
end

function elefluid.transfer_timer_tick(pos, elapsed)
	local refresh = true
	local node    = minetest.get_node_or_nil(pos)

	if not node then
		return false
	end

	local meta    = minetest.get_meta(pos)
	local targets = {}

	-- Only allow the node directly behind to be a start of a network
	local tpos  = vector.add(minetest.facedir_to_dir(node.param2), pos)
	local tnode = minetest.get_node(tpos)
	local ndef  = minetest.registered_nodes[tnode.name]
	if not ele.helpers.get_item_group(tnode.name, "elefluid_transport") and
		(not ndef['node_io_can_put_liquid'] or not ndef['node_io_can_put_liquid'](tpos, tnode, "")) then
		minetest.forceload_free_block(pos)
		return
	end

	-- Retrieve network
	targets = fluid_targets(pos, tpos)

	-- No targets, don't proceed
	if #targets == 0 then
		return true
	end

	-- Begin transfer
	local srcpos  = ele.helpers.face_front(pos, node.param2)
	local srcnode = minetest.get_node(srcpos)

	-- Make sure source node is not air
	if not srcnode or srcnode.name == "air" then
		return true
	end

	local srcdef = minetest.registered_nodes[srcnode.name]

	-- Make sure source node is a registered fluid container
	if not srcdef['node_io_can_take_liquid'] then
		return false
	end

	local c = srcdef.node_io_can_take_liquid(srcpos, srcnode, "")
	if not c then return false end

	local srcmeta = minetest.get_meta(srcpos)
	local srcdef  = minetest.registered_nodes[srcnode.name]
	local fl_size = srcdef.node_io_get_liquid_size(srcpos, srcnode, "")
	local buffers = {}
	for i = 1, fl_size do
		buffers[i] = srcdef.node_io_get_liquid_name(srcpos, srcnode, "", i)
	end
	if not #buffers then return true end

	-- Limit the amount of fluid pumped per cycle
	local pcapability = ele.helpers.get_node_property(meta, pos, "fluid_pump_capacity")
	local pumped      = 0

	-- Transfer some fluid here
	for _,pos in pairs(targets) do
		if not vector.equals(pos, srcpos) then
			if pumped >= pcapability then break end
			local destnode = minetest.get_node(pos)
			local destdef  = minetest.registered_nodes[destnode.name]
			local pp = nil

			if destdef['node_io_can_put_liquid'] then
				if destdef.node_io_can_put_liquid(pos, destnode, "") then
					pp = {}
					local fl_size = destdef.node_io_get_liquid_size(pos, destnode, "")
					for i = 1, fl_size do
						pp[i] = destdef.node_io_get_liquid_name(pos, destnode, "", i)
					end
					if not #pp then pp = nil end
				end
			end

			local changed = false

			if pp ~= nil then
				for bindex,bfluid in pairs(pp) do
					for aindex,afluid in pairs(buffers) do
						if pumped >= pcapability then break end
						if (afluid == bfluid or bfluid == "") then
							local idef = destdef.node_io_room_for_liquid(pos, destnode, "", afluid, pcapability)
							if idef > 0 then
								local fluidcount = srcdef.node_io_get_liquid_stack(srcpos, srcnode, "", aindex):get_count()
								local defc = math.min(fluidcount, idef)
								local defi = srcdef.node_io_take_liquid(srcpos, srcnode, "", nil, afluid, defc)
								if defi.millibuckets > 0 then
									local lo = destdef.node_io_put_liquid(pos, destnode, "", nil, afluid, defi.millibuckets)
									pumped = pumped + (defi.millibuckets - lo)
									changed = true
								end
							end
						end
					end
				end
			end

			if changed then
				minetest.get_node_timer(srcpos):start(1.0)
				minetest.get_node_timer(pos):start(1.0)
			end
		end
	end

	return refresh
end

function elefluid.refresh_node(pos)
	minetest.get_node_timer(pos):start(1.0)
	return
end

minetest.register_lbm({
    label = "Fluid Transfer Tick",
    name = "elepower_fapi:fluid_transfer_tick",
    nodenames = {"group:elefluid_transport_source"},
    run_at_every_load = true,
    action = elefluid.refresh_node,
})
