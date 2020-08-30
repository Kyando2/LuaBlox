local here = ...
here = here:gsub("baseclass", "")

local BaseClass = require(here .. 'class')("BaseClass")

function BaseClass:__init() -- Default implementation
	return self
end



return BaseClass