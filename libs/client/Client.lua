local discordia = require("discordia")
local timer = require("timer")
local Resolver = require("client/Resolver")
local shared = require("shared")
local enums = discordia.enums

local Command = require("containers/Command")
local Cache = discordia.class.classes.Cache

local Client = discordia.class.classes.Client

function Client:newSlashCommand( name, guild )
	local c = Command( {type = enums.applicationCommandType.chatInput, name = name, guild = Resolver.guildId( guild )}, self )
	table.insert(self._applicationCommandsUnregistered, c)
	self:_queueCommands()
	return c
end

function Client:newUserCommand( name, guild )
	local c = Command( {type = enums.applicationCommandType.user, name = name, guild = Resolver.guildId( guild )}, self )
	table.insert(self._applicationCommandsUnregistered, c)
	self:_queueCommands()
	return c
end

function Client:newMessageCommand( name, guild )
	local c = Command( {type = enums.applicationCommandType.message, name = name, guild = Resolver.guildId( guild )}, self )
	table.insert(self._applicationCommandsUnregistered, c)
	self:_queueCommands()
	return c
end

function Client:getCommand( id ) return shared.getCommand( self, Resolver.commandId( id ) ) end

function Client:deleteCommand( id ) shared.deleteCommand( self, Resolver.commandId( id ) ) end

function Client.__getters:applicationCommands()
	return self._applicationCommands
end

function Client:_pushCommands()
	if self._applicationCommandsUnregistered[1] then
		local commands = self._applicationCommandsUnregistered
		self._applicationCommandsUnregistered = {}
		
		for _,v in ipairs(commands) do
			if v.guild then
				v:_load( self._api:createGuildApplicationCommand(v._guild, v:_payload()) )
				
				v.guild._applicationCommands:_put( v )
			else
				v:_load( self._api:createGlobalApplicationCommand(v:_payload()) )
				
				self._applicationCommands:_put( v )
			end
			
			v._queued = false
		end
	end
	
	if self._applicationCommandsModified[1] then
		local commands = self._applicationCommandsModified
		self._applicationCommandsModified = setmetatable({}, {__mode = "v"})
		
		local payloads = {}
		
		for _,v in ipairs(commands) do
			assert(v, "you a poopy head")
			local index = v._guild or "global"
			payloads[index] = payloads[index] or {}
			table.insert(payloads[index], v:_payload())
		end
		
		if payloads.global then
			local results, err = self._api:bulkOverwriteGlobalApplicationCommands(payloads.global)
			assert(not err, err)
			for _,v in ipairs(results) do
				self._applicationCommands:_insert( v )
			end
			payloads.global = nil
		end
		
		for guild,payload in pairs(payloads) do
			local results, err = self._api:bulkOverwriteGuildApplicationCommands(guild, payload)
			assert(not err, err)
			commands = self:getGuild(guild)._applicationCommands
			for _,v in ipairs(results) do
				commands:_insert( v )
			end
		end
	end
end

function Client:_queueCommands()
	if self._commandUpdater then return end
	self._commandUpdater = timer.setImmediate(function()
		self._commandUpdater = nil
		coroutine.wrap(Client._pushCommands)(self)
	end)
end

local oldClientInit = Client.__init

function Client:__init( ... )
	self._applicationCommandsUnregistered = {}
	self._applicationCommandsModified = setmetatable({}, {__mode = "v"})
	self._applicationCommands = Cache( {}, Command, self )
	
	self._commandUpdater = true
	
	local initResults = oldClientInit(self, ... )
	
	self:onceSync("ready", function()
		self:_pushCommands()
		
		local results, err = self._api:getGlobalApplicationCommands()
		assert(not err, err)
		for _,v in ipairs(results) do
			self._applicationCommands:_insert( v )
		end
		
		for guild in self.guilds:iter() do
			local results, err = self._api:getGuildApplicationCommands( guild.id )
			assert(not err, err)
			for _,v in ipairs(results) do
				guild._applicationCommands:_insert( v )
			end
		end
		
		self:info("Registered application commands")
		
		self._commandUpdater = nil
	end)
	
	self:on("interactionCreate", function( interaction )
		local data = interaction.data
		local command = (data.guild_id and self:getGuild(data.guild_id) or self)._applicationCommands:get( data.id )
		if not command then self:warning("Unhandled application command callback: %s", data.id) return end
		
		local group, sub
		for _,v in ipairs(data.options or {}) do
			if v.type == enums.applicationCommandOptionType.subCommandGroup then
				group = v
				for _,v in ipairs(v.options or {}) do
					if v.type == enums.applicationCommandOptionType.subCommand then
						sub = v
					end
				end
				break
			elseif v.type == enums.applicationCommandOptionType.subCommand then
				sub = v
				break
			end
		end
		
		local callbacks, args, argsOrdered
		
		if group and sub then -- command is a subCommandGroup
			local container = command
			for _,v in ipairs(container._options) do
				if v.name == group.name then
					container = v
					break
				end
			end
			for _,v in ipairs(container._options) do
				if v.name == sub.name then
					container = v
					break
				end
			end
			
			callbacks = container._listeners or {}
		elseif sub then -- command is a subCommand
			local container = command
			for i,v in ipairs(container._options) do
				if v.name == sub.name then
					container = v
					break
				end
			end
			
			callbacks = container._listeners or {}
		elseif not group then -- command has no sub commands
			callbacks = command._listeners or {}
		end
		
		if not callbacks then self:warning("idk XD") return end
		
		for _,v in ipairs(callbacks) do
			coroutine.wrap(v)(interaction, args, argsOrdered)
		end
		
	end)
	
	return initResults
end

return Client