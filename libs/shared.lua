-- shared functions between Client and Guild, DRY and all

local discordia = require("discordia")
local Resolver = require("client/Resolver")
local class = discordia.class
local enum = discordia.enums

local Command = require("containers/Command")

local shared = {}

function shared.newCommand( self, client, commandType, name, overwriteGuild )
	local tblIndex = self._commandInit and "_commandInit" or "_commandTable"
	local c = Command( {type = enum.applicationCommandType[cType], guild = Resolver.guildId(overwriteGuild or self), name = name}, self, client )
	local exists = false
	for i,other in ipairs(self[tblIndex]) do
		if c:compare(other) then
			self[tblIndex][i] = c
			exists = true
		end
	end
	if not exists then table.insert(self[tblIndex], c) end
	return c
end

function shared.deleteCommand( self, id )
	local c = self._commandCache:find(function(c) return c.id == id end)
	c:delete()
end

function shared.getCommand( self, id )
	local c = self._commandCache:find(function(c) return c.id == id end)
	if not c then
		if class.isInstance( self, class.classes.Guild ) then
			c = Command( self._api:getGlobalApplicationCommand(id), self, self._client )
		else
			c = Command( self._api:getGlobalApplicationCommand(id), self, self )
		end
		table.insert(self._commandTable, c)
	end
	return c
end

function shared.cacheCommands( self )
	local commands
	if class.isInstance( self, class.classes.Guild ) then
		commands = self._api:getGuildApplicationCommands( self._id )
	else
		commands = self._api:getGlobalApplicationCommands()
	end
	for _,command in ipairs(commands) do
		local c = Command( command, self, self )
		for i,other in ipairs(self._commandTable) do
			if other._id then if self._id == other._id then self._commandTable[i] = other return end
			elseif self:compare(other) then return end
		end
		table.insert(self._commandTable, c)
	end
end

return shared