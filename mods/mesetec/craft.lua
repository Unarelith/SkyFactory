minetest.register_craft({
	output = "mesetec:nodeswitch",
	recipe = {{"","mesecons:wire_00000000_off",""},
		{"mesecons_materials:silicon","mesecons_lamp:lamp_off","mesecons_materials:silicon"},
		{"","default:mese_crystal",""},
	}
})


minetest.register_craft({
	output = "mesetec:objdec",
	recipe = {{"mesecons_materials:silicon","mesecons_solarpanel:solar_panel_off","mesecons_materials:silicon"}
	}
})


minetest.register_craft({
	output = "mesetec:light",
	recipe = {{"mesecons_materials:silicon","mesecons_solarpanel:solar_panel_off","mesecons_materials:silicon"}
	}
})

minetest.register_craft({
	output = "mesetec:delayer",
	recipe = {{"mesecons_delayer:delayer_off_1","default:copper_ingot","mesecons_delayer:delayer_off_1"},
	}
})


minetest.register_craft({
	output = "mesetec:oxygen 3",
	recipe = {{"","mesecons:wire_00000000_off",""},
		{"default:sand","mesecons_lamp:lamp_off","default:sand"},
		{"","default:torch",""},
	}
})

minetest.register_craft({
	output = "mesetec:dmg 3",
	recipe = {{"","mesecons:wire_00000000_off",""},
		{"default:sand","mesecons_lamp:lamp_off","default:sand"},
		{"","default:mese_crystal",""},
	}
})

minetest.register_craft({
	output = "mesetec:ladder 3",
	recipe = {{"","mesecons:wire_00000000_off",""},
		{"default:sand","mesecons_lamp:lamp_off","default:sand"},
		{"","default:ladder_wood",""},
	}
})


minetest.register_craft({
	output = "mesetec:keycard",
	recipe = {{"mesecons_materials:silicon","mesecons:wire_00000000_off","mesecons_materials:silicon"},
		{"mesecons_materials:silicon","mesecons_lamp:lamp_off","mesecons_materials:silicon"},
	}
})

minetest.register_craft({
	output = "mesetec:codelock",
	recipe = {{"default:steel_ingot","mesecons:wire_00000000_off","default:steel_ingot"},
		{"default:steel_ingot","mesecons_luacontroller:luacontroller0000","default:steel_ingot"},
		{"default:steel_ingot","mesecons_lamp:lamp_off","default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "mesetec:controller",
	recipe = {{"","mesecons:wire_00000000_off",""},
		{"default:steel_ingot","mesecons_walllever:wall_lever_off","default:steel_ingot"},
		{"","default:stick",""},
	}
})

minetest.register_craft({
	output = "mesetec:hacktool",
	recipe = {{"mesecons:wire_00000000_off","","mesecons:wire_00000000_off"},
		{"default:steel_ingot","default:mese_crystal","default:steel_ingot"},
		{"","default:stick",""},
	}
})

minetest.register_craft({
	output = "mesetec:objdec",
	recipe = {{"","mesecons:wire_00000000_off",""},
		{"","mesecons_detector:object_detector_off",""},
		{"","mesecons_luacontroller:luacontroller0000",""},
	}
})

minetest.register_craft({
	output = "mesetec:mtptarget",
	recipe = {{"default:steel_ingot","mesecons:wire_00000000_off","default:steel_ingot"},
		{"default:steel_ingot","default:mese_crystal","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "mesetec:mtp",
	recipe = {{"default:steel_ingot","mesecons:wire_00000000_off","default:steel_ingot"},
		{"default:mese_crystal","mesecons_luacontroller:luacontroller0000","default:mese_crystal"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})


minetest.register_craft({
	output = "mesetec:ptp",
	recipe = {{"default:steel_ingot","mesecons:wire_00000000_off","default:steel_ingot"},
		{"default:mese_crystal_fragment","mesecons_detector:object_detector_off","default:mese_crystal_fragment"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "mesetec:ptptarget",
	recipe = {{"default:steel_ingot","mesecons:wire_00000000_off","default:steel_ingot"},
		{"default:mese_crystal_fragment","mesecons_luacontroller:luacontroller0000","default:mese_crystal_fragment"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})