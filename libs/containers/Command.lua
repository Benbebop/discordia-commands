--[=[
@c Command x Snowflake
@d Represents an application command of any type. This object has no way to update automatically, so changes will not register until manually requested, this usually isnt an issue unless you control the bot through multiple different instances.
]=]

local discordia = require("discordia")
local timer = require("timer")
local class = discordia.class
local Snowflake = class.classes.Snowflake
local ArrayIterable = class.classes.ArrayIterable

local Command, get = class("Command", Snowflake)

local function execute(self)
	local payload = {
		name = self._name, description = self._description,
		default_member_permissions = self._default_member_permissions, dm_permission = self._dm_permission, default_permission = self._default_permission,
		nsfw = self._nsfw,
		options = {}
	}
	if self._new then
		if self._guild then
			self._client._api:createGuildApplicationCommand(self._guild, payload)
		else
			self._client._api:createGlobalApplicationCommand(payload)
		end
	else
		if self._guild then
			self._client._api:editGuildApplicationCommand(self._guild, self._id, payload)
		else
			self._client._api:editGlobalApplicationCommand(self._id, payload)
		end
	end
end

function Command:_queue()
	if self._client._token then
		timer.clearTimer(self._timer)
		self._timer = timer.setImmediate(coroutine.wrap(execute), self)
	end
end

--[=[
@m overwrite
@p data table
@d Manually overwrite command data with a raw table.
]=]
function Command:overwrite( data )
	if data.options then
		data.options = ArrayIterable()
	end
	
	self:_queue()
end

function Command:__init( data, client, parent )
	Snowflake.__init(self, data, parent)
	self._client = client
	
	self:overwrite( data )
	
	if not self._client._token then
		self._client:on("ready", function()
			self:_queue()
		end)
	else
		self:_queue()
	end
end

--[=[
@p guild number The command type. Use the applicationCommandType enumeration for a human-readable representation.
]=]
function get.type(self)
	return self._type
end

--[=[
@p guild nil/string/Guild The guild in which this command was registered. This only applies to guild commands.
]=]
function get.guild(self)
	return self._client:getGuild( self._guild )
end

--[=[
@p options ArrayIterable An ArrayIterable of options for this command. This only applies to chatInput commands.
]=]
function get.options(self)
	return self._options
end

--[=[
@m setName
@p name string
@d Se the command's name. This should be between 1 and 32 characters in length.
]=]
function Command:setName( name )
	
	
	self:_queue()
end

--[=[
@p name string The command's name. This should be between 1 and 32 characters in length.
]=]
function get.name(self)
	return self._name
end

--[=[
@m setDescription
@p description string
@d Set the command's description. This should be between 1 and 100 characters in length. This only applies to chatInput commands.
]=]
function Command:setDescription( description )
	
	
	self:_queue()
end

--[=[ 
@p description string The command's description. This should be between 1 and 100 characters in length. This only applies to chatInput commands.
]=]
function get.description(self)
	return self._description
end

--[=[
@m setDefaultMemberPermissions
@p permissions Permissions
@d Set permissions required to use this command. This only applies to guild commands.
]=]
function Command:setDefaultMemberPermissions( permissions )
	
	
	self:_queue()
end

--[=[
@p defaultMemberPermissions Permissions Permissions required to use this command. This only applies to guild commands.
]=]
function get.defaultMemberPermissions(self)
	return self._default_member_permissions
end

--[=[
@m setDmPermission
@p hasDmPermission boolean
@d Manually overwrite command data with a raw table.
]=]
function Command:setDmPermission( hasDmPermission )
	
	
	self:_queue()
end

--[=[
@p dmPermission boolean Whether this command can be used in dms. This only applies to global commands.
]=]
function get.dmPermission(self)
	return self._dm_permission
end

--[=[
@m setDefaultPermission
@p hasDefaultPermission boolean
@d Whether this command is enabled by default in a guild. This only applies to guild commands. Note: This is a soon depricated feature and should not be used.
]=]
function Command:setDefaultPermission( hasDefaultPermission )
	if self._default_permission == nil then
		self._default_member_permissions = hasDefaultPermission and 0 or self._default_member_permissions
	else
		self._default_permission = hasDefaultPermission
	end
	
	self:_queue()
end

--[=[
@p defaultPermission boolean Whether this command is enabled by default in a guild. This only applies to guild commands.
]=]
function get.defaultPermission(self)
	if self._default_permission == nil then
		return self._default_member_permissions ~= 0
	else
		return self._default_permission
	end
end

--[=[
@m setNsfw
@p isNsfw boolean
@d Set whether this command is age-restricted.
]=]
function Command:setNsfw( isNsfw )
	self._nsfw = isNsfw
	
	self:_queue()
end

--[=[
@p nsfw boolean Whether this command is age-restricted.
]=]
function get.nsfw(self)
	return self._nsfw
end

function get.version(self)
	return self._version
end

return Command