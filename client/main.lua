-- Placeholder interactions
CreateThread(function()
    for k, v in pairs(Config.Stations) do
        -- Add Target for Locker
        exports['rpa-lib']:AddTargetZone('police_locker_'..k, v.locker, vector3(1, 1, 2), {
            options = {
                {
                    label = "Open Locker",
                    icon = "fas fa-tshirt",
                    action = function()
                        -- Toggle Duty wrapper or open skin menu
                        TriggerServerEvent('rpa-police:server:toggleDuty')
                    end
                }
            }
        }, false)

        -- Vehicle Spawner logic...
    end
end)
