
local etching = {
	["elepower_dynamics:pcb_blank"] = {
		time   = 5,
		result = "elepower_dynamics:pcb"
	}
}

-- Etching Acid

minetest.register_node("elepower_dynamics:etching_acid_source", {
	description  = "Etching Acid Source",
	drawtype     = "liquid",
	tiles        = {"elepower_etching_acid.png"},
	alpha        = 200,
	paramtype    = "light",
	walkable     = false,
	pointable    = false,
	diggable     = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_source = "elepower_dynamics:etching_acid_source",
	liquid_alternative_flowing = "elepower_dynamics:etching_acid_flowing",
	liquid_viscosity = 4,
	damage_per_second = 4,
	post_effect_color = {a = 103, r = 65, g = 8, b = 0},
	groups = {acid = 1, etching_acid = 1, liquid = 3, tree_fluid = 1},
	sounds = default.node_sound_water_defaults(),
	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		local istack = itemstack:get_name()
		if not clicker or clicker:get_player_name() == "" then
			return itemstack
		end

		if not etching[istack] then
			return itemstack
		end

		local recipe = etching[istack]
		local out    = ItemStack(recipe.result)
		local inv    = clicker:get_inventory()
		local meta   = minetest.get_meta(pos)
		local uses   = meta:get_int("uses")

		if inv:room_for_item("main", out) then
			inv:add_item("main", out)
			itemstack:take_item(1)
			uses = uses + 1
		end

		-- Limited etchings
		if uses == 10 then
			minetest.set_node(pos, {name = "default:water_source"})
		else
			meta:set_int("uses", uses)
		end

		return itemstack
	end
})

minetest.register_node("elepower_dynamics:etching_acid_flowing", {
	description = "Flowing Etching Acid",
	drawtype = "flowingliquid",
	tiles = {"elepower_etching_acid.png"},
	special_tiles = {"elepower_etching_acid.png", "elepower_etching_acid.png"},
	alpha = 200,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "elepower_dynamics:etching_acid_flowing",
	liquid_alternative_source = "elepower_dynamics:etching_acid_source",
	liquid_viscosity = 4,
	damage_per_second = 4,
	post_effect_color = {a = 103, r = 65, g = 8, b = 0},
	groups = {acid = 1, etching_acid = 1, liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})

bucket.register_liquid("elepower_dynamics:etching_acid_source", "elepower_dynamics:etching_acid_flowing",
		"elepower_dynamics:bucket_etching_acid",   "#410800", "Etching Acid Bucket")

-----------
-- Gases --
-----------

minetest.register_node("elepower_dynamics:steam", {
	description = "Steam",
	groups      = {not_in_creative_inventory = 1, gas = 1},
	tiles       = {"elepower_steam.png"},
})

minetest.register_node("elepower_dynamics:oxygen", {
	description = "Oxygen",
	groups      = {not_in_creative_inventory = 1, gas = 1},
	tiles       = {"elepower_steam.png"},
})

minetest.register_node("elepower_dynamics:hydrogen", {
	description = "Hydrogen",
	groups      = {not_in_creative_inventory = 1, gas = 1},
	tiles       = {"elepower_steam.png"},
})

minetest.register_node("elepower_dynamics:nitrogen", {
	description = "Nitrogen",
	groups      = {not_in_creative_inventory = 1, gas = 1},
	tiles       = {"elepower_steam.png"},
})
