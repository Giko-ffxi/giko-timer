local config   = require('lib.giko.config')
local common   = require('lib.giko.common')
local monster  = require('lib.giko.monster')
local death    = require('lib.giko.death')
local chat     = require('lib.giko.chat')

local listener = { character = nil }

listener.packet = function(mode, input, m_mode, m_message, blocked)

    local entity = GetPlayerEntity()

    if entity ~= nil and entity.Name ~= listener.character then

        listener.character = entity.Name

        if listener.character ~= config.broadcaster then
            ashita.timer.create('login', 5, 1, function() chat.tell(config.broadcaster, '@giko sync') end)
        end

    end

    return false

end

listener.text = function(mode, input, m_mode, m_message, blocked)
    
    if config.broadcaster ~= "" then
     
        if ((mode == tonumber(0xC) and (string.find(string.gsub(input, '[%W]', ''), string.format('^%s', config.broadcaster)))) or ((mode == tonumber(0xE) or mode == tonumber(0xD6)) and (string.find(string.gsub(input, '[%W]', ''), string.format('^%%d%s', config.broadcaster)))) or ((mode == tonumber(0x6) or mode == tonumber(0xD5)) and (string.find(string.gsub(input, '[%W]', ''), string.format('^%%d%s', config.broadcaster))))) then
            listener.tod(input)      
        end

    end

    for k,share in ipairs(config.sharelist) do

        if ((mode == tonumber(0xC) and (string.find(string.lower(string.gsub(input, '[%W]', '')), string.lower(string.format('^%sTimer', share)))))) then
            listener.timer(input)      
        end    

        if ((mode == tonumber(0xC) and (string.find(string.lower(string.gsub(input, '[%W]', '')), string.lower(string.format('^%sToD', share)))))) then
            listener.tod(input)      
        end 

    end

    return false

end

listener.timer = function(input)

    local lbl, Y, m, d, H, M, S, z, l = string.match(input, '%[Timer%]%[([%w%s]+)%]%[(%d%d%d%d)%-(%d%d)%-(%d%d)%s(%d%d):(%d%d):(%d%d)%s([%-%+]%d%d%d%d)%]%[(%w+)%]')

    if Y and m and d and H and M and S and z ~= nil then
        controller.custom.add(lbl, os.date('%Y-%m-%d %H:%M:%S', os.time({year=Y, month=m, day=d, hour=H, min=M, sec=S}) - common.offset_to_seconds(z)), l)
    end

end

listener.tod = function(input)

    local sets = {}

    for k,mob in ipairs(monster.notorious) do 
            
        for n,name in ipairs(common.flatten(mob.names)) do  
 
            local Y, m, d, H, M, S, z, D = string.match(input, string.format('%%[ToD%%]%%[%s%%]%%[(%%d%%d%%d%%d)%%-(%%d%%d)%%-(%%d%%d)%%s(%%d%%d):(%%d%%d):(%%d%%d)%%s([%%-%%+]%%d%%d%%d%%d)%%]', name))
            local D                      = string.match(input, string.format('%%[ToD%%]%%[%s%%]%%[%%d%%d%%d%%d%%-%%d%%d%%-%%d%%d%%s%%d%%d:%%d%%d:%%d%%d%%s[%%-%%+]%%d%%d%%d%%d%%]%%[(%%d+)%%]', name))
            local day                    = string.match(input, string.format('%%[Day%%]%%[%s%%]%%[(%%d+)%%]', name))

            if Y and m and d and H and M and S and z ~= nil then
                death.set_tod(name, os.date('%Y-%m-%d %H:%M:%S', os.time({year=Y, month=m, day=d, hour=H, min=M, sec=S}) - common.offset_to_seconds(z)), tonumber(D or 0))
            end

            if day ~= nil then
                death.set_day(name, tonumber(day - 1))
            end

        end

        for n,name in ipairs(mob.sets) do  
            if not common.in_array(sets, name) then
                table.insert(sets, name)
            end
        end

    end

    for k,set in ipairs(sets) do  

        local tod = string.match(input, string.format('%%[ToD%%].*%%[%s%%]%%[(%%w+)%%]', set))
        local n   = 0
        local s   = 1

        if (tod ~= nil) then                    
            for k,mob in ipairs(monster.notorious) do
                for k,name in ipairs(mob.sets) do   
                    if name == set then

                        local hq  = mob.names.hq and 1 or 0
                        local gmt = string.sub(tod, s + hq, s + hq + 7)
                        local day = mob.names.hq and string.sub(tod, s, s) or 0
                      
                        if gmt ~= nil then
                           death.set_tod(mob.names.nq[1], os.date('%Y-%m-%d %H:%M:%S', common.hex_to_int(gmt) - common.offset_to_seconds(os.date('%z', os.time()))))
                           death.set_day(mob.names.nq[1], common.hex_to_int(day))
                        end

                        s = s + hq + 8
                        n = n + 1
                    end
                end
            end
        end
    end

end

return listener
