factory.log = {}

function factory.log.make_logger(level)
	return function(text, ...)
		minetest.log(level, "[factory] "..text:format(...))
	end
end

factory.log.warning = factory.log.make_logger("warning")
factory.log.action = factory.log.make_logger("action")
factory.log.info = factory.log.make_logger("info")
