
function ele.register_conduit(nodename, nodedef)
	if not nodedef.groups then
		nodedef.groups = {}
	end

	-- Ensure this node is in the conductor group
	if not nodedef.groups["ele_conductor"] then
		nodedef.groups["ele_conductor"] = 1
	end

	-- Cable node density
	local cd = 1/8

	if nodedef.ele_conductor_density then
		cd = nodedef.ele_conductor_density
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
			"group:ele_machine",
			"group:ele_conductor",
		},
	}

	for k,v in pairs(defaults) do
		if not nodedef[k] then
			nodedef[k] = v
		end
	end

	ele.register_base_device(nodename, nodedef)
end
