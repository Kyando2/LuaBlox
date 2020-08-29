local meta = {}
local __printer = print

--[[
Toggle for the print function
--]]
local debugMode = true

function print(...) 
	if debugMode then
		__printer(...)
	end
end

string.startswith = function(self, str) 
    return self:find('^' .. str) ~= nil
end

function meta:__call(...)
	local obj = setmetatable({}, self)
	obj:__init(...)
	return obj
end

function meta:__newindex(k, v)
	if not k:startswith("__") then
		print('Adding native property ' .. k ..' to Class ' .. self.__name)
	end
	rawset(self, k, v)
end

return setmetatable({},
	{__call = 
	function(_, name, ancestor)
		print('\n--- Generating Class ---')
		print(name)
		if ancestor then print("From ancestor " .. ancestor.__name) end

		local class = setmetatable({}, meta)
		local dict = {}

		if ancestor then
			for k1, v1 in pairs(ancestor) do
				if not k1:startswith("__") then
					print('Adding inherited property ' .. k1 .. ' from ancestor ' .. ancestor.__name)
					dict[k1] = v1
				end
			end
			for k2, v2 in pairs(ancestor.__dict) do
				if not k2:startswith("__") then
					print('Adding inherited property ' .. k2 .. ' from ancestor ' .. ancestor.__name)
					dict[k2] = v2
				end
			end
		end

		function class:__index(k)
			if dict[k] then
				return dict[k]
			elseif rawget(class, k) then
				return rawget(class, k)
			end
			return nil
		end

		function class:__newindex(k, v)
			dict[k] = v
		end
		
		class.__dict = dict
		class.__name = name

		print('------------------------\n')
		return class, dict
end})
