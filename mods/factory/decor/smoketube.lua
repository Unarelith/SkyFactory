minetest.register_node("factory:smoke_tube", {
	drawtype = "nodebox",
	tiles = {"factory_machine_brick_1.png"},
	paramtype = "light",
	description = factory.S("Smoke Tube"),
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125,-0.5,0.3125,0.125,0.5,0.375},
			{-0.125,-0.5,-0.375,0.125,0.5,-0.3125},
			{0.3125,-0.5,-0.125,0.375,0.5,0.125},
			{-0.375,-0.5,-0.125,-0.3125,0.5,0.125},
			{0.125,-0.5,0.25,0.25,0.5,0.3125},
			{0.25,-0.5,0.125,0.3125,0.5,0.25},
			{0.25,-0.5,-0.25,0.3125,0.5,-0.125},
			{0.125,-0.5,-0.3125,0.25,0.5,-0.25},
			{-0.25,-0.5,-0.3125,-0.125,0.5,-0.25},
			{-0.3125,-0.5,-0.25,-0.25,0.5,-0.125},
			{-0.3125,-0.5,0.125,-0.25,0.5,0.25},
			{-0.25,-0.5,0.25,-0.125,0.5,0.3125},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.375,-0.5,-0.375,0.375,0.5,0.375},
		}
	},
})

factory.smoke_spawners = {}

function get_smoke_spawner_at(pos)
	for _,sp in pairs(factory.smoke_spawners) do
		if vector.equals(sp.pos,pos) then
			return sp
		end
	end
end

function factory.start_smoke(pos,pressure,time)
	if get_smoke_spawner_at(pos) then return false end
	local yv = pressure or 1
	local id = minetest.add_particlespawner({
		amount = 4,
		time = time or 0,
		minpos = {x = pos.x - 0.2, y = pos.y + 0.3, z = pos.z - 0.2},
		maxpos = {x = pos.x + 0.2, y = pos.y + 0.6, z = pos.z + 0.2},
		minvel = {x=-0.4, y=yv, z=-0.4},
		maxvel = {x=0.4, y=yv*2, z=0.4},
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 0.8,
		maxexptime = 2,
		minsize = 2,
		maxsize = 4,
		collisiondetection = false, --perhaps
		vertical = false,
		texture = "factory_smoke.png",
	})
	if time == 0 or time == nil then
		table.insert(factory.smoke_spawners, {pos = pos, id = id})
	end
	return true
end

function factory.stop_smoke(pos)
	for i,sp in pairs(factory.smoke_spawners) do
		if vector.equals(sp.pos,pos) then
			minetest.delete_particlespawner(sp.id)
			factory.smoke_spawners[i] = nil
		end
	end
end

function factory.get_smoke_on_tube(machine_pos)
	for i=1,7 do
		local pos = vector.add(machine_pos,{x=0,y=i,z=0})
		if get_smoke_spawner_at(pos) then
			return pos
		end
	end
end

function factory.smoke_on_tube(machine_pos, active)
	local pos
	local height = 0
	for i=1,7 do -- SMOKE TUBE CHECK
		pos = vector.add(machine_pos,{x=0,y=i,z=0})
		local dn = minetest.get_node(pos)
		if dn.name == "factory:smoke_tube" then
			height = height + 1
		else break end
	end
	pos = vector.add(machine_pos,{x=0,y=height,z=0})

	local last_smoke = factory.get_smoke_on_tube(machine_pos)
	if last_smoke then
		if not vector.equals(last_smoke,pos) then
			factory.log.info("smoking place changed %s",minetest.pos_to_string(pos))
			factory.stop_smoke(last_smoke)
			return factory.smoke_on_tube(machine_pos, active)
		end
	end

	if minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name ~= "air" then
		if last_smoke then
			factory.stop_smoke(last_smoke)
		end
		return false
	end

	if height < 2 then
		if last_smoke then
			factory.stop_smoke(last_smoke)
		end
		return false
	else
		if active then
			factory.start_smoke(pos)
			return true
		else
			factory.stop_smoke(pos)
			return true
		end
	end
end