--[=[
@c Command x Snowflake
@d Represents an application command of any type. This object has no way to update automatically, so changes will not register until manually requested, this usually isnt an issue unless you control the bot through multiple different instances. No check are made for whether an operation is valid for the type of command you are making, so be weary what you are inputting.
]=]

local discordia = require("discordia")
local timer = require("timer")
local class = discordia.class
local Snowflake = class.classes.Snowflake
local ArrayIterable = class.classes.ArrayIterable
local Resolver = require("discordia/client/Client/Resolver")

local Permissions = discordia.class.classes.Permissions
local Option = require("containers/Option")

local Command, get = class("Command", Snowflake)

function Command:_execute()
	self._timer = nil
	local payload = {
		name = self._name, description = self._description,
		default_member_permissions = self._default_member_permissions.value, dm_permission = self._dm_permission, default_permission = self._default_permission,
		nsfw = self._nsfw,
		options = {}
	}
	for i,v in ipairs(self._options) do
		payload.options[i] = v:_raw()
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
			data = self._client._api:createGuildApplicationCommand(self._guild, payload))
		else
			data = self._client._api:createGlobalApplicationCommand(payload)
		end
	end
	self._id, self._version = data.id, data.version
	self:overwrite( data )
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
			options[i] = Option(v, self._client, self)
		end
		self._options = ArrayIterable( options )
	end
end

--[=[
@m overwrite
@p data table
@d Overwrite command data with a raw table.
]=]
function Command:overwrite( data )
	self._name, self._description = data.name, data.description
	self._default_member_permissions, self._dm_permission, self._default_permission = Permissions(data.default_member_permissions), data.dm_permission, data.default_permission
	self._nsfw = data.nsfw
	self:_setOptions( data )
	
	self:_queue()
end

function Command:__init( data, parent, client )
	self._client = client or parent._client
	
	self:_setOptions( data )
	
	Snowflake.__init(self, data, parent)
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
@m addOption
@r option Option
@d Add a new option to the command. This only applies to chatInput commands.
]=]
function Command:addOption()
	local o = Option( {}, self, self._client )
	table.insert(self._options, o)
	return o
end

--[=[
@m addOption
@p index number
@d Remove an option from the command. This is the same as `table.remove(Command.options, index)`. This only applies to chatInput commands.
]=]
function Command:deleteOption( index )
	table.remove(self._options, index)
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
@d Set the command's name. This should be between 1 and 32 characters in length.
]=]
function Command:setName( name )
	self._name = name
	
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
	self._description = description
	
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
@p permissions Permissions-Resolvable
@d Set permissions required to use this command. This only applies to guild commands.
]=]
function Command:setDefaultMemberPermissions( permissions )
	self._default_member_permissions = Resolver.permission(permissions).value
	
	self:_queue()
end

--[=[
@m getDefaultMemberPermissions
@r Permissions-Resolvable
@d Get permissions required to use this command. This only applies to guild commands.
]=]
function Command:getDefaultMemberPermissions()
	return class.classes.Permissions(self._default_member_permissions)
end

--[=[
@m setDmPermission
@p hasDmPermission boolean
@d Manually overwrite command data with a raw table.
]=]
function Command:setDmPermission( hasDmPermission )
	self._dm_permission = hasDmPermission
	
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
@d Whether this command is enabled by default in a guild. This only applies to guild commands. Note: This is a soon depricated feature, `Command.defaultMemberPermissions:disableAll()` should be used instead
]=]
function Command:setDefaultPermission( hasDefaultPermission )
	if self._default_permission == nil then
		self._default_member_permissions = (not hasDefaultPermission) and 0 or self._default_member_permissions
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

--[=[
@m compare
@p other Command
@d Whether this command would overwrite the other when pushed to discord.
]=]
function Command:compare( other )
	return (self._type == other._type) and (self._guild == other._guild) and (self._name == other._name)
end

--[=[
@m delete
@d Deletes the command
]=]
function Command:delete( other )
	
end

return Command