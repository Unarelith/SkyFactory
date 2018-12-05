-- Nuclear fuel enrichment plant

local function get_formspec(craft_type, power, progress, pos)
	if not progress then progress = 0 end
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		ele.formspec.power_meter(power)..
		"list[context;src;2,0.75;1,1;]"..
		"image[3.5,0.75;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
		(progress)..":gui_furnace_arrow_fg.png^[transformR270]"..
		"list[context;dst;5,0.25;2,2;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"image[7,3;1,1;elenuclear_radioactive.png]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

elepm.register_craft_type("enrichment", {
	description = "Enrichment",
	inputs      = 1,
})

elepm.register_crafter("elepower_nuclear:enrichment_plant", {
	description = "Enrichment Plant",
	craft_type = "enrichment",
	tiles = {
		"elenuclear_machine_top.png",  "elepower_lead_block.png",  "elenuclear_machine_side.png",
		"elenuclear_machine_side.png", "elenuclear_machine_side.png", "elenuclear_enrichment_plant.png",
	},
	groups = {ele_user = 1, cracky = 3},
	ele_capacity = 64000,
	ele_usage    = 1000,
	ele_inrush   = 8000,
	get_formspec = get_formspec,
})
