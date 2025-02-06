-- Client-Side Script
local Config = {}

Config.Classes = {
    ['B'] = {
        vehicles = { 'blista', 'sultan', 'tailgater', 'jugular', 'komoda', 'vstr', 'neo', 'streiter', 'raiden', 'rhinehart' }, -- Example Class B vehicles
        modifiers = {
            acceleration = 1.0,   -- 1.0 = default value
            brake = 1.0,         -- 1.0 = default value
            topSpeed = 1.0       -- 1.0 = default value
        }
    },
    -- Add more classes as needed
    ['A'] = {
        vehicles = { 'zentorno', 'adder', 'entityxf', 'nero2', 'vacca', 'reaper' },
        modifiers = {
            acceleration = 1.2,
            brake = 1.1,
            topSpeed = 1.3
        }
    }
}

-- Convert vehicle names to hashes during resource start
for className, classData in pairs(Config.Classes) do
    classData.hashes = {}
    for _, vehicleName in ipairs(classData.vehicles) do
        local hash = GetHashKey(vehicleName)
        classData.hashes[hash] = true
    end
end

-- Check if vehicle belongs to a class and apply modifiers
local function CheckVehicleClass(vehicle)
    local model = GetEntityModel(vehicle)
    
    for className, classData in pairs(Config.Classes) do
        if classData.hashes[model] then
            -- Apply acceleration multiplier
            SetVehicleEnginePowerMultiplier(vehicle, classData.modifiers.acceleration)
            
            -- Apply brake multiplier
            SetVehicleBrakeMultiplier(vehicle, classData.modifiers.brake)
            
            -- Apply top speed modifier
            local defaultSpeed = GetVehicleModelEstimatedMaxSpeed(model)
            SetEntityMaxSpeed(vehicle, defaultSpeed * classData.modifiers.topSpeed)
            
            -- Debug message (remove in production)
            print(("Applied %s class modifiers to vehicle"):format(className))
            return
        end
    end
end

-- Event handler for vehicle entry
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            local ped = PlayerPedId()
            
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                
                -- Only apply if player is driver
                if GetPedInVehicleSeat(vehicle, -1) == ped then
                    CheckVehicleClass(vehicle)
                end
            end
        end
    end)
end)

-- Reset modifiers when exiting vehicle
AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == 'CEventNetworkPlayerLeftVehicle' then
        local vehicle = args[2]
        if DoesEntityExist(vehicle) then
            -- Reset to default values
            SetVehicleEnginePowerMultiplier(vehicle, 1.0)
            SetVehicleBrakeMultiplier(vehicle, 1.0)
            SetEntityMaxSpeed(vehicle, -1.0) -- -1 resets to default
        end
    end
end)
