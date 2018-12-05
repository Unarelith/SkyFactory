minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if mesetec.nodeswitch_user then
		local name=placer:get_player_name()
		if mesetec.nodeswitch_user[name] then
			if minetest.get_item_group(newnode.name,"liquid")>0 then
				return
			elseif mesetec.nodeswitch_user[name].p1 then
				minetest.add_entity(pos, "mesetec:pos2"):get_luaentity().user=name
				mesetec.nodeswitch_user[name].p2=pos
				mesetec.nodeswitch_user[name].node2=newnode.name
				mesetec.consnodeswitch(name)
			else
				minetest.add_entity(pos, "mesetec:pos1"):get_luaentity().user=name
				minetest.add_entity(pos, "mesetec:pos1")
				mesetec.nodeswitch_user[name].p1=pos
				mesetec.nodeswitch_user[name].node1=newnode.name
			end
		end
	end
end)

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if mesetec.nodeswitch_user then
		local name=puncher:get_player_name()
		if mesetec.nodeswitch_user[name] then
			if minetest.get_node(pointed_thing.above).name~="air" then
				return
			elseif mesetec.nodeswitch_user[name].p1 then
				if mesetec.nodeswitch_user[name].pun then
					minetest.chat_send_player(name, "A node is already punched")
				end
				minetest.add_entity(pointed_thing.above, "mesetec:pos2"):get_luaentity().user=name
				mesetec.nodeswitch_user[name].p2=pointed_thing.above
				mesetec.nodeswitch_user[name].node2=minetest.get_node(pointed_thing.above).name
				mesetec.consnodeswitch(name)
			else
				minetest.add_entity(pointed_thing.above, "mesetec:pos1"):get_luaentity().user=name
				mesetec.nodeswitch_user[name].p1=pointed_thing.above
				mesetec.nodeswitch_user[name].pun=1
				mesetec.nodeswitch_user[name].node1=minetest.get_node(pointed_thing.above).name
			end
		end
	end
end)

mesetec.consnodeswitch=function(name)
	if mesetec.nodeswitch_user[name].p1 and mesetec.nodeswitch_user[name].p2 then
		local meta=minetest.get_meta(mesetec.nodeswitch_user[name].pos)
		local npos1=mesetec.nodeswitch_user[name].p1
		local npos2=mesetec.nodeswitch_user[name].p2
		minetest.get_meta(npos1):set_string("mesetec_nodeswitch",name)
		minetest.get_meta(npos2):set_string("mesetec_nodeswitch",name)
		meta:set_string("node1",mesetec.nodeswitch_user[name].node1)
		meta:set_string("node2",mesetec.nodeswitch_user[name].node2)
		meta:set_string("pos1",minetest.pos_to_string(npos1))
		meta:set_string("pos2",minetest.pos_to_string(npos2))
		meta:set_int("able",1)
		mesetec.nodeswitch_user[name]=nil
		if #mesetec.nodeswitch_user==0 then mesetec.nodeswitch_user=nil end
	end
end

mesetec.consnodeswitch_switch=function(pos,state)
		local meta=minetest.get_meta(pos)
		if meta:get_int("able")==0 then return end
		local pos1=minetest.string_to_pos(meta:get_string("pos1"))
		local pos2=minetest.string_to_pos(meta:get_string("pos2"))
		local node1=meta:get_string("node1")
		local node2=meta:get_string("node2")
		local owner=meta:get_string("owner")
		local meta1=minetest.get_meta(pos1)
		local meta2=minetest.get_meta(pos2)
		if minetest.is_protected(pos1, owner)
		or minetest.is_protected(pos2, owner)
		or meta1:get_string("mesetec_nodeswitch")~=owner
		or meta2:get_string("mesetec_nodeswitch")~=owner then
			meta:set_int("able",0)
			return
		end
		meta1=meta1:to_table()
		meta2=meta2:to_table()
		local n1=minetest.get_node(pos1)
		local n2=minetest.get_node(pos2)
		if not ((state==1 and node1==n1.name and node2==n2.name) or (state==2 and node1==n2.name and node2==n1.name)) then
			meta:set_int("able",0)
			return
		end
		minetest.set_node(pos2,n1)
		minetest.get_meta(pos2):from_table(meta1)
		minetest.set_node(pos1,n2)
		minetest.get_meta(pos1):from_table(meta2)
