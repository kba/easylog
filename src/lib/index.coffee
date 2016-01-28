LogPattern = require 'log-pattern'
FindUp = require 'find-up'
ReadPkgUp = require 'read-pkg-up'
Chokidar = require 'chokidar'
DeepMerge = require 'deepmerge'
Fs = require 'fs'
Path = require 'path'
MkdirP = require 'mkdirp'
WinstonTimer = require 'winston-timer'
Winston = require 'winston'
Inspect = require('util').inspect

NODE_ENV = { 'development', 'production' }
DEFAULT_CONFIG = require './default-easylog.json'
Schema = require './schema'

class EasyLogRoot

	_throw: (msg, meta={}) ->
		@_log.error.apply @_log, arguments
		throw new Error(msg)

	_loadConfigs : ->
		configs = [DEFAULT_CONFIG]
		# package.json / easylog
		# easylog.json
		# easylog-{process.env.NODE_ENV}.json
		json_locations = ['package.json', 'easylog.json', "easylog-#{@node_env}.json"]
		for json_location in @config_file_candidates
			fname = FindUp.sync json_location, {cwd: @cwd}
			if not fname
				@_log.silly "Not found", json_location
				continue
			@_files_to_watch.push json_location
			@_log.silly "Try loading config: #{fname}."
			try
				_config = JSON.parse(Fs.readFileSync(json_location))
			catch e
				@_log.error "Parsing error", fname
			unless _config.easylog
				@_log.silly "No 'easylog' element", fname
				continue
			@_log.info "Loading config: #{fname}: ", _config.easylog
			unless @_validate(Schema.ValidationLevel.FRAGMENT, _config.easylog, fname).valid
				continue
			configs.push _config.easylog
		@config or= {}
		loaded_config = {}
		for _config in configs
			loaded_config = DeepMerge loaded_config, _config
		loaded_config.level_values = DeepMerge @injected_deps.winston.config[loaded_config.levels_name].levels, loaded_config.level_value or {}
		loaded_config.level_colors = DeepMerge @injected_deps.winston.config[loaded_config.levels_name].colors, loaded_config.level_colors or {}
		# @_validate(Schema.ValidationLevel.BASIC, loaded_config)
		unless @_validate(Schema.ValidationLevel.FULL, loaded_config).valid
			@_throw "Invalid conifg", result
		for k of loaded_config
			if k is 'loggers'
				@config[k] = DeepMerge @config[k] or {}, loaded_config[k]
			else
				@config[k] = loaded_config[k]

	_validate: (level, config, fname) ->
		@_log.silly "Validating #{level}", fname
		result = Schema.validate(level, config)
		unless result.valid
			delete result.error?.stack
			msg = "Invalid configuration"
			if fname
				msg += " in '#{fname}'"
			@_log.error msg, Inspect result, colors: true, depth: 3
		return result

	_setupTransports: (logger_name, logger_conf) ->
		transports = []
		enabled_transports = logger_conf.transports or @config.transports
		for transport_name in enabled_transports
			transport_conf = @config.transports_available[transport_name]
			unless transport_conf
				@_throw("Configuration error: No such transport available: #{transport_name}")
			if not transport_conf._transport_defaults of @config.transport_defaults
				@_throw("Configuration error: No such transport_defaults: #{transport_conf._transport_defaults}")
			transport_conf = DeepMerge @config.transport_defaults[transport_conf._transport_defaults], transport_conf
			if not transport_conf.formatter and transport_conf.formatter_pattern
				transport_conf.formatter = LogPattern.formatter(
					pattern: transport_conf.formatter_pattern
					styles: transport_conf.styles
					levelColors: @config.level_colors
				)
			if not transport_conf.filename and transport_conf.filename_pattern
				transport_conf.filename = LogPattern.formatter(transport_conf.filename_pattern)(
					level: transport_conf.level
					logdir: @logdir
					app_name: @package_json.name
				)
			# setup level
			if logger_conf.level
				transport_conf.level = logger_conf.level
			# setup label
			if not transport_conf.label
				transport_conf.label = logger_conf.label
			if not transport_conf.label and transport_conf.label_pattern
				transport_conf.label = @_label_for_filename(transport_conf.label_pattern, DeepMerge logger_conf, transport_conf)
			else
				transport_conf.label = logger_name
			[cls, imports...] = transport_conf._transport_class
			if cls not of @injected_deps
				@_throw "Module '#{cls}' for transport #{transport_name} was not injected"
			cls = @injected_deps[cls]
			for _cls in imports
				cls = cls[_cls]
			transports.push new(cls)(transport_conf)
		return transports

	_setupContainer: ->
		transports = @_setupTransports('/', DeepMerge(@config, {filename: @cwd, child: null}))
		@container = new @injected_deps.winston.Container({transports})
		@container.default = {transports}
		@container.rootLogger = @getLogger(label: @root_label)
		@_log = @getLogger(label: 'easylog', level: @easylog_level)
		if @override_winston
			@injected_deps.winston.log = =>
				@container.rootLogger.log.apply @container.rootLogger, arguments

	_findRootDir : () ->
		for clue in @root_dir_files
			fname = FindUp.sync clue
			if fname
				return Path.dirname(fname)
		return process.cwd()

	_label_for_filename: (pattern, _options) ->
		opts = DeepMerge {pattern: pattern}, _options
		# opts.filename = opts.filename.replace(@cwd, '')
		opts.filename or= '/'
		opts.cwd = process.cwd
		label = LogPattern.formatter(opts)()
		# @_log.silly "Filename '#{opts.filename}' -> Label: '#{label}'"
		return label

	_extend_logger: (logger, options) ->
		logger.child = (name) =>
			childOpts = DeepMerge(options, {child:name})
			return @getLogger childOpts
		WinstonTimer(logger)

	getLogger : (options) ->
		if typeof options is 'string'
			options = {filename: options}
		if 'filename' not of options and 'label' not of options
			@_throw("Must pass an object with a 'filename' or a 'label' property, such as the global 'module'")
		loggerName = options.label or @_label_for_filename(@config.label_pattern, options)
		@config.loggers[loggerName] or= {}
		for k in ['filename', 'child', 'label', 'level']
			@config.loggers[loggerName][k] = options[k] if options[k]
		@container.add(loggerName, transports: @_setupTransports(loggerName, @config.loggers[loggerName]))
		ret = @container.get(loggerName,
			colors: @config.level_colors
			levels: @config.level_values)
		@_extend_logger(ret, options)
		return ret

	_start_watching : ->
		@_files_to_watch or= []
		@_watcher = Chokidar.watch(@_files_to_watch, persistent: false)
		@_watcher.on 'change', =>
			@reload()

	_stop_watching : ->
		@_files_to_watch or= []
		if @_watcher
			@_watcher.unwatch f for f in @_files_to_watch
			@_files_to_watch = []
			@_watcher.close()


	constructor: (options={}) ->
		@node_env                = process.env.NODE_ENV or NODE_ENV.development
		@easylog_level           = options.easylog_level or 'debug'
		@root_dir_files          = options.root_dir_files or ['package.json', '.git', '.hg']
		@cwd                     = options.cwd or @_findRootDir()
		@logdir                  = options.logdir or Path.join(@cwd, 'logs')
		@root_label              = options.root_label or 'ROOT'
		@override_winston        = if 'override_winston' of options then options.override_winston else true
		@injected_deps           = options.injected_deps or {}
		@injected_deps.winston or= Winston
		@package_json            = options.package_json or ReadPkgUp.sync(cwd: @cwd).pkg or {name:'my-app'}
		@config_file_candidates  = [
			'package.json'
			'easylog.json'
			Path.join(process.env.HOME, '.config', @package_json.name, 'easylog.json')
			"easylog-#{@node_env}.json"
		]
		oldLevel = @injected_deps.winston.level
		@_log = @injected_deps.winston
		@_log.level = @easylog_level
		MkdirP.sync @logdir
		@reload()
		@injected_deps.winston.level = oldLevel
	
	reload: ->
		@_stop_watching()
		@_loadConfigs()
		@_log.silly 'EasyLog Configuration:', JSON.stringify(@config, null, 2)
		@_setupContainer()
		@_log.debug 'Reloaded easylog setup'
		@_start_watching()

easyLog = null

module.exports = EasyLog = (options={}) ->
	EasyLog.ensureSetup(options)
	options.label or= easyLog.root_label unless options.filename
	return easyLog.getLogger(options)

EasyLog.ensureSetup = (options) ->
	easyLog = EasyLog.setup(options) unless easyLog

EasyLog.setup = (options={}) ->
	easyLog = new EasyLogRoot(options)

EasyLog.getRoot = -> easyLog

EasyLog.getConfig = ->
	return easyLog.config
