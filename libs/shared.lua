-- shared functions between Client and Guild, DRY and all

local discordia = require("discordia")
local Resolver = require("client/Resolver")
local class = discordia.class
local enum = discordia.enums

local Command = require("containers/Command")

local shared = {}

function shared.newCommand( self, client, commandType, name, overwriteGuild )
	local c = Command( {type = enum.applicationCommandType[cType], guild = Resolver.guildId(overwriteGuild or self), name = name}, self, client )
	local exists = false
	for i,other in ipairs(self._commandTable) do
		if c:compare(other) then
			self._commandTable[i] = c
			exists = true
		end
	end
	if not exists then table.insert(self._commandTable, c) end
	return c
end

function shared.deleteCommand( self, id )
	local c = self._commandCache:find(function(c) return c.id == id end)
	c:delete()
end

function shared.getCommand( self, command )
	command = Resolver.commandId( command )
	local c
	for _,v in ipairs(self._commandTable) do
		if v._id == command then c = v break end
	end
	if not c then
		if class.isInstance( self, class.classes.Guild ) then
			c = Command( self.client._api:getGuildApplicationCommand(self._id, command), self )
		else
			c = Command( self._api:getGlobalApplicationCommand(command), self )
		end
		table.insert(self._commandTable, c)
	end
	return c
end

function shared.cacheCommands( self )
	local commands
	if class.isInstance( self, class.classes.Guild ) then
		commands = self.client._api:getGuildApplicationCommands( self._id )
	else
		commands = self._api:getGlobalApplicationCommands()
	end
	for _,command in ipairs(commands) do
		local c = Command( command, self, self )
		for i,other in ipairs(self._commandTable) do
			if other._id then if c._id == other._id then self._commandTable[i] = other return end
			elseif c:compare(other) then return end
		end
		table.insert(self._commandTable, c)
	end
end

return shared