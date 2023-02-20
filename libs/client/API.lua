local discordia = require("discordia")
local API = discordia.class.classes.API

local f = string.format

local endpoints = require("endpoints")

-- global commands --

function API:getGlobalApplicationCommands()
	return self:request("GET", f(endpoints.GLOBAL_COMMANDS, self._client.user.id))
end

function API:createGlobalApplicationCommand(payload)
	return self:request("POST", f(endpoints.GLOBAL_COMMANDS, self._client.user.id), payload)
end

function API:getGlobalApplicationCommand(id)
	return self:request("GET", f(endpoints.GLOBAL_COMMAND, self._client.user.id, id))
end

function API:editGlobalApplicationCommand(id, payload)
	return self:request("PATCH", f(endpoints.GLOBAL_COMMAND, self._client.user.id, id), payload)
end

function API:deleteGlobalApplicationCommand(id)
	return self:request("DELETE", f(endpoints.GLOBAL_COMMAND, self._client.user.id, id))
end

function API:bulkOverwriteGlobalApplicationCommands(payload)
	return self:request("PUT", f(endpoints.GLOBAL_COMMANDS, self._client.user.id), payload)
end

-- guild commands --

function API:getGuildApplicationCommands(guild_id)
	return self:request("GET", f(endpoints.GUILD_COMMANDS, self._client.user.id, guild_id))
end

function API:createGuildApplicationCommand(guild_id, payload)
	return self:request("POST", f(endpoints.GUILD_COMMANDS, self._client.user.id, guild_id), payload)
end

function API:getGuildApplicationCommand(guild_id, command_id)
	return self:request("GET", f(endpoints.GUILD_COMMAND, self._client.user.id, guild_id, command_id))
end

function API:editGuildApplicationCommand(guild_id, command_id, payload)
	return self:request("PATCH", f(endpoints.GUILD_COMMAND, self._client.user.id, guild_id, command_id), payload)
end

function API:deleteGuildApplicationCommand(guild_id, command_id)
	return self:request("DELETE", f(endpoints.GUILD_COMMAND, self._client.user.id, guild_id, command_id))
end

function API:bulkOverwriteGuildApplicationCommands(guild_id, payload)
	return self:request("PUT", f(endpoints.GUILD_COMMANDS, self._client.user.id, guild_id), payload)
end

-- permissions --

function API:getApplicationCommandsPermissions(guild_id)
	return self:request("GET", f(endpoints.GLOBAL_COMMANDS_PERMISSIONS, self._client.user.id, id))
end

function API:getApplicationCommandPermissions(guild_id, command_id)
	return self:request("GET", f(endpoints.GUILD_COMMAND_PERMISSIONS, self._client.user.id, guild_id, command_id))
end

function API:editApplicationCommandPermissions(guild_id, command_id, payload)
	return self:request("PUT", f(endpoints.GUILD_COMMAND_PERMISSIONS, self._client.user.id, guild_id, command_id), payload)
end

return API
