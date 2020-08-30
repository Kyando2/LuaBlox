local here = ...
here = here:gsub("promise", "")

local BaseClass = require(here ..'baseclass')
local Promise = require(here .. 'class')("Promise", BaseClass)

local resume = coroutine.resume

--[[
Promises for HTTP requestsS (basic wrappers for coroutines)
]]--
function Promise:__init(options) 
	if not options.coro then return error("Must provide a coro") end
	self.__coro = options.coro
	self.status = "alive"
	return self
end

function Promise:getResult()
	self.status = "dead"
	x, y, z = resume(self.__coro)
	return y, z
end

function Promise:abstractResult()
	return resume(self.__coro)
end

return Promise