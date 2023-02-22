package.path = (string.gsub(_addon.path, '[^\\]+\\?$', '')) .. 'giko-common\\' .. '?.lua;' .. package.path

_addon.author 	= 'giko'
_addon.name 	= 'giko-timer'
_addon.version 	= '1.0.6'

ui         = require('core.ui')
console    = require('core.console')
controller = require('core.controller')
listener   = require('core.listener')

ashita.register_event('load', controller.load)
ashita.register_event('command', console.input)
ashita.register_event('incoming_packet', listener.packet)
ashita.register_event('incoming_text', listener.text)
ashita.register_event('render', controller.render)
ashita.register_event('mouse', ui.mouse)
ashita.register_event('key', ui.key)
ashita.register_event('unload', controller.unload)