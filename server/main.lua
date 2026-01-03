local Casings = {}

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
