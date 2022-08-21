local config  = require('lib.giko.config')
local common  = require('lib.giko.common')
local monster = require('lib.giko.monster')
local chat    = require('lib.giko.chat')
local console = { command= {} }

console.input = function(command, ntype)

    local command, args = string.match(command, '^/giko[%s-]+timer%s+(%w+)(.*)')

    if command == nil then
        return false
    end

    local registry = 
    {
        ['sync']     = console.command.sync,
        ['visible']  = console.command.visible,
        ['enable']   = console.command.enable,
        ['disable']  = console.command.disable,
        ['pos']      = console.command.pos
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
        
    chat.tell(config.broadcaster, '@giko sync')
    
end

console.command.visible = function(args)

    config.ui.visible = not config.ui.visible 
    config.save()

end

console.command.enable = function(args)

    local tokens = common.split(string.lower(args), ' ')
    
    for k,mob in ipairs(monster.notorious) do    
        for n,name in ipairs(common.flatten(mob.names)) do  
            if common.in_array(tokens, string.lower(name)) then
                config.timers.monsters[string.lower(mob.names.nq[1])] = true
            end
        end
    end

    config.save()
    
end

console.command.disable = function(args)

    local tokens = common.split(string.lower(args), ' ')
    
    for k,mob in ipairs(monster.notorious) do    
        for n,name in ipairs(common.flatten(mob.names)) do  
            if common.in_array(tokens, string.lower(name)) then
                config.timers.monsters[string.lower(mob.names.nq[1])] = false
            end
        end
    end
    
    config.save()
    
end

console.command.pos = function(args)  

    config.ui.position = {tonumber(common.split(string.lower(args), ' ')[1]) or 50, tonumber(common.split(string.lower(args), ' ')[2]) or 125}
    config.save()

end

console.command.help = function(args)

    common.help('/giko timer', 
    {
        {'/giko timer sync', 'Synchronize timers with the broadcaster.'},
        {'/giko timer visible', 'Toggle the ui on and off.'},
        {'/giko timer enable <mob>', 'Show the timer for mob.'},
        {'/giko timer disable <mob>', 'Hide the timer for mob.'},
        {'/giko timer pos <x> <y>', 'Set the position of the ui at x,y.'}
    })

end

return console