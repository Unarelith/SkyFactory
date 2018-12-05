
--[[
	Reactor fitness check:
		8x8x8 area surrounding the core must either contain..
			Water source nodes
			Neutron Absorber (with active medium)
			Fluid Port (with COLD coolant available)
			Also acceptable nodes:
				Any fluid transfer conduit
				Any reactor component
			Unacceptable nodes (These raise heat INSTANTLY!):
				Lava source
				Hot coolant
		..in order to keep the heat below critical. Any other detected node will either be MOLTEN or ACTIVATED (TODO) (you don't want this!)
	Reactor core will be replaced by a molten core when the heat reaches 100%. All components and fuel will be lost!
]]

local AREA_SIZE = 8

local function calculate_fitness(pos)
	-- Calculate the heat sink percentage
	-- Amount of nodes we shall count down from
	local add  = {x = (AREA_SIZE) / 2, y = (AREA_SIZE) / 2, z = (AREA_SIZE) / 2}
	local minp = vector.subtract(pos, add)
	local maxp = vector.add(pos, add)

	-- Get the vmanip mapgen object and the nodes and VoxelArea
	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(minp, maxp)
	local area = VoxelArea:new{MinEdge=e1, MaxEdge=e2}
	local data = manip:get_data()

	local ids = {
		c_water = minetest.get_content_id("default:water_source"),
		c_lava  = minetest.get_content_id("default:lava_source"),
	}

	local excession = 0
	local hu = 0
	local nodes = 0
	for i in area:iter(
		minp.x, minp.y, minp.z,
		maxp.x, maxp.y, maxp.z
	) do
		nodes = nodes + 1
		if data[i] == ids["c_water"] then
			hu = hu - 1
		elseif data[i] == ids["c_lava"] then
			hu = hu + 1
		else
			local dp = minetest.get_name_from_content_id(data[i])
			if excession <= 16 and (ele.helpers.get_item_group(dp, "ele_reactor_component") or
				ele.helpers.get_item_group(dp, "ele_neutron_absorbant") or
				ele.helpers.get_item_group(dp, "elefluid_transport_source") or
				ele.helpers.get_item_group(dp, "elefluid_transport") or
				ele.helpers.get_item_group(dp, "tube") or
				ele.helpers.get_item_group(dp, "tubedevice")) then
				hu = hu - 1
				excession = excession + 1
			elseif ele.helpers.get_item_group(dp, "hot") then
				hu = hu + 1
			else
				hu = hu + 1
			end
		end
	end

	hu = nodes + hu

	return 100 - math.floor(100 * hu / nodes), hu
end

local function fuel_after_depletion(inv)
	local fuel_count = 0
	local change = false

	local list = inv:get_list("fuel")
	for i,stack in pairs(list) do
		local sname = stack:get_name()
		if ele.helpers.get_item_group(sname, "fissile_fuel") then
			local stdef = minetest.registered_items[sname]
			if stdef.fissile_count then
				local meta    = stack:get_meta()
				local fscount = meta:get_int("fission_count")
				if fscount < stdef.fissile_count then
					fscount    = fscount    + 1
					fuel_count = fuel_count + 1

					meta:set_int("fission_count", fscount)
					meta:set_string("description", ("%s\nDepleted: %d "):format(stdef.description,
						math.floor(100 * fscount / stdef.fissile_count)).." %")
				else
					stack = ItemStack("elepower_nuclear:fuel_rod_depleted")
				end
				list[i] = stack
				change = true
			end
		end
	end

	if change then
		inv:set_list("fuel", list)
	end

	return fuel_count
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("fuel")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	if not ele.helpers.get_item_group(stack:get_name(), "fissile_fuel") then
		return 0
	end

	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function get_core_formspec(heat, power)
	local status = "Activate by extracting the control rods"

	if heat > 80 then
		status = "!!! TEMPERATURE CRITICAL !!!"
	elseif heat > 90 then
		status = "!!! REACTOR CRITICAL !!!"
	elseif heat > 95 then
		status = "!!! REACTOR MELTDOWN IMMINENT !!!"
	elseif power > 0 then
		status = "Active reaction chain"
	end

	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[context;fuel;2.5,0;3,3;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		ele.formspec.create_bar(0, 0, power, "#ff0000", true)..
		ele.formspec.create_bar(0.5, 0, heat, "#ffdd11", true)..
		"label[0,3;Power: \t"..power.."%]"..
		"label[0,3.25;Heat: \t"..heat.."%]"..
		"label[0,3.75;".. status .."]"..
		"listring[current_player;main]"..
		"listring[context;fuel]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function get_controller_formspec(rod_pos, selected)
	-- TODO: Reactor-dependent rod count
	local rods  = 4
	local ctrls = {}

	for num, depth in pairs(rod_pos) do
		local xoffset = (num / rods) * 8
		local sel     = ""

		if num == selected then
			sel = " <- "
		end

		local fspc = ("label[%d,0;%s]"):format(xoffset - 0.25, depth .. " %" .. sel)

		fspc = fspc .. ele.formspec.create_bar(xoffset - 1, 0.5, 100 - depth, "#252625", true)

		table.insert(ctrls, fspc)
	end

	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		table.concat( ctrls, "" )..
		"button[0,3.5;1.5,0.5;next;Next]"..
		"button[1.5,3.5;1.5,0.5;prev;Previous]"..
		"button[3.25,3.5;1.5,0.5;stop;SCRAM]"..
		"button[5,3.5;1.5,0.5;up;Raise]"..
		"button[6.5,3.5;1.5,0.5;down;Lower]"..
		"tooltip[next;Select the next control rod]"..
		"tooltip[prev;Select the previous control rod]"..
		"tooltip[stop;Drops all the rods into the reactor core, instantly stopping it]"..
		"tooltip[up;Raise selected control rod]"..
		"tooltip[down;Lower selected control rod]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function get_port_formspec(cool, hot)
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.fluid_bar(0, 0, cool)..
		ele.formspec.fluid_bar(7, 0, hot)..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function reactor_core_timer(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()
	local headless = false
	local fuel_reactor = 0

	-- SAFEGUARD: Expect a controller to be above the core
	local controller_pos  = {x = pos.x, y = pos.y + 1, z = pos.z}
	local controller_node = minetest.get_node_or_nil(controller_pos)
	if not controller_node or controller_node.name ~= "elepower_nuclear:fission_controller" then
		-- Don't do anything without a head
		headless = true
	end

	local controller = minetest.get_meta(controller_pos)

	-- Only read area ever so often
	-- Calculate the absorbance of heat around the core
	local hp = meta:get_int("absorbance")
	local absorb_tick = meta:get_int("absorb_tick")
	if absorb_tick > 10 then
		hp = calculate_fitness(pos)
		absorb_tick = 0
	else
		absorb_tick = absorb_tick + 1
	end

	meta:set_int("absorb_tick", absorb_tick)
	meta:set_int("absorbance", hp)

	-- Get reactor power setting
	local power_setting_target = controller:get_int("setting")
	local power_setting        = meta:get_int("setting")

	-- Do nothing
	if headless then
		power_setting = 0
	else
		if not (power_setting_target == 0 and power_setting == 0) then
			-- Decrease or increase power
			if power_setting_target > power_setting then
				power_setting = power_setting + 1
			elseif power_setting_target < power_setting then
				power_setting = power_setting - 5
			end

			if power_setting < 0 then
				power_setting = 0
			elseif power_setting > 100 then
				power_setting = 100
			end
		end
	end

	if power_setting > 0 then
		fuel_reactor = fuel_after_depletion(inv)
		if fuel_reactor == 0 then
			-- Enforce zero power setting when no fuel present
			power_setting = 0
		end
	end

	-- Set power setting
	meta:set_int("setting", power_setting)

	-- Get reactor heat
	local heat = meta:get_int("heat")

	-- Calculate heat
	if hp < 75 and power_setting > 0 then
		heat = heat + (math.floor(((100-(hp/100))*power_setting)) + 1)
	elseif power_setting > 5 then
		local ceiling = math.floor(power_setting / 2)
		if heat ~= ceiling then
			if heat > ceiling then
				heat = heat - 1
			else
				heat = heat + fuel_reactor
			end
		end
	elseif heat > 0 then
		heat = heat - 1
	end

	if heat >= 100 then
		-- TODO: Melt
		print("It ded.")
		minetest.set_node(pos, {name = "air"})
		return false
	end

	-- Nothing left to do in this timer, exit
	if power_setting == 0 and heat == 0 then
		meta:set_int("heat", heat)
		meta:set_string("formspec", get_core_formspec(heat, power_setting))
		return false
	end

	-- Expect a fluid port below the core
	-- TODO: Allow multiple fluid ports in the core's affected area
	local fluid_port_pos  = {x = pos.x, y = pos.y - 1, z = pos.z}
	local fluid_port_node = minetest.get_node_or_nil(fluid_port_pos)
	if fluid_port_node ~= nil and fluid_port_node.name == "elepower_nuclear:reactor_fluid_port" then
		local fpmeta = minetest.get_meta(fluid_port_pos)

		if fpmeta:get_int("burst") == 0 and heat > 0 then
			fpmeta:set_int("burst", 1)
			minetest.get_node_timer(fluid_port_pos):start(1.0)
			heat = heat - 1
		end
	end

	meta:set_int("heat", heat)
	meta:set_string("formspec", get_core_formspec(heat, power_setting))

	return true
end

local function reactor_controller_timer(pos)
	local meta     = minetest.get_meta(pos)
	local settings = {}
	local averg    = 0

	for i = 1, 4 do
		table.insert(settings, meta:get_int("c" .. i))
		averg = averg + settings[i]
	end

	meta:set_int("setting", 100 - (averg / 4))
	meta:set_string("formspec", get_controller_formspec(settings, meta:get_int("selected")))

	-- Ping the core
	local core_pos  = {x = pos.x, y = pos.y - 1, z = pos.z}
	local core_node = minetest.get_node_or_nil(core_pos)
	if core_node and core_node.name == "elepower_nuclear:fission_core" then
		local timer = minetest.get_node_timer(core_pos)
		if not timer:is_started() then
			timer:start(1.0)
		end
	end

	return false
end

local function reactor_controller_manage(pos, formname, fields, sender)
	if sender and sender ~= "" and minetest.is_protected(pos, sender:get_player_name()) then
		return
	end

	local meta     = minetest.get_meta(pos)
	local selected = meta:get_int("selected")
	local change   = false

	if fields["next"] then
		selected = selected + 1
		if selected > 4 then
			selected = 1
		end

		meta:set_int("selected", selected)
		change = true
	elseif fields["prev"] then
		selected = selected - 1
		if selected == 0 then
			selected = 4
		end

		meta:set_int("selected", selected)
		change = true
	elseif fields["stop"] then
		for i = 1, 4 do
			meta:set_int("c" .. i, 100)
		end
		change = true
	elseif fields["up"] then
		local sl = meta:get_int("c"..selected)
		sl = sl - 10

		if sl <= 0 then
			sl = 0
		end

		meta:set_int("c"..selected, sl)
		change = true
	elseif fields["down"] then
		local sl = meta:get_int("c"..selected)
		sl = sl + 10

		if sl >= 100 then
			sl = 100
		end

		meta:set_int("c"..selected, sl)
		change = true
	end

	if change then
		minetest.get_node_timer(pos):start(0.2)
	end
end

local function reactor_port_timer(pos)
	local refresh = false
	local meta = minetest.get_meta(pos)
	local cool = fluid_lib.get_buffer_data(pos, "cool")
	local hot  = fluid_lib.get_buffer_data(pos, "hot")

	local heat_burst = meta:get_int("burst")
	if heat_burst > 0 then
		-- Convert a bucket of cold coolant into hot coolant

		local coolant = math.min(cool.amount, 1000)
		if coolant > 0 and hot.amount + coolant < hot.capacity then
			meta:set_int("burst", 0)

			cool.amount = cool.amount - coolant
			hot.amount  = hot.amount  + coolant

			refresh = true

			meta:set_string("cool_fluid", "elepower_nuclear:coolant_source")
			meta:set_string("hot_fluid", "elepower_nuclear:hot_coolant_source")

			meta:set_int("cool_fluid_storage", cool.amount)
			meta:set_int("hot_fluid_storage",  hot.amount)
		end
	end

	meta:set_string("formspec", get_port_formspec(cool, hot))

	return refresh
end

-- Reactor Core
ele.register_base_device("elepower_nuclear:fission_core", {
	description = "Fission Reactor Core",
	groups = {
		cracky = 3,
		ele_reactor_core = 1,
		ele_reactor_component = 1,
	},
	tiles = {
		"elenuclear_fission_core_top.png",  "elepower_lead_block.png",  "elenuclear_fission_core_side.png",
		"elenuclear_fission_core_side.png", "elenuclear_fission_core_side.png", "elenuclear_fission_core_side.png",
	},
	on_timer = reactor_core_timer,
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()

		inv:set_size("fuel", 9)
		meta:set_int("absorb_tick", 11)

		meta:set_string("formspec", get_core_formspec(0,0,false))
	end,
	can_dig = can_dig,
	allow_metadata_inventory_put  = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = ele.default.allow_metadata_inventory_take,

	on_metadata_inventory_move = ele.default.metadata_inventory_changed,
	on_metadata_inventory_put  = ele.default.metadata_inventory_changed,
	on_metadata_inventory_take = ele.default.metadata_inventory_changed,
})

-- Reactor Control
ele.register_base_device("elepower_nuclear:fission_controller", {
	description = "Fission Control Module\nPlace me on top of a Fission Reactor Core",
	groups = {
		cracky = 3,
		ele_reactor_component = 1,
	},
	tiles = {
		"elenuclear_fission_core_top.png",  "elepower_lead_block.png",  "elenuclear_fission_controller_side.png",
		"elenuclear_fission_controller_side.png", "elenuclear_fission_controller_side.png", "elenuclear_fission_controller_side.png",
	},
	on_timer = reactor_controller_timer,
	on_receive_fields = reactor_controller_manage,
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()

		meta:set_int("c1", 100)
		meta:set_int("c2", 100)
		meta:set_int("c3", 100)
		meta:set_int("c4", 100)

		meta:set_int("setting", 0)
		meta:set_int("selected", 1)

		meta:set_string("formspec", get_controller_formspec({100, 100, 100, 100}, 1))
	end
})

-- Reactor Fluid Port
ele.register_base_device("elepower_nuclear:reactor_fluid_port", {
	description = "Reactor Fluid Port\nPlace me on the bottom of a Fission Reactor Core",
	groups = {
		cracky = 3,
		ele_reactor_component = 1,
		ele_port = 1,
		fluid_container = 1,
	},
	tiles = {
		"elenuclear_machine_top.png",  "elepower_lead_block.png",  "elenuclear_machine_side.png^elepower_power_port.png",
		"elenuclear_machine_side.png^elepower_power_port.png", "elenuclear_machine_side.png^elepower_power_port.png",
		"elenuclear_machine_side.png^elepower_power_port.png",
	},
	on_timer = reactor_port_timer,
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)

		meta:set_string("cool_fluid", "elepower_nuclear:coolant_source")
		meta:set_string("hot_fluid", "elepower_nuclear:hot_coolant_source")

		meta:set_string("formspec", get_port_formspec())
	end,
	fluid_buffers = {
		cool = {
			capacity  = 16000,
			accepts   = {"default:water_source", "elepower_nuclear:coolant_source"},
			drainable = false,
		},
		hot = {
			capacity  = 16000,
			accepts   = {"elepower_nuclear:hot_coolant_source"},
			drainable = true,
		}
	},
})

-- Load reactor cores
minetest.register_lbm({
    label = "Refresh Reactors on load",
    name = "elepower_nuclear:fission_core",
    nodenames = {"elepower_nuclear:fission_core"},
    run_at_every_load = true,
    action = function (pos)
		minetest.get_node_timer(pos):start(1.0)
    end,
})
