LastVehicles = {}

function GetStockWorth(name)
    local stockWorth = nil
    ESX.TriggerServerCallback('pede:getStockWorth', function(returnedStockWorth)
        stockWorth = returnedStockWorth
    end, name)
    while stockWorth == nil do
        Citizen.Wait(10)
    end
    return stockWorth
end

function SpawnSoldVehicle(veh, plate, player, spawncoords, spawnheading, company, carprice, cardealer)
    ESX.Game.SpawnVehicle(veh, spawncoords, spawnheading, function(vehicle)
        local mods = ESX.Game.GetVehicleProperties(vehicle)
        SetVehicleNumberPlateText(vehicle, plate)
        TriggerServerEvent('give:car:to:player', plate, player, mods, veh, company, carprice, cardealer)
    end)
end


function SplitNumber(n)
    local sign = n < 0 and "-" or ""
    local integerPart, decimalPart = math.modf(math.abs(n))
    local formattedNumber = tostring(integerPart):reverse():gsub("(%d%d%d)","%1."):reverse()

    if decimalPart ~= 0 then
        formattedNumber = formattedNumber .. "." .. string.format("%03d", math.abs(decimalPart * 1000))
    end

    -- Check if the first character is a dot, and remove it if present
    if formattedNumber:sub(1, 1) == "." then
        formattedNumber = formattedNumber:sub(2)
    end

    return sign .. formattedNumber
end

function CheckPlate(plate, callback)
    ESX.TriggerServerCallback('pede:getNumberPlate', function(returnedPlate)
        local doesPlateExist

            if returnedPlate == nil then
                doesPlateExist = false
            end
            if #returnedPlate > 0 and returnedPlate[1].plate == plate then
                doesPlateExist = true
            else
                doesPlateExist = false
            end
        callback(doesPlateExist)
    end, plate)
end

function CreateNumberPlate()
    local plateCountry
    local plates = {
        ["DK"] = {
            Letters = 2,
            Numbers = 5
        },
        ["SWE"] = {
            Letters = 3,
            Numbers = 3
        },
        ["GER"] = {
            Letters = 4,
            Numbers = 3
        },
    }

    if plates[Config.Plates] ~= nil then
        plateCountry = plates[Config.Plates]
    else
        plateCountry = plates["DK"]
    end

    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local numbers = "0123456789"

    local plate = ""
    
    repeat
        Citizen.Wait(0)

        -- Bogstaver
        for _ = 1, plateCountry.Letters do
            local randomIndex = math.random(#letters)
            plate = plate .. letters:sub(randomIndex, randomIndex)
        end
        
        -- Tal
        for _ = 1, plateCountry.Numbers do
            local randomIndex = math.random(#numbers)
            plate = plate .. numbers:sub(randomIndex, randomIndex)
        end

        local isExist = false
        CheckPlate(plate, function(doesPlateExist)
            isExist = doesPlateExist
        end)

    until isExist == false

    return plate
end

function RemoveCatalogVehicle()
        while #LastVehicles > 0 do
        local vehicle = LastVehicles[1]
    
        ESX.Game.DeleteVehicle(vehicle)
        table.remove(LastVehicles, 1)
    end
end

function StopCatalog()
    SetEntityVisible(PlayerPedId(), true, true)
    FreezeEntityPosition(PlayerPedId(), false)
end

function SpawnCatalogVehicle(modelname)
    local spawnCoords = Config.CatalogSpawn
    local heading = 20.0

    SetEntityCoords(PlayerPedId(), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, false, false, false)
    SetEntityVisible(PlayerPedId(), false, false)
    FreezeEntityPosition(PlayerPedId(), true)
    
    local vehicleModel = GetHashKey(modelname)


    ESX.Game.SpawnLocalVehicle(vehicleModel, spawnCoords, heading, function(vehicle)
        table.insert(LastVehicles, vehicle)
        SetVehicleDoorsLockedForAllPlayers(vehicle, true)
        SetVehicleAllowNoPassengersLockon(vehicle, true)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        FreezeEntityPosition(vehicle, true)
    end)
end

function OpenBossMenu(jobname)
    TriggerEvent('esx_society:openBossMenu', jobname, function()
    end, {wash = false})
end