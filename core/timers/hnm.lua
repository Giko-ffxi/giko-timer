local config  = require('lib.giko.config')
local death   = require('lib.giko.death')
local monster = require('lib.giko.monster')
local common  = require('lib.giko.common')
local sound   = require('lib.giko.sound')
local hnm     = {}

hnm.get_timers = function()
    
    local timers = {}

    for key, timer in pairs(config.timers.monsters) do
        
        if timer.enabled then
            
            local mob    = monster.get(key)
            local window = death.get_window(key, common.to_seconds(config.offset or 1))
            
            if window ~= nil and window.countdown ~= nil then

                for z, alert in ipairs(timer.alerts) do
                    if window.countdown - 1 == common.to_seconds(alert.play_at) and not config.ui.sound.muted then
                        sound.call((alert.sound and alert.sound.call) or config.ui.sound.call or 1, (alert.sound and alert.sound.volume) or config.ui.sound.volume or 5, (alert.sound and alert.sound.lib) or config.ui.sound.lib or 'giko.call')
                    end
                end

                if ui.hover or window.countdown < (timer.visible_at and common.to_seconds(timer.visible_at) or 3600) then
                    table.insert(timers, {time = string.sub(window.time, 6), countdown = window.countdown, lbl = string.format("%s - %s%s%s", config.ui.mode ~= "time" and common.to_time(math.max(window.countdown, 0)) or string.sub(window.time, 6), mob.names.nq[1], window.countdown <= 0 and string.format(' - Open - %s ', common.to_duration(common.to_seconds(window.length) + window.countdown)) or '', #mob.windows.at > 1 and string.format(' - %sW%d', window.day ~= nil and string.format(' D%d - ', window.day) or '', window.count) or '')})
                end

            end
        end

    end

    return timers
        
end


hnm.get_share = function(key)
    
    local share = nil
    local mob   = monster.get(key)

    if mob ~= nil then      

        local tod = death.get_tod(key)    

        if tod ~= nil then
            share = string.format("[ToD][%s][%s][%s]", mob.names.nq[1], common.gmt_to_local_date(tod.gmt), tod.day)
        end
        
    end    

    return share
        
end

return hnm