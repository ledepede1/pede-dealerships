--- Both catalog and democars here.
local ox_target = exports.ox_target

function RgbConvert(rgbString)
    local r, g, b = rgbString:match("(%d+), (%d+), (%d+)")
    return tonumber(r), tonumber(g), tonumber(b)
end


function SpawnDemoVehicle(coords, jobName)
    local stock = {}
    ESX.TriggerServerCallback('pede:getStock', function(returnedStock)
        for k, v in pairs(returnedStock) do
            table.insert(stock, {  
                title = v.label,
                description = ("Minimums salgspris %s DKK"):format(SplitNumber(v.minprice)),
                onSelect = function()
                    local settingsCar = lib.inputDialog('Vælg farve til | '..v.label, {
                        {type = 'checkbox', label = 'Skal køretøjet dreje rundt'},
                        {type = 'color', label = 'Colour input', default = 'rgb(123,123,123)', format='rgb'},
                      })

                      if not settingsCar then return end
                      SpawnVeh(v.modelname, coords, settingsCar[2], settingsCar[1], jobName)
                end
            }) 
        end
        
        lib.registerContext({
            id = 'demo_menu'..coords,
            title = 'Fremvis køretøj fra lageret',
            options = stock,
        })
        
        lib.showContext('demo_menu'..coords)
    end, jobName)
end

function SpawnVeh(car, coords, rgb, turning, jobname)
    local r,g,b = RgbConvert(rgb)
    local carSpawned
    local price
    local carLabel

    if ESX.Game.IsSpawnPointClear(coords, 5) then
        ESX.TriggerServerCallback('pede:getCarStockPrice', function(returnedStock)
            carLabel = returnedStock[1].label
        end, jobname, car)

        ESX.Game.SpawnVehicle(car, coords, 20, function (vehicle)
            carSpawned = true

            ox_target:addBoxZone({
                coords = GetEntityCoords(vehicle),
                name = "deleteveh:"..vehicle,
                size = vec3(2.5, 2.5, 2.5),
                rotation = 45,
                drawSprite = true,
                options = {
                    {
                        name = 'delete:showcar:'..vehicle,
                        onSelect = function ()
                            ox_target:removeZone("deleteveh:"..vehicle)
                            DeleteVehicle(vehicle)
                            carSpawned = false
                        end,
                        icon = 'fa-solid fa-car',
                        label = Locales[Lang].targets.removeShowcar,
                        groups = {[jobname] = 0}
                    },
                    {
                        icon = "fa-solid fa-info",
                        label = "Information om køretøjet",
                        onSelect = function ()
                            lib.registerContext({
                                id = 'information_menu'..vehicle,
                                title = Locales[Lang].targets.showcarInfo,
                                options = {
                                    {
                                        title = ("Køretøj: %s"):format(carLabel),
                                    },
                                },
                            })
    
                            lib.showContext('information_menu'..vehicle)
                        end,
                    }
                }
            })

            SetVehicleDoorsLockedForAllPlayers(vehicle, true)
            SetVehicleDoorsLocked(vehicle, 2)
            SetVehicleAllowNoPassengersLockon(vehicle, true)
            FreezeEntityPosition(vehicle, true)


            SetVehicleCustomPrimaryColour(
                vehicle, 
                r, 
                g, 
                b
            )

            SetVehicleDirtLevel(vehicle, 0.0)

            lib.notify({
                title = Locales[Lang].notifications.title,
                description = Locales[Lang].notifications.showedACar,
                type = "success"
            })

            if Config.AllowTurning and turning  then
                Citizen.CreateThread(function()
                    while carSpawned == true do
                        Citizen.Wait(0)
                        local heading = GetEntityHeading(vehicle)
                        SetEntityHeading(vehicle, heading + 0.3)
                    end
                end)
            end
        end)
    else
        lib.notify({
            title = Locales[Lang].notifications.title,
            description = Locales[Lang].notifications.vehicleBlocking,
            type = "error"
        })
    end
end

function CatalogMenu(category, CatalogCoords)
    local isWatching = false

    local options2 = {}
    local categories = {}
    local vehLabels = Locales[Lang].vehLabels

    ESX.TriggerServerCallback('pede:getBuyableStock', function(returnedBuyableStock)
        for k, v in pairs(returnedBuyableStock) do
            local categoryTable = categories[v.category] or {}
            table.insert(categoryTable, {
                title = v.label,
                description = "Tryk for se dette køretøj",
                onSelect = function()
                    isWatching = true
                    RemoveCatalogVehicle()
                    SpawnCatalogVehicle(v.modelname)
                    
                    lib.showContext('catalog_entered_'..vehLabels[v.category])
                end,
            })
            categories[v.category] = categoryTable
        end
    
        for cat, opts in pairs(categories) do
            table.insert(options2, {
                title = vehLabels[cat],
                icon = "fa-solid fa-credit-card",
                description = "Se på "..vehLabels[cat], 
                onSelect = function()
                    lib.registerContext({
                        id = 'catalog_entered_'..vehLabels[cat],
                        menu = 'catalog_'..category,
                        onExit = function ()
                            if isWatching == true then
                                RemoveCatalogVehicle()
                                SetEntityCoords(PlayerPedId(), CatalogCoords.x, CatalogCoords.y, CatalogCoords.z, true, false, false, false)
                                StopCatalog()
                                isWatching = false
                            end
                        end,
                        title = 'Katalog',
                        options = opts,
                    })
                    lib.showContext('catalog_entered_'..vehLabels[cat])
                end,
            })
        end
    
        lib.registerContext({
            id = 'catalog_'..category,
            title = 'Katalog',
            onExit = function ()
                if isWatching == true then
                    RemoveCatalogVehicle()
                    SetEntityCoords(PlayerPedId(), CatalogCoords.x, CatalogCoords.y, CatalogCoords.z, true, false, false, false)
                    StopCatalog()
                    isWatching = false
                end
            end,
            options = options2,
        })
        lib.showContext('catalog_'..category)
    end, category)
end    