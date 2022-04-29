local config   = require('lib.giko.config')
local common   = require('lib.giko.common')
local monster  = require('lib.giko.monster')
local death    = require('lib.giko.death')
local listener = { }

listener.listen = function(mode, input, m_mode, m_message, blocked)

    if config.broadcaster ~= nil then
        if ((mode == tonumber(0xC) and (string.find(string.gsub(input, '[%W]', ''), string.format('^%s', config.broadcaster)))) or (mode == tonumber(0xE) and (string.find(string.gsub(input, '[%W]', ''), string.format('^%%d%s', config.broadcaster))))) then
            listener.tod(input)      
        end
    end

    return false

end

listener.tod = function(input)

    local sets = {}

    for k,mob in ipairs(monster.notorious) do 
            
        for k,q in pairs(mob.names) do

            local Y, m, d, H, M, S, z = string.match(input, string.format('%%[ToD%%]%%[%s%%]%%[(%%d%%d%%d%%d)%%-(%%d%%d)%%-(%%d%%d)%%s(%%d%%d):(%%d%%d):(%%d%%d)%%s([%%-%%+]%%d%%d%%d%%d)%%]', q[1]))
            local day                 = string.match(input, string.format('%%[Day%%]%%[%s%%]%%[(%%d+)%%]', q[1]))

            if Y and m and d and H and M and S and z ~= nil then
                death.set_tod(q[1], os.date('%Y-%m-%d %H:%M:%S', os.time({year=Y, month=m, day=d, hour=H, min=M, sec=S}) - common.offset_to_seconds(z)))   
            end

            if day ~= nil then
                death.set_day(q[1], day - 1)
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