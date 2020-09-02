local here = ...
here = here:gsub("classes/group", "")
-- Classes
local Cache = require(here ..'classes/cache')
-- Class
local Group, get = require(here .. 'classes/class')("Group", Cache)
-- Utils
local json = require(here .. 'utils/json')
-- Static
local endpoints = require(here .. 'static/endpoints')


function Group:__init(options)
	Cache.__init(self)
	self.id = tostring(options.id)
	self.client = options.client
	return self
end

function Group:_fetchInfo(sp)
	local rsp = self.client:_get{
		url = endpoints.groupData .. self.id
	}
	local response, headers = rsp:catch("There was an error with the request")
	local data = json.decode(response[1])
	self:add("name", data.name); self:add("memberCount", data.memberCount); self:add("description", data.description);
	return self:get(sp)
end

function get.name(self)
	if self:get("name") then return self:get("name")
	else return self:_fetchInfo("name") end
end

return Group