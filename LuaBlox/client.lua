-- HTTP client
local http = require 'socket.http'
local https = require 'ssl.https'
-- JSON decoder
json = require 'LuaBlox.json'
local BaseClass = require('LuaBlox.baseclass')
local Client = require('LuaBlox.class')('Client', BaseClass)
local regex = "Roblox.XsrfToken.setToken\%('(.+)'%)"

-- Local meth

function Client:setHeaders(k, v)
	self.headers[k] = v
end

function Client:updateCSRFToken()
    -- X-CSRFToken
    resp, headers = self:request {
    url = 'https://roblox.com/home',
	}
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
    print("CSRF-TOKEN: >" .. CSRFToken .. " <")
    self:setHeaders("X-CSRF-TOKEN", CSRFToken)
end

function Client:verifyConnection()
    self:updateCSRFToken()
    resp, headers = self:request {
        url = 'https://friends.roblox.com/v1/my/friends/count'
        }
    for k, v in pairs(resp) do
        print("'" .. k .. "' : '" .. v .. "'\n")
    end
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

function Client:request(options)
    options = options or {}
    headers = self.headers or options.headers
    updatecsrf = options.update or false
    url = options.url or 'https://roblox.com/home'
    meth = options.meth or 'GET'
    headers["Content-Type"] = options.contentType or 'application/json'
    resp = {}

    r, c, h = https.request {
        method = meth,
        url = url,
        headers = headers,
        sink = ltn12.sink.table(resp)
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
    return resp, h
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

return Client