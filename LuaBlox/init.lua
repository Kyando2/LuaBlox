local here = ...
here = here .. "/" 
print(here)

local pub = {
	Client = require(here .. "classes/client"),
	Player = require(here .. "classes/player")
}

return pub