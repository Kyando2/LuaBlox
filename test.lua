local Client = require 'LuaBlox.client'
local auth = require 'secret'

local client = Client()

client:connect(auth)

local player = client:getPlayer("182262920")

print(player.username)

print(player.username)

