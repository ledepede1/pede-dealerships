Lang = Config.Language

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)
    
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)


Citizen.CreateThread(function()
    for _, dealershipInfo in pairs(Config.Dealerships) do
        local blip = AddBlipForCoord(dealershipInfo.MenuTargets[1].x, dealershipInfo.MenuTargets[1].y, dealershipInfo.MenuTargets[1].z)

        
            SetBlipSprite(blip, dealershipInfo.blip.id)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, dealershipInfo.blip.size)
            SetBlipColour(blip, dealershipInfo.blip.color)



            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(dealershipInfo.CompanyLabel)
            EndTextCommandSetBlipName(blip)
    end
end)

RegisterNetEvent("send:accept:dialog:to:player:client")
AddEventHandler("send:accept:dialog:to:player:client", function(carname, numberplate, price, modelname, player, spawncoords, spawnheading, jobName, cardealer)
    local playerAcceptDialog = lib.alertDialog({
        header = (Locales[Lang].playerAcceptBuy.header):format(carname),
        content = string.format(Locales[Lang].playerAcceptBuy.desc, carname, numberplate, SplitNumber(price)),
        centered = true,
        cancel = true
    })
    if playerAcceptDialog == "confirm" then
        SpawnSoldVehicle(modelname, numberplate, player, spawncoords, spawnheading, jobName, price, cardealer)
    end
end)

RegisterNetEvent("pededealerships:notify:client")
AddEventHandler("pededealerships:notify:client", function(title, desc, type)
    lib.notify({
        title = title,
        description = desc,
        type = type
    })
end)