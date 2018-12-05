
-- Node IO System
local nodeiodef = {
	node_io_can_put_liquid = function (pos, node, side)
		return minetest.get_item_group(node.name, 'fluid_container') > 0
	end,
	node_io_can_take_liquid = function (pos, node, side)
		return minetest.get_item_group(node.name, 'fluid_container') > 0
	end,
		-- if false, transfer node should only put and take in 1000 increments
		-- inventory nodes that don't accept milibuckets should:
			-- return zero in node_io_room_for_liquid() if non-1000 increment
			-- return millibuckets parameter in node_io_put_liquid() if non-1000 increment
			-- only return upto a 1000 increment in node_io_take_liquid()
		-- transfer nodes that can put non-1000 increments should always check this or the inventory node might pretend to be full
	node_io_accepts_millibuckets = function(pos, node, side) return true end,
	node_io_put_liquid = function(pos, node, side, putter, liquid, millibuckets)
		local buffers = fluid_lib.get_node_buffers(pos)
		local leftovers = 0
		for buffer,data in pairs(buffers) do
			if millibuckets == 0 then break end
			local didnt_fit = fluid_lib.insert_into_buffer(pos, buffer, liquid, millibuckets)
			millibuckets = millibuckets - (millibuckets - didnt_fit)
			leftovers = leftovers + didnt_fit
		end
		return leftovers
	end,
		-- returns millibuckets if inventory can hold entire amount, else returns amount the inventory can hold
		-- use millibuckets=1 to check if not full, then call put_liquid() with actual amount to transfer
		-- use millibuckets=1000 with room_for_liquid() and put_liquid() to only insert full buckets
	node_io_room_for_liquid = function(pos, node, side, liquid, millibuckets)
		local buffers = fluid_lib.get_node_buffers(pos)
		local insertable = 0
		for buffer,data in pairs(buffers) do
			local insert = fluid_lib.can_insert_into_buffer(pos, buffer, liquid, millibuckets)
			if insert > 0 then
				insertable = insert
				break
			end
		end
		return insertable
	end,
	
		-- returns {name:string, millibuckets:int} with <= want_millibuckets or nil if inventory is empty or doesn't have want_liquid
		-- want_liquid should be the name of a source liquid (in bucket.liquids of bucket mod)
	node_io_take_liquid = function(pos, node, side, taker, want_liquid, want_millibuckets)
		local buffers = fluid_lib.get_node_buffers(pos)
		local took = 0
		local name = ""
		for buffer,data in pairs(buffers) do
			local bfdata = fluid_lib.get_buffer_data(pos, buffer)
			local storage = bfdata.amount
			local fluid = bfdata.fluid
			if (fluid == want_liquid or want_liquid == "") and storage >= want_millibuckets then
				name, took = fluid_lib.take_from_buffer(pos, buffer, want_millibuckets)
				if took > 0 then break end
			end
		end
		return {name = name, millibuckets = took}
	end,
	
	node_io_get_liquid_size = function (pos, node, side)
		-- this is always 1 unless inventory can hold multiple liquid types
		local cnt = 0
		local bfs = fluid_lib.get_node_buffers(pos)
		for _ in pairs(bfs) do
			cnt = cnt + 1
		end
		return cnt
	end,

	node_io_get_liquid_name = function(pos, node, side, index)
		local cnt = {}
		local bfs = fluid_lib.get_node_buffers(pos)
		for buf in pairs(bfs) do
			cnt[#cnt + 1] = buf
		end
		if not cnt[index] then return ItemStack(nil) end
		local meta = minetest.get_meta(pos)

		return meta:get_string(cnt[index] .. "_fluid")
	end,

	node_io_get_liquid_stack = function(pos, node, side, index)
		local cnt = {}
		local bfs = fluid_lib.get_node_buffers(pos)
		for buf in pairs(bfs) do
			cnt[#cnt + 1] = buf
		end
		if not cnt[index] then return ItemStack(nil) end
		local meta = minetest.get_meta(pos)

		return ItemStack(meta:get_string(cnt[index] .. "_fluid") .. " " ..
			meta:get_int(cnt[index] .. "_fluid_storage"))
	end,
}

function fluid_lib.register_node(nodename)
	minetest.override_item(nodename, nodeiodef)
end
