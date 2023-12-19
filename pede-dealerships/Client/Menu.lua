function OpenDealerMenu(name, jobName, category, spawncoords, spawnheading, testcarcoords, testcarheading)
    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
    local playerName = Locales[Lang].noPlayersNearby
    local stockWorth = GetStockWorth(jobName)

        if closestPlayer ~= -1 or closestPlayerDistance < 3.0 then
            ESX.TriggerServerCallback('pede:getPlayerName', function(returnedName)
                playerName = returnedName



        lib.registerContext({
          id = 'cardealer_main_menu',
          title = Config.Menus.mainmenu.title,
          options = {
            {
                title = Config.Menus.mainmenu.testcars.title,
                icon = Config.Menus.mainmenu.testcars.icon,
                onSelect = function ()
                    TestDriveMenu(jobName, testcarcoords, testcarheading)
                end,
            },
            {
              title = Config.Menus.mainmenu.sellcars.title,
              description = Config.Menus.mainmenu.sellcars.description,
              icon = Config.Menus.mainmenu.sellcars.icon,
              onSelect = function()
                OpenSellMenu(jobName, spawncoords, spawnheading)
              end,
              metadata = {
                {label = Config.Menus.mainmenu.sellcars.metadata, value = playerName},
              },
            },
            {
                title = Config.Menus.mainmenu.stock.title,
                description = (Config.Menus.mainmenu.stock.description):format(name),
                icon = Config.Menus.mainmenu.stock.icon,
                metadata = {
                    {label = (Config.Menus.mainmenu.stock.metadata):format(name), value = SplitNumber(stockWorth).." DKK"},
                  },
                onSelect = function()
                    OpenStock(jobName)
                end
            },
            {
                title = Config.Menus.mainmenu.buystock.title,
                description = (Config.Menus.mainmenu.buystock.description):format(name),
                icon = Config.Menus.mainmenu.buystock.icon,
                onSelect = function()
                    if ESX.PlayerData.job.grade >= Config.AllowedToBuyStock then
                        BuyStock(jobName, category)
                    else
                        lib.notify({
                            title = Locales[Lang].notifications.title,
                            description = Locales[Lang].notifications.notAllowed,
                            type = "error"
                        })
                    end
                end
            },
            {
                title = Config.Menus.mainmenu.editprices.title,
                description = (Config.Menus.mainmenu.editprices.description):format(name),
                icon = Config.Menus.mainmenu.editprices.icon,
                onSelect = function()
                    ChangePrices(jobName)
                end
            },
          }
        })
            lib.showContext('cardealer_main_menu')
        end, GetPlayerServerId(closestPlayer))
    end
end

function ChangePrices(company)
    if ESX.PlayerData.job.grade_name == Config.bossName and ESX.PlayerData.job.name == company then
    local stock = {}
    ESX.TriggerServerCallback('pede:getStock', function(returnedStock)
        for k, v in pairs(returnedStock) do
            table.insert(stock, {  
                title = v.label,
                description = (Config.Menus.changeprices.description):format(SplitNumber(v.minprice)),
                onSelect = function ()
                    local newPrice = lib.inputDialog((Config.Menus.changeprices.dialog.title):format(v.label), {
                        {type = 'number', label = Config.Menus.changeprices.dialog.label, description = Config.Menus.changeprices.dialog.description, icon = Config.Menus.changeprices.dialog.icon, defualt=v.minprice},
                    })
                    if not newPrice then return end

                    ESX.TriggerServerCallback('pede:changePrices:minprice', function(returnedMinPrice)
                        if returnedMinPrice > newPrice[1] then
                            lib.notify({
                                title = Locales[Lang].notifications.title,
                                description = Locales[Lang].notifications.changePriceTooLow,
                                type = "error"
                            })
                        else
                            TriggerServerEvent("change:car:price", v.modelname, company, newPrice[1])
                        end
                    end, v.modelname)
                end,
            }) 
        end
            
            lib.registerContext({
                id = 'cardealer_stock_change_prices'..company,
                title = 'Ændre priser',
                menu = 'cardealer_main_menu',
                options = stock,
            })
            
                lib.showContext('cardealer_stock_change_prices'..company)
        end, company)
    else
        lib.notify({
            title = Locales[Lang].notifications.title,
            description = Locales[Lang].notifications.notAllowed,
            type = "error"
        })
    end
