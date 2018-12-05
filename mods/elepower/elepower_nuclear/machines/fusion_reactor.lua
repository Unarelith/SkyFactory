
local struct_cache = {}

local iC = 1 -- Casing
local iR = 2 -- Controller
local iI = 3 -- Inputs
local iO = 4 -- Outputs
local iE = 5 -- Energy Inputs
local iX = 6 -- Center nodes

-- Width and Height of the structure
local structure_size = 15

-- This is the reactor structure (y 0 to 2)
local reactor_structure = {}

local controller_pos = {x = 7, z = 14}

local reactions = {
	{
		input1 = "elepower_nuclear:deuterium 1000",     -- 1st input fluid
		input2 = "elepower_nuclear:tritium 1000",       -- 2nd input fluid
		output = "elepower_nuclear:helium_plasma 2000", -- output fluid
		power_ignite = 16000, -- ignition cost
		power_upkeep = 1000,  -- reaction sustain cost
		time = 360,           -- reaction time
	}
}

-- Determine the validity of the structure from the position of the controller
local function determine_structure(pos, player)
	local node = minetest.get_node_or_nil(pos)
	if not node then return nil end

	local hsize  = math.floor(structure_size / 2)
	local hindex = {x = hsize, y = 1, z = structure_size}

	-- TODO: Determine build direction
	--local front = ele.helpers.face_front(pos, node.param2)

	-- Load appropriate map piece into memory for easier parsing
	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(vector.subtract(pos, hindex), vector.add(pos, hindex))
	local area = VoxelArea:new{MinEdge=e1, MaxEdge=e2}
	local data = manip:get_data()
	local success = true

	local inputs  = {}
	local outputs = {}
	local power   = {}

	for y = -1, 1 do
		if not success then break end

		local arr = reactor_structure[(y + 2)]

		for i = 1, #arr do
			local ntype = arr[i]
			local indx = i - 1

			if ntype ~= 0 then
				local z = math.floor(indx / structure_size)
				local x = math.floor(indx % structure_size)

				local relX = controller_pos.x - x
				local relZ = controller_pos.z - z

				local scan_pos = vector.add(pos, {x = relX, y = y, z = relZ})
				local index = area:indexp(scan_pos)
				if data[index] ~= ntype then
					if player then
						minetest.chat_send_player(player, ('Incorrect node at %d,%d,%d; expected %s, found %s'):format(
							scan_pos.x,scan_pos.y,scan_pos.z,minetest.get_name_from_content_id(ntype),
							minetest.get_name_from_content_id(data[index])))
					end
					success = false
					break
				end

				if ntype == iI then
					table.insert(inputs, scan_pos)
				elseif ntype == iO then
					table.insert(outputs, scan_pos)
				elseif ntype == iE then
					table.insert(power, scan_pos)
				end
			end
		end
	end

	if success and player then
		minetest.chat_send_player(player, "Multi-node structure complete!")
	end

	return success, inputs, outputs, power
end

local function notify_controller_presence(posi, posj)
	for _, pos in pairs(posi) do
		local meta = minetest.get_meta(pos)
		meta:set_string("ctrl", posj)

		local t = minetest.get_node_timer(pos)
		if not t:is_started() then
			t:start(1.0)
		end
	end
end

local function controller_formspec(in1, in2, out, power, time, state)
	local bar = "image[3.5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"

	if time ~= nil then
		bar = "image[3.5,1;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
			  (time)..":gui_furnace_arrow_fg.png^[transformR270]"
	end

	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		ele.formspec.fluid_bar(1, 0, in1)..
		ele.formspec.fluid_bar(2, 0, in2)..
		bar..
		ele.formspec.fluid_bar(7, 0, out)..
		ele.formspec.state_switcher(7, 2.5, state)
end

local function get_recipe(i1, i2)
	local result = {time = 0}

	for _, d in pairs(reactions) do
		local i1a = ItemStack(d.input1)
		local i2a = ItemStack(d.input2)

		if (i1a:get_name() == i1.fluid and i1.amount >= i1a:get_count()) and
			(i2a:get_name() == i2.fluid and i2.amount >= i2a:get_count()) then
			result = d
			result.out = ItemStack(result.output)
			result.i1 = i1a
			result.i2 = i2a
			break
		end
	end

	return result
