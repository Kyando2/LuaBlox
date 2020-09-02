local CSRFTOKENREGEX = "Roblox.XsrfToken.setToken\%('(.+)'%)"
-- Builtin
local https = require 'ssl.https'
-- Shortcuts
local running = coroutine.running

local exports = {}

local function redirect(options, headers)
    options.url = h.location
    exports.request(options)
end

local function getIndex(tokenText)
    local target = string.byte("'")
    for i = 1, #tokenText do
        if string.byte(tokenText, i) == target then
            return (i-1)
        end
    end
end

function exports.request(options)
    if not running() then return error("Cannot execute request outside of coroutine") end
   
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

    if c == 308 then redirect(options, h) end

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