--[=[
@c Client
@d Some new functions added onto Discordia's Client.
]=]

local Client = {}

--[=[
@m newSlashCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a slash command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newSlashCommand( name, guild )
	
end

--[=[
@m newUserCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a user command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newUserCommand( name, guild )
	
end

--[=[
@m newMessageCommand
@p name string
@op guild Guild-ID-Resolvable
@r Command
@d Create or overwrite (if it already exists) a message command. Providing a guild will make it a guild command, elsewise it will be a global command.
]=]
function Client:newMessageCommand( name, guild )
	
end

--[=[
@m getCommand
@p id Command-ID-Resolvable
@r Command
@d Get a global command.
]=]
function Client:getGlobalCommand( id )
	
end

--[=[
@m getGuildCommand
@p guild Guild-ID-Resolvable
@p id Command-ID-Resolvable
@r Command
@d Get a guild command.
]=]
function Client:getGuildCommand( guild, id )
	
end

--[=[
@m cacheCommands
@d Get all commands and cache them.
]=]
function Client:cacheCommands()
	
end

return Client