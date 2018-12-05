local S = factory.S
local device = {}

local facedir_to_dir = {
	{x= 0, y=0,  z= 1},
	{x= 1, y=0,  z= 0},
	{x= 0, y=0,  z=-1},
	{x=-1, y=0,  z= 0},
	{x= 0, y=-1, z= 0},
	{x= 0, y=1,  z= 0},
}

function device.set_infotext(meta)
	local desc = meta:get_string("factory_description")
	local status = meta:get_string("factory_status")
	if status ~= "" then
		desc = desc .. "\nstatus: " .. status
	end
	local charge = meta:get_int("factory_energy") .. "/" .. meta:get_int("factory_max_charge")
	meta:set_string("infotext", S("@1charge: @2", desc.."\n", charge))
end

function device.get_energy(meta)
	return meta:get_int("factory_energy")
end

function device.set_energy(meta,value)
	meta:set_int("factory_energy", value)
	device.set_infotext(meta)
end

function device.set_name(meta,device_name)
	meta:set_string("factory_description", device_name)
	device.set_infotext(meta)
end

function device.set_status(meta,status)
	meta:set_string("factory_status", status)
	device.set_infotext(meta)
end

function device.set_max_charge(meta,max_charge)
	meta:set_int("factory_max_charge", max_charge)
	device.set_infotext(meta)
end

function device.get_max_charge(meta)
	return meta:get_int("factory_max_charge")
end

function device.store(meta, push_energy)
	local energy = device.get_energy(meta)
	local max_energy = device.get_max_charge(meta)
	local taken = math.min(push_energy, max_energy - energy)
	device.set_energy(meta, taken + energy)
	return push_energy - taken
end

function device.try_use(meta,energy_amount)
	local energy = device.get_energy(meta)
	if energy >= energy_amount then
		device.set_energy(meta, energy - energy_amount)
		return true
	else
		return false
	end
end

function factory.electronics.is_device(node)
	local nname = factory.get_node_name(node)
	return minetest.get_item_group(nname, "factory_electronic") > 0
end

function device.distribute(pos,energy_amount)
	local remain = energy_amount
	for _,dir in pairs(facedir_to_dir) do
		if remain == 0 then
			break
		end
		local nodepos = vector.add(pos,dir)
		local node = minetest.get_node(nodepos)
		if factory.electronics.is_device(node) then
			local nodedef = minetest.registered_nodes[node.name]
			if nodedef then
				local pushfunc = nodedef.on_push_electricity
				if pushfunc then
					remain = pushfunc(nodepos,remain)
				end
			end
		end
	end
	return remain
end

factory.electronics.device = device