end

local function controller_timer(pos)
	local refresh = false
	local meta = minetest.get_meta(pos)

	-- Cache all reactor components
	local cpos = minetest.pos_to_string(pos)
	if not struct_cache[cpos] then
		local st, i, o, p = determine_structure(pos)
		if st then
			struct_cache[cpos] = {
				inputs = i,
				outputs = o,
				power = p,
			}

			notify_controller_presence(i, cpos)
			notify_controller_presence(o, cpos)
			notify_controller_presence(p, cpos)
		else
			return false
		end
	end

	local in1_buffer = fluid_lib.get_buffer_data(pos, "in1")
	local in2_buffer = fluid_lib.get_buffer_data(pos, "in2")
	local out_buffer = fluid_lib.get_buffer_data(pos, "out")

	local capacity   = ele.helpers.get_node_property(meta, pos, "capacity")
	local storage    = ele.helpers.get_node_property(meta, pos, "storage")
	local pow_buffer = {capacity = capacity, storage = storage, usage = 0}

	local time     = meta:get_int("src_time")
	local time_res = meta:get_int("src_time_max")

	-- Deuterium + Tritium -> Helium Plasma
	while true do
		local recipe = get_recipe(in1_buffer, in2_buffer)
		if recipe.time == 0 then break end

		if time_res == 0 then
			if recipe.power_ignite > pow_buffer.storage then
				break
			end

			pow_buffer.storage = pow_buffer.storage - recipe.power_ignite
			pow_buffer.usage = recipe.power_ignite

			time_res = recipe.time
			time = 0
			refresh = true
			break
		end

		-- Cool the reaction down when out of power (aka stop it)
		if recipe.power_upkeep > pow_buffer.storage then
			time = 0
			time_res = 0
			break
		end

		refresh = true
		pow_buffer.storage = pow_buffer.storage - recipe.power_upkeep
		pow_buffer.usage = recipe.power_upkeep

		if time ~= time_res then
			time = time + 1
			break
		end

		if (recipe.out:get_name() ~= out_buffer.fluid and out_buffer.fluid ~= "") or
			((recipe.out:get_count()) + out_buffer.amount > out_buffer.capacity) then
			break
		end

		out_buffer.fluid = recipe.out:get_name()
		out_buffer.amount = out_buffer.amount + recipe.out:get_count()

		in1_buffer.amount = in1_buffer.amount - result.i1:get_count()
		in2_buffer.amount = in2_buffer.amount - result.i2:get_count()

		if in1_buffer.amount == 0 then
			in1_buffer.fluid = ""
		end

		if in2_buffer.amount == 0 then
			in2_buffer.fluid = ""
		end

		time = 0
		time_res = 0
		break
	end

	meta:set_string("in1_fluid", in1_buffer.fluid)
	meta:set_int("in1_fluid_storage", in1_buffer.amount)

	meta:set_string("in2_fluid", in2_buffer.fluid)
	meta:set_int("in2_fluid_storage", in2_buffer.amount)

	meta:set_string("out_fluid", out_buffer.fluid)
	meta:set_int("out_fluid_storage", out_buffer.amount)

	meta:set_int("src_time", time)
	meta:set_int("src_time_max", time_res)

	meta:set_int("storage", pow_buffer.storage)

	local pcrt = 0
	if time_res > 0 then
		pcrt = math.floor(100 * time / time_res)
	end

	meta:set_string("formspec", controller_formspec(in1_buffer, in2_buffer, out_buffer, pow_buffer, 0, pcrt))

	return refresh
end

local function get_port_controller(pos)
	local meta = minetest.get_meta(pos)
	local ctrl = minetest.string_to_pos(meta:get_string("ctrl"))
	if not ctrl then return nil end
	local ctrl_node = minetest.get_node_or_nil(ctrl)

	if not ctrl_node or ctrl_node.name ~= "elepower_nuclear:reactor_controller" then
		return nil
	end

	return ctrl, minetest.get_meta(ctrl)
