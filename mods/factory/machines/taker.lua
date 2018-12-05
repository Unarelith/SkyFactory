factory.taker = {}

function factory.taker.take(pos,dir,invlist)
	local src = vector.add(pos,dir)
	local meta = minetest.env:get_meta(src)
	local inv = meta:get_inventory()
	if not inv:is_empty(invlist) then
		local list = inv:get_list(invlist)
		for i,item in ipairs(list) do
			if item:get_name() ~= "" then
				factory.do_moving_item(pos, item:peek_item(1))
				item:take_item()
				inv:set_stack(invlist, i, item)
				return
			end
		end
	end
end

function factory.register_taker(prefix, suffix, speed, name, ctiles)
	-- Backwards compatiblity for any version below 0.5
	minetest.register_alias("factory:"..prefix.."taker"..suffix, "factory:"..prefix.."taker"..suffix.."_on")

	local nodeon = {
		drawtype = "nodebox",
		tiles = ctiles,
		paramtype = "light",
		description = factory.S(name),
		groups = {cracky=3, mesecon_effector_off = 1},
		paramtype2 = "facedir",
		legacy_facedir_simple = true,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5,-0.5,-0.5,0.5,-0.4375,0.5}, --base1
				{-0.125,-0.5,-0.375,0.125,0.0625,0.375}, --base2
				{-0.125,0.25,-0.5,0.125,0.3125,0.375}, --tube
				{-0.375,-0.5,-0.0625,0.375,0.0625,0.0625}, --base3
				{-0.125,-0.125,0.375,0.125,0.125,0.5}, --tube2
				{-0.125,0.0625,0.3125,0.125,0.25,0.375}, --NodeBox6
				{-0.125,0.0625,-0.5,-0.0625,0.25,0.3125}, --NodeBox7
				{0.0625,0.0625,-0.5,0.125,0.25,0.3125}, --NodeBox8
				{-0.0625,0.0625,-0.5,0.0625,0.125,0.3125}, --NodeBox9
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5,-0.5,-0.5,0.5,0.5,0.5},
			}
		},
		mesecons = {effector = {
			action_on = function(pos, node)
				minetest.swap_node(pos, {name="factory:"..prefix.."taker"..suffix.."_off", param2 = node.param2})
			end
		}}
	}

	local nodeoff = {
		drawtype = "nodebox",
		tiles = ctiles,
		paramtype = "light",
		description = factory.S(name),
		groups = {cracky=3, not_in_creative_inventory=1, mesecon_effector_on = 1},
		paramtype2 = "facedir",
		legacy_facedir_simple = true,
		drop="factory:"..prefix.."taker"..suffix.."_on",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5,-0.5,-0.5,0.5,-0.4375,0.5}, --base1
				{-0.125,-0.5,-0.375,0.125,0.0625,0.375}, --base2
				{-0.125,0.25,-0.5,0.125,0.3125,0.375}, --tube
				{-0.375,-0.5,-0.0625,0.375,0.0625,0.0625}, --base3
				{-0.125,-0.125,0.375,0.125,0.125,0.5}, --tube2
				{-0.125,0.0625,0.3125,0.125,0.25,0.375}, --NodeBox6
				{-0.125,0.0625,-0.5,-0.0625,0.25,0.3125}, --NodeBox7
				{0.0625,0.0625,-0.5,0.125,0.25,0.3125}, --NodeBox8
				{-0.0625,0.0625,-0.5,0.0625,0.125,0.3125}, --NodeBox9
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5,-0.5,-0.5,0.5,0.5,0.5},
			}
		},
		mesecons = {effector = {
			action_off = function(pos, node)
				minetest.swap_node(pos, {name="factory:"..prefix.."taker"..suffix.."_on", param2 = node.param2})
			end
		}}
	}
	minetest.register_node("factory:"..prefix.."taker"..suffix.."_on", nodeon)
	minetest.register_node("factory:"..prefix.."taker"..suffix.."_off", nodeoff)

	minetest.register_abm({
		nodenames = {"factory:"..prefix.."taker"..suffix.."_on"},
		neighbors = nil,
		interval = speed,
		chance = 1,
		action = function(pos, node)
			local facedir = node.param2
			local dir = minetest.facedir_to_dir(facedir)
			local src = vector.add(pos,dir)
			local target = minetest.get_node(src)
			if target.name == "default:chest" or target.name == "default:chest_locked" then
				factory.taker.take(pos,dir,"main")
			end
			if target.name == "factory:swapper" then
				local takefrom = ""
				-- 0 = none
				-- 1 = left
				-- 2 = middle
				-- 3 = right
				if facedir == 1 then
					if target.param2 == 0 then takefrom = "loverflow" end
					if target.param2 == 3 then takefrom = "overflow" end
					if target.param2 == 2 then takefrom = "roverflow" end
				elseif facedir == 2 then
					if target.param2 == 1 then takefrom = "loverflow" end
					if target.param2 == 0 then takefrom = "overflow" end
					if target.param2 == 3 then takefrom = "roverflow" end
				elseif facedir == 3 then
					if target.param2 == 2 then takefrom = "loverflow" end
					if target.param2 == 1 then takefrom = "overflow" end
					if target.param2 == 0 then takefrom = "roverflow" end
				elseif facedir == 0 then
					if target.param2 == 3 then takefrom = "loverflow" end
					if target.param2 == 2 then takefrom = "overflow" end
					if target.param2 == 1 then takefrom = "roverflow" end
				end
				if takefrom ~= "" then
					factory.taker.take(pos,dir,takefrom)
				end
			end
			if factory.has_dst_output(target) then
				factory.taker.take(pos,dir,"dst")
			end
		end,
	})
end

factory.register_taker("", "", 2.5, "Pneumatic Taker", {"factory_steel_noise_red.png"})
factory.register_taker("", "_gold", 1.8, "Pneumatic Taker Mk II", {"factory_steel_noise_gold.png"})
factory.register_taker("", "_diamond", 1.2, "Pneumatic Taker Mk III", {"factory_steel_noise_diamond.png"})
