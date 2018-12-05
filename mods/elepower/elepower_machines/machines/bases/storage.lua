
local function get_formspec_default(power)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		"image[2,0.5;1,1;gui_furnace_arrow_bg.png^[transformR180]"..
		"list[context;out;2,1.5;1,1;]"..
		"image[5,0.5;1,1;gui_furnace_arrow_bg.png]"..
		"list[context;in;5,1.5;1,1;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		"listring[context;out]"..
		"listring[current_player;main]"..
		"listring[context;in]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("in") and inv:is_empty("out")
end

local function item_in_group(stack, grp)
	return ele.helpers.get_item_group(stack:get_name(), grp)
end

function elepm.register_storage(nodename, nodedef)
	local levels = nodedef.ele_levels or 8
	local level_overlay = nodedef.ele_overlay or "elepower_power_level_"
	if not nodedef.groups then
		nodedef.groups = {}
	end

	nodedef.groups["ele_machine"]  = 1
	nodedef.groups["ele_storage"]  = 1
	nodedef.groups["ele_provider"] = 1

	nodedef.can_dig = can_dig

	-- Allow for custom formspec
	local get_formspec = get_formspec_default
	if nodedef.get_formspec then
		get_formspec = nodedef.get_formspec
		nodedef.get_formspec = nil
	end

	nodedef.on_timer = function (pos, elapsed)
		local meta    = minetest.get_meta(pos)
		local refresh = false

		local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
		local storage  = ele.helpers.get_node_property(meta, pos, "storage")

		local percent = storage / capacity
		local level   = math.floor(percent * levels)

		ele.helpers.swap_node(pos, nodename .. "_" .. level)
		meta:set_string("formspec", get_formspec({capacity = capacity, storage = storage, usage = 0}))
		meta:set_string("infotext", ("%s Active"):format(nodedef.description) .. "\n" ..
			ele.capacity_text(capacity, storage))

		local inv = meta:get_inventory()

		-- Powercell to item
		local itemcharge = inv:get_stack("out", 1)
		local output     = ele.helpers.get_node_property(meta, pos, "output")
		if itemcharge and not itemcharge:is_empty() and item_in_group(itemcharge, "ele_tool") then
			local crg   = ele.tools.get_tool_property(itemcharge, "storage")
			local cap   = ele.tools.get_tool_property(itemcharge, "capacity")
			local tmeta = itemcharge:get_meta()

			local append = 0

			if crg + output < cap then
				append = output
			else
				if crg <= cap then
					append = cap - crg
				end
			end

			if storage > append and append ~= 0 then
				crg = crg + append
				storage = storage - append
				refresh = true
			end

			tmeta:set_int("storage", crg)
			itemcharge = ele.tools.update_tool_wear(itemcharge)
			inv:set_stack("out", 1, itemcharge)
		end

		-- Item to powercell
		local itemdischarge = inv:get_stack("in", 1)
		local inrush        = ele.helpers.get_node_property(meta, pos, "inrush")
		if itemdischarge and not itemdischarge:is_empty() and 
				(item_in_group(itemdischarge, "ele_tool") or item_in_group(itemdischarge, "ele_machine")) then
			local crg   = ele.tools.get_tool_property(itemdischarge, "storage")
			local tmeta = itemdischarge:get_meta()

			local discharge = 0

			if crg >= inrush then
				discharge = inrush
			else
				discharge = inrush - crg
			end

			if storage + discharge > capacity then
				discharge = capacity - storage
			end

			if discharge <= crg and discharge ~= 0 then
				crg = crg - discharge
				storage = storage + discharge
				refresh = true
			end

			tmeta:set_int("storage", crg)
			itemdischarge = ele.tools.update_tool_wear(itemdischarge)
			inv:set_stack("in", 1, itemdischarge)
		end

		if refresh then
			meta:set_int("storage", storage)
		end

		return refresh
	end

	nodedef.on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()
		inv:set_size("out", 1)
		inv:set_size("in", 1)

		local capacity = ele.helpers.get_node_property(meta, pos, "capacity")
		meta:set_string("formspec", get_formspec({ capacity = capacity, storage = 0, usage = 0 }))
	end

	for i = 0, levels do
		local cpdef = table.copy(nodedef)

		-- Add overlay to the tile texture
		if cpdef.tiles and cpdef.tiles[6] and i > 0 then
			cpdef.tiles[6] = cpdef.tiles[6] .. "^" .. level_overlay .. i ..".png"
		end

		if i > 0 then
			cpdef.groups["not_in_creative_inventory"] = 1
		end

		ele.register_machine(nodename .. "_" .. i, cpdef)
	end
end
