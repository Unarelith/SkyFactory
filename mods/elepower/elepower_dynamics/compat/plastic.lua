if minetest.get_modpath("homedecor") == nil and minetest.get_modpath("pipeworks") == nil then
	minetest.register_craftitem(":homedecor:oil_extract", {
		    description = "Oil Extract",
		    inventory_image = "elepower_oil_extract.png",
	})

	minetest.register_craftitem(":homedecor:paraffin", {
		    description = "Unprocessed Paraffin",
		    inventory_image = "elepower_paraffin.png",
	})

	minetest.register_alias("homedecor:plastic_base", "homedecor:paraffin")

	minetest.register_craftitem(":homedecor:plastic_sheeting", {
		    description = "Plastic Sheet",
		    inventory_image = "elepower_plastic_sheeting.png",
	})

	minetest.register_craft({
		type = "shapeless",
		output = "homedecor:oil_extract 4",
		recipe = {
			"group:leaves",
			"group:leaves",
			"group:leaves",
			"group:leaves",
			"group:leaves",
			"group:leaves"
		}
	})

	minetest.register_craft({
		    type = "cooking",
		    output = "homedecor:paraffin",
		    recipe = "homedecor:oil_extract",
	})

	minetest.register_craft({
		    type = "cooking",
		    output = "homedecor:plastic_sheeting",
		    recipe = "homedecor:paraffin",
	})

	minetest.register_craft({
		    type = "fuel",
		    recipe = "homedecor:oil_extract",
		    burntime = 30,
	})

	minetest.register_craft({
		    type = "fuel",
		    recipe = "homedecor:paraffin",
		    burntime = 30,
	})

	minetest.register_craft({
		    type = "fuel",
		    recipe = "homedecor:plastic_sheeting",
		    burntime = 30,
	})
end
