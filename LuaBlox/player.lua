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
	local rsp = self.client:reqwest{
		url = endpoints.username .. self.id
	}
	x, y = rsp:catch("There was an error with the request")
	local _username = json.decode(x[1]).Username
	self.cache:add("Username", _username)
	return _username
end

function get.username(self)
	if self.cache:get("Username") then return self.cache:get("Username")
	else return self:fetchName() end
end

return Player

