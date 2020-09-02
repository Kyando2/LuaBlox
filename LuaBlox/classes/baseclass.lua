local here = ...
print(here)
here = here:gsub("classes/baseclass", "")

local BaseClass = require(here .. 'classes/class')("BaseClass")

function BaseClass:__init() -- Default implementation
	return self
end

return BaseClass