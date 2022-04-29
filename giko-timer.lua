package.path = (string.gsub(_addon.path, '[^\\]+\\?$', '')) .. 'giko-common\\' .. '?.lua;' .. package.path

_addon.author 	= 'giko'
_addon.name 	= 'giko-timer'
_addon.version 	= '1.0.0'

ui           = require('core.ui')
console      = require('core.console')
listener     = require('core.listener')
synchronizer = require('core.synchronizer')

ashita.register_event('load', synchronizer.load)
ashita.register_event('command', console.input)
ashita.register_event('incoming_text', listener.listen)
ashita.register_event('render', ui.render)
ashita.register_event('unload', ui.unload)