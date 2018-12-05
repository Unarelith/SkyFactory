
local S = protector.intllib

-- get static spawn position
local statspawn = minetest.string_to_pos(minetest.settings:get("static_spawnpoint"))
		or {x = 0, y = 2, z = 0}

-- is pvp protection enabled
protector.pvp = minetest.settings:get_bool("protector_pvp")

-- is night-only pvp enabled
protector.night_pvp = minetest.settings:get_bool("protector_night_pvp")

-- disables PVP in your own protected areas
if minetest.settings:get_bool("enable_pvp") and protector.pvp then

	if minetest.register_on_punchplayer then

		minetest.register_on_punchplayer(function(player, hitter,
				time_from_last_punch, tool_capabilities, dir, damage)

			if not player
			or not hitter then
				print(S("[Protector] on_punchplayer called with nil objects"))
			end

			if not hitter:is_player() then
				return false
			end

			-- no pvp at spawn area
			local pos = player:get_pos()

			if pos.x < statspawn.x + protector.spawn
			and pos.x > statspawn.x - protector.spawn
			and pos.y < statspawn.y + protector.spawn
			and pos.y > statspawn.y - protector.spawn
			and pos.z < statspawn.z + protector.spawn
			and pos.z > statspawn.z - protector.spawn then
				return true
			end

			-- do we enable pvp at night time only ?
			if protector.night_pvp then

				-- get time of day
				local tod = minetest.get_timeofday() or 0

				if tod > 0.2 and tod < 0.8 then
					--
				else
					return false
				end
			end

			-- is player being punched inside a protected area ?
			if minetest.is_protected(pos, hitter:get_player_name()) then
				return true
			end

			return false

		end)
	else
		print(S("[Protector] pvp_protect not active, update your version of Minetest"))

	end
else
	print(S("[Protector] pvp_protect is disabled"))
end
