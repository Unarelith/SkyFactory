-- Nodes for transferring fluids
-- All units are in millibuckets (1 bucket)

-- This is the node that takes fluid from another node.
function elefluid.register_transfer_node(nodename, nodedef)
	if not nodedef.groups then
		nodedef.groups = {}
	end

	nodedef.groups["elefluid_transport_source"] = 1
	nodedef.paramtype2 = "facedir"
	nodedef.legacy_facedir_simple = true
	nodedef.on_timer = elefluid.transfer_timer_tick

	local orig_construct = nodedef.on_construct
	nodedef.on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("fluid_store", 0)
		meta:set_string("fluid", "")

		elefluid.refresh_node(pos)

		if orig_construct then
			orig_construct(pos)
		end
	end

	nodedef.on_punch = function (pos, node, puncher, pointed_thing)
		minetest.get_node_timer(pos):start(1.0)
		minetest.node_punch(pos, node, puncher, pointed_thing)
	end

	-- Default transfer capacity
	if not nodedef.ele_fluid_pump_capacity then
		nodedef.ele_fluid_pump_capacity = 1000
	end

	minetest.register_node(nodename, nodedef)
end

-- This is the node that allows for fluid transfer.
function elefluid.register_transfer_duct(nodename, nodedef)
	if not nodedef.groups then
		nodedef.groups = {}
	end

	nodedef.groups["elefluid_transport"] = 1

	-- Duct node density
	local cd = 1/7

	if nodedef.ele_duct_density then
		cd = nodedef.ele_duct_density
	end

	-- Default values, including the nodebox
	local defaults = {
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {
				{-cd, -cd, -cd, cd, cd, cd}
			},
			connect_front = {
				{-cd, -cd, -1/2, cd, cd, -cd}
			},
			connect_back = {
				{-cd, -cd, cd, cd, cd, 1/2}
			},
			connect_top = {
				{-cd, cd, -cd, cd, 1/2, cd}
			},
			connect_bottom = {
				{-cd, -1/2, -cd, cd, -cd, cd}
			},
			connect_left = {
				{-1/2, -cd, -cd, cd, cd, cd}
			},
			connect_right = {
				{cd, -cd, -cd, 1/2, cd, cd}
			},
		},
		paramtype = "light",
		connect_sides = { "top", "bottom", "front", "left", "back", "right" },
		is_ground_content = false,
		connects_to = {
			"group:elefluid_transport",
			"group:elefluid_transport_source",
			"group:fluid_container"
		},
	}

	for k,v in pairs(defaults) do
		if not nodedef[k] then
			nodedef[k] = v
		end
	end

--	nodedef.on_construct = elefluid.refresh_node
--	nodedef.after_destruct = elefluid.refresh_node

	minetest.register_node(nodename, nodedef)
end
