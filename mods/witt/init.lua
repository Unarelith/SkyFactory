local player_to_id_text = {} -- Storage of players so the mod knows what huds to update
local player_to_id_mtext = {}
local player_to_id_image = {}
local player_to_cnode = {} -- Get the current looked at node
local player_to_animtime = {} -- For animation
local player_to_animon = {} -- For disabling animation
local player_to_enabled = {} -- For disabling WiTT

local ypos = 0.1

minetest.register_globalstep(function(dtime) -- This will run every tick, so around 20 times/second
    for _, player in ipairs(minetest:get_connected_players()) do -- Do everything below for each player in-game
        if player_to_enabled[player] == nil then player_to_enabled[player] = true end -- Enable by default
        if not player_to_enabled[player] then return end -- Don't do anything if they have it disabled
        local lookat = get_looking_node(player) -- Get the node they're looking at

        player_to_animtime[player] = math.min((player_to_animtime[player] or 0.4) + dtime, 0.5) -- Animation calculation

        if player_to_animon[player] then -- If they have animation on, display it
            update_player_hud_pos(player, player_to_animtime[player])
        end

        if lookat then
            if player_to_cnode[player] ~= lookat.name then -- Only do anything if they are looking at a different type of block than before
                player_to_animtime[player] = nil -- Reset the animation

                local nodename, mod = "Undefined node", "Undefined mod"
                local node_object = minetest.registered_nodes[lookat.name]
                if node_object then
                    nodename, mod = describe_node(lookat) -- Get the details of the block in a nice looking way
                    player:hud_change(player_to_id_image[player], "text", handle_tiles(node_object)) -- Pass it to handle_tiles which will return a texture of that block (or nothing if it can't create it)
                end

                player:hud_change(player_to_id_text[player], "text", nodename) -- If they are looking at something, display that
                player:hud_change(player_to_id_mtext[player], "text", mod)
            end
            player_to_cnode[player] = lookat.name -- Update the current node
        else
            blank_player_hud(player) -- If they are not looking at anything, do not display the text
            player_to_cnode[player] = nil -- Update the current node
        end

    end
end)

minetest.register_on_joinplayer(function(player) -- Add the hud to all players
    player_to_id_text[player] = player:hud_add({ -- Add the block name text
        hud_elem_type = "text",
        text = "test",
        number = 0xffffff,
        alignment = {x = 1, y = 0},
        position = {x = 0.5, y = ypos},
    })
    player_to_id_mtext[player] = player:hud_add({ -- Add the mod name text
        hud_elem_type = "text",
        text = "test",
        number = 0x2d62b7,
        alignment = {x = 1, y = 0},
        position = {x = 0.5, y = ypos+0.015},
    })
    player_to_id_image[player] = player:hud_add({ -- Add the block image
        hud_elem_type = "image",
        text = "",
        scale = {x = 0.25, y = 0.25},
        alignment = 0,
        position = {x = 0.5, y = ypos},
        offset = {x = -40, y = 0}
    })
end)

minetest.register_chatcommand("wanim", { -- Command to turn witt animations on/off
	params = "<on/off>",
	description = "Turn WiTT animations on/off",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return false end
        player_to_animon[player] = param == "on"
        return true
	end
})

minetest.register_chatcommand("witt", { -- Command to turn witt on/off
	params = "<on/off>",
	description = "Turn WiTT on/off",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return false end
        player_to_enabled[player] = param == "on"
        blank_player_hud(player)
        player_to_cnode[player] = nil
        return true
	end
})

function get_looking_node(player) -- Return the node the given player is looking at or nil
    local lookat
    for i = 0, 10 do -- 10 is the maximum distance you can point to things in creative mode by default
        local lookvector = -- This variable will store what node we might be looking at
            vector.add( -- This add function corrects for the players approximate height
                vector.add( -- This add function applies the camera's position to the look vector
                    vector.multiply( -- This multiply function adjusts the distance from the camera by the iteration of the loop we're in
                        player:get_look_dir(),
                        i -- Goes from 0 to 10
                    ),
                    player:get_pos()
                ),
                vector.new(0, 1.5, 0)
            )
        lookat = minetest.get_node_or_nil( -- This actually gets the node we might be looking at
            lookvector
        ) or lookat
        if lookat ~= nil and lookat.name ~= "air" and lookat.name ~= "walking_light:light" then break else lookat = nil end -- If we *are* looking at something, stop the loop and continue
    end
    return lookat
end

function describe_node(node) -- Return a string that describes the node and mod
    local mod, nodename = minetest.registered_nodes[node.name].mod_origin, minetest.registered_nodes[node.name].description -- Get basic (not pretty) info
    if nodename == "" then -- If it doesn't have a proper name, just use the technical one
        nodename = node.name
    end
    mod = remove_unneeded(capitalize(mod)) -- Make it look good
    nodename = remove_unneeded(capitalize(nodename))
    return nodename, mod
end

function remove_unneeded(str) -- Remove characters like '-' and '_' to make the string look better
    return str:gsub("[_-]", " ")
end

function capitalize(str) -- Capitalize every word in a string, looks good for node names
    return string.gsub(" "..str, "%W%l", string.upper):sub(2)
end

function handle_tiles(node) -- Return an image of the tile
    local tiles = node.tiles

    if tiles then -- Make sure every tile is a string
        for i,v in pairs(tiles) do
            if type(v) == "table" then
                if tiles[i].name then
                    tiles[i] = tiles[i].name
                else
                    return ""
                end
            end
        end

        -- These are the types it can draw correctly
        if node.drawtype == "normal" or node.drawtype == "allfaces" or node.drawtype == "allfaces_optional" or node.drawtype == "glasslike" or node.drawtype == "glasslike_framed" or node.drawtype == "glasslike_framed_optional" then
            if #tiles == 1 then -- This type of block has only 1 image, so it must be on all faces
                return minetest.inventorycube(tiles[1], tiles[1], tiles[1])
            elseif #tiles == 3 then -- This type of block has 3 images, so it's probably 1 on top, 1 on bottom, the rest on the side
                return minetest.inventorycube(tiles[1], tiles[3], tiles[3])
            elseif #tiles == 6 then -- This one has 6 images, so display the ones we can
                return minetest.inventorycube(tiles[1], tiles[6], tiles[5]) -- Not actually sure if 5 is the correct number but it's basically the same thing most of the time
            end
        end
    end

    return "" -- If it can't do anything, return with a blank image
end

function update_player_hud_pos(player, to_x, to_y) -- Change position of hud elements
    to_y = to_y or ypos
    player:hud_change(player_to_id_text[player], "position", {x = to_x, y = to_y})
    player:hud_change(player_to_id_image[player], "position", {x = to_x, y = to_y})
    player:hud_change(player_to_id_mtext[player], "position", {x = to_x, y = to_y+0.015})
end

function blank_player_hud(player) -- Make hud appear blank
    player:hud_change(player_to_id_text[player], "text", "")
    player:hud_change(player_to_id_mtext[player], "text", "")
    player:hud_change(player_to_id_image[player], "text", "")
end

