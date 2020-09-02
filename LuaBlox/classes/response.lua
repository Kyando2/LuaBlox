local here = ...
here = here:gsub("classes/response", "")
-- Classes
local BaseClass = require(here ..'classes/baseclass')
-- Class
local Response = require(here .. 'classes/class')("Promise", BaseClass)
-- Shortcut
local resume = coroutine.resume


-- Directly gives back the result ignoring the possibility of error
function Response:abstract()
	self.status = "dead"
	x, y, z = resume(self.__coro)
	return y, z
end

-- Catches any exception during the request
function Response:catch(errorMessage)
	self.status = "dead"
	x, y, z = resume(self.__coro)
	if not x then return error(errorMessage) end
	return y, z
end

--[[
Responses for HTTP requests (basic wrappers for coroutines)
]]--
function Response:__init(options) 
	if not options.coro then return error("Must provide a coro") end
	self.__coro = options.coro
	self.status = "alive"
	return self
end

return Response