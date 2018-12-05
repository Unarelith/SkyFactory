local S = factory.S
local autocrafterCache = {}
-- caches some recipe data to avoid to call the slow function minetest.get_craft_result() every second

local count_index = factory.count_index

local function get_item_info(stack)
	local name = stack:get_name()
	local def = minetest.registered_items[name]
	local description = def and def.description or S("unknown item")
	return description, name
end

local function get_craft(pos, inventory, hash)
	local nhash = hash or minetest.hash_node_position(pos)
	local craft = autocrafterCache[nhash]
	if not craft then
		local recipe = inventory:get_list("recipe")
		local output, decremented_input = minetest.get_craft_result({method = "normal", width = 3, items = recipe})
		craft = {recipe = recipe, consumption=count_index(recipe), output = output, decremented_input = decremented_input}
		autocrafterCache[nhash] = craft
	end
	return craft
end

-- note, that this function assumes allready being updated to virtual items
-- and doesn't handle recipes with stacksizes > 1
local function after_recipe_change(pos, inventory)
	local meta = minetest.get_meta(pos)
	-- if we emptied the grid, there's no point in keeping it running or cached
	if inventory:is_empty("recipe") then
		autocrafterCache[minetest.hash_node_position(pos)] = nil
		meta:set_string("infotext", S("unconfigured Autocrafter"))
		inventory:set_stack("output", 1, "")
		return
	end
	local recipe = inventory:get_list("recipe")

	local hash = minetest.hash_node_position(pos)
	local craft = autocrafterCache[hash]

	if craft then
		-- check if it changed
		local cached_recipe = craft.recipe
		for i = 1, 9 do
			if recipe[i]:get_name() ~= cached_recipe[i]:get_name() then
				autocrafterCache[hash] = nil -- invalidate recipe
				craft = nil
				break
			end
		end
	end

	craft = craft or get_craft(pos, inventory, hash)
	local output_item = craft.output.item
	local description, name = get_item_info(output_item)
	meta:set_string("infotext", S("'@1' Autocrafter (@2)",description, name))
	inventory:set_stack("output", 1, output_item)

end

-- clean out unknown items and groups, which would be handled like unknown items in the crafting grid
-- if minetest supports query by group one day, this might replace them
-- with a canonical version instead
local function normalize(item_list)
	for i = 1, #item_list do
		local name = item_list[i]
		if not minetest.registered_items[name] then
			item_list[i] = ""
		end
	end
	return item_list
end

local function on_output_change(pos, inventory, stack)
	if not stack then
		inventory:set_list("output", {})
		inventory:set_list("recipe", {})
	else
		local input = minetest.get_craft_recipe(stack:get_name())
		if not input.items or input.type ~= "normal" then return end
		local items, width = normalize(input.items), input.width
		local item_idx, width_idx = 1, 1
		for i = 1, 9 do
			if width_idx <= width then
				inventory:set_stack("recipe", i, items[item_idx])
				item_idx = item_idx + 1
			else
				inventory:set_stack("recipe", i, ItemStack(""))
			end
			width_idx = (width_idx < 3) and (width_idx + 1) or 1
		end
		-- we'll set the output slot in after_recipe_change to the actual result of the new recipe
	end
	after_recipe_change(pos, inventory)
end

local function update_meta(meta)
	local fs = 	"size[8,12]"..
			"list[context;recipe;0,0;3,3;]"..
			"image[3,1;1,1;gui_hb_bg.png^[colorize:#141318:255]"..
			"list[context;output;3,1;1,1;]"..
			"list[context;src;0,4.5;8,3;]"..
			"list[context;dst;4,0;4,3;]"..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots..
			default.get_hotbar_bg(0,8) ..
			"list[current_player;main;0,8;8,4;]" ..
			"listring[current_player;main]"..
			"listring[context;src]" ..
			"listring[current_player;main]"..
			"listring[context;dst]"
	meta:set_string("formspec",fs)

	local output = meta:get_inventory():get_stack("output", 1)
	if output:is_empty() then -- doesn't matter if paused or not
		meta:set_string("infotext", S("unconfigured Autocrafter"))
		return false
	end

	local description, name = get_item_info(output)
	local infotext = S("'%s' Autocrafter (%s)"):format(description, name)

	meta:set_string("infotext", infotext)
	return true
end

minetest.register_node("factory:autocrafter", {
	description = S("Autocrafter"),
	drawtype = "normal",
	tiles = {"factory_machine_brick_1.png", "factory_machine_brick_2.png",
		"factory_machine_side_1.png", "factory_machine_side_1.png",
		"factory_machine_side_1.png", "factory_machine_brick_1.png^factory_small_diamond_gear.png"},
	groups = {cracky = 3, factory_src_input = 1, factory_dst_output = 1},
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("src", 3*8)
		inv:set_size("recipe", 3*3)
		inv:set_size("dst", 4*3)
		inv:set_size("output", 1)
		update_meta(meta)
	end,
	can_dig = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return (inv:is_empty("src") and inv:is_empty("dst"))
	end,
	on_destruct = function(pos)
		autocrafterCache[minetest.hash_node_position(pos)] = nil
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack)
		local inv = minetest.get_meta(pos):get_inventory()
		if listname == "recipe" then
			stack:set_count(1)
			inv:set_stack(listname, index, stack)
			after_recipe_change(pos, inv)
			return 0
		elseif listname == "output" then
			on_output_change(pos, inv, stack)
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack)
		local inv = minetest.get_meta(pos):get_inventory()
		if listname == "recipe" then
			inv:set_stack(listname, index, ItemStack(""))
			after_recipe_change(pos, inv)
			return 0
		elseif listname == "output" then
			on_output_change(pos, inv, nil)
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
		local inv = minetest.get_meta(pos):get_inventory()
		local stack = inv:get_stack(from_list, from_index)

		if to_list == "output" then
			on_output_change(pos, inv, stack)
			return 0
		elseif from_list == "output" then
			on_output_change(pos, inv, nil)
			if to_list ~= "recipe" then
				return 0
			end -- else fall through to recipe list handling
		end

		if from_list == "recipe" or to_list == "recipe" then
			if from_list == "recipe" then
				inv:set_stack(from_list, from_index, ItemStack(""))
			end
			if to_list == "recipe" then
				stack:set_count(1)
				inv:set_stack(to_list, to_index, stack)
			end
			after_recipe_change(pos, inv)
			return 0
		end

		return count
	end,
})

minetest.register_abm({
	nodenames = {"factory:autocrafter"},
	interval = 2.5,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		local craft = get_craft(pos, inventory)
		local output_item = craft.output.item
		-- only use crafts that have an actual result
		if output_item:is_empty() or not craft then
			meta:set_string("infotext", S("unconfigured Autocrafter: unknown recipe"))
			return
		end

		-- check if we have enough room in dst
		if not inventory:room_for_item("dst", output_item) then	return end
		local consumption = craft.consumption
		local inv_index = count_index(inventory:get_list("src"))
		-- check if we have enough material available
		for itemname, number in pairs(consumption) do
			if (not inv_index[itemname]) or inv_index[itemname] < number then return end
		end
		-- consume material
		for itemname, number in pairs(consumption) do
			for _= 1, number do -- We have to do that since remove_item does not work if count > stack_max
				inventory:remove_item("src", ItemStack(itemname))
			end
		end

		-- craft the result into the dst inventory and add any "replacements" as well
		inventory:add_item("dst", output_item)
		for i = 1, 9 do
			inventory:add_item("dst", craft.decremented_input.items[i])
		end
	end,
})