Config = {}

--[[
    ==========================================
    PERMISSIONS
    ==========================================
    
    You can grant permissions via:
    1. QB-Core/QBOX groups (admin, mod, etc.)
    2. Server.cfg ConVars with player identifiers
    
    server.cfg examples:
    setr rpa_police:admin "steam:110000123456789,license:abc123"
    setr rpa_police:manage_ranks "steam:110000987654321"
]]

-- Who can use police admin commands (hire, fire, manage ranks)
Config.AdminPermissions = {
    groups = {'admin', 'god'},              -- QB-Core groups allowed
    jobs = {'police'},                       -- Job-based (must be police)
    minGrade = 4,                            -- Minimum grade for job-based permission
    resourceConvar = 'admin'                 -- Checks: setr rpa_police:admin "steam:xxx"
}

-- Who can access the police armory
Config.ArmoryPermissions = {
    jobs = {'police'},
    minGrade = 0,
    onDuty = true                            -- Must be on duty
}

-- Who can spawn police vehicles
Config.VehiclePermissions = {
    jobs = {'police'},
    minGrade = 0,
    onDuty = true
}

-- Who can use evidence collection
Config.EvidencePermissions = {
    jobs = {'police'},
    minGrade = 0,
    onDuty = true
}

Config.Stations = {
    ['mrpd'] = {
        label = "Mission Row PD",
        coords = vector3(441.8, -981.5, 30.7),
        locker = vector3(452.6, -992.8, 30.7),
        armory = vector3(452.2, -980.1, 30.7),
        garage = vector4(434.9, -975.7, 25.7, 180.0)
    }
}

Config.Vehicles = {
    ['police'] = { label = 'Police Cruiser', rank = 0 },
    ['police2'] = { label = 'Police Charger', rank = 1 },
}
