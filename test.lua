local LuaBlox = require 'LuaBlox'
local auth = require 'secret'

local client = LuaBlox.Client()

client:connect(auth)

local group = client:getGroup(5029105)

print(group.name)

print(group.name)

