
ele.gases = {}

function ele.register_gas(itemname, name, gas_source, image)
	if itemname ~= nil then
		minetest.register_craftitem(itemname, {
			description = name .. " Gas Container",
			inventory_image = image,
			groups = {gas_container = 1}
		})
	end

	ele.gases[gas_source] = {
		itemname = itemname,
		name = name,
		source = gas_source,
	}
end

function ele.get_gas_for_container(container)
	for src,data in pairs(ele.gases) do
		if data.itemname and data.itemname == container then
			return src
		end
	end
	return nil
end

minetest.register_craftitem("elepower_dynamics:gas_container", {
	description = "Empty Gas Container",
	inventory_image = "elepower_gas_container.png",
	groups = {gas_container = 1}
})

ele.register_gas(nil, "Steam", "elepower_dynamics:steam")

ele.register_gas("elepower_dynamics:hydrogen_container", "Hydrogen",
	"elepower_dynamics:hydrogen", "elepower_gas_hydrogen.png")

ele.register_gas("elepower_dynamics:oxygen_container", "Oxygen",
	"elepower_dynamics:oxygen", "elepower_gas_oxygen.png")

ele.register_gas("elepower_dynamics:nitrogen_container", "Nitrogen",
	"elepower_dynamics:nitrogen", "elepower_gas_nitrogen.png")

