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

--[=[
@m overwrite
@p data table
@d Manually overwrite command data with a raw table.
]=]
function Command:overwrite( data, parent )
	if data.options then
		data.options = ArrayIterable()
	end
	
	Snowflake.__init(self, data, parent or self._parent)
end
Command.__init = Command.overwrite

local function execute(self)
	
end

function Command:_queue()
	timer.clearTimer(self._timer)
	self._timer = timer.setImmediate(execute, self)
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
@m overwrite
@p data table
@d Manually overwrite command data with a raw table.
]=]
function Command:setName( name )
	
end

--[=[
@p name string The command's name. This should be between 1 and 32 characters in length.
]=]
function get.name(self)
	return self._name
end

--[=[
@m overwrite
@p data table
@d Manually overwrite command data with a raw table.
]=]
function Command:setDescription( name )
	
end

--[=[ 
@p description string The command's description. This should be between 1 and 100 characters in length. This only applies to chatInput commands.
]=]
function get.description(self)
	return self._description
end

--[=[
@m overwrite
@p data table
@d Manually overwrite command data with a raw table.
]=]
function Command:setDefaultMemberPermissions( name )
	
end

--[=[
@p defaultMemberPermissions Permissions A Permissions object of permissions required to use this command. This only applies to guild commands.
]=]
function get.defaultMemberPermissions(self)
	return self._default_member_permissions
end

--[=[
@m overwrite
@p data table
@d Manually overwrite command data with a raw table.
]=]
function Command:setDmPermission( name )
	
end

--[=[
@p dmPermission boolean Whether this command can be used in dms. This only applies to global commands.
]=]
function get.dmPermission(self)
	return self._dm_permission
end

--[=[
@m overwrite
@p data table
@d Manually overwrite command data with a raw table.
]=]
function Command:setDefaultPermission( name )
	
end

--[=[
@p defaultPermission boolean Whether this command is enabled by default in a guild. This only applies to guild commands. Note: This is a depricated feature and should not be used.
]=]
function get.defaultPermission(self)
	if self._default_permission == nil then
		return self._default_member_permissions == 0
	else
		return self._default_permission
	end
end

--[=[
@m overwrite
@p data table
@d Manually overwrite command data with a raw table.
]=]
function Command:setDefaultPermission( name )
	
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