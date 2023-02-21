local discordia = require("discordia")
local timer = require("timer")
local class = discordia.class
local Container = class.classes.Container
local Resolver = require("client/Resolver")

local Option, get = class("Option", Container)

local function queue( self )
	if self._command._queued then return end
	self.client:_queueCommands()
	table.insert(self.client._applicationCommandsModified, self._command)
	self._command._queued = true
end

function Option:__hash()
	return self._command:__hash()
end

function Option:_payload()
	local payload = {
		type = self._type,
		name = self._name, description = self._description,
		required = not not self._required,
		channel_types = self._channel_types,
		min_value = self._min_value, max_value = self._max_value, min_length = self._min_length, max_length = self._max_length,
		autocomplete = not not self._autocomplete
	}
	if self._choices then
		payload.choices = {}
		for i,v in ipairs(self._choices) do
			payload.choices[i] = v:_payload()
		end
	end
	if self._options then
		payload.options = {}
		for i,v in ipairs(self._options) do
			if v._enabled ~= false then
				table.insert(payload.options, v:_payload())
			end
		end
	end
	return payload
end

function Option:_load( data )
	self._name, self._description = data.name, data.description
	self._required = data.required
	self._channel_types = data.channel_types
	self._min_value, self._max_value, self._min_length, self._max_length = data.min_value, data.max_value, data.min_length, data.max_length
	self._autocomplete = data.autocomplete and self._autocomplete
	if data.options then
		self._options = self._options or {}
		local options = {}
		for i,v in ipairs(data.options) do
			options[i] = self._options[i] and self._options[i]:_load(v) or Option(v, self)
		end
		self._options = options
	end
	return self
end

function Option:__init( data, parent, command )
	self._command = command or parent._command
	self._type = data.type
	
	Container.__init(self, {}, parent)
	
	self:_load( data )
end

function get.type(self)
	return self._type
end

function Option:setName( name )
	self._name = name
	
	queue( self )
	
	return self
end

function get.name(self)
	return self._name
end

function Option:setDescription( description )
	self._description = description
	
	queue( self )
	
	return self
end

function get.description(self)
	return self._description
end

function Option:setRequired( isRequired )
	self._required = isRequired
	
	queue( self )
	
	return self
end

function get.required(self)
	return self._required
end

function Option:addChoice()
	local o = Choice( {}, self, self.client )
	self._choices = self._choices or {}
	table.insert(self._choices, o)
	return o
end

function Option:deleteChoice( index )
	table.remove(self._choices, index)
	
	queue( self )
	
	return self
end

function get.choices(self)
	return self._choices
end

function Option:addOption( optionType, name )
	local o = Option( {type = optionType, name = name}, self )
	self._options = self._options or {}
	table.insert(self._options, o)
	return o
end

function Option:deleteOption( index )
	table.remove(self._options, index)
	
	queue( self )
	
	return self
end

function get.options(self)
	return self._options
end

function Option:setChannelType( channelType, isShown )
	self._channel_types = self._channel_types or {}
	local exists = false
	for i,v in ipairs(self._channel_types) do
		if v == channelType then
			self._channel_types = isShown and tonumber(channelType) or nil
		end
	end
	if not exists then table.insert( self._channel_types, channelType ) end
	
	queue( self )
	
	return self
end

function get.channelTypes(self)
	return self._channel_types
end

function Option:setMinValue( value )
	self._min_value = value
	
	queue( self )
	
	return self
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

function Option:callback( callback )
	self._listeners = self._listeners or {}
	table.insert(self._listeners, callback)
	
	return self
end

function Option:autocomplete( callback )
	self._autocomplete = callback
	
	return self
end

function Option:setEnabled( isEnabled )
	self._enabled = isEnabled
	
	queue( self )
	
	return self
end

function Option:remove()
	for i,v in ipairs( self._parent._options ) do
		if self == v then
			table.remove( self._parent._options, i )
			break
		end
	end
end

return Option