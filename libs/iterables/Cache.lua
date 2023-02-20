local discordia = require("discordia")

local Cache = discordia.class.classes.Cache

local function hash(data)
	if data.id then -- snowflakes
		return data.id
	elseif data.user then -- members
		return data.user.id
	elseif data.emoji then -- reactions
		return data.emoji.id ~= null and data.emoji.id or data.emoji.name
	elseif data.code then -- invites
		return data.code
	else
		return nil, 'json data could not be hashed'
	end
end

function Cache:_put( obj ) -- put an object directly into cache
	self._objects[hash(obj)] = obj
	self._count = self._count + 1
	return obj
end

return Cache