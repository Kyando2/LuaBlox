local here = ...
here = here:gsub("classes/client", "")
-- Classes
local BaseClass = require(here ..'classes/baseclass')
local Response = require(here .. 'classes/response')
local Player = require(here .. 'classes/player')
local Client = require(here ..'classes/class')('Client', BaseClass)
-- Utils
local json = require(here .. 'utils/json')
local utils = require(here .. 'utils/utils')
local request = require(here .. 'utils/request')
-- Shortcuts
local running = coroutine.running
local status = coroutine.status
local resume = coroutine.resume


function Client:_setHeaders(k, v)
	self.headers[k] = v
end

function Client:_updateCSRFToken()
    local data = self:_reqwest {
        url = 'https://roblox.com/home',
	}
    resp, headers = data:catch("There was an error executing this request")
    local content = table.concat(resp)
    self:_setHeaders("X-CSRF-TOKEN", request.getToken(content))
end

function Client:_verifyConnection()
    self:_updateCSRFToken()
    local prom = self:_reqwest {
        url = 'https://friends.roblox.com/v1/my/friends/count'
        }
end

function Client:_setCookie(k, v)
	self.cookies[k] = v
    cookieList = {}
    for k, v in pairs(self.cookies) do
        table.insert(cookieList, k)
        table.insert(cookieList, "=")
        table.insert(cookieList, v)
        table.insert(cookieList, ";")
    end

    self:_setHeaders("Cookie", table.concat(cookieList))
end

function Client:_reqwest(options)
    options.headers = options.headers or self.headers
    local coro = coroutine.create(request.request)
    x, y, z = resume(coro, options)
    return Response{coro = coro}
end

function Client:connect(authCookie)
    self:_setCookie('.ROBLOSECURITY', authCookie)

    self:_verifyConnection()
end

function Client:getPlayer(id)
    return Player{id=id,client=self}
end

function Client:__init(options)
    self.cookies = {}
    self.headers = {}
    return self
end

return Client