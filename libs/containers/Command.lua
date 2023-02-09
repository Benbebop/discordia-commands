local discordia = require("discordia")
local timer = require("timer")
local class = discordia.class
local Snowflake = class.classes.Snowflake
local Resolver = require("client/Resolver")

local Permissions = discordia.class.classes.Permissions
local Option = require("containers/Option")

local Command, get = class("Command", Snowflake)

function Command:_execute()
	self._timer = nil
	local payload = {
		name = self._name, description = self._description,
		default_member_permissions = (self._default_member_permissions or {}).value, dm_permission = self._dm_permission, default_permission = self._default_permission,
		nsfw = self._nsfw,
		options = self._options and {}
	}
	if self._options then
		for i,v in ipairs(self._options) do
			payload.options[i] = v:_raw()
		end
	end
	local data
	if self._id then
		if self._guild then
			data = self._client._api:editGuildApplicationCommand(self._guild, self._id, payload)
		else
			data = self._client._api:editGlobalApplicationCommand(self._id, payload)
		end
	else
		if self._guild then
			data = self._client._api:createGuildApplicationCommand(self._guild, payload)
		else
			data = self._client._api:createGlobalApplicationCommand(payload)
		end
	end
	self._id, self._version = data.id, data.version
	self:_save( data )
end

function Command:_queue()
	if self._client._token and not self._timer then
		self._timer = timer.setImmediate(coroutine.wrap(self._execute), self)
	end
end

function Command:_setOptions( data )
	if data.options then
		local options = {}
		for i,v in ipairs(data.options) do
			options[i] = Option(v, self._client, self, self)
		end
		self._options = options
	end
end

function Command:_save( data )
	self._name, self._description = data.name, data.description
	self._default_member_permissions, self._dm_permission, self._default_permission = Permissions(data.default_member_permissions), data.dm_permission, data.default_permission
	self._nsfw = data.nsfw
	self:_setOptions( data )
end

function Command:overwrite( data )
	self:_save( data )
	
	self:_queue()
end

function Command:__init( data, parent, client )
	self._client = client or parent._client
	
	self:_setOptions( data )
	
	Snowflake.__init(self, data, parent)
end

function get.type(self)
	return self._type
end

function get.guild(self)
	return self._client:getGuild( self._guild )
end

function Command:addOption( optionType, name )
	local o = Option( {type = optionType, name = name}, self, self, self._client )
	self._options = self._options or {}
	table.insert(self._options, o)
	return o
end

function Command:deleteOption( index )
	table.remove(self._options, index)
	
	self:_queue()
end

function get.options(self)
	return self._options
end

function Command:setName( name )
	self._name = name
	
	self:_queue()
end

function get.name(self)
	return self._name
end

function Command:setDescription( description )
	self._description = description
	
	self:_queue()
end

function get.description(self)
	return self._description
end

function Command:setDefaultMemberPermissions( permissions )
	self._default_member_permissions = Resolver.permission(permissions).value
	
	self:_queue()
end

function Command:getDefaultMemberPermissions()
	return class.classes.Permissions(self._default_member_permissions)
end

function Command:setDmPermission( hasDmPermission )
	self._dm_permission = hasDmPermission
	
	self:_queue()
end

function get.dmPermission(self)
	return self._dm_permission
end

function Command:setDefaultPermission( hasDefaultPermission )
	if self._default_permission == nil then
		self._default_member_permissions = (not hasDefaultPermission) and 0 or self._default_member_permissions
	else
		self._default_permission = hasDefaultPermission
	end
	
	self:_queue()
end

function get.defaultPermission(self)
	if self._default_permission == nil then
		return self._default_member_permissions ~= 0
	else
		return self._default_permission
	end
end

function Command:setNsfw( isNsfw )
	self._nsfw = isNsfw
	
	self:_queue()
end

function get.nsfw(self)
	return self._nsfw
end

function get.version(self)
	return self._version
end

function Command:compare( other )
	return (self._type == other._type) and (self._guild == other._guild) and (self._name == other._name)
end

function Command:delete( other )
	
end

function Command:callback( callback )
	self._listeners = self._listeners or {}
	table.insert(self._listeners, callback)
end

return Command