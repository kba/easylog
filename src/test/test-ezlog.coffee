ezlog = require('../lib')
ezlog.setup()
log = Winston = require 'winston'
log = ezlog(module)
# log = ezlog(
#     filename: __filename,
#     inject:
#         'winston-nssocket': require('winston-nssocket')
# )

log.silly 'foo yay'
log.debug 'foo yay'
log.info 'foo yay'
log.warn 'foo yay'
log.error 'foo yay'
# log.child('foo').debug 'foo yay'
# log.start('bla')
setTimeout ->
	# log.stop_log('bla')
	Winston.info 'yay'
, 5000

# log.debug 'container', ezlog.getRoot().container
# log.debug 'container', Winston.loggers

log.warn ezlog.getConfig().loggers
