local here = ...
here = here:gsub("player", "")

local BaseClass = require(here ..'baseclass')
local Player, get = require(here .. 'class')("Player", BaseClass)
local Cache = require(here .. 'Cache')
local json = require(here .. 'json')

local endpoints = {username = "https://api.roblox.com/users/"}

function Player:__init(options)
	self.id = options.id
	self.client = options.client
	self.cache = Cache()
	return self
end

function Player:fetchName()
	local prom = self.client:reqwest{
		url = endpoints.username .. self.id
	}
	x, y = prom:getResult()
	self._username = json.decode(x[1]).Username
	self.cache:add("Username", self._username)
	return self._username
end

function get.username(self)
	if self._username then return self._username 
	else return self:fetchName() end
end

return Player