end

local function port_destruct(pos)
	local meta = minetest.get_meta(pos)
	local ctrl, ctrl_meta = get_port_controller(pos)
	if not ctrl then return nil end

	-- Remove controller's cache entry, forcing it to redetect its structure
	local ctrl_name = minetest.pos_to_string(ctrl)
	if struct_cache[ctrl_name] then
		struct_cache[ctrl_name] = nil
	end

	local t = minetest.get_node_timer(ctrl)
	if not t:is_started() then
		t:start(1.0)
	end
end

-- Transfer power from the power port to the controller
local function power_timer(pos)
	local refresh = false
	local meta = minetest.get_meta(pos)
	local ctrl, ctrl_meta = get_port_controller(pos)

	if not ctrl then
		meta:set_string("No controller found.")
		return false
	end

	local localc = ele.helpers.get_node_property(meta, pos, "capacity")
	local locals = ele.helpers.get_node_property(meta, pos, "storage")

	local remotec = ele.helpers.get_node_property(ctrl_meta, ctrl, "capacity")
	local remotes = ele.helpers.get_node_property(ctrl_meta, ctrl, "storage")

	if remotes ~= remotec then
		if remotes + locals > remotec then
			local add = remotec - remotes
			locals  = locals - add
			remotes = remotes + add
		else
			remotes = remotes + locals
			locals  = 0
		end
		refresh = true
	end

	if refresh then
		meta:set_int("storage", locals)
		ctrl_meta:set_int("storage", remotes)

		local t = minetest.get_node_timer(ctrl)
		if not t:is_started() then
			t:start(1.0)
		end
	end

	meta:set_string("infotext", ("Connected to controller at %s\nLocal %s"):format(
		minetest.pos_to_string(ctrl), ele.capacity_text(localc, locals)))

	return refresh
end

local function port_timer(pos)
	local meta = minetest.get_meta(pos)
	local ctrl = get_port_controller(pos)

	if not ctrl then
		meta:set_string("No controller found.")
		return false
	end

	meta:set_string("infotext", "Connected to controller at " .. minetest.pos_to_string(ctrl))
	return false
end

-----------
-- Nodes --
-----------

minetest.register_node("elepower_nuclear:reactor_controller", {
	description = "Fusion Reactor Controller",
	tiles = {
		"elepower_advblock_combined.png", "elepower_advblock_combined.png", "elepower_advblock_combined.png",
		"elepower_advblock_combined.png", "elepower_advblock_combined.png", "elepower_advblock_combined.png^elenuclear_fusion_controller.png",
	},
	groups = {
		cracky = 2,
	},
	fluid_buffers = {
		in1 = {
			capacity  = 16000,
			accepts   = {"elepower_nuclear:deuterium"},
			drainable = false,
		},
		in2 = {
			capacity  = 16000,
			accepts   = {"elepower_nuclear:tritium", "elepower_nuclear:helium"},
			drainable = false,
		},
		out = {
			capacity  = 16000,
			accepts   = nil,
			drainable = true,
		},
	},
	ele_capacity = 64000,
	on_timer = controller_timer,
	on_punch = function (pos, node, puncher, pointed_thing)
		determine_structure(pos, puncher:get_player_name())
		minetest.node_punch(pos, node, puncher, pointed_thing)
	end,
})

minetest.register_node("elepower_nuclear:reactor_power", {
	description = "Fusion Reactor Power Port (Input)",
	tiles = {
		"elepower_advblock_combined.png", "elepower_advblock_combined.png", "elepower_advblock_combined.png",
		"elepower_advblock_combined.png", "elepower_advblock_combined.png", "elepower_advblock_combined.png^elenuclear_power_port.png^elepower_power_port.png",
	},
	paramtype2 = "facedir",
	groups = {
		cracky = 2,
		ele_machine = 1,
		ele_user = 1,
	},
	ele_capacity = 8000,
	ele_usage = 0,
	ele_inrush = 500,
	on_timer = power_timer,
	on_destruct = port_destruct,
})

