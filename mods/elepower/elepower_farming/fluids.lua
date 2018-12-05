
-- Tree Sap

minetest.register_node("elepower_farming:tree_sap_source", {
	description  = "Tree Sap Source",
	drawtype     = "liquid",
	tiles        = {"elefarming_tree_sap.png"},
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
	liquid_alternative_source = "elepower_farming:tree_sap_source",
	liquid_alternative_flowing = "elepower_farming:tree_sap_flowing",
	liquid_viscosity = 7,
	post_effect_color = {a = 103, r = 84, g = 34, b = 0},
	groups = {tree_sap = 3, liquid = 3, raw_bio = 1, tree_fluid = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("elepower_farming:tree_sap_flowing", {
	description = "Flowing Tree Sap",
	drawtype = "flowingliquid",
	tiles = {"elefarming_tree_sap.png"},
	special_tiles = {"elefarming_tree_sap.png", "elefarming_tree_sap.png"},
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
	liquid_alternative_flowing = "elepower_farming:tree_sap_flowing",
	liquid_alternative_source = "elepower_farming:tree_sap_source",
	liquid_viscosity = 7,
	post_effect_color = {a = 103, r = 84, g = 34, b = 0},
	groups = {tree_sap = 3, liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})

-- Tree Resin

minetest.register_node("elepower_farming:resin_source", {
	description  = "Resin Source",
	drawtype     = "liquid",
	tiles        = {"elefarming_tree_sap.png"},
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
	liquid_alternative_source = "elepower_farming:resin_source",
	liquid_alternative_flowing = "elepower_farming:resin_flowing",
	liquid_viscosity = 8,
	post_effect_color = {a = 103, r = 84, g = 34, b = 0},
	groups = {resin = 3, liquid = 3, raw_bio = 1, tree_fluid = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("elepower_farming:resin_flowing", {
	description = "Flowing Resin",
	drawtype = "flowingliquid",
	tiles = {"elefarming_tree_sap.png"},
	special_tiles = {"elefarming_tree_sap.png", "elefarming_tree_sap.png"},
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
	liquid_alternative_source = "elepower_farming:resin_source",
	liquid_alternative_flowing = "elepower_farming:resin_flowing",
	liquid_viscosity = 8,
	post_effect_color = {a = 103, r = 84, g = 34, b = 0},
	groups = {resin = 3, liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})

-- Biomass

minetest.register_node("elepower_farming:biomass_source", {
	description  = "Biomass Source",
	drawtype     = "liquid",
	tiles        = {"elefarming_biomass.png"},
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
	liquid_alternative_source = "elepower_farming:biomass_source",
	liquid_alternative_flowing = "elepower_farming:biomass_flowing",
	liquid_viscosity = 7,
	post_effect_color = {a = 103, r = 0, g = 42, b = 0},
	groups = {biomass = 3, liquid = 3},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("elepower_farming:biomass_flowing", {
	description = "Flowing Biomass",
	drawtype = "flowingliquid",
	tiles = {"elefarming_biomass.png"},
	special_tiles = {"elefarming_biomass.png", "elefarming_biomass.png"},
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
	liquid_alternative_flowing = "elepower_farming:biomass_flowing",
	liquid_alternative_source = "elepower_farming:biomass_source",
	liquid_viscosity = 7,
	post_effect_color = {a = 103, r = 0, g = 42, b = 0},
	groups = {biomass = 3, liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})

-- Biofuel

minetest.register_node("elepower_farming:biofuel_source", {
	description  = "Biofuel Source",
	drawtype     = "liquid",
	tiles        = {"elefarming_biofuel.png"},
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
	liquid_alternative_source = "elepower_farming:biofuel_source",
	liquid_alternative_flowing = "elepower_farming:biofuel_flowing",
	liquid_viscosity = 7,
	post_effect_color = {a = 103, r = 255, g = 163, b = 0},
	groups = {biofuel = 3, liquid = 3},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("elepower_farming:biofuel_flowing", {
	description = "Flowing Biofuel",
	drawtype = "flowingliquid",
	tiles = {"elefarming_biofuel.png"},
	special_tiles = {"elefarming_biofuel.png", "elefarming_biofuel.png"},
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
	liquid_alternative_flowing = "elepower_farming:biofuel_flowing",
	liquid_alternative_source = "elepower_farming:biofuel_source",
	liquid_viscosity = 7,
	post_effect_color = {a = 103, r = 255, g = 163, b = 0},
	groups = {biofuel = 3, liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})

-- Sludge

minetest.register_node("elepower_farming:sludge_source", {
	description  = "Sludge Source",
	drawtype     = "liquid",
	tiles        = {"elefarming_tar.png"},
	paramtype    = "light",
	walkable     = false,
	pointable    = false,
	diggable     = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_source = "elepower_farming:sludge_source",
	liquid_alternative_flowing = "elepower_farming:sludge_flowing",
	liquid_viscosity = 8,
	post_effect_color = {a = 50, r = 0, g = 0, b = 0},
	groups = {sludge = 3, liquid = 3},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("elepower_farming:sludge_flowing", {
	description = "Flowing Sludge",
	drawtype = "flowingliquid",
	tiles = {"elefarming_tar.png"},
	special_tiles = {"elefarming_tar.png", "elefarming_tar.png"},
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
	liquid_alternative_flowing = "elepower_farming:sludge_flowing",
	liquid_alternative_source = "elepower_farming:sludge_source",
	liquid_viscosity = 8,
	post_effect_color = {a = 50, r = 0, g = 0, b = 0},
	groups = {sludge = 3, liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})

if minetest.get_modpath("bucket") ~= nil then
	bucket.register_liquid("elepower_farming:tree_sap_source", "elepower_farming:tree_sap_flowing",
		"elepower_farming:bucket_tree_sap", "#411400", "Tree Sap Bucket")

	bucket.register_liquid("elepower_farming:resin_source",    "elepower_farming:resin_flowing",
		"elepower_farming:bucket_resin",    "#411401", "Resin Bucket")

	bucket.register_liquid("elepower_farming:biomass_source",  "elepower_farming:biomass_flowing",
		"elepower_farming:bucket_biomass",  "#002c01", "Biomass Bucket")

	bucket.register_liquid("elepower_farming:biofuel_source",  "elepower_farming:biofuel_flowing",
		"elepower_farming:bucket_biofuel",  "#762700", "Biofuel Bucket")

	bucket.register_liquid("elepower_farming:sludge_source",   "elepower_farming:sludge_flowing",
		"elepower_farming:bucket_sludge",   "#121212", "Sludge Bucket")

	fluid_tanks.register_tank(":elepower_dynamics:portable_tank", {
		description = "Portable Tank",
		capacity    = 8000,
		accepts     = true,
		tiles       = {
			"elepower_tank_base.png", "elepower_tank_side.png", "elepower_tank_base.png^elepower_power_port.png",
		}
	})
end
