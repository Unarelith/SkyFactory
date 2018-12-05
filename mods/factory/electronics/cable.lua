minetest.register_node("factory:cable", {
	description = "cable",
	drawtype = "nodebox",
	tiles = {"factory_belt_bottom_clean.png"},
	groups = {factory_electronic = 1, snappy = 1},
	is_ground_content = false,
	node_box = {
		type = "connected",
		fixed = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
		connect_top = {-0.25,0.25,-0.25,0.25,0.5,0.25},
		connect_bottom = {-0.25,-0.5,-0.25,0.25,-0.25,0.25},
		connect_front = {-0.25,-0.25,-0.5,0.25,0.25,-0.25},
		connect_left = {-0.5,-0.25,-0.25,-0.25,0.25,0.25},
		connect_back = {-0.25,-0.25,0.25,0.25,0.25,0.5},
		connect_right = {0.25,-0.25,-0.25,0.5,0.25,0.25},
	},
	connects_to = {"group:factory_electronic"},
	connect_sides = { "top", "bottom", "front", "left", "back", "right" },
	--[[sounds = {
            footstep = <SimpleSoundSpec>,
            dig = <SimpleSoundSpec>, -- "__group" = group-based sound (default)
            dug = <SimpleSoundSpec>,
            place = <SimpleSoundSpec>,
            place_failed = <SimpleSoundSpec>,
        },]]
	on_push_electricity = function(pos,energy)
		local meta = minetest.get_meta(pos)
		if meta:get_int("distribution_heat") == 0 then
			meta:set_int("distribution_heat",1)
			local remain = factory.electronics.device.distribute(pos,energy)
			meta:set_int("distribution_heat",0)
			return remain
		else
			return energy
		end
	end
})

minetest.register_craft({
	output = 'factory:cable',
	recipe = {
		{"factory:fiber", "factory:copper_wire", "factory:fiber"}
	},
})

minetest.register_lbm({
        label = "cooldown cables",
        name = "factory:cooldown_cables",
        nodenames = {"factory:cable"},
        run_at_every_load = true,
        action = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("distribution_heat",0)
	end,
})