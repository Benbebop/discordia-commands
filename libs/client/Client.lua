--[=[
@c Client
@d All additions made to the Client class.
]=]

local discordia = require("discordia")
local Resolver = require("discordia/client/Client/Resolver")
local Cache = discordia.class.classes.Cache
local enum = require("enums")
local shared = require("shared")

local Command = require("containers/Command")

local Client = discordia.class.classes.Client

--[=[
@m newSlashCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a slash command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newSlashCommand( name, guild ) return shared.newCommand( guild and self:getGuild(Resolver.guildId(guild)) or self, self, "chatInput", name, guild ) end

--[=[
@m newUserCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a user command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newUserCommand( name, guild ) return shared.newCommand( guild and self:getGuild(Resolver.guildId(guild)) or self, self, "user", name, guild ) end

--[=[
@m newMessageCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a message command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newMessageCommand( name, guild ) return shared.newCommand( guild and self:getGuild(Resolver.guildId(guild)) or self, self, "message", name, guild ) end

--[=[
@m getCommand
@p id string
@r Command
@d Get a global command.
]=]
function Client:getGlobalCommand( id ) return shared.getCommand( self, id ) end

--[=[
@m getCommand
@p id Command-ID-Resolvable
@r Command
@d Get a global command.
]=]
function Client:deleteGlobalCommand( id ) shared.deleteCommand( self, id ) end

--[=[ 
@p applicationCommands Cache All global commands currently cached to the client. This also contains guild commands if the client has not been run yet. Note: This is not updated by gateway events, you can request an update by using `Client:cacheCommands()`.
]=]
function Client.__getters:applicationCommands()
	return self._commandCache
end

--[=[
@m cacheCommands
@d Get all global commands and cache them.
]=]
function Client:cacheCommands() shared.cacheCommands(self) end

local oldClientInit = Client.__init

function Client:__init( ... )
	self._commandInit = {}
	self._commandCache = Cache( self._commandInit )
	
	self:on("ready", function()
		self:cacheCommands()
	end)
	
	return oldClientInit(self, ... )
end

return Client