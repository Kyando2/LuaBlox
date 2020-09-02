local here = ...
here = here:gsub("classes/player", "")
-- Classes
local BaseClass = require(here ..'classes/baseclass')
local Cache = require(here .. 'classes/Cache')
local Player, get = require(here .. 'classes/class')("Player", BaseClass, Cache)
-- Utils
local json = require(here .. 'utils/json')
-- Static
local endpoints = require(here .. 'static/endpoints')


function Player:_fetchName()
	local rsp = self.client:_reqwest{
		url = endpoints.username .. self.id
	}
	x, y = rsp:catch("There was an error with the request")
	local _username = json.decode(x[1]).Username
	self:add("Username", _username)
	return _username
end

function Player:__init(options)
	Cache.__init(self)
	self.id = tostring(options.id)
	self.client = options.client
	return self
end

function get.username(self)
	if self:get("Username") then return self:get("Username")
	else return self:_fetchName() end
end

return Player

