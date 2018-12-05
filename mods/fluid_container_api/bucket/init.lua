-- Minetest 0.4 mod: bucket
-- See README.md for licensing and other information.

local napi = minetest.get_modpath("node_io")

minetest.register_alias("bucket",       "bucket:bucket_empty")
minetest.register_alias("bucket_water", "bucket:bucket_water")
minetest.register_alias("bucket_lava",  "bucket:bucket_lava")

minetest.register_craft({
	output = 'bucket:bucket_empty 1',
	recipe = {
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'', 'default:steel_ingot', ''},
	}
})

bucket = {}
bucket.liquids = {}

local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos)
			.. " with a bucket")
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

-- Register a new liquid
--    source          = name of the source node
--    flowing         = name of the flowing node
--    itemname        = name of the new bucket item (or nil if liquid is not takeable)
--    inventory_image = texture of the new bucket item (ignored if itemname == nil)
--    name            = text description of the bucket item
--    groups          = (optional) groups of the bucket item, for example {water_bucket = 1}
--    force_renew     = (optional) bool. Force the liquid source to renew if it has a
--                    source neighbour, even if defined as 'liquid_renewable = false'.
--                    Needed to avoid creating holes in sloping rivers.
-- This function can be called from any mod (that depends on bucket).
function bucket.register_liquid(source, flowing, itemname, inventory_image, name,
		groups, force_renew)
	bucket.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = itemname,
		force_renew = force_renew,
	}
	bucket.liquids[flowing] = bucket.liquids[source]

	if itemname ~= nil then
		-- Create an image using a color
		if inventory_image:match("^#") then
			inventory_image = "bucket.png^(bucket_mask.png^[multiply:".. inventory_image ..")"
		end

		minetest.register_craftitem(itemname, {
			description = name,
			inventory_image = inventory_image,
			stack_max = 1,
			liquids_pointable = true,
			groups = groups,

			on_place = function(itemstack, user, pointed_thing)
				-- Must be pointing to node
				if pointed_thing.type ~= "node" then
					return
				end

				local node = minetest.get_node_or_nil(pointed_thing.under)
				local ndef = node and minetest.registered_nodes[node.name]

				-- Call on_rightclick if the pointed node defines it
				if ndef and ndef.on_rightclick and
						not (user and user:is_player() and
						user:get_player_control().sneak) then
					return ndef.on_rightclick(
						pointed_thing.under,
						node, user,
						itemstack)
				end

				local lpos

				-- Check if pointing to a buildable node
				if ndef and ndef.buildable_to then
					-- buildable; replace the node
					lpos = pointed_thing.under
				else
					-- not buildable to; place the liquid above
					-- check if the node above can be replaced

					lpos = pointed_thing.above
					node = minetest.get_node_or_nil(lpos)
					local above_ndef = node and minetest.registered_nodes[node.name]

					if not above_ndef or not above_ndef.buildable_to then
						-- do not remove the bucket with the liquid
						return itemstack
					end
				end

				if check_protection(lpos, user
						and user:get_player_name()
						or "", "place "..source) then
					return
				end

				-- Fill any fluid buffers if present
				local place = true
				local ppos  = pointed_thing.under
				local node  = minetest.get_node(ppos)

				-- Node IO Support
				local usedef = ndef
				local defpref = "node_io_"
				local lookat = "N"

				if napi then
					usedef = node_io
					lookat = node_io.get_pointed_side(user, pointed_thing)
					defpref = ""
				end

				if usedef[defpref..'can_put_liquid'] and usedef[defpref..'can_put_liquid'](ppos, node, lookat) then
					if usedef[defpref..'room_for_liquid'](ppos, node, lookat, source, 1000) >= 1000 then
						usedef[defpref..'put_liquid'](ppos, node, lookat, user, source, 1000)
						if ndef.on_timer then
							minetest.get_node_timer(ppos):start(ndef.node_timer_seconds or 1.0)
						end
						place = false
					end
				end

				if place then
					minetest.set_node(lpos, {name = source})
				end

				return ItemStack("bucket:bucket_empty")
			end
		})
	end
end

function bucket.get_liquid_for_bucket(itemname)
	local found = nil

	for source, b in pairs(bucket.liquids) do
		if b.itemname and b.itemname == itemname then
			found = source
			break
		end
	end

	return found
end

