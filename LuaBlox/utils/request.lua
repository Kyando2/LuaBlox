local CSRFTOKENREGEX = "Roblox.XsrfToken.setToken\%('(.+)'%)"
-- Builtin
local http = require 'socket.http'
local https = require 'ssl.https'
-- Shortcuts
local running = coroutine.running

local exports = {}

local function redirect(options, headers, func)
    options.url = headers.location
    func(options)
end

local function getIndex(tokenText)
    local target = string.byte("'")
    for i = 1, #tokenText do
        if string.byte(tokenText, i) == target then
            return (i-1)
        end
    end
end

function exports.get(options)
    if not running() then return error("Cannot execute request outside of coroutine") end
   
    options = options or {}
    local headers = options.headers
    local url = options.url or 'https://roblox.com/home'
    local meth = 'GET'
    headers["Content-Type"] = options.contentType or 'application/json'
    resp = {}

    r, c, h = https.request {
        method = meth,
        url = url,
        headers = headers,
        sink = ltn12.sink.table(resp),
        }

    if c == 308 then redirect(options, h, exports.get) end

    if c ~= 200 then print("Received an HTTP error code: " .. tostring(c)) 
        error(table.concat(resp))
    end
    
    coroutine.yield()

    coroutine.yield(resp, h)
end

function exports.getToken(text)
    local tokenText = string.match(text, CSRFTOKENREGEX)
    return string.sub(tokenText, 1, getIndex(tokenText))
end

return exports