local here = ...
here = here:gsub("client", "")
-- Builtin
local http = require 'socket.http'
local https = require 'ssl.https'
-- Local
local json = require(here .. 'json')
local BaseClass = require(here ..'baseclass')
local Response = require(here .. 'response')
local Player = require(here .. 'player')
local Client = require(here ..'class')('Client', BaseClass)
local regex = "Roblox.XsrfToken.setToken\%('(.+)'%)"


local running = coroutine.running
local status = coroutine.status
local resume = coroutine.resume
-- Local meth

function Client:setHeaders(k, v)
	self.headers[k] = v
end

function Client:updateCSRFToken()
    -- X-CSRFToken
    local resp = self:reqwest {
        url = 'https://roblox.com/home',
	}
    resp, headers = resp:catch("There was an error executing this request")
    local CSRFToken = string.match(table.concat(resp), regex)
    local target = string.byte("'")
    local num = 0 
    for idx = 1, #CSRFToken do
        if CSRFToken:byte(idx) == target then
            num = idx
            break
        end
    end
    CSRFToken = string.sub(CSRFToken, 1, (num-1))
    self:setHeaders("X-CSRF-TOKEN", CSRFToken)
end

function Client:verifyConnection()
    self:updateCSRFToken()
    local prom = self:reqwest {
        url = 'https://friends.roblox.com/v1/my/friends/count'
        }
end

function Client:setCookie(k, v)
	self.cookies[k] = v
    cookieList = {}
    for k, v in pairs(self.cookies) do
        table.insert(cookieList, k)
        table.insert(cookieList, "=")
        table.insert(cookieList, v)
        table.insert(cookieList, ";")
    end

    self:setHeaders("Cookie", table.concat(cookieList))
end

local function request(options)
    if not running() then return error("Cannot execute request outside of coroutine") end
    -- Initializing
    options = options or {}
    headers = options.headers
    url = options.url or 'https://roblox.com/home'
    meth = options.meth or 'GET'
    headers["Content-Type"] = options.contentType or 'application/json'
    resp = {}

    r, c, h = https.request {
        method = meth,
        url = url,
        headers = headers,
        sink = ltn12.sink.table(resp),
        }

    if c == 308 then
        url = h.location
        r, c, h = https.request {
        method = meth,
        url = url,
        headers = headers,
        sink = ltn12.sink.table(resp)
        }
    end

    if c ~= 200 then print("Received an HTTP error code: " .. tostring(c)) 
        error(table.concat(resp))
    end
    coroutine.yield()
    return resp, h
end

function Client:reqwest(options)
    options.headers = self.headers or options.headers
    local coro = coroutine.create(request)
    resume(coro, options)
    return Response{coro = coro}
end

-- Public meth

function Client:__init(options)
    self.cookies = {}
    self.headers = {}
    return self
end

function Client:connect(authCookie)
    self:setCookie('.ROBLOSECURITY', authCookie)

    self:verifyConnection()
end

function Client:getPlayer(id)
    return Player{id=id,client=self}
end

return Client