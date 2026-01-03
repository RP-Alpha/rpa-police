RegisterNetEvent('rpa-police:server:toggleDuty', function()
    local src = source
    local player = exports['rpa-lib']:GetFramework().Functions.GetPlayer(src)
    
    -- QB specific duty toggle often requires direct framework call or job update
    -- Ideally framework handles this, but here's a placeholder
    exports['rpa-lib']:Notify(src, "Toggled Duty", "success")
end)
