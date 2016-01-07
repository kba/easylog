DeepMerge      = require 'deepmerge'
TV4            = require 'tv4'
Traverse       = require 'traverse'
Inspect        = require('util').inspect
DEFAULT_CONFIG = require '../lib/default-easylog.json'

BaseSchema =
	title: 'easylog configuration'
	$schema: "http://json-schema.org/draft-04/schema#",
	# http://standards.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html#idm140276333767712
	definitions: {}
	additionalProperties: false
	properties:
		levels_name:
			type: 'string'
			default: 'npm'
			enum: ['cli', 'npm', 'syslog']
		level_values:
			type: 'object'
			$ref: '#/definitions/level_values'
		level:
			type: 'string'
			$ref: '#/definitions/level'
		level_colors:
			type: 'object'
			$ref: '#/definitions/level_colors'
		label_pattern:
			type: 'string'
			$ref: '#/definitions/label_pattern'
		transport_defaults:
			type: 'object'
			$ref: '#/definitions/transport_defaults'
		transports:
			type: 'object'
			$ref: '#/definitions/transports'
		transports_available:
			type: 'object'
			$ref: '#/definitions/transports_available'
		loggers:
			type: 'object'
			$ref: '#/definitions/loggers'
	required: [
		'levels_name'
		'level_values'
		'level_colors'
		'transport_defaults'
		'transports_available'
		'label_pattern'
		'transports'
	]

BaseSchema.definitions.transports =
	type: 'array'
	items:
		type: 'string'

BaseSchema.definitions.label_pattern =
	name: 'Pattern of a label'
	type: 'string'

BaseSchema.definitions.transport_defaults =
	type: 'object'
	additionalProperties: false
	patternProperties:
		"^[a-z][-a-z_0-9]+$":
			type: 'object'
			$ref: '#/definitions/transport_default'

BaseSchema.definitions.transport_default =
	additionalProperties: false
	properties:
		label_pattern:
			type: 'string'
			$ref: '#/definitions/label_pattern'
		filename_pattern:
			type: 'string'
			$ref: '#/definitions/filename_pattern'
		formatter_pattern:
			type: 'string'
			$ref: '#/definitions/formatter_pattern'
		silent:
			type: 'boolean'
		host:
			type: 'string'
		port:
			type: 'integer'
		maxsize:
			type: 'integer'
		level:
			type: 'string'
			$ref: '#/definitions/level'
		styles:
			type: 'object'
			additionalProperties: true
		_transport_class:
			type: 'array'
			minItems: 2
			items:
				type: 'string'
	required: [
		'_transport_class'
	]

BaseSchema.definitions.loggers =
	type: 'object'
	additionalProperties: false
	properties:
		_root:
			type: 'object'
	patternProperties:
		'.*':
			type: 'object'
			properties:
				filename:
					type: 'string'
				label:
					type: 'string'
				level:
					type: 'string'
					$ref: '#/definitions/level'
			additionalProperties: false

BaseSchema.definitions.transports_available =
	type: 'object'
	additionalProperties: false
	patternProperties:
		"^[a-z][-a-z_0-9]+$":
			type: 'object'
			$ref: '#/definitions/transport_available'

BaseSchema.definitions.level =
	type: 'string'

BaseSchema.definitions._transport_defaults =
	type: 'string'

BaseSchema.definitions.transport_available =
	type: 'object'
	additionalProperties: true
	properties:
		_transport_defaults:
			$ref: '#/definitions/_transport_defaults'
	required: [
		'_transport_defaults'
	]

BaseSchema.definitions.level_values =
	additionalProperties: false
	patternProperties:
		'^[a-z]+$':
			type: 'integer'
	minProperties: 1

BaseSchema.definitions.level_colors =
	additionalProperties: false
	patternProperties:
		'^[a-z]+$':
			type: 'string'
	minProperties: 1

NonRequireSchema = DeepMerge {}, BaseSchema
Traverse(NonRequireSchema).forEach (obj) ->
	if typeof obj is 'object' and 'required' of obj
		delete obj.required

module.exports.ValidationLevel = ValidationLevel = { 'FRAGMENT', 'BASIC', 'FULL' }

module.exports.schema = schema = (validationLevel, config) ->
	if validationLevel is ValidationLevel.BASIC
		return BaseSchema
	else if validationLevel is ValidationLevel.FRAGMENT
		return NonRequireSchema
	else if validationLevel is ValidationLevel.FULL
		unless typeof config is 'object'
			throw new Error("Must pass config option to generate schema at validationLevel #{validationLevel}.")
		ConfigSchema = DeepMerge {}, BaseSchema
		def = ConfigSchema.definitions
		# level_colors / level_values
		config.level_values or= {}
		config.level_colors or= {}
		levelNames = Object.keys(config.level_values)
		def.level.enum = levelNames
		for prop, range of {level_colors:'string', level_values:'integer'}
			delete def[prop].patternProperties
			def[prop].required = levelNames
			def[prop].properties = {}
			def[prop].properties[k] = {type: range} for k in levelNames
		# _transport_defaults -> transport_defaults
		def._transport_defaults.enum = Object.keys(config.transport_defaults)
		# transports -> transports_available
		def.transports.items.enum = Object.keys(config.transports_available)
		# console.log Inspect ConfigSchema, colors: true, depth: 3
		return ConfigSchema
	else
		throw new Error("Unknown validation level #{validationLevel}. Possible values: #{ValidationLevel}")

module.exports.validate = validate = (validationLevel, config) ->
	return TV4.validateResult(schema.apply(@, arguments), config)
