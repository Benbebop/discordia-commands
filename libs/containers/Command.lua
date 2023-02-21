local discordia = require("discordia")
local timer = require("timer")
local Resolver = require("client/Resolver")
local class = discordia.class

local Snowflake = class.classes.Snowflake
local Permissions = discordia.class.classes.Permissions
local Option = require("containers/Option")

local Command, get = class("Command", Snowflake)

local function queue( self )
	if self._queued then return end
	self.client:_queueCommands()
	table.insert(self.client._applicationCommandsModified, self)
	self._queued = true
end

function Command:_payload()
	local payload = {
		type = self._type, name = self._name, guild = Resolver.guildId( self._guild ),
		name = self._name, description = self._description,
		nsfw = self._nsfw
	}
	
	if self._options then
		payload.options = {}
		
		for i,v in ipairs(self._options) do
			payload.options[i] = v:_payload()
		end
	end
	
	return payload
end

function Command:_load( data )
	self._id = self._id or data.id
	self._name, self._description = data.name, data.description
	self._default_member_permissions, self._dm_permission, self._default_permission = Permissions(data.default_member_permissions), data.dm_permission, data.default_permission
	self._nsfw = data.nsfw
	if data.options then
		self._options = self._options or {}
		local options = {}
		for i,v in ipairs(data.options) do
			options[i] = self._options[i] and self._options[i]:_load(v) or Option(v, self, self)
		end
		self._options = options
	end
end

function Command:__init( data, parent )
	self._type, self._guild = data.type, data.guild
	
	Snowflake.__init(self, {}, parent)
	
	self:_load( data )
	
	queue( self )
end

function get.id(self)
	return self._id
end

function get.type(self)
	return self._type
end

function get.guild(self)
	return self.client:getGuild( self._guild )
end

function Command:addOption( optionType, name )
	local o = Option( {type = optionType, name = name}, self, self, self.client )
	self._options = self._options or {}
	table.insert(self._options, o)
	queue( self )
	return o
end

function Command:deleteOption( index )
	table.remove(self._options, index)
	
	queue( self )
	
	return self
end

function get.options(self)
	return self._options
end

function Command:setName( name )
	self._name = name
	
	queue( self )
	return self
end

function get.name(self)
	return self._name
end

function Command:setDescription( description )
	self._description = description
	
	queue( self )
	
	return self
end

function get.description(self)
	return self._description
end

function Command:setDefaultMemberPermissions( permissions )
	self._default_member_permissions = Resolver.permission(permissions).value
	
	queue( self )
	
	return self
end

function Command:getDefaultMemberPermissions()
	return class.classes.Permissions(self._default_member_permissions)
end

function Command:setDmPermission( hasDmPermission )
	self._dm_permission = hasDmPermission
	
	queue( self )
	
	return self
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
	
	queue( self )
	
	return self
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
	
	queue( self )
	
	return self
end

function get.nsfw(self)
	return self._nsfw
end

function get.version(self)
	return self._version
end

function Command:compare( other )
	return (self._type == (other._type or other.type)) and (self._guild == (other._guild or other.guild)) and (self._name == (other._name or other.name))
end

function Command:delete()
	if self._guild then
		self.client._api:deleteGuildApplicationCommand(self._guild, self._id)
	else
		self.client._api:deleteGlobalApplicationCommand(self._id)
	end
	
	self._parent._applicationCommands:_delete( self._id )
end

function Command:callback( callback )
	self._listeners = self._listeners or {}
	table.insert(self._listeners, callback)
	
	return self
end

return Command