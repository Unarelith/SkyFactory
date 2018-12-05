
-------------------
-- Virtual Nodes --
-------------------

-- These nodes are used as "fluids"
-- They do not actually exist as nodes that should be placed.

minetest.register_node("elepower_nuclear:tritium", {
	description = "Tritium Gas",
	groups      = {not_in_creative_inventory = 1, oddly_breakable_by_hand = 1, gas = 1},
	tiles       = {"elenuclear_gas.png"},
})

minetest.register_node("elepower_nuclear:deuterium", {
	description = "Deuterium Gas",
	groups      = {not_in_creative_inventory = 1, oddly_breakable_by_hand = 1, gas = 1},
	tiles       = {"elenuclear_gas.png"},
})

minetest.register_node("elepower_nuclear:helium", {
	description = "Helium Gas",
	groups      = {not_in_creative_inventory = 1, oddly_breakable_by_hand = 1, gas = 1},
	tiles       = {"elenuclear_helium.png"},
})

minetest.register_node("elepower_nuclear:helium_plasma", {
	description = "Helium Plasma\nSuperheated",
	groups      = {not_in_creative_inventory = 1, oddly_breakable_by_hand = 1, gas = 1},
	tiles       = {"elenuclear_helium_plasma.png"},
})

ele.register_gas(nil, "Tritium", "elepower_nuclear:tritium")
ele.register_gas(nil, "Deuterium", "elepower_nuclear:deuterium")
ele.register_gas(nil, "Helium", "elepower_nuclear:helium")
ele.register_gas(nil, "Helium Plasma", "elepower_nuclear:helium_plasma")

-------------
-- Liquids --
-------------

-- Heavy Water
minetest.register_node("elepower_nuclear:heavy_water_source", {
	description = "Heavy Water Source",
	drawtype = "liquid",
	tiles = {
		{
			name = "elenuclear_heavy_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	special_tiles = {
		{
			name = "elenuclear_heavy_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
			backface_culling = false,
		},
	},
	alpha = 160,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "elepower_nuclear:heavy_water_flowing",
	liquid_alternative_source = "elepower_nuclear:heavy_water_source",
	liquid_viscosity = 4,
	post_effect_color = {a = 103, r = 13, g = 69, b = 121},
	groups = {heavy_water = 3, liquid = 3, puts_out_fire = 1, cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("elepower_nuclear:heavy_water_flowing", {
	description = "Flowing Heavy Water",
	drawtype = "flowingliquid",
	tiles = {"elenuclear_heavy_water.png"},
	special_tiles = {
		{
			name = "elenuclear_heavy_water_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
		{
			name = "elenuclear_heavy_water_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
	},
	alpha = 160,
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
	liquid_alternative_flowing = "elepower_nuclear:heavy_water_flowing",
	liquid_alternative_source = "elepower_nuclear:heavy_water_source",
	liquid_viscosity = 4,
	post_effect_color = {a = 103, r = 13, g = 69, b = 121},
	groups = {heavy_water = 3, liquid = 3, puts_out_fire = 1,
		not_in_creative_inventory = 1, cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})


-- Cold coolant

minetest.register_node("elepower_nuclear:coolant_source", {
	description  = "Cold Coolant Source",
	drawtype     = "liquid",
	tiles        = {"elenuclear_cold_coolant.png"},
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
	liquid_alternative_source = "elepower_nuclear:coolant_source",
	liquid_alternative_flowing = "elepower_nuclear:coolant_flowing",
	liquid_viscosity = 2,
	post_effect_color = {a = 128, r = 36, g = 150, b = 255},
	groups = {liquid = 3, coolant = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("elepower_nuclear:coolant_flowing", {
	description = "Cold Coolant Flowing",
	drawtype = "flowingliquid",
	tiles = {"elenuclear_cold_coolant.png"},
	special_tiles = {"elenuclear_cold_coolant.png", "elenuclear_cold_coolant.png"},
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
	liquid_alternative_flowing = "elepower_nuclear:coolant_flowing",
	liquid_alternative_source = "elepower_nuclear:coolant_source",
	liquid_viscosity = 2,
	post_effect_color = {a = 128, r = 36, g = 150, b = 255},
	groups = {coolant = 3, liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})

-- Hot coolant

minetest.register_node("elepower_nuclear:hot_coolant_source", {
	description  = "Hot Coolant Source",
	drawtype     = "liquid",
	tiles        = {"elenuclear_hot_coolant.png"},
	alpha        = 200,
	paramtype    = "light",
	walkable     = false,
	pointable    = false,
	diggable     = false,
	buildable_to = true,
	is_ground_content = false,
	damage_per_second = 4 * 2,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_source = "elepower_nuclear:hot_coolant_source",
	liquid_alternative_flowing = "elepower_nuclear:hot_coolant_flowing",
	liquid_viscosity = 2,
	post_effect_color = {a = 128, r = 136, g = 100, b = 158},
	groups = {liquid = 3, coolant = 1, hot = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("elepower_nuclear:hot_coolant_flowing", {
	description = "Hot Coolant Flowing",
	drawtype = "flowingliquid",
	tiles = {"elenuclear_hot_coolant.png"},
	special_tiles = {"elenuclear_hot_coolant.png", "elenuclear_hot_coolant.png"},
	alpha = 200,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	damage_per_second = 4 * 2,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "elepower_nuclear:hot_coolant_flowing",
	liquid_alternative_source = "elepower_nuclear:hot_coolant_source",
	liquid_viscosity = 2,
	post_effect_color = {a = 128, r = 136, g = 100, b = 158},
	groups = {coolant = 3, liquid = 3, not_in_creative_inventory = 1, hot = 1},
	sounds = default.node_sound_water_defaults(),
})

if minetest.get_modpath("bucket") ~= nil then
	bucket.register_liquid("elepower_nuclear:coolant_source", "elepower_nuclear:hot_coolant_flowing",
		"elepower_nuclear:bucket_coolant", "#2497ff", "Coolant (Cold)")

	bucket.register_liquid("elepower_nuclear:hot_coolant_source", "elepower_nuclear:hot_coolant_flowing",
		"elepower_nuclear:bucket_hot_coolant", "#88649e", "Coolant (Hot)")

	bucket.register_liquid("elepower_nuclear:heavy_water_source", "elepower_nuclear:heavy_water_flowing",
		"elepower_nuclear:bucket_heavy_water", "#0d4579", "Heavy Water Bucket")
end
