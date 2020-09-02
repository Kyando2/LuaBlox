local exports = {}

function exports.is(object, class)
	for _, v in pairs(object.__ancestors) do
		if v == class then return true end
	end
	return false
end

return exports