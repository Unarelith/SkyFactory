
-----------------------
-- Utility Functions --
-----------------------

ele.helpers = {}

function ele.helpers.round(v)
	return math.floor(v + 0.5)
end

function ele.helpers.swap_node(pos, noded)
	local node = minetest.get_node(pos)
	
	if type(noded) ~= "table" then
		local n = table.copy(node)
		n.name = noded
		noded = n
	end

	if node.name == noded.name then
		return false
	end

	minetest.swap_node(pos, noded)

	return true
end

function ele.helpers.get_or_load_node(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then return node end
	local vm = VoxelManip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	return nil
end

function ele.helpers.get_item_group(name, grp)
	return minetest.get_item_group(name, grp) > 0
end

function ele.helpers.flatten(map)
	local list = {}
	for key, value in pairs(map) do
		list[#list + 1] = value
	end
	return list
end

function ele.helpers.get_node_property(meta, pos, prop)
	local value = meta:get_int(prop)

	if value == 0 or value == nil then
		local nname = minetest.get_node(pos).name
		local ndef  = minetest.registered_nodes[nname]
		value = ndef["ele_"..prop]
	end

	if not value then return 0 end

	return value
end

-- Look for item name regardless of mod
function ele.helpers.scan_item_list(item_name)
	local found = nil

	for name in pairs(minetest.registered_items) do
		local nomod = name:gsub("([%w_]+):", "")
		if nomod == item_name then
			found = name
			break
		end
	end

	return found
end

function ele.helpers.face_front(pos, fd)
	local back = minetest.facedir_to_dir(fd)
	local front = table.copy(back)

	front.x = front.x * -1 + pos.x
	front.y = front.y * -1 + pos.y
	front.z = front.z * -1 + pos.z

	return front
end

function ele.helpers.comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function ele.helpers.state_enabled(meta, pos, state)
	if not state then
		state = meta:get_int("state")
	end

	if state == 0 then
		return true
	elseif state == 1 then
		return false
	end

	if state == 2 and meta:get_int("signal_interrupt") == 1 then
		return true
	elseif state == 3 and meta:get_int("signal_interrupt") == 0 then
		return true
	end

	return false
end
