local here = ...
here = here:gsub("classes/player", "")
-- Classes
local BaseClass = require(here ..'classes/baseclass')
local Player = require(here .. 'classes/player')
-- Class
local Member, get = require(here .. 'classes/class')("Member", Player)

function Member:__init(options)
	Player.__init(self, options)
	return self
end

return Member