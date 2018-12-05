-- Fluid Tanks
-- Copyright (c) 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

fluid_tanks = {}

-- Preserve fluid count in the item stack dropped
local function preserve_metadata(pos, oldnode, oldmeta, drops)
	local buffer    = fluid_lib.get_buffer_data(pos, "buffer")
	local meta      = minetest.get_meta(pos)

	if buffer.amount > 0 then
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]

		for i,stack in pairs(drops) do
			local stack_meta = stack:get_meta()
			stack_meta:set_int("fluid_storage", buffer.amount)
			stack_meta:set_string("fluid", buffer.fluid)
			stack_meta:set_string("description", ("%s\nContents: %s"):format(ndef.description,
				fluid_lib.buffer_to_string(buffer)))

			drops[i] = stack
		end
	end

	return drops
end

-- Retrieve fluid count from itemstack when placed
local function after_place_node(pos, placer, itemstack, pointed_thing)
	local item_meta = itemstack:get_meta()
	local fluid_cnt = item_meta:get_int("fluid_storage")
	local fluid     = item_meta:get_string("fluid")
	
	if fluid_cnt then
		local meta = minetest.get_meta(pos)
		meta:set_string("buffer_fluid", fluid)
		meta:set_int("buffer_fluid_storage", fluid_cnt)
	end

	minetest.get_node_timer(pos):start(0.2)

	return false
end

local function tank_on_timer(pos, elapsed)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)

	local buffer = fluid_lib.get_buffer_data(pos, "buffer")
	local percentile = buffer.amount / buffer.capacity

	local node_name = node.name
	local ndef = minetest.registered_nodes[node_name]
	if buffer.amount == 0 and ndef['_base_node'] then
		node_name = ndef['_base_node']
	end

	-- Select valid tank for current fluid
	if buffer.amount > 0 and not ndef['_base_node'] and buffer.fluid ~= "" then
		local fluid_name = fluid_lib.cleanse_node_name(buffer.fluid)
		local new_node_name = node.name .. "_" .. fluid_name
		local new_def = minetest.registered_nodes[new_node_name]
		if new_def then
			node_name = new_node_name
			ndef = new_def
		end
	end

	if buffer.amount == 0 and ndef['_base_node'] then
		node_name = ndef['_base_node']
		ndef = minetest.registered_nodes[node_name]
		meta:set_string("buffer_fluid", "")
	end

	if node_name:match("^:") ~= nil then
		node_name = node_name:sub(2)
		ndef = minetest.registered_nodes[node_name]
	end

	-- Update infotext
	meta:set_string("infotext", ("%s\nContents: %s"):format(ndef.description,
		fluid_lib.buffer_to_string(buffer)))

	local param2 = math.min(percentile * 63, 63)

	-- Node changed, lets switch it
	if node_name ~= node.name or param2 ~= node.param2 then
		minetest.swap_node(pos, {name = node_name, param2 = param2, param1 = node.param1})
	end

	return false
end

local function create_tank_node(tankname, def, fluid_name)
	local capacity = def.capacity or 16000
	local tiles    = def.tiles or {"default_glass.png", "default_glass_detail.png"}
	local desc     = def.description
	local srcnode  = def.srcnode or nil
	local accepts  = def.accepts or true

	local groups = {cracky = 1, oddly_breakable_by_hand = 3, fluid_container = 1}

	if srcnode then
		groups["not_in_creative_inventory"] = 1
	end

	if minetest.registered_nodes[tankname] then
		return
	end

	local special_tiles = {}
	if fluid_name then
		local fdef = minetest.registered_nodes[fluid_name]
		if fdef and fdef.tiles then
			special_tiles = fdef.tiles
		end
	end

	minetest.register_node(tankname, {
		description = desc,
		drawtype = "glasslike_framed_optional",
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		is_ground_content = false,
		sunlight_propagates = true,
		special_tiles = special_tiles,
		fluid_buffers = {
			buffer = {
				capacity  = capacity,
				accepts   = accepts,
				drainable = true,
			}
		},
		on_construct = function ( pos )
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Empty "..desc)
		end,
		on_timer = tank_on_timer,
		groups = groups,
		tiles = tiles,
		_base_node = srcnode,
		node_timer_seconds = 0.2,
		preserve_metadata = preserve_metadata,
		after_place_node = after_place_node,
	})

	if tankname:match("^:") then
		tankname = tankname:sub(2)
	end

	fluid_lib.register_node(tankname)
end

function fluid_tanks.register_tank(tankname, def)
	local accepts  = def.accepts or true

	if not accepts then return end

	if not minetest.registered_nodes[tankname] then
		create_tank_node(tankname, def)
	end

	if type(accepts) == "string" then
		accepts = {accepts}
	end

	if type(accepts) == "table" then
		local new_accepts = {}
		for _,s in ipairs(accepts) do
			if s:match("^group:") then
				local grp = s:gsub("^(group:)", "")
				for f in pairs(bucket.liquids) do
					if minetest.get_item_group(f, grp) > 0 then
						new_accepts[#new_accepts + 1] = f
					end
				end
			else
				if bucket.liquids[s] then
					new_accepts[#new_accepts + 1] = s
				end
			end
		end
		accepts = new_accepts
	end

	if accepts == true then
		accepts = {}
		for _,i in pairs(bucket.liquids) do
			accepts[#accepts + 1] = i.source
		end
	end

	def.srcnode = tankname

	for _, src in ipairs(accepts) do
		local fluid = fluid_lib.cleanse_node_name(src)
		create_tank_node(tankname .. "_" .. fluid, def, src)
	end
end

fluid_tanks.register_tank("fluid_tanks:tank", {
	description = "Fluid Tank",
	capacity = 16000,
	accepts = true,
})
