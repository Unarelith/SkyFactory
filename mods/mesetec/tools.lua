minetest.register_tool("mesetec:controller", {
	description = "Mese teleport target controller",
	inventory_image = "mesetec_control.png",
on_use = function(itemstack, user, pointed_thing)
	local name=user:get_player_name()
	if pointed_thing.type=="node" and minetest.get_node(pointed_thing.under).name=="mesetec:mtptarget" and minetest.is_protected(pointed_thing.under, name)==false then
		local pos=pointed_thing.under
		local item=itemstack:to_table()
		local meta=minetest.deserialize(item["metadata"])
		local mode=mesetec.strpos(pos,false)
		meta={}
		meta.mode=mesetec.strpos(pos,false)
		mode=(meta.mode)
		meta.mode=mode
		item.metadata=minetest.serialize(meta)
		itemstack:replace(item)
		minetest.chat_send_player(user:get_player_name(), "Target set!")
	else
		local item=itemstack:to_table()
		local meta=minetest.deserialize(item["metadata"])

		if meta==nil then
			minetest.chat_send_player(user:get_player_name(), "Punch a Mese teleport target")
			return itemstack
		end
		local pos=mesetec.strpos(meta.mode,true)
		local t_pos=mesetec.distance(pos,user:get_pos())
		if t_pos>mesetec.mtp_distance then
			minetest.chat_send_player(name, "Error: too faraway (max: " .. mesetec.mtp_distance ..", current: " .. (math.floor(t_pos+0.5)) .. ")")
			return itemstack
		end
		mesecon.receptor_on(pos)
		minetest.after(1, function(pos)
				mesecon.receptor_off(pos)
		end, pos)
	end
	return itemstack
end
})

minetest.register_tool("mesetec:hacktool", {
	description = "Mese hack tool",
	inventory_image = "mesetec_hack.png",
on_use = function(itemstack, user, pointed_thing)
	local pos=user:get_pos()
	local name=user:get_player_name()
	if pointed_thing.type=="node" and minetest.is_protected(pointed_thing.under, name)==false then
		pos=pointed_thing.under
		local node=minetest.get_node(pos)
			mesecon.receptor_on(pos)
			minetest.after(1, function(pos,node)
					mesecon.receptor_off(pos)
			end, pos, node)
	end
	return itemstack
end
})








minetest.register_tool("mesetec:keycard", {
	description = "Keycard",
	inventory_image = "mesetecptp_keycard.png",
on_place = function(itemstack, user, pointed_thing)
	local name=user:get_player_name()
	if pointed_thing.type=="node" and minetest.get_node(pointed_thing.under).name=="mesetec:codelock" then
		local pos=pointed_thing.under
		local nmeta=minetest.get_meta(pos)
		local owner=nmeta:get_string("owner")
		if owner~=name then return itemstack end
		local t_item=itemstack:to_table()
		local t_meta=minetest.deserialize(t_item["metadata"])
		if t_meta and t_meta.owner and t_meta.owner~=owner then return itemstack end
		local item=itemstack:to_table()
		local code=nmeta:get_string("data")
		local meta={}
		meta.code=code
		meta.owner=owner
		item.metadata=minetest.serialize(meta)
		itemstack:replace(item)
		minetest.chat_send_player(user:get_player_name(), "Keycard coded")
	end
		return itemstack
end,
on_use = function(itemstack, user, pointed_thing)
		local item=itemstack:to_table()
		local meta=minetest.deserialize(item["metadata"])
		if meta==nil then
			minetest.chat_send_player(user:get_player_name(), "Punch a codelock")
			return itemstack
		end
		if pointed_thing.type=="node" and minetest.get_node(pointed_thing.under).name=="mesetec:codelock" then
			local pos=pointed_thing.under
			local nmeta=minetest.get_meta(pos)
			local owner=nmeta:get_string("owner")
			local code=nmeta:get_string("data")
			if owner~=meta.owner or code~=meta.code then
				return itemstack
			end
			local node=minetest.get_node(pos)
				mesecon.receptor_on(pos, mesecon.rules.buttonlike_get(node))
			minetest.after(1, function(pos,node)
				mesecon.receptor_off(pos, mesecon.rules.buttonlike_get(node))
			end, pos,node)
		end
		return itemstack
end
})