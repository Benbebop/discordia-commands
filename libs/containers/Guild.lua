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

local oldGuildInit = Guild.__init

function Guild:__init( ... )
	self._commandTable = {}
	self._commandCache = Cache( self._commandTable )
	
	return oldGuildInit(self, ... )
end