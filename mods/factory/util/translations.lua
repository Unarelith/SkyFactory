if not minetest.translate then
	factory.log.warning("Minetest translator not found!")
	function factory.translate(_, str, ...)
		local arg = {n=select('#', ...), ...}
		return str:gsub("@(.)", function (matched)
			local c = string.byte(matched)
			if string.byte("1") <= c and c <= string.byte("9") then
				return arg[c - string.byte("0")]
			else
				return matched
			end
		end)
	end
	if minetest.get_translator then
		factory.log.warning("minetest.translate not found, this is really strange...")
		factory.S = minetest.get_translator("factory")
	else
		function factory.get_translator(textdomain)
			return function(str,...)
				return factory.translate(textdomain or "", str, ...)
			end
		end
		factory.S = factory.get_translator("factory")
	end
else
	if not minetest.get_translator then
		factory.log.warning("minetest.get_translator not found, this is really strange...")
		function factory.get_translator(textdomain)
			return function(str,...)
				return minetest.translate(textdomain or "", str, ...)
			end
		end
		factory.S = factory.get_translator("factory")
	else
		factory.S = minetest.get_translator("factory")
	end
end
