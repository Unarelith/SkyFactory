-- storage/api.lua

local BASENAME = "microexpansion"

-- [function] register cell
function microexpansion.register_cell(itemstring, def)
  if not def.inventory_image then
    def.inventory_image = itemstring
  end

  -- register craftitem
  minetest.register_craftitem(BASENAME..":"..itemstring, {
    description = def.description,
    inventory_image = BASENAME.."_"..def.inventory_image..".png",
    groups = {microexpansion_cell = 1},
    stack_max = 1,
    microexpansion = {
      base_desc = def.description,
      drive = {
        capacity = def.capacity or 5000,
      },
    },
  })

  -- if recipe, register recipe
  if def.recipe then
    -- if recipe, register recipe
    if def.recipe then
      microexpansion.register_recipe(BASENAME..":"..itemstring, def.recipe)
    end
  end
end

-- [function] Get cell size
function microexpansion.get_cell_size(name)
  local item = minetest.registered_craftitems[name]
  if item then
    return item.microexpansion.drive.capacity
  end
end

-- [function] Calculate max stacks
function microexpansion.int_to_stacks(int)
  return math.floor(int / 99)
end

-- [function] Calculate number of pages
function microexpansion.int_to_pagenum(int)
  return math.floor(microexpansion.int_to_stacks(int) / 32)
end

-- [function] Move items from inv to inv
function microexpansion.move_inv(inv1, inv2)
  local finv, tinv   = inv1.inv, inv2.inv
  local fname, tname = inv1.name, inv2.name

  for i,v in ipairs(finv:get_list(fname) or {}) do
    if tinv and tinv:room_for_item(tname, v) then
      local leftover = tinv:add_item( tname, v )
      finv:remove_item(fname, v)
      if leftover and not(leftover:is_empty()) then
        finv:add_item(fname, v)
      end
    end
  end
end

-- [function] Update cell description
function microexpansion.cell_desc(inv, listname, spos)
  local stack = inv:get_stack(listname, spos)

  if stack:get_name() ~= "" then
    local meta      = stack:get_meta()
    local base_desc = minetest.registered_craftitems[stack:get_name()].microexpansion.base_desc
  	local max_slots = inv:get_size("main")
  	local max_items = math.floor(max_slots * 99)

  	local slots, items = 0, 0
  	-- Get amount of items in drive
  	for i = 1, max_items do
  		local stack = inv:get_stack("main", i)
  		local item = stack:get_name()
  		if item ~= "" then
  			slots = slots + 1
  			local num = stack:get_count()
  			if num == 0 then num = 1 end
  			items = items + num
  		end
    end

    -- Update description
    meta:set_string("description", base_desc.."\n"..
      minetest.colorize("grey", tostring(items).."/"..tostring(max_items).." Items"))
    -- Update stack
    inv:set_stack(listname, spos, stack)
	end
end
