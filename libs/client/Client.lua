local discordia = require("discordia")
local Resolver = require("client/Resolver")
local Cache = discordia.class.classes.Cache
local enums = discordia.enums
local shared = require("shared")

local Command = require("containers/Command")

local Client = discordia.class.classes.Client

function Client:newSlashCommand( name, guild ) return shared.newCommand( guild and self:getGuild(Resolver.guildId(guild)) or self, self, "chatInput", name, guild ) end

function Client:newUserCommand( name, guild ) return shared.newCommand( guild and self:getGuild(Resolver.guildId(guild)) or self, self, "user", name, guild ) end

function Client:newMessageCommand( name, guild ) return shared.newCommand( guild and self:getGuild(Resolver.guildId(guild)) or self, self, "message", name, guild ) end

function Client:getGlobalCommand( id ) return shared.getCommand( self, Resolver.commandId( id ) ) end

function Client:deleteGlobalCommand( id ) shared.deleteCommand( self, Resolver.commandId( id ) ) end

function Client.__getters:applicationCommands()
	return self._commandCache
end

function Client:cacheCommands() shared.cacheCommands(self) end

local oldClientInit = Client.__init

function Client:__init( ... )
	self._commandInit = {}
	self._commandCache = Cache( self._commandInit )
	
	local initResults = oldClientInit(self, ... )
	
	self:on("ready", function()
		self._commandTable = self._commandInit self._commandInit = nil
		
		self:cacheCommands()
		
		local toRemove = {}
		for i,v in ipairs(self._commandTable) do
			v:_execute()
			if v._guild then
				table.insert( self:getGuild(v._guild)._commandTable, v )
				table.insert( toRemove, i )
			end
		end
		for _,v in ipairs(toRemove) do table.remove(self._commandTable, v) end
	end)
	
	self:on("interactionCreate", function( interaction )
		if interaction.type ~= enums.interactionType.applicationCommand then return end
		local data = interaction.data
		local command
		if data.guild_id then
			command = self:getGuild( data.guild_id ):getGuildCommand( data.id )
		else
			command = self:getGlobalCommand( data.id )
		end
		if (not command) or (not command._listeners) then self:warning("Unhandled command event: %s", interaction.data.name) return end
		local args, argsOrdered
		if interaction.data.type == enums.applicationCommandType.chatInput then
			args, argsOrdered = {}, {}
			for i,v in ipairs(interaction.data.options) do
				argsOrdered[i] = v.value
				args[v.name] = v.value
			end
		end
		for _,v in ipairs( command._listeners ) do
			coroutine.wrap(v)( interaction, args, argsOrdered )
		end
	end)
	
	return initResults
end

return Client