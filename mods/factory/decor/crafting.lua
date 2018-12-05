minetest.register_craft({
	output = "factory:smoke_tube",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"}
	}
})

minetest.register_craft({
	output = 'factory:factory_brick 6',
	recipe = {
		{'factory:factory_lump', 'factory:factory_lump'},
		{'factory:factory_lump', 'factory:factory_lump'},
	}
})

minetest.register_craft({
	output = 'factory:sieve_stack 6',
	recipe = {
		{'factory:factory_brick', '', 'factory:factory_brick'},
		{'factory:factory_brick', '', 'factory:factory_brick'},
		{'factory:factory_brick', '', 'factory:factory_brick'},
	}
})

minetest.register_craft({
	output = 'factory:half_sieve_stack 6',
	recipe = {
		{'factory:factory_brick', '', 'factory:factory_brick'},
		{'factory:factory_brick', '', 'factory:factory_brick'},
	}
})

minetest.register_craft({
	output = 'factory:sieve_single 6',
	recipe = {
		{'factory:factory_brick', 'factory:sieve_stack', 'factory:factory_brick'},
		{'factory:factory_brick', 'factory:sieve_stack', 'factory:factory_brick'},
		{'factory:factory_brick', 'factory:sieve_stack', 'factory:factory_brick'},
	}
})

minetest.register_craft({
	output = 'factory:half_sieve_single 6',
	recipe = {
		{'factory:factory_brick', 'factory:sieve_stack', 'factory:factory_brick'},
		{'factory:factory_brick', 'factory:sieve_stack', 'factory:factory_brick'},
	}
})

minetest.register_craft({
	output = 'factory:sieve_stack',
	recipe = {
		{'factory:half_sieve_stack'},
		{'factory:half_sieve_stack'},
	}
})

minetest.register_craft({
	output = 'factory:sieve_single',
	recipe = {
		{'factory:half_sieve_single'},
		{'factory:half_sieve_single'},
	}
})