module.exports.npm =
	colors:
		silly: 'magenta'
		debug: 'yellow'
		info: 'green'
		warn: 'red'
		error: 'red bold'
module.exports = DEFAULT_CONFIG =
	levels_name: 'npm'
	label_pattern: '%s(,^src/|lib/|src/lib/,,%-pkgdir/%path{%name}%?(%config{child})(#%config{child}))'
	transport_defaults:
		console:
			_transport_class: ['winston', 'transports', 'Console']
			label_pattern: '%pkg{name}' +
						   '%@{sep}(:)' +
						   '%@{name}(%path{%name})' +
						   '%?(%config{child})(' +
						       '%@{sep}(#)' +
						       '%@{child}(%config{child})' +
						   ')'
			formatter_pattern: '[%levelColor(%pad{-5}(%LEVEL))] ' +
						       '%levelColor(%date)' +
						       ' |%label| ' +
						       '%message' +
						       '%meta'
			styles:
				'dir': 'grey bold'
				'child': 'cyan bold'
				'sep': 'grey'
				'name': 'blue bold'
			silent: false
			level: 'silly'
		file:
			_transport_class: ['winston', 'transports', 'File']
			formatter_pattern: '[%LEVEL] %label %date %path{name} %message %meta'
			filename_pattern: '%!{logdir}/%!{app_name}%?(%level)(-%level).log'
			maxsize: 10 * 1024 * 1024
			level: 'silly'
		mail:
			_transport_class: ['winston-mail', 'Mail']
			level: 'error'
		http:
			_transport_class: ['winston-nssocket', 'Nssocket']
			host: 'localhost'
			port: 9003
	loggers:
		'ROOT':
			label: '/'
			level: 'info'
	transports: ['console', 'file']
	transports_available:
		console:
			_transport_defaults: 'console'
		console_colorful:
			_transport_defaults: 'console'
			label_pattern: '%@{dir}(%pad{4}(%short-path(%-pkgdir)))' +
						   '%@{sep}(/)' +
						   '%@{name}(%path{%name})' +
						   '%?(%config{child})(' +
						       '%@{sep}(#)' +
						       '%@{child}(%config{child})' +
						   ')'
		file:
			_transport_defaults: 'file'
		mail:
			_transport_defaults: 'mail'
		http:
			_transport_defaults: 'http'

_populate_available_transports = () ->
	for level of Winston.config[DEFAULT_CONFIG.levels].levels
		for transport of DEFAULT_CONFIG.transport_defaults
			DEFAULT_CONFIG.transports_available["#{transport}_#{level}"] =
				_defaults: transport
				level: level