end

function OpenStock(jobName)
    local stock = {}
    ESX.TriggerServerCallback('pede:getStock', function(returnedStock)
        for k, v in pairs(returnedStock) do
            table.insert(stock, {  
                title = string.format(Config.Menus.openstock.title, v.label, v.stock),
                description = (Config.Menus.openstock.description):format(SplitNumber(v.minprice)),
                onSelect = function()
                    if ESX.PlayerData.job.grade_name == Config.bossName and ESX.PlayerData.job.name == jobName then
                    local amount = lib.inputDialog((Config.Menus.openstock.dialog.title):format(v.label), {
                        {type = 'number', label = Config.Menus.openstock.dialog.label, description = (Config.Menus.openstock.dialog.description):format(v.label), icon = Config.Menus.openstock.dialog.icon, min=1},
                    })
                    if not amount then return end

                    ESX.TriggerServerCallback('pede:getBuyPrice', function(returnedPrice, returnedStock)
                        local returnPrice = returnedPrice.buyprice / 100 * Config.SendBackReward * amount[1]
                        if amount[1] > returnedStock.stock then
                            lib.notify({
                                title = Locales[Lang].notifications.title,
                                description = (Locales[Lang].notifications.toManyReturnSend):format(v.label),
                                type = "error"
                            })
                        return end

                        local confirm = lib.alertDialog({
                            header = Config.Menus.openstock.acceptreturn.header,
                            content = string.format(Config.Menus.openstock.acceptreturn.content, amount[1], v.label, SplitNumber(returnPrice)),
                            centered = true,
                            cancel = true
                        })
                        if confirm == "confirm" then
                            TriggerServerEvent("send:car:retur", v.modelname, jobName, returnPrice, amount[1])
                            lib.notify({
                                title = Locales[Lang].notifications.title,
                                description = string.format(Locales[Lang].notifications.returnedVehicle,amount[1], v.label, SplitNumber(returnPrice)),
                                type = "inform"
                            })
                            end
                        end, v.modelname)
                    else
                        lib.notify({
                            title = Locales[Lang].notifications.title,
                            description = Locales[Lang].notifications.notAllowed,
                            type = "error"
                        })
                    end
                end,
            }) 
        end
            
            lib.registerContext({
                id = 'cardealer_stock'..jobName,
                title = 'Lager',
                menu = 'cardealer_main_menu',
                options = stock,
            })
            
            lib.showContext('cardealer_stock'..jobName)
    end, jobName)
end

function BuyStock(jobName, category)
    local options2 = {}
    local categories = {}
    local vehLabels = Locales[Lang].vehLabels

    ESX.TriggerServerCallback('pede:getBuyableStock', function(returnedBuyableStock)
        for k, v in pairs(returnedBuyableStock) do
            local categoryTable = categories[v.category] or {}
            table.insert(categoryTable, {
                title = v.label,
                description = (Config.Menus.buystock.description):format(SplitNumber(v.buyprice)),
                onSelect = function()
                    local amount = lib.inputDialog((Config.Menus.buystock.dialog.title):format(v.label), {
                        {type = 'number', label = Config.Menus.buystock.dialog.label, description = Config.Menus.buystock.dialog.description, icon = Config.Menus.buystock.dialog.icon},
                    })
                    if not amount then return end

                    TriggerServerEvent("pede:buyStock", jobName, v.modelname, amount[1])
                end,
            })
            categories[v.category] = categoryTable
        end

        for cat, opts in pairs(categories) do
            table.insert(options2, {
                title = vehLabels[cat],
                icon = "fa-solid fa-credit-card",
                description = "Køb "..vehLabels[cat].." hjem", 
                onSelect = function()
                    lib.registerContext({
                        id = 'cardealer_buystock'..vehLabels[cat],
                        menu = 'cardealer_buystock'..jobName,
                        title = 'Køb køretøjer hjem',
                        options = opts,
                    })
                    lib.showContext('cardealer_buystock'..vehLabels[cat])
                end,
            })
        end

        lib.registerContext({
            id = 'cardealer_buystock'..jobName,
            menu = 'cardealer_main_menu',
            title = 'Køb køretøjer hjem',
            options = options2,
        })
        lib.showContext('cardealer_buystock'..jobName)
    end, category)
end