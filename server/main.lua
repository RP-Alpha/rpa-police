local Casings = {}
local OnDuty = {}

-- Duty Toggle
RegisterNetEvent('rpa-police:server:toggleDuty', function()
    local src = source
    local Framework = exports['rpa-lib']:GetFramework()
    local Player = Framework.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local job = Player.PlayerData.job
    if job.name ~= 'police' then
        exports['rpa-lib']:Notify(src, _U('not_police') or "You are not a police officer", "error")
        return
    end
    
    OnDuty[src] = not OnDuty[src]
    
    if OnDuty[src] then
        exports['rpa-lib']:Notify(src, _U('on_duty') or "You are now on duty", "success")
        -- Could give loadout here
        TriggerClientEvent('rpa-police:client:setDuty', src, true)
    else
        exports['rpa-lib']:Notify(src, _U('off_duty') or "You are now off duty", "info")
        TriggerClientEvent('rpa-police:client:setDuty', src, false)
    end
end)

-- Cuff Target Player
RegisterNetEvent('rpa-police:server:cuff', function(targetId)
    local src = source
    local Framework = exports['rpa-lib']:GetFramework()
    local Player = Framework.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local job = Player.PlayerData.job
    if job.name ~= 'police' then
        exports['rpa-lib']:Notify(src, _U('not_police') or "You are not a police officer", "error")
        return
    end
    
    -- Check if target exists
    local TargetPlayer = Framework.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        exports['rpa-lib']:Notify(src, _U('invalid_target') or "Invalid target", "error")
        return
    end
    
    -- Trigger cuff animation on target
    TriggerClientEvent('rpa-police:client:cuff', targetId)
    exports['rpa-lib']:Notify(src, _U('player_cuffed') or "Player cuffed", "success")
end)

RegisterNetEvent('rpa-police:server:addCasing', function(coords, weapon)
    table.insert(Casings, {
        coords = coords,
        weapon = weapon,
        id = os.time()
    })
    TriggerClientEvent('rpa-police:client:syncCasings', -1, Casings)
end)

RegisterNetEvent('rpa-police:server:collectCasing', function(index)
    local src = source
    if Casings[index] then
        local casing = Casings[index]
        table.remove(Casings, index)
        TriggerClientEvent('rpa-police:client:syncCasings', -1, Casings)
        
                         -- Give item via bridge
        exports['rpa-lib']:Notify(src, _U('evidence_collected', 'Casing'), "success")
        -- exports['rpa-lib']:AddItem(src, 'casing', 1, { weapon = casing.weapon })
    end
end)
