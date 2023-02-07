local discordia = require("discordia")
local Resolver = require("client/Resolver")
local Cache = discordia.class.classes.Cache
local enum = require("enums")
local shared = require("shared")

local Command = require("containers/Command")

local Guild = discordia.class.classes.Guild

function Guild:newSlashCommand( name ) return shared.newCommand( self, self._client, "userInput", name ) end

function Guild:newUserCommand( name, guild ) return shared.newCommand( self, self._client, "userInput", name ) end

function Guild:newMessageCommand( name, guild ) return shared.newCommand( self, self._client, "userInput", name ) end

function Guild:getGlobalCommand( id ) return shared.getCommand( self, Resolver.commandId( id ) ) end

function Guild:deleteGlobalCommand( id ) shared.deleteCommand( self, Resolver.commandId( id ) ) end

function Guild.__getters:applicationCommands()
	return self._commandCache
end

function Guild:cacheCommands() shared.cacheCommands(self) end

local oldGuildInit = Guild.__init

function Guild:__init( ... )
	self._commandTable = {}
	self._commandCache = Cache( self._commandTable )
	
	return oldGuildInit(self, ... )
end