--[=[
@c Client
@d All additions made to the Client class.
]=]

local discordia = require("discordia")
local Resolver = require("discordia/client/Client/Resolver")
local Cache = discordia.class.classes.Cache
local enum = require("enums")

local Command = require("containers/Command")

local Client = discordia.class.classes.Client

--[=[
@m newSlashCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a slash command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newSlashCommand( name, guild )
	local c = Command( {new = true, type = enum.applicationCommandType.chatInput, id = 0, guild = guild and Resolver.guild(guild).id, name = name}, self, self )
	table.insert(self._commandTable, c)
	return c
end

--[=[
@m newUserCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a user command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newUserCommand( name, guild )
	local c = Command( {new = true, type = enum.applicationCommandType.user, id = 0, guild = guild and Resolver.guild(guild).id, name = name}, self, self )
	table.insert(self._commandTable, c)
	return c
end

--[=[
@m newMessageCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a message command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newMessageCommand( name, guild )
	local c = Command( {new = true, type = enum.applicationCommandType.message, id = 0, _guild = guild and Resolver.guild(guild).id, name = name}, self, self )
	table.insert(self._commandTable, c)
	return c
end

--[=[
@m getCommand
@p id Command-ID-Resolvable
@r Command
@d Get a global command.
]=]
function Client:getGlobalCommand( id )
	local c = self._commandCache:find(function(c) return c.id == id end)
	if not c then
		c = Command( self._api:getGlobalApplicationCommand(id), self, self )
		table.insert(self._commandTable, c)
	end
	return c
end

--[=[
@m getCommand
@p id Command-ID-Resolvable
@r Command
@d Get a global command.
]=]
function Client:deleteGlobalCommand( id )
	local c = self._commandCache:find(function(c) return c.id == id end)
	c:delete()
end

--[=[ 
@p applicationCommands TableIterable All global commands currently cached to the client. Note: This is not updated by gateway events, you can request an update by using `Client:cacheCommands()`.
]=]
function Client.__getters:applicationCommands()
	return self._commandCache
end

--[=[
@m cacheCommands
@d Get all commands and cache them. This will overwrite any changes made on the same event loop.
]=]
function Client:cacheCommands()
	local commands = self._api:getGlobalApplicationCommands()
	for _,command in ipairs(commands) do
		local c = Command( command, self, self )
		table.insert(self._commandTable, c)
	end
end

local oldClientInit = Client.__init

function Client:__init( ... )
	self._commandTable = {}
	self._commandCache = Cache( self._commandTable )
	
	self:on("ready", function()
		self:cacheCommands()
	end)
	
	return oldClientInit(self, ... )
end

return Client