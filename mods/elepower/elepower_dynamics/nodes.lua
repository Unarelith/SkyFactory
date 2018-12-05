
---------------
-- Overrides --
---------------

-----------
-- Nodes --
-----------

-- Ores

minetest.register_node("elepower_dynamics:stone_with_lead", {
	description = "Lead Ore",
	tiles = {"default_stone.png^elepower_mineral_lead.png"},
	groups = {cracky = 2},
	drop = 'elepower_dynamics:lead_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("elepower_dynamics:stone_with_nickel", {
	description = "Nickel Ore",
	tiles = {"default_stone.png^elepower_mineral_nickel.png"},
	groups = {cracky = 2},
	drop = 'elepower_dynamics:nickel_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("elepower_dynamics:stone_with_viridisium", {
	description = "Viridisium Ore",
	tiles = {"default_stone.png^elepower_mineral_viridisium.png"},
	groups = {cracky = 3},
	drop = 'elepower_dynamics:viridisium_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("elepower_dynamics:stone_with_zinc", {
	description = "Zinc Ore",
	tiles = {"default_stone.png^elepower_mineral_zinc.png"},
	groups = {cracky = 3},
	drop = 'elepower_dynamics:zinc_lump',
	sounds = default.node_sound_stone_defaults(),
})

-- Other

minetest.register_node("elepower_dynamics:particle_board", {
	description = "Particle Board",
	tiles = {"elepower_particle_board.png"},
	groups = {choppy = 2, wood = 1},
	drop = 'elepower_dynamics:wood_dust 4',
	sounds = default.node_sound_wood_defaults(),
})

-- Blocks

minetest.register_node("elepower_dynamics:viridisium_block", {
	description = "Viridisium Block",
	tiles = {"elepower_viridisium_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("elepower_dynamics:lead_block", {
	description = "Lead Block",
	tiles = {"elepower_lead_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("elepower_dynamics:invar_block", {
	description = "Invar Block",
	tiles = {"elepower_invar_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 3},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("elepower_dynamics:nickel_block", {
	description = "Nickel Block",
	tiles = {"elepower_nickel_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 3},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("elepower_dynamics:zinc_block", {
	description = "Zinc Block",
	tiles = {"elepower_zinc_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 3},
	sounds = default.node_sound_metal_defaults(),
})
