
local CAPACITY = 8000

minetest.register_node("elepower_machines:accumulator", {
	description = "Water Accumulator",
	groups = {fluid_container = 1, oddly_breakable_by_hand = 1, cracky = 1},
	tiles = {
		"elepower_machine_top.png^elepower_power_port.png", "elepower_machine_base.png", "elepower_machine_accumulator.png",
		"elepower_machine_accumulator.png", "elepower_machine_accumulator.png", "elepower_machine_accumulator.png",
	},
	fluid_buffers = {
		water = {
			capacity = CAPACITY
		}
	},
	on_construct = function ( pos )
		local meta = minetest.get_meta(pos)
		meta:set_string("water_fluid", "default:water_source")
	end
})

minetest.register_abm({
	nodenames = {"elepower_machines:accumulator"},
	label     = "elefluidAccumulator",
	interval  = 2,
	chance    = 1/5,
	action    = function(pos, node, active_object_count, active_object_count_wider)
		local meta   = minetest.get_meta(pos)
		local buffer = fluid_lib.get_buffer_data(pos, "water")
		if not buffer or buffer.amount == buffer.capacity then return end

		local positions = {
			{x=pos.x+1,y=pos.y,z=pos.z},
			{x=pos.x-1,y=pos.y,z=pos.z},
			{x=pos.x,  y=pos.y,z=pos.z+1},
			{x=pos.x,  y=pos.y,z=pos.z-1},
		}

		local amount = 0
		for _,fpos in pairs(positions) do
			local node = minetest.get_node(fpos)
			if node.name == "default:water_source" then
				amount = amount + 1000
			end
		end

		if amount == 0 then
			meta:set_string("infotext", "Submerge me in water!")
			return
		end

		local give = 0
		if buffer.amount + amount > buffer.capacity then
			give = buffer.capacity - buffer.amount
		else
			give = amount
		end

		buffer.amount = buffer.amount + give

		meta:set_int("water_fluid_storage", buffer.amount)
		meta:set_string("water_fluid", "default:water_source")
		meta:set_string("infotext", fluid_lib.buffer_to_string(buffer))
	end
})

fluid_lib.register_node("elepower_machines:accumulator")
