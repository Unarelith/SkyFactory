
-- Fluid bar for formspec
function ele.formspec.fluid_bar(x, y, fluid_buffer)
	local texture = "default_water.png"
	local metric  = 0
	local tooltip = ("tooltip[%d,%d;1,2.5;%s]"):format(x, y, "Empty Buffer")

	if fluid_buffer and fluid_buffer.fluid and fluid_buffer.fluid ~= "" and
		minetest.registered_nodes[fluid_buffer.fluid] ~= nil then
		texture = minetest.registered_nodes[fluid_buffer.fluid].tiles[1]
		if type(texture) == "table" then
			texture = texture.name
		end

		local fdesc = fluid_lib.cleanse_node_description(fluid_buffer.fluid)
		metric  = math.floor(100 * fluid_buffer.amount / fluid_buffer.capacity)
		tooltip = ("tooltip[%d,%d;1,2.5;%s\n%s / %s %s]"):format(x, y, fdesc, 
			ele.helpers.comma_value(fluid_buffer.amount), ele.helpers.comma_value(fluid_buffer.capacity), fluid_lib.unit)
	end

	return "image["..x..","..y..";1,2.8;elepower_gui_barbg.png"..
		   "\\^[lowpart\\:"..metric.."\\:"..texture.."\\\\^[resize\\\\:64x128]"..
		   "image["..x..","..y..";1,2.8;elepower_gui_gauge.png]"..
		   tooltip
end
