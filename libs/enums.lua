-- THIS IS DISCORDIA COMMAND BITCH, WE TAB IN THIS MUTHAFUCKA BETTA TAKE YO SPACE ASS BACK TO DISCORDIA INTERACTIONS

local discordia = require("discordia")
local enums = discordia.enums

enums.applicationCommandType = {
	chatInput = 1,
	user = 2,
	message = 3
}

enums.applicationCommandOptionType = {
	subCommand = 1,
	subCommandGroup = 2,
	string = 3,
	integer = 4,
	boolean = 5,
	user = 6,
	channel = 7,
	role = 8,
	mentionable = 9,
	number = 10,
	attachment = 11
}

enums.applicationCommandPermissionType = {
	role = 1,
	user = 2,
	channel = 3
}

return enums