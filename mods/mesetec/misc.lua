mesetec.form2=function(pos,player,try)
	local meta=minetest.get_meta(pos)
	local name=player:get_player_name()
	local owner=meta:get_string("owner")==name
	local data=meta:get_string("data")
	mesetec.mtpuser[player:get_player_name()]=pos
	local gui=""
	gui=""
	.."size[3,5]"
	.."tooltip[data;Enter code]"
	.."button[0,1;1,1;b1;1]"
	.."button[1,1;1,1;b2;2]"
	.."button[2,1;1,1;b3;3]"
	.."button[0,2;1,1;b4;4]"
	.."button[1,2;1,1;b5;5]"
	.."button[2,2;1,1;b6;6]"
	.."button[0,3;1,1;b7;7]"
	.."button[1,3;1,1;b8;8]"
	.."button[2,3;1,1;b9;9]"
	.."button[1,4;1,1;b0;0]"
	if owner then
		if not mesetec.mtcuser[name] then
			mesetec.mtcuser[name]=data
		end
		gui=gui.."button_exit[2,4;1,1;ok;OK]"
		gui=gui.."button_exit[0,4;1,1;save;Save]"
		gui=gui.."field[0.3,0;3,1;data;;" .. mesetec.mtcuser[name] .."]"
	else
		if not mesetec.mtcuser[name] then
			mesetec.mtcuser[name]=""
		end
		gui=gui.."button_exit[2,4;1,1;ok;OK]"
		gui=gui.."field[0.3,0;3,1;data;;" .. mesetec.mtcuser[name] .."]"
		mesetec.mtcuser[name]=nil
	end
	minetest.after(0.1, function(gui)
		return minetest.show_formspec(player:get_player_name(), "mesetec.code",gui)
	end, gui)
end


minetest.register_node("mesetec:codelock", {
	description = "Codelock panel",
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		mesetec.form2(pos,player)
	end,
	tiles = {"default_steel_block.png","default_steel_block.png","default_steel_block.png","default_steel_block.png","default_steel_block.png","mesetec_code.png"},
	groups = {mesecon_needs_receiver = 1,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	mesecons = {receptor = {
		rules = mesecon.rules.buttonlike_get,
		state = mesecon.state.off
	}},
	after_place_node = function(pos, placer, itemstack)
		local meta=minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name())
	end,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.4375, 0.375, 0.1875, 0.0625, 0.5},
		}
	}
})



minetest.register_node("mesetec:dmg", {
	description = "Mese damage block",
	tiles = {"mesetec_trap.png^[colorize:#f9570001"},
	alpha=1,
	inventory_image = "default_lava.png^mesetec_trap2.png",
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	drawtype="glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesetec:dmg2",
		rules = mesetec.rules
	}},
})
minetest.register_node("mesetec:dmg2", {
	description = "Mese damage block",
	tiles = {"mesetec_trap.png"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=1},
	is_ground_content = false,
	drawtype="glasslike",
	alpha=0,
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	damage_per_second = 2,
	walkable = false,
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesetec:dmg",
		rules = mesetec.rules
	}},
})

minetest.register_node("mesetec:oxygen", {
	description = "Mese oxygen block",
	tiles = {"mesetec_trap.png^[colorize:#00a5a201"},
	alpha=1,
	inventory_image = "default_river_water.png^mesetec_trap2.png",
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	drawtype="glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesetec:oxygen2",
		rules = mesetec.rules
	}},
})
minetest.register_node("mesetec:oxygen2", {
	description = "Mese oxygen block",
	tiles = {"mesetec_trap.png"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=1},
	is_ground_content = false,
	drawtype="glasslike",
	alpha=1,
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	drowning = 1,
	walkable = false,
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesetec:oxygen",
		rules = mesetec.rules
	}},
})

minetest.register_node("mesetec:ladder", {
	description = "Mese ladder block",
	tiles = {"mesetec_trap.png^[colorize:#87878701"},
	alpha=1,
	inventory_image = "default_ladder_wood.png^mesetec_trap2.png",
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	drawtype="glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesetec:ladder2",
		rules = mesetec.rules
	}},
})
minetest.register_node("mesetec:ladder2", {
	description = "Mese ladder block",
	tiles = {"mesetec_trap.png"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=1},
	is_ground_content = false,
	drawtype="glasslike",
	alpha=1,
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesetec:ladder",
		rules = mesetec.rules
	}},
})

minetest.register_node("mesetec:delayer", {
	description = "Delayer (Punch to change time)",
	tiles = {"mesetec_delayer.png","default_sandstone_block.png"},
	groups = {dig_immediate = 2,mesecon=1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
	type="fixed",
	fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesetec:ladder",
		rules = mesetec.rules
	}},
on_punch = function(pos, node, player, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local time=meta:get_int("time")
			if time>=10 then time=0 end
			meta:set_int("time",time+1)
			meta:set_string("infotext","Delayer (" .. (time+1) ..")")
		end
	end,
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("time",1)
			meta:set_string("infotext","Delayer (1)")
			meta:set_int("case",0)
	end,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if meta:get_int("case")==2 then
			meta:set_int("case",0)
			mesecon.receptor_off(pos)
		end
		if meta:get_int("case")==1 then
			meta:set_int("case",2)
			mesecon.receptor_on(pos)
			minetest.get_node_timer(pos):start(meta:get_int("time"))
		end
		return false
	end,
	mesecons = {effector = {
		action_on = function (pos, node)
			local meta = minetest.get_meta(pos)
			if meta:get_int("case")==0 then
				meta:set_int("case",1)
				minetest.get_node_timer(pos):start(meta:get_int("time"))
			end

		end,
	}}
})

minetest.register_node("mesetec:light", {
	description = "Light check",
	tiles = {"jeija_solar_panel.png","default_steel_block.png"},
	groups = {dig_immediate = 2,mesecon=1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
	type="fixed",
	fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	is_ground_content = false,
	mesecons = {receptor = {
		rules = mesecon.rules.buttonlike_get,
		rules = mesetec.rules
	}},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			mesetec.form1(pos,player,"num")
		end
	end,
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext","Light")
	end,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		local l=meta:get_int("light")
		local rl=minetest.get_node_light(pos)
		meta:set_string("infotext","Light: " .. rl)
		if l==rl then
			mesecon.receptor_on(pos)
		else
			mesecon.receptor_off(pos)
		end
		return true
	end,
})
