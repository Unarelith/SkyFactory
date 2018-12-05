
ele.tools = {}

local creative = minetest.settings:get_bool("creative_mode")

-- Get a tool property
function ele.tools.get_tool_property(itemstack, param)
	local meta  = itemstack:get_meta()
	local value = meta:get_int(param)

	if not value or value == 0 then
		local itemdef = minetest.registered_items[itemstack:get_name()]
		local dparam  = itemdef["ele_" .. param]
		if dparam then
			value = dparam
		end
	end

	return value
end

-- Set tool capabilities based on wear
function ele.tools.groupcaps(itemstack)
	local wear    = itemstack:get_wear()
	local meta    = itemstack:get_meta()
	local itemdef = minetest.registered_items[itemstack:get_name()]

	if wear == 65535 and meta:get_int("disable") ~= 1 and not creative then
		local prvcaps = itemstack:get_tool_capabilities()
		meta:set_string("toolcaps", minetest.serialize(prvcaps))
		meta:set_tool_capabilities({})
		meta:set_int("disable", 1)

		return itemstack
	end

	if wear ~= 65535 and meta:get_int("disable") == 1 then
		local prvcaps = minetest.deserialize(meta:get_string("toolcaps"))
		meta:set_tool_capabilities(prvcaps)
		meta:set_int("disable", 0)
	end

	return itemstack
end

function ele.tools.update_tool_wear(itemstack)
	local capacity = ele.tools.get_tool_property(itemstack, "capacity")
	local storage  = ele.tools.get_tool_property(itemstack, "storage")

	local meta = itemstack:get_meta()
	local itemdef = minetest.registered_items[itemstack:get_name()]

	local percent  = storage / capacity
	local wear     = math.floor((1-percent) * 65535)

	local tooldesc = meta:get_string("tool_description")
	if tooldesc == "" then tooldesc = itemdef.description end

	meta:set_string("description", tooldesc .. "\n" .. ele.capacity_text(capacity, storage))

	itemstack:set_wear(wear)
	itemstack = ele.tools.groupcaps(itemstack)

	return itemstack
end

function ele.register_tool(toolname, tooldef)
	if not tooldef.groups then
		tooldef.groups = {}
	end

	tooldef.groups["ele_tool"] = 1

	-- Start cleaning up the tooldef
	local defaults = {
		ele_capacity = 1600,
		ele_usage    = 64,
	}

	-- Ensure everything that's required is present
	for k,v in pairs(defaults) do
		if not tooldef[k] then
			tooldef[k] = v
		end
	end

	local original_after_use = tooldef.after_use

	-- Apply wear
	tooldef.after_use = function (itemstack, user, node, digparams)
		if original_after_use then
			itemstack = original_after_use(itemstack, user, node, digparams)
		end

		local meta    = itemstack:get_meta()
		local storage = ele.tools.get_tool_property(itemstack, "storage")
		local usage   = ele.tools.get_tool_property(itemstack, "usage")

		if digparams.wear == 0 then
			return itemstack
		end

		storage = storage - usage
		if storage < 0 then
			storage = 0
		end

		meta:set_int("storage", storage)
		itemstack = ele.tools.update_tool_wear(itemstack)

		return itemstack
	end

	-- Special uses tools
	if tooldef.on_use then
		local original_on_use = tooldef.on_use
		tooldef.on_use = function (itemstack, player, pointed_thing)
			if not player or minetest.is_protected(pos, player:get_player_name()) then
				return itemstack
			end

			local storage = ele.tools.get_tool_property(itemstack, "storage")
			local usage   = ele.tools.get_tool_property(itemstack, "usage")
			local pos     = pointed_thing.under

			if not pos or (storage < usage and not creative) then
				return nil
			end

			local original_stack = ItemStack(itemstack)
			itemstack = original_on_use(itemstack, player, pointed_thing)

			if not itemstack then
				return nil
			end

			local node = minetest.get_node(pos)

			return tooldef.after_use(itemstack, player, node, {wear = 1, time = 0, diggable = true})
		end
	end

	minetest.register_tool(toolname, tooldef)
end
