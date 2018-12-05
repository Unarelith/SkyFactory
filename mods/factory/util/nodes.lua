function factory.swap_node(pos,name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos,node)
end

function factory.get_objects_with_square_radius(pos, rad)
  rad = rad + .5;
  local objs = {}
  for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, math.sqrt(3)*rad)) do
    if not object:is_player()
    and object:get_luaentity()
    and (object:get_luaentity().name == "__builtin:item" or object:get_luaentity().name == "factory:moving_item") then
      local opos = object:getpos()
      if pos.x - rad <= opos.x and opos.x <= pos.x + rad
      and pos.y - rad <= opos.y and opos.y <= pos.y + rad
      and pos.z - rad <= opos.z and opos.z <= pos.z + rad then
        objs[#objs + 1] = object
      end
    end
  end
  return objs
end

function factory.get_node_name(node)
	local nname
	if type(node) == "string" then
		nname = node
	elseif type(node) == "table" then
		if node.name then
			nname = node.name
		elseif node.x then
			nname = minetest.get_node(node).name
		end
	end
	return nname
end

function factory.has_src_input(node)
	local nname = factory.get_node_name(node)
	if minetest.get_item_group(nname, "factory_src_input") > 0 then
		return true
	elseif nname == "default:furnace" or nname == "default:furnace_active" then
		return true
	end
	return false
end

function factory.has_fuel_input(node)
	local nname = factory.get_node_name(node)
	if minetest.get_item_group(nname, "factory_fuel_input") > 0 then
		return true
	elseif nname == "default:furnace" or nname == "default:furnace_active" then
		return true
	end
	return false
end

function factory.has_dst_output(node)
	local nname = factory.get_node_name(node)
	if minetest.get_item_group(nname, "factory_dst_output") > 0 then
		return true
	elseif nname == "default:furnace" or nname == "default:furnace_active" then
		return true
	end
	return false
end
