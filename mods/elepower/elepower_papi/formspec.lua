-- Formspec helpers

ele.formspec = {}
ele.formspec.gui_switcher_icons = {
	[0] = "elepower_gui_check.png",
	"elepower_gui_cancel.png",
	"mesecons_wire_on.png^elepower_gui_mese_mask.png^\\[makealpha\\:255,0,0",
	"mesecons_wire_off.png^elepower_gui_mese_mask.png^\\[makealpha\\:255,0,0",
}

function ele.formspec.state_switcher(x, y, state)
	if not state then state = 0 end
	local icon = ele.formspec.gui_switcher_icons[state]
	local statedesc = ele.default.states[state]

	if statedesc then
		statedesc = statedesc.d
	else
		statedesc = ""
	end
	statedesc = statedesc .. "\nPress to toggle"

	return "image_button["..x..","..y..";1,1;"..icon..";cyclestate;]"..
		"tooltip[cyclestate;"..statedesc.."]"
end

function ele.formspec.create_bar(x, y, metric, color, small)
	if not metric or type(metric) ~= "number" or metric < 0 then metric = 0 end

	local width = 1
	local gauge = "image[0,0;1,2.8;elepower_gui_gauge.png]"

	-- Smaller width bar
	if small then
		width = 0.25
		gauge = ""
	end

	return "image["..x..","..y..";"..width..",2.8;elepower_gui_barbg.png"..
		"\\^[lowpart\\:"..metric.."\\:elepower_gui_bar.png\\\\^[multiply\\\\:"..color.."]"..
		gauge
end

function ele.formspec.power_meter(capacitor)
	if not capacitor then
		capacitor = { capacity = 8000, storage = 0, usage = 0 }
	end

	local pw_percent = math.floor(100 * capacitor.storage / capacitor.capacity)
	local usage = capacitor.usage
	if not usage then
		usage = 0
	end

	return ele.formspec.create_bar(0, 0, pw_percent, "#00a1ff") ..
		"tooltip[0,0;1,2.5;"..
		minetest.colorize("#c60303", "Energy Storage\n")..
		minetest.colorize("#0399c6", ele.capacity_text(capacitor.capacity, capacitor.storage))..
		minetest.colorize("#565656", "\nPower Used / Generated: " .. usage .. " " .. ele.unit) .. "]"
end
