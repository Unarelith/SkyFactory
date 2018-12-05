-- microexpansion/init.lua
microexpansion = {}
microexpansion.modpath = minetest.get_modpath("microexpansion") -- modpath
local modpath = microexpansion.modpath -- modpath pointer

-- Formspec GUI related stuff
microexpansion.gui_bg = "bgcolor[#080808BB;true]background[5,5;1,1;gui_formbg.png;true]"
microexpansion.gui_slots = "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

-- logger
function microexpansion.log(content, log_type)
  if not content then return false end
  if log_type == nil then log_type = "action" end
  minetest.log(log_type, "[MicroExpansion] "..content)
end

-- Load API
dofile(modpath.."/api.lua")

-------------------
----- MODULES -----
-------------------

local loaded_modules = {}

local settings = Settings(modpath.."/modules.conf"):to_table()

-- [function] Get module path
function microexpansion.get_module_path(name)
  local module_path = modpath.."/modules/"..name

  if io.open(module_path.."/init.lua") then
    return module_path
  end
end

-- [function] Load module (overrides modules.conf)
function microexpansion.load_module(name)
  if loaded_modules[name] ~= false then
    local module_init = microexpansion.get_module_path(name).."/init.lua"

    if module_init then
      dofile(module_init)
      loaded_modules[name] = true
      return true
    else
      microexpansion.log("Invalid module \""..name.."\". The module either does not exist "..
        "or is missing an init.lua file.", "error")
    end
  else
    return true
  end
end

-- [function] Require module (does not override modules.conf)
function microexpansion.require_module(name)
  if settings[name] and settings[name] ~= false then
    return microexpansion.load_module(name)
  end
end

for name,enabled in pairs(settings) do
  if enabled ~= false then
    microexpansion.load_module(name)
  end
end
