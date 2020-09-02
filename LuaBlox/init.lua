local here = ...
here = here .. "/" 

local pub = {
	Client = require(here .. "classes/client"),
	Player = require(here .. "classes/player")
}

return pub