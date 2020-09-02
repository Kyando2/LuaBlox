local here = ...
here = here:gsub("classes/Cache", "")
-- Classes
local BaseClass = require(here ..'classes/baseclass')
local Cache = require(here .. 'classes/class')("Cache", BaseClass)

function Cache:add(k, v) 
	self.data[k] = {v, false}
end

function Cache:hide(k)
	local v = self.data[k][1]
	self.data[k] = {v, true}
end

function Cache:get(k)
	local data = self.data
	if data[k] then
		if data[k][2] == false then
			return data[k][1]
		end
	end
end

function Cache.__init(self, options)
	self.data = {}
	return self
end

return Cache