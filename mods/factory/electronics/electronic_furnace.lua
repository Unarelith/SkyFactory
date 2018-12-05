local S = factory.S
local device = factory.electronics.device

function factory.forms.electronic_furnace(item_percent)
	--TODO: fix positions
    local formspec =
	"size[8,8.5]"
	..factory_gui_bg
	..factory_gui_bg_img
	..factory_gui_slots
	.."list[current_name;src;2.75,2.5;1,1;]"
	.."image[3.75,1.5;1,1;gui_ind_furnace_arrow_bg.png^[lowpart:"
	        ..(item_percent*100)..":gui_ind_furnace_arrow_fg.png^[transformR270]"
	.."list[current_name;dst;4.75,0.5;2,2;]"
	.."list[current_player;main;0,4.25;8,1;]"
	.."list[current_player;main;0,5.5;8,3;8]"
	..factory.get_hotbar_bg(0,4.25)
	.."listring[current_name;dst]"
	.."listring[current_player;main]"
	.."listring[current_name;src]"
    return formspec
end

minetest.register_node("factory:electronic_furnace", {
	description = S("Electronic Furnace"),
	--TODO: more recognizable texture
	tiles = {"factory_steel_noise.png^factory_vent_slates.png", "factory_machine_steel_dark.png",
		"factory_steel_noise.png", "factory_steel_noise.png",
		"factory_steel_noise.png^factory_lightning.png", "factory_steel_noise.png^factory_lightning.png"},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3, hot=1 ,factory_electronic = 1, factory_src_input = 1, factory_dst_output = 1},
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", factory.forms.electronic_furnace(0))
		local inv = meta:get_inventory()
		inv:set_size("src", 1)
		inv:set_size("dst", 4)
		device.set_name(meta,S("Electronic Furnace"))
		device.set_energy(meta, 0)
		device.set_max_charge(meta,200)
	end,
	can_dig = function(pos)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("dst") then
			return false
		elseif not inv:is_empty("src") then
			return false
		end
		return true
	end,
	allow_metadata_inventory_put = function(_, listname, _, stack)
		if listname == "src" then
			return stack:get_count()
		elseif listname == "dst" then
			return 0
		end
	end,
	allow_metadata_inventory_move = function(_, _, _, to_list, _, count)
		if to_list == "src" then
			return count
		elseif to_list == "dst" then
			return 0
		end
	end,
	on_push_electricity = function(pos,energy)
		local meta = minetest.get_meta(pos)
		return device.store(meta,energy)
	end
})

minetest.register_abm({
	nodenames = {"factory:electronic_furnace"},
	interval = 1.0,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		local srclist = inv:get_list("src")
		local cooked, aftercooked

		if srclist then
			cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		end

		if cooked == nil or cooked.item:is_empty() then
			device.set_status(meta,S("empty"))
			meta:set_string("formspec", factory.forms.electronic_furnace(0))
			return
		end

		if device.try_use(meta,10) then
			meta:set_float("src_time", meta:get_float("src_time") + 1)
			device.set_status(meta,S("active"))
			local item_percent = meta:get_float("src_time")/cooked.time
			meta:set_string("formspec", factory.forms.electronic_furnace(item_percent))
			if cooked and cooked.item and meta:get_float("src_time") >= cooked.time then
				-- check if there's room for output in "dst" list
				if inv:room_for_item("dst",cooked.item) then
					-- Put result in "dst" list
					inv:add_item("dst", cooked.item)
					-- take stuff from "src" list
					inv:set_stack("src", 1, aftercooked.items[1])
				else
					factory.log.info("Could not insert '"..cooked.item:to_string().."'")
				end
				meta:set_float("src_time", 0)
				meta:set_string("formspec", factory.forms.electronic_furnace(0))
			end
		else
			meta:set_float("src_time", 0)
			device.set_status(meta,S("unpowered"))
		end
	end
})

minetest.register_craft({
	output = "factory:electronic_furnace",
	recipe = {
		{"default:steel_ingot", "default:furnace", "default:steel_ingot"},
		{"default:steel_ingot", "factory:steel_wire", "factory:battery_item"},
		{"default:steel_ingot", "factory:battery_item", "default:steel_ingot"},
	},
})