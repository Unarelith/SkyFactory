function factory.insert_object_item(inv,listname,stack,obj)
	if inv:room_for_item(listname, stack) then
		inv:add_item(listname, stack)
		if obj~=nil then obj:remove() end
		return true
	else
		return false
	end
end

function factory.count_index(invlist)
	local index = {}
	for _, stack in pairs(invlist) do
		if not stack:is_empty() then
			local stack_name = stack:get_name()
			index[stack_name] = (index[stack_name] or 0) + stack:get_count()
		end
	end
	return index
end
