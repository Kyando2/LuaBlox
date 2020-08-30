--[[
MIT License

Copyright (c) 2020 Kyando
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--


local metadata = {}
local __printer = print

-- Toggle for the print function
local debugMode = true

function print(...) 
	if debugMode then
		__printer(...)
	end
end

string.startswith = function(self, str) 
    return self:find('^' .. str) ~= nil
end

function metadata:__call(...)
	local obj = setmetatable({}, self)
	obj:__init(...)
	return obj
end

function metadata:__newindex(k, v)
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

		--[[
		**ATTRIBUTE TYPES**
		
		There are four different attribute types; NATIVE, INHERITED, ADDED and GETTER

		NATIVE:
			Native attributes are attributes that are added when creating the class
			after using the implementation provided here. They are the 3rd to be fetched
			when searching for an attribute
		
		INHERITED:
			Inherited attributes are attributes that are inherited from the parent
			They are always the last ones to be fetched

		ADDED:
			Added attributes are attributes taht are added after the initialization of the class
			They are always the second ones fetched when searching for an attribute

		GETTER:
			Functions that have been added to the getter dictionary returned from this module
			They are the first one fetched when searching an attribute and are automatically called
			with the cls attribute

		]]--
		local class = setmetatable({}, metadata)
		local dict = {}
		local inherited = {}
		local getter = {}
		--[[
		**INHERITANCE**

		All native and inherited attributes from parent class are transfered to this class as inherited attributes

		]]--

		if ancestor then
			for k1, v1 in pairs(ancestor) do
				if not k1:startswith("__") then
					print('Adding inherited property ' .. k1 .. ' from ancestor ' .. ancestor.__name)
					inherited[k1] = v1
				end
			end
			for k2, v2 in pairs(ancestor.__dict) do
				if not k2:startswith("__") then
					print('Adding inherited property ' .. k2 .. ' from ancestor ' .. ancestor.__name)
					inherited[k2] = v2
				end
			end
		end
		--[[
		**INDEX**

		Adding an INDEX method to your class will overpower the default implementation below
		and automatically get called by __index

		]]--
		function class:__index(k)
			if rawget(class, "INDEX") then return rawget(class, "INDEX")(self, k) end
			if inherited["INDEX"] then return inherited.INDEX(self, k) end
			if getter[k] then return getter[k](self) end
			if dict[k] ~= nil then
				return dict[k]
			elseif rawget(class, k) ~= nil then
				return rawget(class, k)
			elseif inherited[k] ~= nil then
				return inherited[k]
			end
			return nil
		end

		function class:__newindex(k, v)
			dict[k] = v
		end
		--[[
		**THE DICT**
		
		The dict table is a table containing all of the added attributes to a Class
		This includes all attributes added after initialization
		-->> THOSE ATTRIBUTES ARE ALWAYS FETCHED **BEFORE** NATIVE AND INHERITED ATTRIBUTES <<--
		As such adding anything to that table will overwrite the native attribute
		For Example:
		Imagine an object with a native "happy" attribute set to true
		print(object.happy)
		>> true
		If we were to then do object.happy = false then 
		print(object)
		>> false
		However if we do object.happy = nil then
		print(object.happy)
		>> true 
		Because it went back to the native attribute

		]]--
		class.__dict = dict
		class.__inherited = inherited
		class.__name = name
		--[[
		**THE GETTER**

		any function added to the getter table will be called when trying to access an attribute
		Example:
		Imagine a class with a _name method which returns the class' name
			function getter.name(self)
				return self:_name()
			end
		This, put simply, transform a call of object:_name() to object.name 

		]]--
		class.__getter = getter 

		print('------------------------\n')
		return class, getter
end})
