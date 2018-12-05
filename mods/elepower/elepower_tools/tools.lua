
ele.register_tool("elepower_tools:hand_drill", {
	description = "Hand Drill",
	inventory_image = "eletools_hand_drill.png",
	wield_image = "eletools_hand_drill.png^[transformFX",
	tool_capabilities = {
		full_punch_interval = 0.2,
		max_drop_level = 1,
		groupcaps={
			cracky = {times={[1]=5, [2]=2, [3]=1}, maxlevel=4},
		},
		damage_groups = {fleshy=4},
	},
	ele_capacity = 8000,
})

ele.register_tool("elepower_tools:chainsaw", {
	description = "Chainsaw",
	inventory_image = "eletools_chainsaw.png",
	wield_image = "eletools_chainsaw.png^[transformFX",
	ele_capacity = 8000,
	ele_usage    = 250,
	on_use = function (itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)

		if not ele.helpers.get_item_group(node.name, "tree") then
			return nil
		end

		local drops = elefarm.tc.capitate_tree(vector.subtract(pos, {x=0,y=1,z=0}), user)
		if not drops or #drops == 0 then
			return nil
		end

		local inv = user:get_inventory()
		for _,drop in pairs(drops) do
			local st = ItemStack(drop)
			if inv:room_for_item("main", st) then
				inv:add_item("main", st)
			else
				minetest.item_drop(st, user, pos)
			end
		end

		return itemstack
	end
})
