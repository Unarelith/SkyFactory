-- Fluid buffer support functions.

local function node_data(pos)
	local node    = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	return node, nodedef
end

function fluid_lib.get_node_buffers(pos)
	local node, nodedef = node_data(pos)
	if not nodedef['fluid_buffers'] then
		return nil
	end

	return nodedef['fluid_buffers']
end

function fluid_lib.get_buffer_data(pos, buffer)
	local node, nodedef = node_data(pos)
	local buffers = fluid_lib.get_node_buffers(pos)

	if not buffers[buffer] then
		return nil
	end

	local meta      = minetest.get_meta(pos)
	local fluid     = meta:get_string(buffer .. "_fluid")
	local amount    = meta:get_int(buffer .. "_fluid_storage")
	local capacity  = buffers[buffer].capacity
	local accepts   = buffers[buffer].accepts
	local drainable = buffers[buffer].drainable

	if drainable == nil then
		drainable = true
	end

	return {
		fluid     = fluid,
		amount    = amount,
		accepts   = accepts,
		capacity  = capacity,
		drainable = drainable,
	}
end

function fluid_lib.buffer_accepts_fluid(pos, buffer, fluid)
	local bfdata = fluid_lib.get_buffer_data(pos, buffer)
	if not bfdata then return false end

	if bfdata.fluid ~= "" and bfdata.fluid ~= fluid then
		return false
	end

	if bfdata.accepts == true or bfdata.accepts == fluid then
		return true
	end

	if type(bfdata.accepts) ~= "table" then
		bfdata.accepts = { bfdata.accepts }
	end

	for _,pf in pairs(bfdata.accepts) do
		if pf == fluid then
			return true
		elseif pf:match("^group") and ele.helpers.get_item_group(fluid, pf:gsub("group:", "")) then
			return true
		end
	end

	return false
end

function fluid_lib.can_insert_into_buffer(pos, buffer, fluid, count)
	local bfdata = fluid_lib.get_buffer_data(pos, buffer)
	if not bfdata then return 0 end
	if not fluid_lib.buffer_accepts_fluid(pos, buffer, fluid) then return 0 end

	local can_put = 0
	if bfdata.amount + count > bfdata.capacity then
		can_put = bfdata.capacity - bfdata.amount
	else
		can_put = count
	end

	return can_put
end

function fluid_lib.insert_into_buffer(pos, buffer, fluid, count)
	local bfdata = fluid_lib.get_buffer_data(pos, buffer)
	if not bfdata then return count end
	if bfdata.fluid ~= fluid and bfdata.fluid ~= "" then return count end

	local can_put = fluid_lib.can_insert_into_buffer(pos, buffer, fluid, count)

	if can_put == 0 then return count end

	local meta = minetest.get_meta(pos)
	meta:set_int(buffer .. "_fluid_storage", bfdata.amount + can_put)
	meta:set_string(buffer .. "_fluid", fluid)

	return 0
end

function fluid_lib.can_take_from_buffer(pos, buffer, count)
	local bfdata = fluid_lib.get_buffer_data(pos, buffer)
	if not bfdata or not bfdata.drainable then return 0 end

	local amount = bfdata.amount
	local take_count = 0

	if amount < count then
		take_count = amount
	else
		take_count = count
	end

	return take_count
end

function fluid_lib.take_from_buffer(pos, buffer, count)
	local bfdata = fluid_lib.get_buffer_data(pos, buffer)
	if not bfdata then return nil end

	local fluid  = bfdata.fluid
	local amount = bfdata.amount

	local take_count = fluid_lib.can_take_from_buffer(pos, buffer, count)

	local new_storage = amount - take_count
	if new_storage == 0 then
		fluid = ""
	end

	local meta = minetest.get_meta(pos)
	meta:set_int(buffer .. "_fluid_storage", new_storage)
	meta:set_string(buffer .. "_fluid", fluid)

	return bfdata.fluid, take_count
end

function fluid_lib.buffer_to_string(buffer)
	if not buffer then return "" end
	local amount      = fluid_lib.comma_value(buffer.amount)
	local capacity    = fluid_lib.comma_value(buffer.capacity)
	local description = "Empty"

	if buffer.fluid ~= "" then
		description = fluid_lib.cleanse_node_description(buffer.fluid)
	end

	return ("%s (%s / %s %s)"):format(description, amount, capacity, fluid_lib.unit)
end
