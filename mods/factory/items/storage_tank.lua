local S = factory.S

factory.registered_storage_tanks = {}

minetest.register_node("factory:storage_tank", {
	description = S("Storage Tank"),
	drawtype = "glasslike_framed", --FIXME: connects to others
	tiles = {"factory_steel_noise.png","factory_glass.png^factory_measure.png",
		"factory_glass.png^factory_port.png", "factory_steel_noise.png"},
	inventory_image = "factory_storage_tank.png",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {oddly_breakable_by_hand = 2},
	on_rightclick = function(pos, _, clicker, itemstack)
		local stack = ItemStack(itemstack)
		for n,d in pairs(factory.registered_storage_tanks) do
			if stack:get_name() == d.bucket_full then
				minetest.swap_node(pos, {name = "factory:storage_tank_"..n, param2 = d.increment + 64 + 128})
				local meta = minetest.get_meta(pos)
				meta:set_int("stored", d.increment)
				local inv = clicker:get_inventory()
				if inv:room_for_item("main", {name=d.bucket_empty}) then
					inv:add_item("main", d.bucket_empty)
				else
					local ppos = clicker:getpos()
					ppos.y = math.floor(ppos.y + 0.5)
					minetest.add_item(ppos, d.bucket_empty)
				end
				stack:take_item(1)
				return stack
			end
		end
	end,
})

function factory.register_storage_tank(name, increment, tiles, plaintile, light, bucket_full, bucket_empty)
	factory.registered_storage_tanks[name] = {
		increment = increment,
		bucket_full = bucket_full,
		bucket_empty = bucket_empty
	}
	--TODO: support bucket tables for multiple vessels or bucket registration
	minetest.register_node("factory:storage_tank_" .. name, {
		drawtype = "glasslike_framed",
		tiles = {"factory_steel_noise.png","factory_glass.png^factory_measure.png",
			"factory_glass.png^factory_port.png", "factory_steel_noise.png"},
		special_tiles = tiles,
		paramtype2 = "glasslikeliquidlevel",
		paramtype = "light",
		sunlight_propagates = true,
		light_source = light,
		groups = {oddly_breakable_by_hand = 2, not_in_creative_inventory = 1},
		drop = nil,
		on_dig = function(pos, _, digger)
			local inv = digger:get_inventory()
			local meta = minetest.get_meta(pos)
			local stored = meta:get_int("stored")
			local stack = ItemStack({name="factory:storage_tank_" .. name .. "_inventory", count=1, metadata=stored})
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			else
				minetest.add_item(pos, stack)
			end
			minetest.set_node(pos, {name = "air"})
		end,
		on_rightclick = function(pos, _, clicker, itemstack)
			local stack = ItemStack(itemstack)
			if stack:get_name() == bucket_full then
				local meta = minetest.get_meta(pos)
				local stored = meta:get_int("stored")
				if stored < 63 then
					stored = stored + increment
					meta:set_int("stored", stored)
					meta:set_string("infotext", "Storage Tank (" .. name .. "): "..math.floor((100/63)*stored).."% full")
					minetest.swap_node(pos, {name = "factory:storage_tank_" .. name, param2 = stored + 64 + 128})
					return ItemStack(bucket_empty)
				end
			end
			if stack:get_name() == bucket_empty then
				local meta = minetest.get_meta(pos)
				local stored = meta:get_int("stored")
				if stored > increment then
					stored = stored - increment
					meta:set_int("stored", stored)
					meta:set_string("infotext", "Storage Tank (" .. name .. "): "..math.floor((100/63)*stored).."% full")
					minetest.swap_node(pos, {name = "factory:storage_tank_" .. name, param2 = stored + 64 + 128})
				elseif stored <= increment then
					meta:set_string("infotext", nil)
					minetest.swap_node(pos, {name = "factory:storage_tank"})
				end
				local inv = clicker:get_inventory()
				if inv:room_for_item("main", {name=bucket_full}) then
					inv:add_item("main", bucket_full)
				else
					local ppos = clicker:getpos()
					ppos.y = math.floor(ppos.y + 0.5)
					minetest.add_item(ppos, bucket_full)
				end
				stack:take_item(1)
				return stack
			end
		end,
	})

	minetest.register_craftitem("factory:storage_tank_" .. name .. "_inventory", {
		description = S("Storage Tank (@1)",S(name)),
		--TODO: make inventorycube from lowerpart of the plaintile and storage tank tiles
		inventory_image = plaintile .. "^factory_storage_tank.png",
		wield_image = "factory_storage_tank.png",
		groups = {not_in_creative_inventory = 1},
		stack_max = 1,
		on_place = function(itemstack, placer, pointed_thing)
			local pt = pointed_thing
			if not pt then
				return
			end
			if pt.type ~= "node" then
				return
			end
			local under = minetest.get_node(pt.under)
			local above = minetest.get_node(pt.above)
			local pos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
			local node = minetest.get_node(pos)
			if not minetest.registered_nodes[under.name] then
				return
			end
			if not minetest.registered_nodes[above.name] then
				return
			end
			if not minetest.registered_nodes[node.name].buildable_to then
				return
			end

			local stored = tonumber(itemstack:get_metadata())

			minetest.place_node(pos, {
				name="factory:storage_tank_" .. name,
				param2 = stored + 64 + 128
			})
			local meta = minetest.get_meta(pos)
			meta:set_int("stored", stored)
			meta:set_string("infotext", S("Storage Tank (@1): @2% full",S(name),math.floor((100/63)*stored)))
			minetest.swap_node(pos, {name = "factory:storage_tank_" .. name, param2 = stored + 64 + 128})
			return ""
		end
	})
end

factory.register_storage_tank("water", 4,
	{{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}}},
	"default_water.png", 0, "bucket:bucket_water", "bucket:bucket_empty")
factory.register_storage_tank("lava", 8,
	{{name="default_lava_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}},
	"default_lava.png", 13, "bucket:bucket_lava", "bucket:bucket_empty")