minetest.register_craftitem("bucket:bucket_empty", {
	description = "Empty Bucket",
	inventory_image = "bucket.png",
	stack_max = 99,
	liquids_pointable = true,
	groups = {bucket_empty = 1},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "object" then
			pointed_thing.ref:punch(user, 1.0, { full_punch_interval=1.0 }, nil)
			return user:get_wielded_item()
		elseif pointed_thing.type ~= "node" then
			-- do nothing if it's neither object nor node
			return
		end
		-- Check if pointing to a liquid source
		local node = minetest.get_node(pointed_thing.under)
		local liquiddef = bucket.liquids[node.name]
		local item_count = user:get_wielded_item():get_count()

		if liquiddef ~= nil
		and liquiddef.itemname ~= nil
		and node.name == liquiddef.source then
			if check_protection(pointed_thing.under,
					user:get_player_name(),
					"take ".. node.name) then
				return
			end

			-- default set to return filled bucket
			local giving_back = liquiddef.itemname

			-- check if holding more than 1 empty bucket
			if item_count > 1 then

				-- if space in inventory add filled bucked, otherwise drop as item
				local inv = user:get_inventory()
				if inv:room_for_item("main", {name=liquiddef.itemname}) then
					inv:add_item("main", liquiddef.itemname)
				else
					local pos = user:getpos()
					pos.y = math.floor(pos.y + 0.5)
					minetest.add_item(pos, liquiddef.itemname)
				end

				-- set to return empty buckets minus 1
				giving_back = "bucket:bucket_empty "..tostring(item_count-1)

			end

			-- force_renew requires a source neighbour
			local source_neighbor = false
			if liquiddef.force_renew then
				source_neighbor =
					minetest.find_node_near(pointed_thing.under, 1, liquiddef.source)
			end
			if not (source_neighbor and liquiddef.force_renew) then
				minetest.add_node(pointed_thing.under, {name = "air"})
			end

			return ItemStack(giving_back)
		else
			-- non-liquid nodes will have their on_punch triggered
			local node_def = minetest.registered_nodes[node.name]
			if node_def then
				node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
			end
			return user:get_wielded_item()
		end
	end,
	on_place = function(itemstack, user, pointed_thing)
		-- Must be pointing to node
		if pointed_thing.type ~= "node" then
			return
		end

		local lpos = pointed_thing.under
		local node = minetest.get_node_or_nil(lpos)
		local ndef = node and minetest.registered_nodes[node.name]

		-- Call on_rightclick if the pointed node defines it
		if ndef and ndef.on_rightclick and
				not (user and user:is_player() and
				user:get_player_control().sneak) then
			return ndef.on_rightclick(
				lpos,
				node, user,
				itemstack)
		end

		if check_protection(lpos, user
				and user:get_player_name()
				or "", "take "..node.name) then
			return
		end

		-- Node IO Support
		local usedef = ndef
		local defpref = "node_io_"
		local lookat = "N"

		if napi then
			usedef = node_io
			lookat = node_io.get_pointed_side(user, pointed_thing)
			defpref = ""
		end

		-- Remove fluid from buffers if present
		if usedef[defpref..'can_take_liquid'] and usedef[defpref..'can_take_liquid'](lpos, node, lookat) then
			local bfc = usedef[defpref..'get_liquid_size'](lpos, node, lookat)
			local buffers = {}
			for i = 1, bfc do
				buffers[i] = usedef[defpref..'get_liquid_name'](lpos, node, lookat, i)
			end

			if #buffers > 0 then
				for id,fluid in pairs(buffers) do
					if fluid ~= "" then
						local took = usedef[defpref..'take_liquid'](lpos, node, lookat, user, fluid, 1000)
						if took.millibuckets == 1000 and took.name == fluid then
							if bucket.liquids[fluid] then
								itemstack = ItemStack(bucket.liquids[fluid].itemname)
								if ndef.on_timer then
									minetest.get_node_timer(lpos):start(ndef.node_timer_seconds or 1.0)
								end
								break
							end
						end
					end
				end
			end
		end

		return itemstack
	end
})

bucket.register_liquid(
	"default:water_source",
	"default:water_flowing",
	"bucket:bucket_water",
	"bucket_water.png",
	"Water Bucket",
	{water_bucket = 1}
)

-- River water source is 'liquid_renewable = false' to avoid horizontal spread
-- of water sources in sloping rivers that can cause water to overflow
-- riverbanks and cause floods.
-- River water source is instead made renewable by the 'force renew' option
-- used here.

bucket.register_liquid(
	"default:river_water_source",
	"default:river_water_flowing",
	"bucket:bucket_river_water",
	"bucket_river_water.png",
	"River Water Bucket",
	{water_bucket = 1},
	true
)

bucket.register_liquid(
	"default:lava_source",
	"default:lava_flowing",
	"bucket:bucket_lava",
	"bucket_lava.png",
	"Lava Bucket"
)

minetest.register_craft({
	type = "fuel",
	recipe = "bucket:bucket_lava",
	burntime = 60,
	replacements = {{"bucket:bucket_lava", "bucket:bucket_empty"}},
})

