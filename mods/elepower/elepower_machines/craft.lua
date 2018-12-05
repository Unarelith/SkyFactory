
elepm.craft = {}
elepm.craft.types = {}

function elepm.register_craft_type(name, def)
	elepm.craft.types[name] = {
		inputs      = def.inputs or 2,
		description = def.description or name,
		time        = def.time or 0,
		gui_name    = def.gui_name,
	}

	elepm.craft[name] = {}
end

function elepm.register_craft(craftdef)
	if not craftdef.type or not elepm.craft.types[craftdef.type] then
		return nil
	end

	if craftdef.type == "cooking" or craftdef.type == "fuel" then
		minetest.register_craft(craftdef)
		return
	end

	local inputs  = craftdef.recipe
	local outputs = craftdef.output
	local ctype   = craftdef.type
	local time    = (craftdef.time or craftdef.cooktime or 5) + (elepm.craft.types[ctype].time or 0)

	local craftrecipe = {}
	for _,input in ipairs(inputs) do
		local stack = ItemStack(input)
		if stack and not stack:is_empty() then
			craftrecipe[stack:get_name()] = stack:get_count()
		end
	end

	local craftresult = {}
	if type(outputs) == "table" then
		for _,output in ipairs(outputs) do
			local stack = ItemStack(output)
			if stack and not stack:is_empty() then
				craftresult[#craftresult + 1] = stack:to_string()
			end
		end
	else
		craftresult = ItemStack(outputs)
	end

	local recipe = {
		recipe = craftrecipe,
		output = craftresult,
		time   = time
	}

	table.insert(elepm.craft[ctype], recipe)
end

local no_recipe = {
	time = 0,
	new_input = {},
	output = {}
}

function elepm.get_recipe(type, inputs)
	if not elepm.craft[type] or not inputs then
		return no_recipe
	end

	-- Minetest's cooking builtin type
	if type == "cooking" then
		local result, new_input = minetest.get_craft_result({
			method = "cooking",
			width = 1,
			items = inputs
		})

		if not result or result.time == 0 then
			return no_recipe
		else
			return {
				time = result.time,
				new_input = new_input.items,
				output = result.item
			}
		end
	end

	-- Custom types
	local result = no_recipe
	for _,recipe in ipairs(elepm.craft[type]) do
		local recip_match = true
		local inputs_full = {}
		local new_input   = {}

		for _,input in ipairs(inputs) do
			local in_name = input:get_name()

			if not recipe.recipe[in_name] then
				recip_match = false
			elseif recipe.recipe[in_name] > input:get_count() then
				recip_match = false
			end

			if not recip_match then break end

			table.insert(inputs_full, in_name)

			local istack = ItemStack(in_name)
			istack:set_count(input:get_count() - recipe.recipe[in_name])
			new_input[#new_input + 1] = istack
		end

		if recip_match then
			for _,ingredient in ipairs(recipe.recipe) do
				local its = ItemStack(ingredient)
				if not inputs_full[its:get_name()] then
					recip_match = false
					break
				end
			end
		end

		if recip_match then
			result = recipe
			result.new_input = new_input
			break
		end
	end

	return result
end

-- Cooking craft type built-in.
elepm.register_craft_type("cooking", {
	description = "Cooking",
	inputs = 1,
})
