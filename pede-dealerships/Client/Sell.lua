local nearestPlayerName = Locales[Lang].noPlayersNearby

function OpenSellMenu(jobName, spawncoords, spawnheading)
    local stock = {}

    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
    local stockWorth = GetStockWorth(jobName)

        if closestPlayer ~= -1 or closestPlayerDistance < 3.0 then
            ESX.TriggerServerCallback('pede:getPlayerName', function(returnedName)
                nearestPlayerName = returnedName
            end, GetPlayerServerId(closestPlayer))
        end


    ESX.TriggerServerCallback('pede:getStock', function(returnedStock)
        for _, v in pairs(returnedStock) do
            table.insert(stock, {  
                title = v.label,
                onSelect = function ()
                    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestPlayerDistance > 3.0 then 
                    lib.notify({
                        title = Locales[Lang].notifications.title,
                        description = Locales[Lang].notifications.noPlayersnearby,
                        type = 'error'
                    })
                else
                    local saleMoney = lib.inputDialog((Config.Menus.sellcar.choosePriceDialog.title):format(v.label), {
                        {type = 'number', label = Config.Menus.sellcar.choosePriceDialog.label, description = Config.Menus.sellcar.choosePriceDialog.description, icon = Config.Menus.sellcar.choosePriceDialog.icon, default=v.minprice, min=v.minprice},
                    })
                    if not saleMoney then return end

                    ESX.TriggerServerCallback('pede:getPlayerMoney', function(returnedMoney)

                        if returnedMoney.money >= saleMoney[1] then
                            local cardealerSaleAccept = lib.alertDialog({
                                header = Config.Menus.sellcar.sellerConfirm.header,
                                content = string.format(Config.Menus.sellcar.sellerConfirm.content, v.label, saleMoney[1], nearestPlayerName),
                                centered = true,
                                cancel = true
                            })       
                            local plate = CreateNumberPlate()       
                            if not cardealerSaleAccept then return end
                            if cardealerSaleAccept == "confirm" then
                                TriggerServerEvent("send:accept:dialog:to:player", GetPlayerServerId(closestPlayer), v.modelname, v.label, plate, saleMoney[1], spawncoords, spawnheading, jobName, GetPlayerServerId(PlayerId()))
                            end
                        else
                            lib.notify({
                                title = Locales[Lang].notifications.title,
                                description = Locales[Lang].notifications.buyerNotEnoughMoney,
                                type = 'error'
                            })
                            end
                        end, GetPlayerServerId(closestPlayer))
                    end
                end,
                description = "Tryk for at sælge til: "..nearestPlayerName.."\n".."Producent: "..GetMakeNameFromVehicleModel(GetHashKey(v.modelname)).."\nMindstepris: "..SplitNumber(v.minprice).." DKK"
            }) 
        end

        lib.registerContext({
            id = 'cardealer_stock_sell'..jobName,
            title = Config.Menus.sellcar.title,
            menu = 'cardealer_main_menu',
            options = stock,
        })
        
        lib.showContext('cardealer_stock_sell'..jobName)
    end, jobName)
end