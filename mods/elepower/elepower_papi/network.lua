-- Network graphs are built eminating from provider nodes.
--[[
	TODO:
	Currently, there's a problem where storage nodes are allowed to create their own graph.
	When placing the storage onto a cable, it will add itself to the graph of that cable.
	But, when placing a cable onto the storage, that cable is added to the storage's own graph
	and thus cannot be connected to the previous graph.
]]

-- Network cache
ele.graphcache = {devices = {}}

---------------------
-- Graph Functions --
---------------------

local function table_has_string(arr, str)
	for _,astr in ipairs(arr) do
		if astr == str then
			return true
		end
	end
	return false
end

local function add_node(nodes, pos, pnodeid)
	local node_id = minetest.hash_node_position(pos)

	if not ele.graphcache.devices[node_id] then
		ele.graphcache.devices[node_id] = {}
	end

	if not table_has_string(ele.graphcache.devices[node_id], pnodeid) then
		table.insert(ele.graphcache.devices[node_id], pnodeid)
	end

	if nodes[node_id] then
		return false
	end

	nodes[node_id] = pos
	return true
end

local function add_conductor_node(nodes, pos, pnodeid, queue)
	if add_node(nodes, pos, pnodeid) then
		queue[#queue + 1] = pos
	end
end

local function check_node(users, providers, conductors, pos, pr_pos, pnodeid, queue)
	if minetest.pos_to_string(pos) == pnodeid then return end

	ele.helpers.get_or_load_node(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)

	if ele.helpers.get_item_group(node.name, "ele_conductor") then
		add_conductor_node(conductors, pos, pnodeid, queue)
		return
	end

	if not ele.helpers.get_item_group(node.name, "ele_machine") then
		return
	end

	if ele.helpers.get_item_group(node.name, "ele_user") or
		ele.helpers.get_item_group(node.name, "ele_storage") then
		add_node(users, pos, pnodeid)
	elseif ele.helpers.get_item_group(node.name, "ele_provider") then
		add_node(providers, pos, pnodeid)
	end
end

local function traverse_network(users, providers, conductors, pos, pr_pos, pnodeid, queue)
	local positions = {
		{x=pos.x+1, y=pos.y,   z=pos.z},
		{x=pos.x-1, y=pos.y,   z=pos.z},
		{x=pos.x,   y=pos.y+1, z=pos.z},
		{x=pos.x,   y=pos.y-1, z=pos.z},
		{x=pos.x,   y=pos.y,   z=pos.z+1},
		{x=pos.x,   y=pos.y,   z=pos.z-1}}
	for _, cur_pos in pairs(positions) do
		check_node(users, providers, conductors, cur_pos, pr_pos, pnodeid, queue)
	end
end

local function discover_branches(pr_pos, positions)
	local provider = minetest.get_node(pr_pos)
	local pnodeid  = minetest.pos_to_string(pr_pos)

	if ele.graphcache[pnodeid] then
		local cached = ele.graphcache[pnodeid]
		return cached.users, cached.providers
	end

	local users      = {}
	local providers  = {}
	local queue      = {}
	local conductors = {}

	for _,pos in ipairs(positions) do
		queue = {}

		local node = minetest.get_node(pos)
		if node and ele.helpers.get_item_group(node.name, "ele_conductor") then
			add_conductor_node(conductors, pos, pnodeid, queue)
		elseif node and ele.helpers.get_item_group(node.name, "ele_machine") then
			queue = {pr_pos}
		end

		while next(queue) do
			local to_visit = {}
			for _, posi in ipairs(queue) do
				traverse_network(users, providers, conductors, posi, pr_pos, pnodeid, to_visit)
			end
			queue = to_visit
		end
	end

	-- Add self to providers
	add_node(providers, pr_pos, pnodeid)

	users      = ele.helpers.flatten(users)
	providers  = ele.helpers.flatten(providers)
	conductors = ele.helpers.flatten(conductors)

	ele.graphcache[pnodeid] = {conductors = conductors, users = users, providers = providers}

	return users, providers
end

-----------------------
-- Main Transfer ABM --
-----------------------

local function give_node_power(pos, available)
	local user_meta = minetest.get_meta(pos)
	local capacity  = ele.helpers.get_node_property(user_meta, pos, "capacity")
	local inrush    = ele.helpers.get_node_property(user_meta, pos, "inrush")
	local storage   = user_meta:get_int("storage")

	local total_add = 0

	if available >= inrush then
		total_add = inrush
	elseif available < inrush then
		total_add = available
	end

	if total_add + storage > capacity then
		total_add = capacity - storage
	end

	if storage >= capacity then
		total_add = 0
		storage   = capacity
	end

	return total_add, storage
end

minetest.register_abm({
	nodenames = {"group:ele_provider"},
	label     = "elepower Power Transfer Tick",
	interval  = 1,
	chance    = 1,
	action    = function(pos, node, active_object_count, active_object_count_wider)
		local meta  = minetest.get_meta(pos)
		local meta1 = nil

		local users     = {}
		local providers = {}

		local providerdef = minetest.registered_nodes[node.name]

		-- TODO: Customizable output sides
		local positions = {
			{x=pos.x,   y=pos.y-1, z=pos.z},
			{x=pos.x,   y=pos.y+1, z=pos.z},
			{x=pos.x-1, y=pos.y,   z=pos.z},
			{x=pos.x+1, y=pos.y,   z=pos.z},
			{x=pos.x,   y=pos.y,   z=pos.z-1},
			{x=pos.x,   y=pos.y,   z=pos.z+1}
		}

		local branches = {}
		for _,pos1 in ipairs(positions) do
			local pnode = minetest.get_node(pos1)
			local name  = pnode.name
			local networked = ele.helpers.get_item_group(name, "ele_machine") or
				ele.helpers.get_item_group(name, "ele_conductor")

			if networked then
				branches[#branches + 1] = pos1
			end
		end

		-- No possible branches found
		if #branches == 0 then
			minetest.forceload_free_block(pos)
			return
		else
			minetest.forceload_block(pos)
		end

		-- Find all users and providers
		users, providers = discover_branches(pos, branches)

		-- Calculate power data
		local pw_supply = 0
		local pw_demand = 0

		for _, spos in ipairs(providers) do
			local smeta      = minetest.get_meta(spos)
			local pw_storage = smeta:get_int("storage")
			local p_output   = ele.helpers.get_node_property(smeta, spos, "output")

			if p_output and pw_storage >= p_output then
				pw_supply = pw_supply + p_output
			elseif p_output and pw_storage < p_output then
				pw_supply = pw_supply + pw_storage
			end
		end

		-- Give power to users
		for _,ndv in ipairs(users) do
			if pw_demand > pw_supply then
				break
			end

			-- Sharing: Determine how much each user gets
			local user_gets, user_storage = give_node_power(ndv, (pw_supply - pw_demand))
			pw_demand = pw_demand + user_gets

			if user_gets > 0 then
				local user_meta = minetest.get_meta(ndv)
				user_meta:set_int("storage", user_storage + user_gets)

				-- Set timer on this node
				local t = minetest.get_node_timer(ndv)
				if not t:is_started() then
					t:start(1.0)
				end
			end
		end

		-- Take the power from provider nodes
		if pw_demand > 0 then
			for _, spos in ipairs(providers) do
				if pw_demand == 0 then break end
				local smeta = minetest.get_meta(spos)
				local pw_storage = smeta:get_int("storage")

				if pw_storage >= pw_demand then
					smeta:set_int("storage", pw_storage - pw_demand)
					pw_demand = 0
				else
					pw_demand = pw_demand - pw_storage
					smeta:set_int("storage", 0)
				end

				local t = minetest.get_node_timer(spos)
				if not t:is_started() then
					t:start(1.0)
				end
			end
		end
	end,
})

local function check_connections(pos)
	local connections = {}
	local positions = {
		{x=pos.x+1, y=pos.y,   z=pos.z},
		{x=pos.x-1, y=pos.y,   z=pos.z},
		{x=pos.x,   y=pos.y+1, z=pos.z},
		{x=pos.x,   y=pos.y-1, z=pos.z},
		{x=pos.x,   y=pos.y,   z=pos.z+1},
		{x=pos.x,   y=pos.y,   z=pos.z-1}}

	for _,connected_pos in ipairs(positions) do
		local name = minetest.get_node(connected_pos).name
		if ele.helpers.get_item_group(name, "ele_conductor") or ele.helpers.get_item_group(name, "ele_machine") then
			table.insert(connections, connected_pos)
		end
	end
	return connections
end

-- Update networks when a node has been placed or removed
function ele.clear_networks(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local name = node.name
	local placed = name ~= "air"
	local positions = check_connections(pos)
	if #positions < 1 then return end
	local hash_pos = minetest.hash_node_position(pos)
	local dead_end = #positions == 1
	for _,connected_pos in ipairs(positions) do
		local networks = ele.graphcache.devices[minetest.hash_node_position(connected_pos)] or
			{minetest.pos_to_string(connected_pos)}

		for _,net in ipairs(networks) do
			if net and ele.graphcache[net] then
				-- This is so we can break the pipeline instead of the network search loop
				while true do
					if dead_end and placed then
						-- Dead end placed, add it to the network
						-- Get the networks
						local network_ids = ele.graphcache.devices[minetest.hash_node_position(positions[1])] or
							{minetest.pos_to_string(positions[1])}

						if not #network_ids then
							-- We're evidently not on a network, nothing to add ourselves to
							break
						end

						for _, int_net in ipairs(network_ids) do
							if ele.graphcache[int_net] then
								local network = ele.graphcache[int_net]

								-- Actually add it to the (cached) network
								if not ele.graphcache.devices[hash_pos] then
									ele.graphcache.devices[hash_pos] = {}
								end

								if not table_has_string(ele.graphcache.devices[hash_pos], int_net) then
									table.insert(ele.graphcache.devices[hash_pos], int_net)
								end

								if ele.helpers.get_item_group(name, "ele_conductor") then
									table.insert(network.conductors, pos)
								elseif ele.helpers.get_item_group(name, "ele_machine") then
									if ele.helpers.get_item_group(name, "ele_user") or 
										ele.helpers.get_item_group(name, "ele_storage") then
										table.insert(network.users, pos)
									elseif ele.helpers.get_item_group(name, "ele_provider") then
										table.insert(network.providers, pos)
									end
								end
							end
						end

						break
					elseif dead_end and not placed then
						-- Dead end removed, remove it from the network
						-- Get the network
						local network_ids = ele.graphcache.devices[minetest.hash_node_position(positions[1])] or
							{minetest.pos_to_string(positions[1])}

						if not #network_ids then
							-- We're evidently not on a network, nothing to remove ourselves from
							break
						end

						for _,int_net in ipairs(network_ids) do
							if ele.graphcache[int_net] then
								local network = ele.graphcache[int_net]

								-- The network was deleted.
								if int_net == minetest.pos_to_string(pos) then
									for _,v in ipairs(network.conductors) do
										local pos1 = minetest.hash_node_position(v)
										ele.graphcache.devices[pos1] = nil
									end
									ele.graphcache[int_net] = nil
								else
									-- Search for and remove device
									ele.graphcache.devices[hash_pos] = nil
									for tblname, table in pairs(network) do
										if type(table) == "table" then
											for devicenum, device in pairs(table) do
												if vector.equals(device, pos) then
													table[devicenum] = nil
												end
											end
										end
									end
								end
							end
						end
						break
					else
						-- Not a dead end, so the whole network needs to be recalculated
						for _,v in ipairs(ele.graphcache[net].conductors) do
							local pos1 = minetest.hash_node_position(v)
							ele.graphcache.devices[pos1] = nil
						end
						ele.graphcache[net] = nil
						break
					end
					break
				end
			end
		end
	end
end
