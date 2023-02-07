local discordia = require("discordia")
local timer = require("timer")
local class = discordia.class
local Snowflake = class.classes.Snowflake
local Resolver = require("client/Resolver")

local Option, get = class("Option", Snowflake)

function Option:_raw()
	local payload = {
		type = self._type,
		name = self._name, description = self._description,
		required = not not self._required,
		choices = {}, options =  {}, channel_types = self._channel_types
		min_value = self._min_value, max_value = self._max_value, min_length = self._min_length, max_length = self._max_length,
		autocomplete = not not self._autocomplete
	}
	for i,v in ipairs(self._choices) do
		payload.choices[i] = v:_raw()
	end
	for i,v in ipairs(self._options) do
		payload.options[i] = v:_raw()
	end
	return payload
end

function Option:__init( data, parent, command, client )
	self._client, self._command = client or parent._client, command or parent._command
	
	Snowflake.__init(self, data, parent)
end

function get.type(self)
	return self._type
end

function Option:setName( name )
	self._name = name
	
	self._command:_queue()
end

function get.name(self)
	return self._name
end

function Option:setDescription( description )
	self._description = name
	
	self._command:_queue()
end

function get.description(self)
	return self._description
end

function Option:setRequired( isRequired )
	self._required = isRequired
	
	self._command:_queue()
end

function get.required(self)
	return self._required
end

function Option:addChoice()
	local o = Choice( {}, self, self._client )
	table.insert(self._choices, o)
	return o
end

function Option:deleteChoice( index )
	table.remove(self._choices, index)
	
	self._command:_queue()
end

function get.choices(self)
	return self._choices
end

function Option:addOption()
	local o = Option( {}, self, self._client )
	table.insert(self._options, o)
	return o
end

function Option:deleteOption( index )
	table.remove(self._options, index)
	
	self._command:_queue()
end

function get.options(self)
	return self._options
end

function Option:setChannelType( channelType, isShown )
	local exists = false
	for i,v in ipairs(self._channel_types) do
		if v == channelType then
			self._channel_types = isShown and tonumber(channelType) or nil
		end
	end
	if not exists then table.insert( self._channel_types, channelType ) end
	
	self._command:_queue()
end

function get.channelTypes(self)
	return self._channel_types
end

function Option:setMinValue( value )
	self._min_value = value
	
	self._command:_queue()
end

function get.minValue(self)
	return self._min_value
end

function get.maxValue(self)
	return self._max_value
end

function get.minLength(self)
	return self._min_length
end

function get.maxLength(self)
	return self._max_length
end

function Option:autocomplete( callback )
	self._autocomplete = callback
end

return Option