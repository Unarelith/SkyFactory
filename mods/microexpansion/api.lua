-- microexpansion/api.lua
local BASENAME = "microexpansion"

-- [function] Register Recipe
function microexpansion.register_recipe(output, recipe)
  local function isint(n)
    return n==math.floor(n)
  end

  local function getAmount()
    if isint(recipe[2][1]) then
      local q = recipe[2][1]
      recipe[2][1] = nil
      return q
    else return 1 end
  end

  local function register(amount, recipe)
    minetest.register_craft({
      output = output.." "..amount,
      recipe = recipe,
    })
  end

  local function single()
    register(getAmount(), recipe[2])
  end

  local function multiple()
    for i, item in ipairs(recipe) do
      if i == 0 then return end
      register(getAmount(), recipe[i])
    end
  end

  -- Check type
  if recipe[1] == "single" then single()
  elseif recipe[1] == "multiple" then multiple()
  else return microexpansion.log("invalid recipe for definition "..output..". "..dump(recipe[2])) end
end

-- [function] Register Item
function microexpansion.register_item(itemstring, def)
  -- Set usedfor
  if def.usedfor then
    def.description = def.description .. "\n"..minetest.colorize("grey", def.usedfor)
  end
  -- Update inventory image
  if def.inventory_image then
    def.inventory_image = BASENAME.."_"..def.inventory_image..".png"
  else
    def.inventory_image = BASENAME.."_"..itemstring..".png"
  end

  -- Register craftitem
  minetest.register_craftitem(BASENAME..":"..itemstring, def)

  -- if recipe, Register recipe
  if def.recipe then
    microexpansion.register_recipe(BASENAME..":"..itemstring, def.recipe)
  end
end

-- [function] Register Node
function microexpansion.register_node(itemstring, def)
  -- Set usedfor
  if def.usedfor then
    def.description = def.description .. "\n"..minetest.colorize("grey", def.usedfor)
  end
  -- Update texture
  if auto_complete ~= false then
    for _,i in ipairs(def.tiles) do
      def.tiles[_] = BASENAME.."_"..i..".png"
    end
  end

  -- register craftitem
  minetest.register_node(BASENAME..":"..itemstring, def)

  -- if recipe, register recipe
  if def.recipe then
    microexpansion.register_recipe(BASENAME..":"..itemstring, def.recipe)
  end
end
