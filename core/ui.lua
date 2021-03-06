local config = require('lib.giko.config')
local common = require('lib.giko.common')
local death  = require('lib.giko.death')
local ui     = { timers = {} }

ui.init = function()

    local f = AshitaCore:GetFontManager():Create('__giko_timers_addon')
    
    f:SetFontFamily(config.ui.font.family)
    f:SetFontHeight(config.ui.font.size)
    f:SetPositionX(config.ui.position[1])
    f:SetPositionY(config.ui.position[2])
    f:GetBackground():SetColor(tonumber(config.ui.bgcolor))
    f:GetBackground():SetVisibility(true)
    f:SetVisibility(config.ui.visible)
    f:SetBold(false)
    f:SetText('Giko')

    return f

end

ui.render = function()

    local f = AshitaCore:GetFontManager():Get('__giko_timers_addon') or ui.init()
    local h = '|cFF00FF00|%s-= [ Giko Timers ] =-%s|r'
    local x, y = ashita.gui.GetMousePos()
    local x1 = f:GetBackground():GetPositionX()
    local y1 = f:GetBackground():GetPositionY()
    local x2 = x1 + f:GetBackground():GetWidth()
    local y2 = y1 + f:GetBackground():GetHeight()
    local hover = x > x1 and x < x2 and y > y1 and y < y2

    timers = {}
    size   = string.len(h)

    if config.ui.visible then

        ui.timers.dynamis(timers, hover)
        ui.timers.monsters(timers, hover)

        for k,t in pairs(timers) do
            size = math.max(size, string.len(t))
        end
        
        table.insert(timers, 1, string.format(h, string.format(string.format('%%-%02ds', (size - 15) / 2), ''), string.format(string.format('%%-%02ds', (size - 15) / 2), '')))
        table.sort(timers, function (a, b) return a < b end)

        if table.getn(timers) == 1 then 
            table.insert(timers, string.format('|cFF00FF00|%s-%s|r', string.format(string.format('%%-%02ds', 28), ''), string.format(string.format('%%-%02ds', 28), ''))) 
        end
        
    end

    if config.ui.position[1] ~= x1 or config.ui.position[2] ~= y1 then
        
        config.ui.position[1] = x1
        config.ui.position[2] = y1

        ashita.timer.create('save', 1, 1, function()
            config.save()
        end)

    end

    f:SetText(table.concat(timers, '\n'))    
    f:SetVisibility(config.ui.visible)
    
end

ui.timers.dynamis = function(timers, hover)

    if config.timers.dynamis then

        local time = os.time()
        local dst  = os.date('*t').isdst
        local y, m, d, h, m, s, a, countdown

        while countdown == nil do

            for k, conf in ipairs(config.timers.dynamis) do
               
                y, m, d, a, A = string.match(os.date('%Y-%m-%d %a %A', time), '(%d%d%d%d)%-(%d%d)%-(%d%d)%s(%w+)%s(%w+)') 
                dynamis = os.time({year = y, month = m, day = d, hour = string.gsub(conf.gmt, '%:.*', ''), min = string.gsub(conf.gmt, '.*%:', ''), sec = 0}) + common.offset_to_seconds(os.date('%z', os.time()))
                
                if string.lower(A) == string.lower(conf.day) and dynamis > os.time() then
                    countdown = os.difftime(dynamis, os.time())
                    break
                end

            end

            time = time + 86400
        end

        if hover or countdown < (config.timers.display and common.to_seconds(config.timers.display) or 3600) then
            table.insert(timers, string.format('|%s|  %s - %s Dynamis', config.ui.font.colors[math.min(math.floor(countdown / 600), 2) + 1], common.to_time(countdown), A))
        end

    end
    
end

ui.timers.monsters = function(timers, hover)

    for key, enabled in pairs(config.timers.monsters) do
        if enabled then
            local window = death.get_window(key, common.to_seconds(config.offset), common.to_seconds(config.grace))
            if window ~= nil and window.countdown ~= nil and (hover or window.countdown < (config.timers.display and common.to_seconds(config.timers.display) or 3600)) then
                table.insert(timers, string.format('|%s|  %s - W%d - %s %s', config.ui.font.colors[math.min(math.floor(math.max(window.countdown, 0) / 900), 2) + 1], window.countdown <= 0 and '-=OPEN=-' or common.to_time(math.max(window.countdown, 0)), window.count, window.name, window.day ~= nil and string.format('- Day %s', window.day) or ''))  
            end
        end
    end
    
end

ui.unload = function()

    AshitaCore:GetFontManager():Delete('__giko_timers_addon')   

end

return ui
