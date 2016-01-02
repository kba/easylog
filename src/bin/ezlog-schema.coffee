Fs        = require 'fs'
Schema    = require '../lib/schema'
Path      = require 'path'
program = require 'commander'
PACKAGE_JSON = require('read-pkg-up').sync(cwd: @cwd).pkg
DEFAULT_CONFIG = require '../lib/default-ezlog.json'

COMMANDS = {}
program
	.version(PACKAGE_JSON.version)
	.option(
		"-c --config [config file]"
		"Use this config for full schema dump / validation or output default"
	)
	.option(
		"-l --level <#{Object.keys(Schema.ValidationLevel)}>"
		"Use Schema at this validation level"
		(level) -> Schema.ValidationLevel[level.toUpperCase()]
	)
	.option(
		"-v --validate"
		"Validate config against schema"
	)
	.parse process.argv

_dump = (val) -> JSON.stringify(val, null, 2)

if program.config is true and not program.level
	console.log _dump(DEFAULT_CONFIG)
	process.exit 0
else if not program.level
	console.error("Must specify ValidationLevel")
	program.help()
else if program.level is Schema.ValidationLevel.FULL and not program.config
	console.error("Must specify configFile for FULL level schema dump or validation")
	program.help()
if typeof program.config is 'string'
	try
		config = JSON.parse(Fs.readFileSync(program.args[0]))
	catch e
		console.error("Couldn't read config #{program.config}", e)
		process.exit 2
else if program.config is true
	config = DEFAULT_CONFIG
if program.validate
	result = Schema.validate program.level, config
	unless result.valid
		delete result.error?.stack
		console.error(_dump(result))
		process.exit 1
else
	console.log _dump(Schema.schema program.level, config)
