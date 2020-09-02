local LuaBlox = require 'LuaBlox'
local auth = require 'secret'

local client = LuaBlox.Client()

client:connect(auth)

local player = client:getPlayer("182262920")

print(player.username)

print(player.username)