minetest.register_node("elepower_nuclear:reactor_fluid", {
	description = "Fusion Reactor Fluid Port (Input)",
	tiles = {
		"elepower_advblock_combined.png", "elepower_advblock_combined.png", "elepower_advblock_combined.png",
		"elepower_advblock_combined.png", "elepower_advblock_combined.png",
		"elepower_advblock_combined.png^elenuclear_fluid_port.png^elepower_power_port.png",
	},
	paramtype2 = "facedir",
	groups = {
		cracky = 2,
		fluid_container = 1,
		tube = 1,
	},
	fluid_buffers = {},
	on_timer = port_timer,
	on_destruct = port_destruct,
	node_io_can_put_liquid = function (pos, node, side)
		return true
	end,
	node_io_can_take_liquid = function (pos, node, side)
		return false
	end,
	node_io_get_liquid_size = function (pos, node, side)
		return 2
	end,
	node_io_get_liquid_name = function(pos, node, side, index)
		local ctrl, ctrl_meta = get_port_controller(pos)
		if not ctrl then return nil end

		return ctrl_meta:get_string("in" .. index .. "_fluid")
	end,
	node_io_get_liquid_stack = function(pos, node, side, index)
		local ctrl, ctrl_meta = get_port_controller(pos)
		if not ctrl then return ItemStack(nil) end

		return ItemStack(ctrl_meta:get_string("in" .. index .. "_fluid") .. " " ..
			ctrl_meta:get_int("in" .. index .. "_fluid_storage"))
	end,
	node_io_accepts_millibuckets = function(pos, node, side) return true end,
	node_io_put_liquid = function(pos, node, side, putter, liquid, millibuckets)
		local ctrl, ctrl_meta = get_port_controller(pos)
		if not ctrl then return nil end

		local buffers = fluid_lib.get_node_buffers(ctrl)
		local leftovers = 0
		for buffer,data in pairs(buffers) do
			if millibuckets == 0 then break end
			local didnt_fit = fluid_lib.insert_into_buffer(ctrl, buffer, liquid, millibuckets)
			millibuckets = millibuckets - (millibuckets - didnt_fit)
			leftovers = leftovers + didnt_fit
		end
		return leftovers
	end,
	node_io_room_for_liquid = function(pos, node, side, liquid, millibuckets)
		local ctrl, ctrl_meta = get_port_controller(pos)
		if not ctrl then return nil end

		local buffers = fluid_lib.get_node_buffers(ctrl)
		local insertable = 0
		for buffer,data in pairs(buffers) do
			local insert = fluid_lib.can_insert_into_buffer(ctrl, buffer, liquid, millibuckets)
			if insert > 0 then
				insertable = insert
				break
			end
		end
		return insertable
	end,
})

minetest.register_node("elepower_nuclear:reactor_output", {
	description = "Fusion Reactor Fluid Port (Output)",
	tiles = {
		"elepower_advblock_combined.png", "elepower_advblock_combined.png", "elepower_advblock_combined.png",
		"elepower_advblock_combined.png", "elepower_advblock_combined.png",
		"elepower_advblock_combined.png^elenuclear_fluid_port_out.png^elepower_power_port.png",
	},
	paramtype2 = "facedir",
	groups = {
		cracky = 2,
		fluid_container = 1,
		tube = 1,
	},
	fluid_buffers = {},
	on_timer = port_timer,
	on_destruct = port_destruct,
	node_io_can_put_liquid = function (pos, node, side)
		return false
	end,
	node_io_can_take_liquid = function (pos, node, side)
		return true
	end,
	node_io_accepts_millibuckets = function(pos, node, side) return true end,
	node_io_take_liquid = function(pos, node, side, taker, want_liquid, want_millibuckets)
		local ctrl, ctrl_meta = get_port_controller(pos)
		if not ctrl then return nil end

		local buffers = fluid_lib.get_node_buffers(ctrl)
		local buffer  = "out"
		local took    = 0
		local name    = ""

		local bfdata = fluid_lib.get_buffer_data(ctrl, buffer)
		local storage = bfdata.amount
		local fluid = bfdata.fluid
		if (fluid == want_liquid or want_liquid == "") and storage >= want_millibuckets then
			name, took = fluid_lib.take_from_buffer(ctrl, buffer, want_millibuckets)
		end

		return {name = name, millibuckets = took}
	end,
	node_io_get_liquid_size = function (pos, node, side)
		return 1
	end,
	node_io_get_liquid_name = function(pos, node, side, index)
		local ctrl, ctrl_meta = get_port_controller(pos)
		if not ctrl then return "" end
		return ctrl_meta:get_string("out_fluid")
	end,
	node_io_get_liquid_stack = function(pos, node, side, index)
		local ctrl, ctrl_meta = get_port_controller(pos)
		if not ctrl then return ItemStack(nil) end

		return ItemStack(ctrl_meta:get_string("out_fluid") .. " " ..
			ctrl_meta:get_int("out_fluid_storage"))
	end,
})

