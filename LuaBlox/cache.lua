local here = ...
here = here:gsub("Cache", "")

local BaseClass = require(here ..'baseclass')
local Cache = require(here .. 'class')("Cache", BaseClass)

function Cache:__init(options)
	self.data = {}
	return self
end

function Cache:add(k, v) 
	self.data[k] = {v, false}
end

function Cache:hide(k)
	local v = self.data[k][1]
	self.data[k] = {v, true}
end

function Cache:get(k)
	if self.data[k] then
		if self.data[k][2] == false then
			return data[k][1]
		end
	end
end

return Cache