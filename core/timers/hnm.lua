local config  = require('lib.giko.config')
local death   = require('lib.giko.death')
local monster = require('lib.giko.monster')
local common  = require('lib.giko.common')
local hnm     = {}

hnm.get_timers = function()
    
    local timers = {}

    for key, timer in pairs(config.timers.monsters) do
        
        if timer.enabled then
            
            local mob    = monster.get(key)
            local window = death.get_window(key, common.to_seconds(config.offset or 1))
            
            if window ~= nil and window.countdown ~= nil then

                for z, alert in ipairs(timer.alerts) do
                    if window.countdown - 1 == common.to_seconds(alert.play_at) then
                        ashita.timer.create('alert', 1, 1, function() ashita.misc.play_sound(string.format('%s\\sounds\\%s', _addon.path, alert.sound)) end)
                    end
                end

                if ui.hover or window.countdown < (timer.visible_at and common.to_seconds(timer.visible_at) or 3600) then
                    table.insert(timers, {time = string.sub(window.time, 6), left = math.max(window.countdown, 0), lbl = string.format("|%s|%s - %s %s", config.ui.font.colors[math.min(math.floor(math.max(window.countdown, 0) / 900), 2) + 1], window.countdown <= 0 and '-=OPEN=-' or (config.ui.mode ~= "countdown" and common.to_time(math.max(window.countdown, 0)) or string.sub(window.time, 6)), mob.names.nq[1], #mob.windows.at > 1 and string.format('- %sW%d', window.day ~= nil and string.format('D%d - ', window.day) or '', window.count) or '')})
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