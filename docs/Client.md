All additions made to the Client class.

*Instances of this class should not be constructed by users.*

## Properties

| Name | Type | Description |
|-|-|-|
| applicationCommands | Cache | All global commands currently cached to the client. This also contains guild commands if the client has not been run yet. Note: This is not updated by gateway events, you can request an update by using `Client:cacheCommands()`. |

## Methods

### cacheCommands()

Get all global commands and cache them.

**Returns:** 

----

### getCommand(id)

| Parameter | Type |
|-|-|
| id | string |

Get a global command.

**Returns:** [[Command]]

----

### newMessageCommand(name, guild)

| Parameter | Type | Optional |
|-|-|:-:|
| name | string |  |
| guild | Guild-ID-Resolvable | ✔ |

Create or overwrite (if it already exists) a message command. Providing a guild will make it a guild command, elsewise it will be a global command.

**Returns:** [[Command]]

----

### newSlashCommand(name, guild)

| Parameter | Type | Optional |
|-|-|:-:|
| name | string |  |
| guild | Guild-ID-Resolvable | ✔ |

Create or overwrite (if it already exists) a slash command. Providing a guild will make it a guild command, elsewise it will be a global command.

**Returns:** [[Command]]

----

### newUserCommand(name, guild)

| Parameter | Type | Optional |
|-|-|:-:|
| name | string |  |
| guild | Guild-ID-Resolvable | ✔ |

Create or overwrite (if it already exists) a user command. Providing a guild will make it a guild command, elsewise it will be a global command.

**Returns:** [[Command]]

----

