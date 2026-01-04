-- Interactions
CreateThread(function()
    for k, v in pairs(Config.Stations) do
        -- Add Target for Locker
        exports['rpa-lib']:AddTargetZone('police_locker_'..k, v.locker, vector3(1, 1, 2), {
            options = {
                {
                    label = "Open Locker",
                    icon = "fas fa-tshirt",
                    action = function()
                        TriggerServerEvent('rpa-police:server:toggleDuty')
                    end
                }
            }
        }, false)
        
        -- Vehicle Spawner (Simplified interaction)
        exports['rpa-lib']:AddTargetZone('police_garage_'..k, v.garage, vector3(2, 2, 2), {
            options = {
                {
                    label = "Police Garage",
                    icon = "fas fa-car",
                    action = function()
                        -- In real impl: Open garage menu specific for police
                        exports['rpa-lib']:Notify("Garage interactions to be implemented via rpa-garages", "info")
                    end
                }
            }
        }, false)
    end
end)

-- Handcuff Logic
RegisterNetEvent('rpa-police:client:cuff', function()
    local ped = PlayerPedId()
    if not IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3) then
        RequestAnimDict("mp_arresting")
        while not HasAnimDictLoaded("mp_arresting") do Wait(10) end
        TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
        SetEnableHandcuffs(ped, true)
        SetPedCanPlayGestureAnims(ped, false)
        DisplayRadar(false)
    else
        ClearPedTasks(ped)
        SetEnableHandcuffs(ped, false)
        SetPedCanPlayGestureAnims(ped, true)
        DisplayRadar(true)
    end
end)

-- Command to trigger cuff (Target would call server which triggers this on target)
RegisterCommand('cuff', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestPlayer, closestDistance = nil, 3.0
    
    -- Find closest player
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)
            
            if distance < closestDistance then
                closestPlayer = GetPlayerServerId(playerId)
                closestDistance = distance
            end
        end
    end
    
    if closestPlayer then
        TriggerServerEvent('rpa-police:server:cuff', closestPlayer)
    else
        exports['rpa-lib']:Notify(_U('no_target') or "No player nearby", "error")
    end
end, false)

-- Evidence System
local Casings = {}

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedArmed(ped, 4) then -- Only check if armed with a gun
            if IsPedShooting(ped) then
                local weapon = GetSelectedPedWeapon(ped)
                if weapon ~= `WEAPON_STUNGUN` and weapon ~= `WEAPON_FIREEXTINGUISHER` then
                    -- Trigger Server
                    local coords = GetEntityCoords(ped)
                    TriggerServerEvent('rpa-police:server:addCasing', coords, weapon)
                    Wait(500) -- Rate limit casing drops
                end
            end
            Wait(0)
        else
            Wait(1000) -- Sleep heavily if not armed
        end
    end
end)

RegisterNetEvent('rpa-police:client:syncCasings', function(data)
    Casings = data
end)

-- Rendering Casings
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        if #Casings > 0 then
            for i, casing in ipairs(Casings) do
                if #(coords - casing.coords) < 10.0 then
                    -- Simple Marker
                    DrawMarker(3, casing.coords.x, casing.coords.y, casing.coords.z + 0.02, 0,0,0, 0,0,0, 0.1, 0.1, 0.1, 255, 255, 0, 100, false, false, 2, false, nil, nil, false)
                    
                    if #(coords - casing.coords) < 1.0 then
                         exports['rpa-lib']:TextUI("[E] Collect Casing")
                         if IsControlJustPressed(0, 38) then
                             -- Anim
                             TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)
                             Wait(2000)
                             ClearPedTasks(ped)
                             TriggerServerEvent('rpa-police:server:collectCasing', i)
                         end
                    end
                end
            end
        else
            Wait(1000)
        end
    end
end)
