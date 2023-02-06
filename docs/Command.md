#### *extends Snowflake*

Represents an application command of any type. This object has no way to update automatically, so changes will not register until manually requested, this usually isnt an issue unless you control the bot through multiple different instances. No check are made for whether an operation is valid for the type of command you are making, so be weary what you are inputting.

*Instances of this class should not be constructed by users.*

## Properties

| Name | Type | Description |
|-|-|-|
| defaultPermission | boolean | Whether this command is enabled by default in a guild. This only applies to guild commands. |
| description | string | The command's description. This should be between 1 and 100 characters in length. This only applies to chatInput commands. |
| dmPermission | boolean | Whether this command can be used in dms. This only applies to global commands. |
| guild | nil/string/[[Guild]] | The guild in which this command was registered. This only applies to guild commands. |
| type | number | The command type. Use the applicationCommandType enumeration for a human-readable representation. |
| name | string | The command's name. This should be between 1 and 32 characters in length. |
| nsfw | boolean | Whether this command is age-restricted. |
| options | table | A table of options for this command. This only applies to chatInput commands. |

## Methods

### removeOption(index)

| Parameter | Type |
|-|-|
| index | number |

Remove an option from the command. This is the same as `table.remove(Command.options, index)`. This only applies to chatInput commands.

**Returns:** 

----

### addOption()

Add a new option to the command. This only applies to chatInput commands.

**Returns:** option

----

### compare(other)

| Parameter | Type |
|-|-|
| other | [[Command]] |

Whether this command would overwrite the other when pushed to discord.

**Returns:** 

----

### delete()

Deletes the command

**Returns:** 

----

### getDefaultMemberPermissions()

Get permissions required to use this command. This only applies to guild commands.

**Returns:** Permissions-Resolvable

----

### overwrite(data)

| Parameter | Type |
|-|-|
| data | table |

Overwrite command data with a raw table.

**Returns:** 

----

### setDefaultMemberPermissions(permissions)

| Parameter | Type |
|-|-|
| permissions | Permissions-Resolvable |

Set permissions required to use this command. This only applies to guild commands.

**Returns:** 

----

### setDefaultPermission(hasDefaultPermission)

| Parameter | Type |
|-|-|
| hasDefaultPermission | boolean |

Whether this command is enabled by default in a guild. This only applies to guild commands. Note: This is a soon depricated feature, `Command.defaultMemberPermissions:disableAll()` should be used instead

**Returns:** 

----

### setDescription(description)

| Parameter | Type |
|-|-|
| description | string |

Set the command's description. This should be between 1 and 100 characters in length. This only applies to chatInput commands.

**Returns:** 

----

### setDmPermission(hasDmPermission)

| Parameter | Type |
|-|-|
| hasDmPermission | boolean |

Manually overwrite command data with a raw table.

**Returns:** 

----

### setName(name)

| Parameter | Type |
|-|-|
| name | string |

Set the command's name. This should be between 1 and 32 characters in length.

**Returns:** 

----

### setNsfw(isNsfw)

| Parameter | Type |
|-|-|
| isNsfw | boolean |

Set whether this command is age-restricted.

**Returns:** 

----

