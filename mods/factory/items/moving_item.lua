minetest.register_entity("factory:moving_item", {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collisionbox = {0.125, 0.125, 0.125, 0.125, 0.125, 0.125},
		visual = "wielditem",
		visual_size = {x = 0.2, y = 0.2},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
	},

	physical_state = true,
	itemstring = '',
	set_item = function(self, itemstring)
		self.itemstring = itemstring
		local stack = ItemStack(itemstring)
		local count = stack:get_count()
		local max_count = stack:get_stack_max()
		if count > max_count then
			count = max_count
			self.itemstring = stack:get_name().." "..max_count
		end
		local s = 0.15 + 0.15 * (count / max_count)
		local c = 0.8 * s
		local itemtable = stack:to_table()
		local itemname = nil
		if itemtable then
			itemname = stack:to_table().name
		end
		--[[local item_texture = nil
		local item_type = ""
		if minetest.registered_items[itemname] then
			item_texture = minetest.registered_items[itemname].inventory_image
			item_type = minetest.registered_items[itemname].type
		end--]]
		local prop = {
			is_visible = true,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = s, y = s},
			collisionbox = {-c, -c, -c, c, c, c},
			--automatic_rotate = math.pi * 0.2,
		}
		self.object:set_properties(prop)
	end,

	get_staticdata = function(self)
		return minetest.serialize({
			itemstring = self.itemstring
		})
	end,

	on_activate = function(self, staticdata)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				self.itemstring = data.itemstring
			end
		else
			self.itemstring = staticdata
		end
		self.object:set_armor_groups({immortal = 1})
		self:set_item(self.itemstring)
	end,

	on_step = function(self)
		local pos = self.object:getpos()
		local speed = 0.8
		local apos = vector.round(pos)
		apos.y=apos.y+1
		local napos = minetest.get_node(pos)
		if minetest.get_node(apos).name == "factory:upward_vacuum_on" or napos.name == "factory:upward_vacuum_on" then
			local vacpos
			if napos.name == "factory:upward_vacuum_on" then
				vacpos = vector.round(pos)
			else
				vacpos = vector.round(apos)
			end
			local inv = minetest.get_meta(vacpos):get_inventory()
			if ItemStack(self.itemstring):get_name()==inv:get_list("sort")[1]:get_name() then
				local a = minetest.facedir_to_dir(minetest.get_node(vacpos).param2)
				vacpos.y = vacpos.y + 0.15 --correct height
				local targetpos = vector.add(vacpos,a)
				targetpos.y = targetpos.y
				local dir = vector.subtract(targetpos,pos) --distance to the target
				if math.abs(dir.y)>0.1 then
					dir = vector.subtract(vacpos,pos) --distance to the vacuum
					if math.abs(dir.x)>0.1 or math.abs(dir.z)>0.1 then
						dir.y = 0
						dir.x = math.sign(dir.x)
						dir.z = math.sign(dir.z)
					end
				else
					if math.abs(vector.length(dir))<0.001 then
						local stack = ItemStack(self.itemstring)
						minetest.add_item(pos, stack)
						self.object:remove()
					end
				end
				dir=vector.multiply(dir,2) --correct speed
				self.object:setvelocity(vector.divide(dir,speed))
				return
			end
		end
		-- a copy of the facedir so we don't overwrite the facedir table
		local dir = vector.new(minetest.facedir_to_dir(napos.param2))
		if napos.name == "factory:belt" then
			dir.y = math.floor(pos.y + 0.5) + 0.15 - pos.y --target height
			self.object:setvelocity(vector.divide(dir,speed))
		elseif napos.name == "factory:belt_center" then
			dir.y = math.floor(pos.y + 0.5) + 0.15 - pos.y --target height
			if dir.x == 0 then
				dir.x = (math.floor(pos.x + 0.5) - pos.x) * 2
			elseif dir.z == 0 then
				dir.z = (math.floor(pos.z + 0.5) - pos.z) * 2
			end
			self.object:setvelocity(vector.divide(dir,speed))
		elseif napos.name == "factory:queuedarm" or napos.name == "factory:arm" or napos.name == "factory:overflowarm" then
			dir = vector.subtract(vector.round(pos),pos) --distance to the middle
			if math.abs(dir.x)>0.2 or math.abs(dir.z)>0.2 then
				if dir.y~=0.29 then
					self.object:setpos(vector.add(pos,{x=0,y=dir.y+0.19,z=0})) -- correct position
				end
				dir.y=0
			end
			if math.abs(vector.length(dir))<0.001 then
				local stack = ItemStack(self.itemstring)
				minetest.add_item(pos, stack)
				self.object:remove()
			end
			dir=vector.multiply(dir,2) --correct speed
			self.object:setvelocity(vector.divide(dir,speed))
		elseif napos.name:find("factory:") and napos.name:find("taker") then
			dir = vector.multiply(dir,-1) --output direction
			dir.y = (math.floor(pos.y + 0.5) + 0.19 - pos.y) * 8 --target height
			self.object:setvelocity(vector.divide(dir,speed))
		else
			local stack = ItemStack(self.itemstring)
			local veldir = self.object:getvelocity();
			minetest.add_item({x = pos.x + veldir.x / 3, y = pos.y, z = pos.z + veldir.z / 3}, stack)
			self.object:remove()
		end
	end
})

function factory.do_moving_item(pos, item)
	if item==":" or item=="" then return end
	local stack = ItemStack(item)
	local obj = minetest.add_entity(pos, "factory:moving_item")
	obj:get_luaentity():set_item(stack:to_string())
	return obj
end
