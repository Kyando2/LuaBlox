Client = require 'LuaBlox.client'

client = Client()

auth = ""
client:connect(auth)

player = client:getPlayer("182262920")

