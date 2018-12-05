local S = factory.S
local device = factory.electronics.device

function factory.forms.combustion_generator(fuel_percent)
	--TODO: fix positions
    local formspec =
	"size[8,8.5]"
	..factory_gui_bg
	..factory_gui_bg_img
	..factory_gui_slots
	.."list[current_name;src;2.75,2.5;1,1;]"
	.."image[2.75,1.5;1,1;factory_ind_furnace_fire_bg.png^[lowpart:"
		..(100-fuel_percent)..":factory_ind_furnace_fire_fg.png]"
	.."list[current_player;main;0,4.25;8,1;]"
	.."list[current_player;main;0,5.5;8,3;8]"
	..factory.get_hotbar_bg(0,4.25)
	.."listring[current_player;main]"
	.."listring[current_name;src]"
    return formspec
  end

minetest.register_node("factory:combustion_generator", {
	description = S("Combustion Generator"),
	tiles = {"factory_steel_noise.png^factory_smoke_tube_duct.png", "factory_machine_steel_dark.png",
		"factory_steel_noise.png", "factory_steel_noise.png",
		"factory_steel_noise.png^factory_lightning.png", "factory_steel_noise.png^factory_lightning.png"},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3, hot=1 ,factory_electronic = 1, factory_src_input = 1},
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", factory.forms.combustion_generator(100))
		meta:set_float("fuel_time",0.0)
		meta:set_float("fuel_total_time",0.0)
		local inv = meta:get_inventory()
		inv:set_size("src", 1)
		device.set_name(meta,S("Combustion Generator"))
		device.set_energy(meta, 0)
		device.set_max_charge(meta,100)
	end,
	can_dig = function(pos)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("src") then
			return false
		end
		return true
	end,
	allow_metadata_inventory_put = function(_, listname, _, stack)
		if listname == "src" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				return stack:get_count()
			else
				return 0
			end
		end
	end,
})


minetest.register_abm({
	nodenames = {"factory:combustion_generator"},
	interval = 1.0,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
			if not factory.smoke_on_tube(pos, true) then
				device.set_status(meta,S("no smoke tube"))
				meta:set_string("formspec", factory.forms.combustion_generator(100))
				return
			end
			--currently active
			meta:set_float("fuel_time", meta:get_float("fuel_time") + 1)
			device.store(meta, 10)
			local percent = meta:get_float("fuel_time") / meta:get_float("fuel_totaltime") * 100
			meta:set_string("formspec", factory.forms.combustion_generator(percent))
			device.set_energy(meta,device.distribute(pos,factory.electronics.device.get_energy(meta)))
			return
		end

		device.set_energy(meta,device.distribute(pos,factory.electronics.device.get_energy(meta)))

		--gen has eaten up all the fuel
		meta:set_string("formspec", factory.forms.combustion_generator(100))

		--look for more
		local fuellist = inv:get_list("src")
		local fuel, afterfuel
		if fuellist then
			fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
		else
			factory.log.warning("invetory not found for combustion gen at:%s",minetest.pos_to_string(pos))
		end

		if not fuel or fuel.time <= 0 then
			factory.electronics.device.set_status(meta,S("no fuel to burn"))
			factory.smoke_on_tube(pos, false)
			return
		end

		if factory.electronics.device.get_energy(meta) >= device.get_max_charge(meta) then
			factory.electronics.device.set_status(meta,S("fully charged"))
			factory.smoke_on_tube(pos, false)
			return
		end

		if not factory.smoke_on_tube(pos, true) then
			factory.electronics.device.set_status(meta,S("no smoke tube"))
			return
		end

		meta:set_string("fuel_totaltime", fuel.time)
		meta:set_string("fuel_time", 0)

		inv:set_stack("src", 1, afterfuel.items[1])
		factory.electronics.device.set_status(meta,S("active"))
		meta:set_string("formspec", factory.forms.combustion_generator(0))
	end
})

minetest.register_craft({
	output = "factory:combustion_generator",
	recipe = {
		{"default:steel_ingot", "factory:electric_engine", "default:steel_ingot"},
		{"default:steel_ingot", "bucket:bucket_water", "factory:battery_item"},
		{"default:steel_ingot", "default:furnace", "default:steel_ingot"},
	},
})