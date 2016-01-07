easylog = require('../lib')
easylog.setup()
log = Winston = require 'winston'
log = easylog(module)
# log = easylog(
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
	#
	# log.stop_log('bla')
	Winston.info 'yay'
, 5000

# log.debug 'container', easylog.getRoot().container
# log.debug 'container', Winston.loggers

log.warn easylog.getConfig().loggers
