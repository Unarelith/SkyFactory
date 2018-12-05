
local S = protector.intllib

protector.removal_names = ""
protector.replace_names = ""

minetest.register_chatcommand("protector_remove", {
	params = "<names list>",
	description = S("Remove Protectors around players (separate names with spaces)"),
	privs = {server = true},
	func = function(name, param)

		if not param or param == "" then

			minetest.chat_send_player(name,
				"Protector Names to remove: "
				.. protector.removal_names)

			return
		end

		if param == "-" then

			minetest.chat_send_player(name,
				S("Name List Reset"))

			protector.removal_names = ""

			return
		end

		protector.removal_names = param

	end,
})


minetest.register_chatcommand("protector_replace", {
	params = "<owner name> <name to replace with>",
	description = S("Replace Protector Owner with name provided"),
	privs = {server = true},
	func = function(name, param)

		-- reset list to empty
		if param == "-" then

			minetest.chat_send_player(name, S("Name List Reset"))

			protector.replace_names = ""

			return
		end

		-- show name info
		if param == ""
		and protector.replace_names ~= "" then

			local names = protector.replace_names:split(" ")

			minetest.chat_send_player(name,
				"Replacing Protector name '" .. (names[1] or "")
				.. "' with '" .. (names[2] or "").. "'")

			return
		end

		protector.replace_names = param

	end,
})


minetest.register_abm({
	nodenames = {"protector:protect", "protector:protect2"},
	interval = 8,
	chance = 1,
	catch_up = false,
	action = function(pos, node)

		if protector.removal_names == ""
		and protector.replace_names == "" then
			return
		end

		local meta = minetest.get_meta(pos) ; if not meta then return end
		local owner = meta:get_string("owner")
		--local members = meta:get_string("members")

		if protector.removal_names ~= "" then

			local names = protector.removal_names:split(" ")

			for _, n in pairs(names) do

				if n == owner then
					minetest.set_node(pos, {name = "air"})
				end
			end
		end

		if protector.replace_names ~= "" then

			local names = protector.replace_names:split(" ")

			if names[1] and names[2] and owner == names[1] then

				meta:set_string("owner", names[2])
				meta:set_string("infotext", "Protection (owned by " .. names[2] .. ")")
			end

		end
	end
})


-- show protection areas of nearby protectors owned by you (thanks agaran)
minetest.register_chatcommand("protector_show", {
	params = "",
	description = "Show protected areas of your nearby protectors",
	privs = {},
	func = function(name, param)

		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		local r = protector.radius -- max protector range.

		-- find the protector nodes
		local pos = minetest.find_nodes_in_area(
			{x = pos.x - r, y = pos.y - r, z = pos.z - r},
			{x = pos.x + r, y = pos.y + r, z = pos.z + r},
			{"protector:protect", "protector:protect2"})

		local meta, owner

		-- show a maximum of 5 protected areas only
		for n = 1, math.min(#pos, 5) do

			meta = minetest.get_meta(pos[n])
			owner = meta:get_string("owner") or ""

			if owner == name then
				minetest.add_entity(pos[n], "protector:display")
			end
		end
	end
})
