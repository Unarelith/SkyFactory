
local function get_formspec(power, percent, buffer, state)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		ele.formspec.state_switcher(3.5, 1.5, state)..
		ele.formspec.fluid_bar(7, 0, buffer)..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		default.get_hotbar_bg(0, 4.25)
end

ele.register_fluid_generator("elepower_machines:steam_turbine", {
	description = "Steam Turbine",
	ele_usage = 128,
	tiles = {
		"elepower_machine_top.png^elepower_power_port.png", "elepower_machine_base.png", "elepower_machine_side.png",
		"elepower_machine_side.png", "elepower_turbine_side.png", "elepower_turbine_side.png",
	},
	ele_active_node = true,
	ele_active_nodedef = {
		tiles = {
			"elepower_machine_top.png^elepower_power_port.png", "elepower_machine_base.png", "elepower_machine_side.png",
			"elepower_machine_side.png", "elepower_turbine_side.png", "elepower_turbine_side.png",
		},
	},
	fluid_buffers = {
		steam = {
			capacity  = 8000,
			accepts   = {"elepower_dynamics:steam"},
			drainable = false
		}
	},
	tube = false,
	ele_no_automatic_ports = true,
	fuel_burn_time = 2,
	get_formspec = get_formspec,
})
