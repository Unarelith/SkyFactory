local S = factory.S

minetest.register_craft({
	output = "factory:small_steel_gear 4",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "", "default:steel_ingot"}
	}
})

minetest.register_craft({
	output = "factory:small_gold_gear 4",
	recipe = {
		{"default:gold_ingot", "", "default:gold_ingot"},
		{"", "factory:small_steel_gear", ""},
		{"default:gold_ingot", "", "default:gold_ingot"}
	}
})

minetest.register_craft({
	output = "factory:small_diamond_gear 4",
	recipe = {
		{"default:diamond", "", "default:diamond"},
		{"", "factory:small_gold_gear", ""},
		{"default:diamond", "", "default:diamond"}
	}
})

minetest.register_craft({
	output = "factory:scanner_chip",
	recipe = {
		{"default:steel_ingot", "factory:copper_wire", "default:mese_crystal"},
		{"", "factory:tree_sap", ""},
		{"default:mese_crystal", "", "default:steel_ingot"}
	}
})

minetest.register_craft({
	output = "factory:storage_tank",
	recipe = {
		{"default:glass", 	"default:steel_ingot", 		"default:glass"},
		{"default:glass", 	"", 						"default:glass"},
		{"default:glass", 	"default:steel_ingot", 		"default:glass"}
	}
})

minetest.register_craft({
	output = "factory:sapling_fertilizer",
	recipe = {
		{"default:dirt", 	"default:dirt"},
		{"default:dirt",	"default:dirt"},
	}
})


minetest.register_craft({
	type = "shapeless",
	output = "factory:fan_blade",
	recipe = {
		"default:steel_ingot",
		"factory:tree_sap",
		"default:stick"
	}
})

factory.register_recipe_type("ind_squeezer", {
	description = S("squeezing"),
	icon = "factory_compressor_front.png",
	width = 1,
	height = 1,
})

--TODO: register group:tree instead

factory.register_recipe("ind_squeezer",{
	output = "factory:tree_sap",
	input = {"default:tree"}
})

factory.register_recipe("ind_squeezer",{
	output = "factory:tree_sap",
	input = {"default:jungletree"}
})

factory.register_recipe("ind_squeezer",{
	output = "factory:compressed_clay",
	input = {"default:clay_lump"}
})


factory.register_recipe("ind_squeezer",{
	output = "default:sandstone",
	input = {"default:sand"}
})

minetest.register_craft({
	type = "cooking",
	output = "factory:factory_lump",
	recipe = "factory:compressed_clay"
})

factory.register_recipe_type("wire_drawer", {
	description = S("drawing wire"),
	icon = "factory_wire_drawer_front.png",
	width = 1,
	height = 1,
})

factory.register_recipe("wire_drawer",{
	output = "factory:steel_wire 2",
	input = {"default:steel_ingot"}
})

factory.register_recipe("wire_drawer",{
	output = "factory:copper_wire 2",
	input = {"default:copper_ingot"}
})

factory.register_recipe("wire_drawer",{
	output = "factory:fiber 2",
	input = {"factory:tree_sap"}
})

minetest.register_craft({
	type = "fuel",
	recipe = "factory:tree_sap",
	burntime = 20,
})
