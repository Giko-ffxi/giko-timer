local config = require('lib.giko.config')
local common = require('lib.giko.common')
local death  = require('lib.giko.death')
local ui     = { frame = {}, days = {}, shift = false, hover = false }

ui.load = function()

    ui.frame = ui.component('__giko_timer_ui_frame', nil, config.ui.position[1] or (ashita.gui.io.DisplaySize.x / 2 - 150), config.ui.position[2] or 100)

end

ui.render = function(timers)

    table.sort(timers, function (a, b) return a.countdown < b.countdown end)
    table.foreach(timers, ui.colorize)
    
    ui.frame:SetText(#timers > 0 and table.concat(common.pluck(timers, 'lbl'), '\n') or '|cff888888|                      -                      ')
    ui.frame:SetVisibility(GetPlayerEntity() ~= nil and config.ui.visible)

end

ui.component = function(name, img, x, y, w, h, visibility)

    local component = AshitaCore:GetFontManager():Create(name)

    if img ~= nil then      
        component:GetBackground():SetTextureFromFile(string.format('%s/assets/%s', _addon.path, img))
    end

    component:GetBackground():SetWidth(w ~= nil and w or 0)
    component:GetBackground():SetHeight(h ~= nil and h or 0)
    component:GetBackground():SetVisibility(visibility == true or visibility == nil or false)
    component:GetBackground():SetColor(img ~= nil and 0xFFFFFFFF or 0x80000000)
    
    component:SetFontFamily(config.ui.font.family)
    component:SetFontHeight(config.ui.font.size)
    component:SetPadding(config.ui.padding)
    component:SetPositionX(x + (config.ui.padding / 2))
    component:SetPositionY(y + (config.ui.padding / 2))
    component:SetVisibility(visibility == true or visibility == nil or false)
    component:SetAutoResize(w == nil and h == nil)

    return component

end

ui.colorize = function(k, timer)

    if timer.countdown <= 0 then
        timer.lbl = '|cff00ff00|' .. timer.lbl
    elseif timer.countdown < 60 then
        timer.lbl = '|cffff7d40|' .. timer.lbl
    elseif timer.countdown < 300 then
        timer.lbl = '|cFFFFFF00|' .. timer.lbl
    elseif timer.countdown < 1800 then
        timer.lbl = '|cffc3dbff|' .. timer.lbl
    else
        timer.lbl = '|cff888888|' .. timer.lbl
    end

end


ui.mouse = function(id, x, y, delta, blocked)

    local x1 = ui.frame:GetBackground():GetPositionX()
    local y1 = ui.frame:GetBackground():GetPositionY()
    local x2 = x1 + ui.frame:GetBackground():GetWidth()
    local y2 = y1 + ui.frame:GetBackground():GetHeight()

    ui.hover = x > x1 and x < x2 and y > y1 and y < y2

    if id == 512 and (config.ui.position[1] ~= x1 or config.ui.position[2] ~= y1) then
    
        config.ui.position[1] = x1
        config.ui.position[2] = y1

        ashita.timer.create('save', 1, 1, function()
            config.save()
        end)

    end

    if id == 513 and ui.shift == false and ui.hover == true then
        config.ui.mode = config.ui.mode ~= "time" and "time" or "countdown"
        config.save()
    end

    return false

end

ui.key = function(key, down, blocked)
    
    if key == 42 then
        ui.shift = down
    end

    return false

end

ui.unload = function()

    AshitaCore:GetFontManager():Delete('__giko_timer_ui_frame') 

end

return ui
