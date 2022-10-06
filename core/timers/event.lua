local config  = require('lib.giko.config')
local common  = require('lib.giko.common')
local event   = {}

event.get_timers = function()
    
    local timers = {}

    if config.timers.events then

        for k, event in ipairs(config.timers.events) do

            local time = os.time()
            local dst  = os.date('*t').isdst
            local y, m, d, h, m, s, a, countdown

            while countdown == nil do

                for l, timer in ipairs(event.times) do
                
                    y, m, d, a, A = string.match(os.date('%Y-%m-%d %a %A', time), '(%d%d%d%d)%-(%d%d)%-(%d%d)%s(%w+)%s(%w+)') 

                    event_at = os.time({year = y, month = m, day = d, hour = string.gsub(timer.gmt, '%:.*', ''), min = string.gsub(timer.gmt, '.*%:', ''), sec = 0}) + common.offset_to_seconds(os.date('%z', os.time()))
                    
                    if string.lower(A) == string.lower(timer.day) and event_at > os.time() then
                        countdown = os.difftime(event_at, os.time())
                        break
                    end

                end

                time = time + 86400
            end

            if countdown - 1 == 60 then
                ashita.timer.create('alert', 1, 1, function() ashita.misc.play_sound(string.format('%s\\sounds\\%s', _addon.path, 'default.wav')) end)
            end

            if ui.hover or countdown < (event.visible_at and common.to_seconds(event.visible_at) or 3600) then
                table.insert(timers, {time = os.date('%m-%d %H:%M:%S', event_at), left = math.max(countdown, 0), lbl = string.format('|%s|%s - %s', config.ui.font.colors[math.min(math.floor(countdown / 600), 2) + 1], config.ui.mode ~= "time" and common.to_time(math.max(countdown, 0)) or os.date('%m-%d %H:%M:%S', event_at), event.lbl)})
            end

        end

    end

    return timers
        
end

return event