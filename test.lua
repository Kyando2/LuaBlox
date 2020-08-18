clientHandler = require 'LuaBlox.client'

client = clientHandler:new()

auth = "" -- Your token here
client:connect(auth)