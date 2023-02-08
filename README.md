# Discordia Commands

A library for [Discordia 2](https://github.com/SinisterRectus/Discordia) that provides Application Command support. I tried to keep everything as close to Discordia as possible, so it should be fairly familiar.

# Installation

I won't be putting this on Lit, so you will have to clone it.

1. Follow the instructions for installing [Discordia](https://github.com/SinisterRectus/Discordia).
2. Also install [Discordia Interactions](https://github.com/Bilal2453/discordia-interactions). (not required but highly recommended)
3. `cd` into your bot directory.
4. Then run `git clone https://github.com/Benbebop/discordia-commands ./deps/discordia-commands`

You should then have a folder named `discordia-commands` in your deps folder.

# Application Commands

Application Commands can be boiled down to global, and guild and slash, user, and message.

Global commands can be used anywhere, including dms, and give your bot a nifty little badge. Guild commands are restricted to just one guild and have some extra stuff like permissions.

Slash commands are the most common, they are inputted though text and allow for parameters. User commands are inputted by right clicking on your bot and navigating to `Apps>[your command]`. Message commands are identical to user commands only they are activated by right clicking on your bot's messages.

# Usage

Commands can be created, modified, or deleted at any point (including before running the bot).

Interally most operations rely on immediate timers, so actual requests to discord are made at the end of an event loop. This can be bypassed if this isnt what you want. If a command is modified before running the bot, everything is queued to run at `ready`.

Here is a quick example to get a general idea of how this library works.

```lua
local discordia = require("discordia")
require("discordia-commands")
local enums = discordia.enums

local client = discordia.Client()

local dl = client:newSlashCommand( "say" )
dl:setDescription( "Make the bot say something cool" )
local o = dl:addOption( enums.applicationCommandOptionType.string, "content" )
o:setDescription( "What you want to make the bot say" )
o:setRequired( true )

client:run("Bot " .. TOKEN)
```
*still working on callbacks for commands, you will have to make them yourself*

For further functionality, see the wiki.

# Help

If you encounter any issues, you can dm or ping me in the [discordia server](https://discord.gg/EzRYYDW) at [Benbebop#7867](https://discord.gg/users/459880024187600937).