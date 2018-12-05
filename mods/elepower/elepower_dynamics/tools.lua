
-- Pickaxes

minetest.register_tool("elepower_dynamics:pick_iron", {
	description = "Iron Pickaxe",
	inventory_image = "elepower_tool_ironpick.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=3.90, [2]=1.50, [3]=0.60}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("elepower_dynamics:pick_lead", {
	description = "Lead Pickaxe",
	inventory_image = "elepower_tool_leadpick.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=3.90, [2]=1.60, [3]=0.50}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
})

-- Shovels

minetest.register_tool("elepower_dynamics:shovel_iron", {
	description = "Iron Shovel",
	inventory_image = "elepower_tool_ironshovel.png",
	wield_image = "elepower_tool_ironshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.40, [2]=0.80, [3]=0.20}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("elepower_dynamics:shovel_lead", {
	description = "Lead Shovel",
	inventory_image = "elepower_tool_leadshovel.png",
	wield_image = "elepower_tool_leadshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.50, [2]=0.50, [3]=0.10}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
})

-- Axes

minetest.register_tool("elepower_dynamics:axe_iron", {
	description = "Iron Axe",
	inventory_image = "elepower_tool_ironaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.40, [2]=1.30, [3]=0.80}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("elepower_dynamics:axe_lead", {
	description = "Lead Axe",
	inventory_image = "elepower_tool_leadaxe.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.40, [2]=1.20, [3]=0.70}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
})

-- Swords

minetest.register_tool("elepower_dynamics:sword_iron", {
	description = "Iron Sword",
	inventory_image = "elepower_tool_ironsword.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.4, [2]=1.10, [3]=0.2}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("elepower_dynamics:sword_lead", {
	description = "Lead Sword",
	inventory_image = "elepower_tool_leadsword.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.2, [2]=1.00, [3]=0.1}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=7},
	},
	sound = {breaks = "default_tool_breaks"},
})