end
minetest.register_node("mesetec:nodeswitch", {
	description = "Node switch",
after_place_node = function(pos, placer)
	local meta=minetest.get_meta(pos)
	local p=placer:get_player_name()
	meta:set_string("owner",p)
	minetest.chat_send_player(p, "Place the 1 or 2 nodes to replace with each other")
	minetest.chat_send_player(p, "Or punch somwehere to move the node to there")


	if not mesetec.nodeswitch_user then mesetec.nodeswitch_user={} end
	
	minetest.after(0.1, function(p)
		mesetec.nodeswitch_user[p]={pos=pos,name=p}
	end, p)

	minetest.after(60, function(p)
		if mesetec.nodeswitch_user then
			if mesetec.nodeswitch_user[p] then mesetec.nodeswitch_user[p]=nil end
			if #mesetec.nodeswitch_user==0 then mesetec.nodeswitch_user=nil end
		end
	end, p)
end,


	tiles = {"default_steel_block.png"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	--mesecons = {receptor = {state = "off"}},

	mesecons = {
		receptor = {state = "off"},
		effector = {
			action_on = function (pos, node)
				mesetec.consnodeswitch_switch(pos,1)
				return false
			end,
			action_off = function (pos, node)
				mesetec.consnodeswitch_switch(pos,2)
				return false
			end
		}}

})






minetest.register_node("mesetec:objdec", {
	description = "Object detector",
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		mesetec.form1(pos,player,"obj")
	end,
	tiles = {"default_steel_block.png","jeija_object_detector_off.png^[transform2"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	mesecons = {receptor = {state = "off"}},
	on_construct = function(pos)
		if not mesecon then return false end
		minetest.get_node_timer(pos):start(3)
	end,
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		local data=meta:get_string("data")
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
			if ob and ob:get_luaentity() and (data=="" or (ob:get_luaentity().name==data)) then
				mesecon.receptor_on(pos)
				minetest.swap_node(pos, {name="mesetec:objdec2"})
				minetest.get_node_timer(pos):start(2)
				return true
			end
		end
		return true
	end
})


minetest.register_node("mesetec:objdec2", {
	description = "Object detector",
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		mesetec.form1(pos,player,"obj")
	end,
	tiles = {"default_steel_block.png","jeija_object_detector_on.png^[transform2"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	mesecons = {receptor = {state = "on"}},
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		local data=meta:get_string("data")
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
			if ob and ob:get_luaentity() and (data=="" or (ob:get_luaentity().name==data)) then
				return true
			end
		end
		mesecon.receptor_off(pos)
		minetest.swap_node(pos, {name="mesetec:objdec"})
		minetest.get_node_timer(pos):start(3)
		return true
	end,
})





minetest.register_node("mesetec:mtp", {
	description = "Mese teleport",
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		mesetec.form1(pos,player,"pos")
	end,
	tiles = {"mesetec_ttp.png"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, -0.3125, 0.4375},
		}
	},
	mesecons = {effector = {
		action_on = function (pos, node)
		local meta=minetest.get_meta(pos)
		local po=mesetec.strpos(meta:get_string("data"),true)
		if po~=nil and minetest.get_node(po) and minetest.get_node(po).name=="mesetec:mtptarget" then
			mesecon.receptor_on(po)
		end
		return false
	end,
		action_off = function (pos, node)
		local meta=minetest.get_meta(pos)
		local po=mesetec.strpos(meta:get_string("data"),true)
		if po~=nil and minetest.get_node(po) and minetest.get_node(po).name=="mesetec:mtptarget" then
			mesecon.receptor_off(po)
		end
		return false
	end,
	}}
})

minetest.register_node("mesetec:mtptarget", {
	description = "Mese teleport target",
	tiles = {"mesetec_ttp_target.png"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, -0.3125, 0.4375},
		}
	},
	mesecons = {receptor = {
		state = mesecon.state.off,
		onstate = "mesetec:mtptarget",
	}},
})


minetest.register_node("mesetec:ptp", {
	description = "Player teleport",
	tiles = {"mesetec_ptp.png"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	mesecons = {effector = {
		action_on = function (pos, node)
		local names={}
		local ii=1
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
			if ob then
				names[i]=ob
				ii=ii+1
			end
		end
		if names[1]==nil then return false end
		mesetec.player_teleport.targets=names
		minetest.after((1), function(pos)
			if mesetec.player_teleport.targets then
				mesetec.player_teleport.targets=nil
			end
		end, pos)
		return false
	end,
	}}
})

minetest.register_node("mesetec:ptptarget", {
	description = "Player teleport target",
	tiles = {"mesetecptp_target.png"},
	groups = {mesecon=2,snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	walkable = false,
	mesecons = {effector = {
		action_on = function (pos, node)
		if mesetec.player_teleport.targets then
			for i, ob in pairs(mesetec.player_teleport.targets) do
				if ob then
					ob:move_to(pos)
				end
			end
		end
		mesetec.player_teleport.targets=nil
		return false
	end,
	}},
	drawtype = "nodebox",
	paramtype = "light",
	alpha = 210,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 1.5, 0.5},
		}
	}
})

minetest.register_entity("mesetec:pos1",{
	hp_max = 1,
	physical = false,
	collisionbox = {-0.52,-0.52,-0.52, 0.52,0.52,0.52},
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"mesetec_pos1.png","mesetec_pos1.png","mesetec_pos1.png","mesetec_pos1.png","mesetec_pos1.png","mesetec_pos1.png"}, 
	is_visible = true,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<1 then return self end
		self.timer=0
		self.timer2=self.timer2+dtime
		if self.timer2>2 or not (mesetec.nodeswitch_user and mesetec.nodeswitch_user[self.user]) then
			self.object:remove()
			return self
		end
	end,
	timer=0,
	timer2=0,
	user=""
})

minetest.register_entity("mesetec:pos2",{
	hp_max = 1,
	physical = false,
	collisionbox = {-0.52,-0.52,-0.52, 0.52,0.52,0.52},
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"mesetec_pos2.png","mesetec_pos2.png","mesetec_pos2.png","mesetec_pos2.png","mesetec_pos2.png","mesetec_pos2.png"}, 
	is_visible = true,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<1 then return self end
		self.timer=0
		self.timer2=self.timer2+dtime
		if self.timer2>2 or not (mesetec.nodeswitch_user and mesetec.nodeswitch_user[self.user]) then
			self.object:remove()
			return self
		end
	end,
	timer=0,
	timer2=0,
	user=""
})
