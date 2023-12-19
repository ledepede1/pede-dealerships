function TestDriveMenu(jobName, testdrivespawncoord, heading)
    local stock = {}

    ESX.TriggerServerCallback('pede:getStock', function(returnedStock)
        for k, v in pairs(returnedStock) do
            table.insert(stock, {  
                title = v.label,
                description = ("Tag køretøjet ud til prøvekørsel"),
                onSelect = function()
                if ESX.PlayerData.job.name == jobName then
                    if ESX.Game.IsSpawnPointClear(testdrivespawncoord, 5) then
                        ESX.Game.SpawnVehicle(v.modelname, testdrivespawncoord, heading, function(vehicle)
                            SetVehicleNumberPlateText(vehicle, "T3ST B1L")
                        end)
                        lib.notify({
                            title = Locales[Lang].notifications.title,
                            description = Locales[Lang].notifications.tookOutTestCar,
                            type = "success"
                        })
                    else
                        lib.notify({
                            title =  Locales[Lang].notifications.title,
                            description = Locales[Lang].notifications.vehicleBlocking,
                            type = "error"
                        })
                    end
                end
            end
            }) 
        end
            lib.registerContext({
                id = 'testcars:'..jobName,
                title = 'Lager',
                menu = 'cardealer_main_menu',
                options = stock,
            })
            
            lib.showContext('testcars:'..jobName)
    end, jobName)
end
