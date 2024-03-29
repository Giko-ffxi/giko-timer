local timer   = require('lib.ashita.timer')
local config  = require('lib.giko.config')
local common  = require('lib.giko.common')
local death   = require('lib.giko.death')
local chat    = require('lib.giko.chat')

local controller = { custom = require('core.timers.custom'), event = require('core.timers.event'), hnm = require('core.timers.hnm')}

controller.load = function()

    ui.load()
    
    ashita.timer.create('purge', 15, 0, function() death.purge() end)

end

controller.unload = function()

    ui.unload()
    
    if ashita.timer.is_timer('purge') then
        ashita.timer.remove_timer('purge')
    end

end

controller.render = function()

    local timers = {}

    common.concat(timers, controller.custom.get_timers())
    common.concat(timers, controller.event.get_timers())
    common.concat(timers, controller.hnm.get_timers())

    ui.render(timers)
    
end

controller.share = function(player, lbl)

    local shares = {}
    
    table.insert(shares, controller.custom.get_share(lbl))
    table.insert(shares, controller.hnm.get_share(lbl))

    for k,v in pairs(shares) do
        chat.tell(player, v)
    end 
    
end

return controller
