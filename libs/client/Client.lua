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

local function processError(self, err)
	if not err then return end
	if err:match("^%s*HTTP%s*Error%s*(%d+)") ~= "50035" then error(err) end
	err = err:match("[\n\r]%s+(.+)$")
	self:warning("Malformed commands: " .. err)
	return err
end

function Client:_pushCommands()
	if self._applicationCommandsUnregistered[1] then
		local commands = self._applicationCommandsUnregistered
		self._applicationCommandsUnregistered = {}
		
		local payloads, sorted = {}, {}
		
		for _,v in ipairs(commands) do
			assert(v, "you a poopy head")
			local index = v._guild or "global"
			payloads[index] = payloads[index] or {}
			sorted[index] = sorted[index] or {}
			table.insert(payloads[index], v:_payload())
			table.insert(sorted[index], v)
		end
		
		commands = nil
		
		if payloads.global then
			local results, err = self._api:bulkOverwriteGlobalApplicationCommands(payloads.global)
			if processError(self, err) then return end

			for _,v in ipairs(sorted.global) do
				for _,k in ipairs(results) do
					if v:compare(k) then
						v:_load(k)
						self._applicationCommands:_put( v )
					end
				end
			end
			payloads.global = nil
			sorted.global = nil
		end
		
		for guild,payload in pairs(payloads) do
			local results, err = self._api:bulkOverwriteGuildApplicationCommands(guild, payload)
			if processError(self, err) then return end
			
			for _,v in ipairs(sorted[guild]) do
				for _,k in ipairs(results) do
					if v:compare(k) then
						v:_load(k)
						v.guild._applicationCommands:_put( v )
					end
				end
			end
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
			if processError(self, err) then return end
			
			for _,v in ipairs(results) do
				self._applicationCommands:_insert( v )
			end
			payloads.global = nil
		end
		
		for guild,payload in pairs(payloads) do
			local results, err = self._api:bulkOverwriteGuildApplicationCommands(guild, payload)
			if processError(self, err) then return end
			
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

function Client:defaultCommandCallback(callback)
	self._defaultCommandCallback = callback
end

local oldClientInit = Client.__init

function Client:__init( ... )
	self._applicationCommandsUnregistered = {}
	self._applicationCommandsModified = setmetatable({}, {__mode = "v"})
	self._applicationCommands = Cache( {}, Command, self )
	
	self._commandUpdater = true
	
	local initResults = oldClientInit(self, ... )
	
	self:onceSync("ready", function()
		local init = self._options.initCommands
		if init or init == nil then self:_pushCommands() end
		
		local results, err = self._api:getGlobalApplicationCommands()
		assert(not err, err)
		for _,v in ipairs(results) do
			self._applicationCommands:_insert( v )
		end
		
		self:info("Registered application commands")
		
		self._commandUpdater = nil
	end)
	
	self:on("interactionCreate", function( interaction )
		if interaction.type ~= enums.interactionType.applicationCommand then return end
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
		
		local callbacks

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
			
			callbacks = container._listeners or false
		elseif sub then -- command is a subCommand
			local container = command
			for i,v in ipairs(container._options) do
				if v.name == sub.name then
					container = v
					break
				end
			end
			
			callbacks = container._listeners or false
		elseif not group then -- command has no sub commands
			callbacks = command._listeners or false
		end
		
		local args, argsOrdered = {}, {}
		
		local options = (sub or data).options
		if options then
			for _,v in ipairs((sub or data).options) do
				table.insert(argsOrdered, v.value)
				args[v.name] = v.value
			end
		end
		
		if callbacks == false then 
			if self._defaultCommandCallback then self._defaultCommandCallback(interaction, args, argsOrdered) end
			self:warning("No callbacks registered for: %s", (group or sub or "nil")) 
			return
		end
		if not callbacks then self:warning("idk XD") return end
		
		for _,v in ipairs(callbacks) do
			coroutine.wrap(v)(interaction, args, argsOrdered)
		end
		
	end)
	
	return initResults
end

return Client
