local config  = require('lib.giko.config')
local common  = require('lib.giko.common')
local cache   = require('lib.giko.cache')
local json    = require('json.json')

local custom  = { memory = {} , path = string.format('%s..\\giko-cache\\cache\\giko.timer.csv', _addon.path) }

custom.has = function(lbl)

    return common.in_array_key(custom.memory, string.gsub(string.lower(lbl), '%s', '-'))
    
end

custom.add = function(lbl, gmt, len)

    custom.memory[string.gsub(string.lower(lbl), '%s', '-')] = {lbl = lbl, gmt = gmt, len = common.to_seconds(len)}
    cache.set(custom.path, string.gsub(string.lower(lbl), '%s', '-'), json:encode(custom.memory[string.gsub(string.lower(lbl), '%s', '-')]))

end

custom.remove = function(lbl)

    custom.memory[string.gsub(string.lower(lbl), '%s', '-')] = nil
    cache.remove(custom.path, string.gsub(string.lower(lbl), '%s', '-'))

end

custom.reset = function(lbl)

    custom.memory[string.gsub(string.lower(lbl), '%s', '-')] = {lbl = custom.memory[string.gsub(string.lower(lbl), '%s', '-')].lbl, gmt = os.date('%Y-%m-%d %H:%M:%S', os.time() - common.offset_to_seconds(os.date('%z', os.time()))), len = custom.memory[string.gsub(string.lower(lbl), '%s', '-')].len}
    cache.set(custom.path, string.gsub(string.lower(lbl), '%s', '-'), json:encode(custom.memory[string.gsub(string.lower(lbl), '%s', '-')]))

end

custom.memory = function()

    local memory = {}

    for k, cached in pairs(cache.get_all(custom.path)) do
        memory[k] = json:decode(cached)
    end

    custom.memory = memory 

end

custom.get_timers = function()
    
    local timers = {}

    for k, timer in pairs(custom.memory) do

        local countdown = os.difftime(common.gmt_to_local_time(timer.gmt) + timer.len, os.time())

        if countdown - 1 == 60 then
            ashita.timer.create('alert', 1, 1, function() ashita.misc.play_sound(string.format('%s\\sounds\\%s', _addon.path, 'default.wav')) end)
        end

        if countdown ~= nil and countdown > 0 then
            table.insert(timers, {time = os.date('%m-%d %H:%M:%S', common.gmt_to_local_time(timer.gmt) + timer.len), left = math.max(countdown, 0), lbl = string.format('|%s|%s - %s', config.ui.font.colors[math.min(math.floor(countdown / 600), 2) + 1], config.ui.mode ~= "countdown" and common.to_time(math.max(countdown, 0)) or os.date('%m-%d %H:%M:%S', common.gmt_to_local_time(timer.gmt) + timer.len), timer.lbl)})
        end

    end

    return timers
        
end

custom.get_share = function(lbl)
    
    local share = nil

    for i, timer in pairs(custom.memory) do
        if string.gsub(string.lower(lbl), '%s', '-') == i then
            share = string.format("[Timer][%s][%s][%s]", timer.lbl, common.gmt_to_local_date(timer.gmt), common.to_duration(timer.len))
        end
    end

    return share
        
end

ashita.timer.create('giko_timer_custom_memory_refresh', config.cache and config.cache.refresh or 5, 0, custom.memory); custom.memory()

return custom