
local function get_formspec(heat, cold, water, steam)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.fluid_bar(0, 0, heat)..
		ele.formspec.fluid_bar(1, 0, cold)..
		"image[3.5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		ele.formspec.fluid_bar(6, 0, water)..
		ele.formspec.fluid_bar(7, 0, steam)..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local heat_recipes = {
	["elepower_nuclear:hot_coolant_source"] = {
		out = "elepower_nuclear:coolant_source",
		factor = 1,
	},
	["elepower_nuclear:helium_plasma"] = {
		out = "elepower_nuclear:helium",
		factor = 8,
	},
}

local function heat_exchanger_timer(pos)
	local meta = minetest.get_meta(pos)
	local change = false

	local heat  = fluid_lib.get_buffer_data(pos, "heat")
	local cold  = fluid_lib.get_buffer_data(pos, "cold")
	local water = fluid_lib.get_buffer_data(pos, "water")
	local steam = fluid_lib.get_buffer_data(pos, "steam")

	while true do
		if heat.amount < 1000 or heat.fluid == "" or not heat_recipes[heat.fluid] then
			break
		end

		-- See if we have enough hot coolant
		if heat.amount >= 1000 and heat.fluid ~= "" then
			local damnt = heat_recipes[heat.fluid]
			local water_convert = math.min(water.amount, 1000 * damnt.factor)

			if cold.fluid ~= damnt.fluid and cold.fluid ~= "" then
				break
			end

			if steam.amount + water_convert > steam.capacity then
				water_convert = steam.capacity - steam.amount
			end

			if water_convert > 0 and cold.amount + 1000 < cold.capacity then
				-- Conversion
				heat.amount = heat.amount - 1000
				cold.amount = cold.amount + 1000

				water.amount = water.amount - water_convert
				steam.amount = steam.amount + water_convert

				cold.fluid = damnt.out
				change = true
			end
		end

		break
	end

	if change then
		meta:set_string("cold_fluid", cold.fluid)
		meta:set_string("steam_fluid", "elepower_dynamics:steam")

		meta:set_int("heat_fluid_storage", heat.amount)
		meta:set_int("cold_fluid_storage", cold.amount)

		meta:set_int("water_fluid_storage", water.amount)
		meta:set_int("steam_fluid_storage", steam.amount)
	end

	meta:set_string("formspec", get_formspec(heat, cold, water, steam))

	return change
end

ele.register_machine("elepower_nuclear:heat_exchanger", {
	description = "Shielded Heat Exchanger\nFor use in nuclear power plants",
	tiles = {
		"elenuclear_machine_top.png",  "elepower_lead_block.png",  "elenuclear_machine_side.png",
		"elenuclear_machine_side.png", "elenuclear_machine_side.png", "elenuclear_heat_exchanger.png",
	},
	groups = {cracky = 3, fluid_container = 1},
	fluid_buffers = {
		heat = {
			capacity  = 8000,
			accepts   = {"elepower_nuclear:hot_coolant_source", "elepower_nuclear:helium_plasma"},
			drainable = false,
		},
		cold = {
			capacity  = 8000,
			accepts   = {"elepower_nuclear:coolant_source", "elepower_nuclear:helium"},
			drainable = true,
		},
		water = {
			capacity  = 16000,
			accepts   = {"default:water_source"},
			drainable = false,
		},
		steam = {
			capacity  = 16000,
			accepts   = {"elepower_dynamics:steam"},
			drainable = true,
		},
	},
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_formspec())
	end,
	on_timer = heat_exchanger_timer,
})
