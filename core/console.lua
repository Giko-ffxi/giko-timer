local config  = require('lib.giko.config')
local common  = require('lib.giko.common')
local death   = require('lib.giko.death')
local monster = require('lib.giko.monster')
local chat    = require('lib.giko.chat')
local sound   = require('lib.giko.sound')
local console = { command= {} }

console.input = function(command, ntype)

    local command, args = string.match(command, '^/giko[%s-]+timer%s+([%w-]+)(.*)')

    if command == nil then
        return false
    end

    local registry = 
    {
        ['sync']        = console.command.sync,
        ['visible']     = console.command.visible,
        ['volume']      = console.command.volume,
        ['mute']        = console.command.mute,
        ['enable']      = console.command.enable,
        ['disable']     = console.command.disable,
        ['add']         = console.command.add,
        ['set-day']     = console.command.day,
        ['share']       = console.command.share,
        ['purge']       = console.command.purge,
        ['remove']      = console.command.remove,
        ['reset']       = console.command.reset
    }

    if registry[command] then
        registry[command](args)
    end
    
    if registry[command] == nil then
        console.command.help()
    end

    return true

end

console.command.sync = function(args)
        
    if config.broadcaster ~= nil then
        chat.tell(config.broadcaster, '@giko sync')
    end
    
end

console.command.add = function(args)
          
    local duration = common.split(string.lower(args), ' ')[1]
    local lbl      = common.trim(args.sub(args, (string.find(args, duration)) + #duration + 1))
    local gmt      = os.date('%Y-%m-%d %H:%M:%S', os.time() - common.offset_to_seconds(os.date('%z', os.time())))
    
    if lbl ~= nil and common.to_seconds(duration) > 0 then
        controller.custom.add(lbl, gmt, duration)
    else
        print("Invalid timer: /giko timer add <duration> <label>")
    end
    
end

console.command.remove = function(args)
      
    local lbl = common.trim(args)
  
    if lbl ~= nil and controller.custom.has(lbl) then
        controller.custom.remove(lbl)
    else
        print("Invalid timer: /giko timer remove <label>")
    end
    
end

console.command.day = function(args)
      
    local mob = monster.get(common.trim(string.gsub(args, "%d", '')))
    local day = common.trim(string.match(args, "%d+"))
    
    if mob ~= nil and tonumber(day) ~= nil and tonumber(day) > 0  then           
        death.set_day(mob.names.nq[1], day - 1)      
    else
        print("Invalid day: /giko timer set-day <mob> <day>")
    end

    config.save()
    
end

console.command.reset = function(args)
      
    local lbl = common.trim(args)
    
    if lbl ~= nil and controller.custom.has(lbl) then
        controller.custom.reset(lbl)
    else
        print("Invalid share: /giko timer reset <label>")
    end
    
end

console.command.purge = function(args)
      
    death.purge()
    
end


console.command.share = function(args)
          
    local player = common.split(string.lower(args), ' ')[1]
    local timer  = common.trim(args.sub(args, (string.find(args, player)) + #player + 1))

    if player ~= nil and timer ~= nil then        
        controller.share(player, timer)
    else
        print("Invalid share: /giko timer share <player> <label>")
    end
    
end

console.command.visible = function(args)

    config.ui.visible = not config.ui.visible 
    config.save()

end

console.command.enable = function(args)

    local tokens = common.split(string.lower(args), ' ')
    
    for k,mob in ipairs(monster.notorious) do    
        for n,name in ipairs(common.flatten(mob.names)) do  
            if common.in_array(tokens, string.lower(name)) or common.in_array(tokens, 'all') then
                config.timers.monsters[string.lower(mob.names.nq[1])].enabled = true
            end
        end
    end

    config.save()
    
end

console.command.disable = function(args)

    local tokens = common.split(string.lower(args), ' ')
    
    for k,mob in ipairs(monster.notorious) do    
        for n,name in ipairs(common.flatten(mob.names)) do  
            if common.in_array(tokens, string.lower(name)) or common.in_array(tokens, 'all') then
                config.timers.monsters[string.lower(mob.names.nq[1])].enabled = false
            end
        end
    end
    
    config.save()
    
end

console.command.volume = function(args)

    local volume = tonumber(args:match('%d+'))

    if volume ~= nil and volume >= 1 and volume <= 10 then
        config.ui.sound.volume = args:match('%d+')
        config.save()
        
        sound.call(config.ui.sound.call or 1, config.ui.sound.volume or 5, config.ui.sound.lib or 'giko.call')

    else
        print("Giko timers invalid volume [1-10]")   
    end

end

console.command.mute = function(args)

    config.ui.muted = not config.ui.muted
    config.save()

    print("Giko timers sounds are now " .. (config.ui.muted and "disabled" or "enabled") .. ".")   

end


console.command.help = function(args)

    common.help('/giko timer', 
    {
        {'/giko timer sync', 'Synchronize timers with the broadcaster.'},
        {'/giko timer visible', 'Toggle the ui on and off.'},
        {'/giko timer enable <mob>', 'Show the timer for mob.'},
        {'/giko timer disable <mob>', 'Hide the timer for mob.'},
        {'/giko timer add <duration> <label>', 'Add a custom timer.'},
        {'/giko timer share <player> <label>', 'Share a timer.'},
        {'/giko timer set-day <mob> <day>', 'Set local HQ day for a timer.'},
        {'/giko timer volume <1-10>', 'Adjust the sound volume.'},
        {'/giko timer mute', 'Toggle the sound on and off.'},
        {'/giko timer remove <label>', 'Remove a custom timer.'},
        {'/giko timer reset <label>', 'Reset a custom timer.'},
    })

end

return console