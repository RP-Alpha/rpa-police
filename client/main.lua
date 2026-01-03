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
    -- Get closest player logic
    -- TriggerServerEvent('rpa-police:server:cuff', targetId)
    print("Use target system to cuff")
end)
