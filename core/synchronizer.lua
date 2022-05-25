local cache       = require('lib.giko.cache')
local config      = require('lib.giko.config')
local common      = require('lib.giko.common')
local death       = require('lib.giko.death')
local monster     = require('lib.giko.monster')
local chat        = require('lib.giko.chat')
local json        = require('json.json')
local http        = require('socket.http')
local ltn12       = require("ltn12")
local syncronizer = {}

syncronizer.load = function()

    if config.sync.url ~= "" and config.sync.user  ~= "" and config.sync.password  ~= "" and config.sync.interval ~= "" then
            
        return ashita.timer.create('sync', common.to_seconds(config.sync.interval), 0, function()
            
            local resp = ''
            local c_tods = {}
            local u_flag = false
            local ok, code = http.request({method = "GET", url = config.sync.url, headers = {authorization = "Basic " .. (mime.b64(config.sync.user .. ':' .. config.sync.password))}, sink = function(chunk) if chunk ~= nil and string.match(chunk, '.+\|\{[^}]*\}') then resp = resp .. chunk end return true end })

            if ok and code == 200 and resp ~= '' then
        
                for r in string.gmatch(resp, "[^\r\n]+") do
                    
                    local mob, data = string.match(r, "(.+\)|(\{[^}]*\})")
                    local s_tod = json:decode(data)
                    local c_tod = death.get_tod(mob)
        
                    if c_tod == nil or (c_tod.created_at ~= nil and c_tod.created_at < s_tod.created_at) then
                        c_tods[mob] = json:encode(s_tod)
                        u_flag = true
                    end
                
                end
        
                if u_flag then
                    cache.set(death.cache, c_tods)
                end
        
            end
        
        end)

    end

    if config.broadcaster ~= "" then

        chat.tell(config.broadcaster, '@giko sync')

    end

end

return syncronizer