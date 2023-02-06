--[=[
@c Guild
@d All additions made to the Guild class.
]=]

local discordia = require("discordia")
local Resolver = require("client/Resolver")
local Cache = discordia.class.classes.Cache
local enum = require("enums")
local shared = require("shared")

local Command = require("containers/Command")

local Guild = discordia.class.classes.Guild

--[=[
@m newSlashCommand
@p name string
@r Command
@d Create or overwrite (if it already exists) a guild slash command.
]=]
function Guild:newSlashCommand( name ) return shared.newCommand( self, self._client, "userInput", name ) end

--[=[
@m newUserCommand
@p name string
@r Command
@d Create or overwrite (if it already exists) a guild user command.
]=]
function Guild:newUserCommand( name, guild ) return shared.newCommand( self, self._client, "userInput", name ) end

--[=[
@m newMessageCommand
@p name string
@r Command
@d Create or overwrite (if it already exists) a guild message command.
]=]
function Guild:newMessageCommand( name, guild ) return shared.newCommand( self, self._client, "userInput", name ) end

--[=[
@m getCommand
@p id Command-Id-Resolvable
@r Command
@d Get a guild command.
]=]
function Guild:getGlobalCommand( id ) return shared.getCommand( self, Resolver.commandId( id ) ) end

--[=[
@m getCommand
@p id Command-Id-Resolvable
@r Command
@d Get a global command.
]=]
function Guild:deleteGlobalCommand( id ) shared.deleteCommand( self, Resolver.commandId( id ) ) end

--[=[ 
@p applicationCommands Cache All global commands currently cached to the client. This also contains guild commands if the client has not been run yet. Note: This is not updated by gateway events, you can request an update by using `Client:cacheCommands()`.
]=]
function Guild.__getters:applicationCommands()
	return self._commandCache
end

--[=[
@m cacheCommands
@d Get this guild's commands and cache them.
]=]
function Guild:cacheCommands() shared.cacheCommands(self) end

local oldGuildInit = Guild.__init

function Guild:__init( ... )
	self._commandTable = {}
	self._commandCache = Cache( self._commandTable )
	
	return oldGuildInit(self, ... )
end