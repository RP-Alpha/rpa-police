-- RP-Alpha Police - Server
-- Uses rpa-lib permissions system

local Casings = {}
local OnDuty = {}

-- Helper function to check permissions
local function CheckPermission(source, permConfig)
    return exports['rpa-lib']:HasPermission(source, permConfig, 'police')
end

-- Duty Toggle
RegisterNetEvent('rpa-police:server:toggleDuty', function()
    local src = source
    
    -- Check if player has police job
    local hasPerm, reason = CheckPermission(src, { jobs = {'police'} })
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "You are not a police officer", "error")
        return
    end
    
    OnDuty[src] = not OnDuty[src]
    
    if OnDuty[src] then
        exports['rpa-lib']:Notify(src, "You are now on duty", "success")
        TriggerClientEvent('rpa-police:client:setDuty', src, true)
    else
        exports['rpa-lib']:Notify(src, "You are now off duty", "info")
        TriggerClientEvent('rpa-police:client:setDuty', src, false)
    end
end)

-- Cuff Target Player (requires police job + on duty)
RegisterNetEvent('rpa-police:server:cuff', function(targetId)
    local src = source
    
    local hasPerm, reason = CheckPermission(src, Config.EvidencePermissions)
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "No permission", "error")
        return
    end
    
    -- Check if target exists
    local Framework = exports['rpa-lib']:GetFramework()
    local TargetPlayer = Framework.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        exports['rpa-lib']:Notify(src, "Invalid target", "error")
        return
    end
    
    -- Trigger cuff animation on target
    TriggerClientEvent('rpa-police:client:cuff', targetId)
    exports['rpa-lib']:Notify(src, "Player cuffed", "success")
end)

-- Evidence Collection
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
    
    local hasPerm, reason = CheckPermission(src, Config.EvidencePermissions)
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "No permission", "error")
        return
    end
    
    if Casings[index] then
        local casing = Casings[index]
        table.remove(Casings, index)
        TriggerClientEvent('rpa-police:client:syncCasings', -1, Casings)
        exports['rpa-lib']:Notify(src, "Evidence collected: Casing", "success")
    end
end)

-- Admin Commands (hire, fire, manage ranks)
RegisterCommand('policehire', function(source, args, rawCommand)
    local src = source
    
    local hasPerm, reason = CheckPermission(src, Config.AdminPermissions)
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "No permission", "error")
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        exports['rpa-lib']:Notify(src, "Usage: /policehire [playerID]", "error")
        return
    end
    
    local Framework = exports['rpa-lib']:GetFramework()
    local TargetPlayer = Framework.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        exports['rpa-lib']:Notify(src, "Player not found", "error")
        return
    end
    
    TargetPlayer.Functions.SetJob('police', 0)
    exports['rpa-lib']:Notify(src, "Player hired to police department", "success")
    exports['rpa-lib']:Notify(targetId, "You have been hired to the police department", "success")
end, false)

RegisterCommand('policefire', function(source, args, rawCommand)
    local src = source
    
    local hasPerm, reason = CheckPermission(src, Config.AdminPermissions)
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "No permission", "error")
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        exports['rpa-lib']:Notify(src, "Usage: /policefire [playerID]", "error")
        return
    end
    
    local Framework = exports['rpa-lib']:GetFramework()
    local TargetPlayer = Framework.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        exports['rpa-lib']:Notify(src, "Player not found", "error")
        return
    end
    
    TargetPlayer.Functions.SetJob('unemployed', 0)
    exports['rpa-lib']:Notify(src, "Player fired from police department", "success")
    exports['rpa-lib']:Notify(targetId, "You have been fired from the police department", "error")
end, false)

RegisterCommand('policesetrank', function(source, args, rawCommand)
    local src = source
    
    local hasPerm, reason = CheckPermission(src, Config.AdminPermissions)
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "No permission", "error")
        return
    end
    
    local targetId = tonumber(args[1])
    local rank = tonumber(args[2])
    
    if not targetId or not rank then
        exports['rpa-lib']:Notify(src, "Usage: /policesetrank [playerID] [rank]", "error")
        return
    end
    
    local Framework = exports['rpa-lib']:GetFramework()
    local TargetPlayer = Framework.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        exports['rpa-lib']:Notify(src, "Player not found", "error")
        return
    end
    
    if TargetPlayer.PlayerData.job.name ~= 'police' then
        exports['rpa-lib']:Notify(src, "Player is not a police officer", "error")
        return
    end
    
    TargetPlayer.Functions.SetJob('police', rank)
    exports['rpa-lib']:Notify(src, "Player rank updated", "success")
    exports['rpa-lib']:Notify(targetId, "Your police rank has been updated", "info")
end, false)

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    OnDuty[src] = nil
end)
