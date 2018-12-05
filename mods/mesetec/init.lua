mesetec={maxlight=default.LIGHT_MAX or 15, player_teleport={},mtcuser={},mtpuser={},rules={{x=1,y=0,z=0},{x=-1,y=0,z=0},{x=0,y=1,z=0},{x=0,y=-1,z=0},{x=0,y=0,z=1},{x=0,y=0,z=-1}}



,mtp_distance=30, --Mese teleport distance
}
dofile(minetest.get_modpath("mesetec") .. "/tools.lua")
dofile(minetest.get_modpath("mesetec") .. "/teleob.lua")
dofile(minetest.get_modpath("mesetec") .. "/misc.lua")

dofile(minetest.get_modpath("mesetec") .. "/craft.lua")

mesetec.distance=function(p,o)
return math.sqrt((p.x-o.x)*(p.x-o.x) + (p.y-o.y)*(p.y-o.y)+(p.z-o.z)*(p.z-o.z))
end

mesetec.strpos=function(str,spl)
	if spl then
		local c=","
		if string.find(str," ") then c=" " end
		local s=str.split(str,c)
			if s[3]==nil then
				return nil
			else
				return {x=tonumber(s[1]),y=tonumber(s[2]),z=tonumber(s[3])}
			end
	else	if str.x and str.y and str.z then
			return str.x .."," .. str.y .."," .. str.z
		else
			return nil
		end
	end
end


mesetec.form1=function(pos,player,type)
	local meta=minetest.get_meta(pos)
	local data=meta:get_string("data")
	mesetec.mtpuser[player:get_player_name()]=pos
	local gui=""
	local label=""
	local field=""
	local form=""
	if type=="pos" then
		if data=="" then
			local ppos=player:get_pos()
			ppos={x=math.floor(ppos.x+0.5),y=math.floor(ppos.y+0.5),z=math.floor(ppos.z+0.5)}
			data=mesetec.strpos(ppos,false)
		end
		label="Position of mese teleport target"
		field=data
		form="form1"
	elseif type=="obj" then
		label="Entity name, (like mobs:sheep)"
		field=data
		form="form2"
	elseif type=="num" then
		if data=="" then
			data=minetest.get_node_light(pos)
			if not data then data=0 end
		else
			data=meta:get_int("light")
		end
		label="Light (from 0 to " .. mesetec.maxlight .. ")"
		field=data
		form="form3"
	end
	gui=""
	.."size[3.5,0.2]"
	.."tooltip[data;".. label .."]"
	.."field[0,0;3,1;data;;" .. field .."]"
	.."button_exit[2.5,-0.3;1.3,1;save;Save]"
	minetest.after((0.1), function(gui)
		return minetest.show_formspec(player:get_player_name(), "mesetec." .. form,gui)
	end, gui)
end
minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="mesetec.code" then
		local name=player:get_player_name()
		local pos=mesetec.mtpuser[name]
		mesetec.mtpuser[name]=nil
		if pressed.data==nil then
		mesetec.mtcuser[name]=nil
			return
		end
		local n=0
		if pressed.b1 then
		n=1
		elseif pressed.b2 then
		n=2
		elseif pressed.b3 then
		n=3
		elseif pressed.b4 then
		n=4
		elseif pressed.b5 then
		n=5
		elseif pressed.b6 then
		n=6
		elseif pressed.b7 then
		n=7
		elseif pressed.b8 then
		n=8
		elseif pressed.b9 then
		n=9
		end
		if pressed.save then
			local meta=minetest.get_meta(pos)
			meta:set_string("data",pressed.data)
			minetest.chat_send_player(name, "Code set!")
			mesetec.mtcuser[name]=nil
			return
		elseif pressed.ok then
			local meta=minetest.get_meta(pos)
			if pressed.data==meta:get_string("data") then
				local node=minetest.get_node(pos)
				mesecon.receptor_on(pos, mesecon.rules.buttonlike_get(node))
				minetest.after(1, function(pos,node)
				mesecon.receptor_off(pos, mesecon.rules.buttonlike_get(node))
				end, pos,node)
				mesetec.mtcuser[name]=nil
				return
			elseif meta:get_string("owner")==name then
				n=""
				pressed.data=meta:get_string("data")
			else
				mesetec.mtcuser[name]=""
				pressed.data=""
				n=""
			end
		end
		mesetec.mtcuser[name]=pressed.data .. n
		minetest.after(0.1, function(pos,player)
			mesetec.form2(pos,player)
		end, pos,player)
		return
	end
	if form=="mesetec.form1" then
		if pressed.save  then
			local name=player:get_player_name()
			local pos=mesetec.mtpuser[name]
			mesetec.mtpuser[name]=nil
			if minetest.is_protected(pos, name)==false then
				local meta=minetest.get_meta(pos)
				local po1=pressed.data
				local po=mesetec.strpos(po1,true)
				if po and po.x and po.y and po.z and minetest.get_node(po) then
					if mesetec.distance(pos,po)>mesetec.mtp_distance then
						minetest.chat_send_player(name, "Error: too faraway (max: " .. mesetec.mtp_distance ..", current: " .. (math.floor(mesetec.distance(pos,po)+0.5)) .. ")")
					else
						meta:set_string("data",po1)
						minetest.chat_send_player(name, "Target set!")

						if minetest.get_node(po).name~="mesetec:mtptarget" then
							minetest.chat_send_player(name, "Place a mese teleport target on the position")
						end
					end
					return true
				else
					minetest.chat_send_player(name, "Error: void position")
					return false
				end
			end
		end
		return true

	elseif form=="mesetec.form2" then
		if pressed.save  then
			local name=player:get_player_name()
			local pos=mesetec.mtpuser[name]
			mesetec.mtpuser[name]=nil
			if minetest.is_protected(pos, name)==false then
				local meta=minetest.get_meta(pos)
				meta:set_string("data",pressed.data)
				minetest.chat_send_player(name, "Target set!")
				if pressed.data~="" and not minetest.registered_entities[pressed.data] then
					minetest.chat_send_player(name, "The entity does not exist")
				end
				return true
			end
		end
		return true
	elseif form=="mesetec.form3" then
		if pressed.save  then
			local name=player:get_player_name()
			local pos=mesetec.mtpuser[name]
			mesetec.mtpuser[name]=nil
			if minetest.is_protected(pos, name)==false then
				local meta=minetest.get_meta(pos)
				local l=tonumber(pressed.data)
				if not l or l=="" or l<0 then
					l=0
				elseif l>mesetec.maxlight then
					l=mesetec.maxlight
				end
				meta:set_int("light",l)
				meta:set_string("data",1)
				minetest.get_node_timer(pos):start(5)
				minetest.chat_send_player(name, "Time set!")
				return true
			end
		end
		return true
	end
end)