minetest.register_lbm({
	label = "Enable Fusion Reactors on load",
	name = "elepower_nuclear:fusion_reactors",
	nodenames = {"elepower_nuclear:reactor_controller"},
	run_at_every_load = true,
	action = function (pos)
		local t = minetest.get_node_timer(pos)
		if not t:is_started() then
			t:start(1.0)
		end
	end,
})

-- Define reactor structure with Content IDs

iC = minetest.get_content_id("elepower_machines:advanced_machine_block")
iR = minetest.get_content_id("elepower_nuclear:reactor_controller")
iI = minetest.get_content_id("elepower_nuclear:reactor_fluid")
iO = minetest.get_content_id("elepower_nuclear:reactor_output")
iE = minetest.get_content_id("elepower_nuclear:reactor_power")
iX = minetest.get_content_id("elepower_nuclear:fusion_coil")

reactor_structure = {
	{
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  iC, iC, iC, 0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  iC, iC, 0,  0,  0,  iC, iC, 0,  0,  0,  0,
		0,  0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,  0,
		0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,
		0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,
		0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, iC,  0,
		0,  iI, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, iI,  0,
		0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, iC,  0,
		0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,
		0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,
		0,  0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,  0,
		0,  0,  0,  0,  iC, iC, 0,  0,  0,  iC, iC, 0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  iC, iC, iC, 0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	},
	{
		0,  0,  0,  0,  0,  0,  iC, iE, iC, 0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  iC, iC, iX, iX, iX, iC, iC, 0,  0,  0,  0,
		0,  0,  0,  iC, iX, iX, iC, iC, iC, iX, iX, iC, 0,  0,  0,
		0,  0,  iC, iX, iC, iC, 0,  0,  0,  iC, iC, iX, iC, 0,  0,
		0,  iC, iX, iC, 0,  0,  0,  0,  0,  0,  0,  iC, iX, iC, 0,
		0,  iC, iX, iC, 0,  0,  0,  0,  0,  0,  0,  iC, iX, iC, 0,
		iC, iX, iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, iX, iC,
		iE, iX, iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, iX, iE,
		iC, iX, iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, iX, iC,
		0,  iC, iX, iC, 0,  0,  0,  0,  0,  0,  0,  iC, iX, iC, 0,
		0,  iC, iX, iC, 0,  0,  0,  0,  0,  0,  0,  iC, iX, iC, 0,
		0,  0,  iC, iX, iC, iC, 0,  0,  0,  iC, iC, iX, iC, 0,  0,
		0,  0,  0,  iC, iX, iX, iC, iC, iC, iX, iX, iC, 0,  0,  0,
		0,  0,  0,  0,  iC, iC, iX, iX, iX, iC, iC, 0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  iC, iR, iC, 0,  0,  0,  0,  0,  0,
	},
	{
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  iC, iC, iC, 0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  iC, iC, 0,  0,  0,  iC, iC, 0,  0,  0,  0,
		0,  0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,  0,
		0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,
		0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,
		0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, iC,  0,
		0,  iO, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, iO,  0,
		0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, iC,  0,
		0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,
		0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,
		0,  0,  0,  iC, 0,  0,  0,  0,  0,  0,  0,  iC, 0,  0,  0,
		0,  0,  0,  0,  iC, iC, 0,  0,  0,  iC, iC, 0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  iC, iC, iC, 0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	}
}
