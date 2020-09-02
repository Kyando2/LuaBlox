local here = ...
here = here:gsub("classes/baseclass", "")
-- Class
local BaseClass = require(here .. 'classes/class')("BaseClass")

function BaseClass:__init() -- Default implementation
	return self
end

return BaseClass