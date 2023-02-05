--[=[
@c Client
@d All additions made to the Client class.
]=]

local discordia = require("discordia")
local Resolver = require("discordia/client/Client/Resolver")
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
	local c = Command( {_new = true, _type = enum.applicationCommandType.chatInput, _id = 0, _guild = guild and Resolver.guild(guild).id}, self, self )
end

--[=[
@m newUserCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a user command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newUserCommand( name, guild )
	local c = Command( {_new = true, _type = enum.applicationCommandType.user, _id = 0, _guild = guild and Resolver.guild(guild).id}, self, self )
end

--[=[
@m newMessageCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a message command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newMessageCommand( name, guild )
	local c = Command( {_new = true, _type = enum.applicationCommandType.message, _id = 0, _guild = guild and Resolver.guild(guild).id}, self, self )
end

--[=[
@m getCommand
@p id Command-ID-Resolvable
@r Command
@d Get a global command.
]=]
function Client:getGlobalCommand( id )
	local c = self._appCommands:find(function(c) return c.id == id end)
	if not c then
		c = Command( self._api:getGlobalApplicationCommand(id), self, self )
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
	local c = self._appCommands:find(function(c) return c.id == id end)
	c:delete()
end

--[=[ 
@p applicationCommands TableIterable All global commands currently cached to the client. Note: This is not updated by gateway events, you can request an update by using `Client:cacheCommands()`.
]=]
function Client.__getters:applicationCommands()
	return self._appCommands
end

--[=[
@m cacheCommands
@d Get all commands and cache them. This will overwrite any changes made on the same event loop.
]=]
function Client:cacheCommands()
	
end

local oldClientInit = Client.__init

function Client:__init()
	self:on("ready", function()
		self:cacheCommands()
	end)
	
	return oldClientInit(self)
end

return Client