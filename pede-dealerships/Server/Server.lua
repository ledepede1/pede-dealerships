Lang = Config.Language

for _, v in pairs(Config.Dealerships) do
    TriggerEvent('esx_society:registerSociety', v.jobName, v.CompanyLabel, 'society_'..v.jobName, 'society_'..v.jobName, 'society_'..v.jobName, {type = 'public'})

    local list = MySQL.Sync.fetchAll('SELECT name FROM `addon_account` WHERE `name` = ?', {
        'society_'..v.jobName
    })
    if not list[1] then
    MySQL.insert.await('INSERT INTO `addon_account` (name, label, shared) VALUES (?, ?, ?)', {
        'society_'..v.jobName, v.CompanyLabel, 1
    })
    MySQL.insert.await('INSERT INTO `addon_account_data` (account_name, money) VALUES (?, ?)', {
        'society_'..v.jobName, 0
    })
    print("Created new Society: "..'society_'..v.JobName)
    end
end

-- Callbacks
ESX.RegisterServerCallback('pede:getPlayerName', function(source, cb, player)
    local playerName

    if player == nil then
        playerName = Locales[Lang].noPlayersNearby
    else
        local xPlayer = ESX.GetPlayerFromId(player)
        playerName = xPlayer.getName()
    end
		
	cb(playerName)
end)

ESX.RegisterServerCallback('pede:getPlayerMoney', function(source, cb, player)
	local xPlayer = ESX.GetPlayerFromId(player)
    local playerMoney = xPlayer.getAccount('bank')
		
	cb(playerMoney)
end)

ESX.RegisterServerCallback('pede:getNumberPlate', function(source, cb, numberplate)
	local numberPlate = MySQL.query.await('SELECT plate FROM `owned_vehicles` WHERE plate=?', {
        numberplate
    })

	cb(numberPlate)
end)

ESX.RegisterServerCallback('pede:getStock', function(source, cb, name)
	local stockCars = MySQL.query.await('SELECT * FROM `pede-stock` WHERE company=?', {
        name
    })

	cb(stockCars)
end)

ESX.RegisterServerCallback('pede:getCarStockPrice', function(source, cb, name, modelname)
	local stockCars = MySQL.query.await('SELECT * FROM `pede-stock` WHERE company=? AND modelname=?', {
        name,
        modelname
    })

	cb(stockCars)
end)

ESX.RegisterServerCallback('pede:changePrices:minprice', function(source, cb, name)
	local minBuyPrice = MySQL.query.await('SELECT * FROM `pede-vehicles` WHERE modelname=?', {
        name
    })
    local minPrice = minBuyPrice[1].buyprice

	cb(minPrice)
end)

ESX.RegisterServerCallback('pede:getBuyPrice', function(source, cb, name)
	local buyPrice = MySQL.query.await('SELECT * FROM `pede-vehicles` WHERE modelname=?', {
        name
    })
    local price = buyPrice[1]

    local stock = MySQL.query.await('SELECT * FROM `pede-stock` WHERE modelname=?', {
        name
    })
    local stock = stock[1]

	cb(price, stock)
end)

ESX.RegisterServerCallback('pede:getStockWorth', function(source, cb, name)
    local worth = 0
	local stockCars = MySQL.query.await('SELECT * FROM `pede-stock` WHERE company=?', {
        name
    })
    for k, v in pairs(stockCars) do
        worth = worth + v.minprice * tonumber(v.stock)
    end
	cb(worth)
end)

ESX.RegisterServerCallback('pede:getBuyableStock', function(source, cb, category)
    local stockCars
    if category == "all" then
        stockCars = MySQL.query.await('SELECT * FROM `pede-vehicles`')
    else
        stockCars = MySQL.query.await('SELECT * FROM `pede-vehicles` WHERE companycategory=?', {
            category
        })
    end

	cb(stockCars)
end)

-- Events

RegisterNetEvent("pede:buyStock")
AddEventHandler("pede:buyStock", function(companyName, car, amount)
    local source = source
    local Player = ESX.GetPlayerFromId(source)

    local getSocietyMoney = MySQL.query.await('SELECT money FROM `addon_account_data` WHERE account_name=?', {
        'society_'..companyName
    })

	local getCarData = MySQL.query.await('SELECT * FROM `pede-vehicles` WHERE modelname=?', {
        car
    })

    local minsellprice = tonumber(getCarData[1].buyprice) / 100 * Config.MinSellPercent
    local currentStock = 1

    if tonumber(getSocietyMoney[1].money) >= tonumber(getCarData[1].buyprice)*amount then
    MySQL.query.await('UPDATE `addon_account_data` SET money=? WHERE account_name=?', {
        tonumber(getSocietyMoney[1].money)-tonumber(getCarData[1].buyprice)*amount,
        'society_'..companyName
    })

    local getCarDataStock = MySQL.query.await('SELECT * FROM `pede-stock` WHERE modelname=?', {
        car
    })

    if getCarDataStock and #getCarDataStock >= 0 and getCarDataStock[1] ~= nil and getCarDataStock ~= nil then
    if tonumber(getCarDataStock[1].stock) >= 1 then
        currentStock = tonumber(getCarDataStock[1].stock) + amount
        MySQL.query.await('UPDATE `pede-stock` SET company=?, modelname=?, label=?, minprice=?, stock=? WHERE modelname=?', {
            companyName,
            car,
            getCarData[1].label,
            getCarData[1].buyprice + minsellprice,
            currentStock,
            car
        })
    end
    else
        MySQL.query.await('INSERT INTO `pede-stock` (company, modelname, label, minprice, stock) VALUES (?, ?, ?, ?, ?)', {
            companyName,
            car,
            getCarData[1].label,
            getCarData[1].buyprice + minsellprice,
            currentStock * amount
        })
    end
    TriggerClientEvent("notify:client", source, Locales[Lang].notifications.title,string.format(Locales[Lang].notifications.boughtStock, amount, getCarData[1].label, tonumber(getCarData[1].buyprice)*amount), "success")
    Log(string.format("Name: %s ID: %s \nkøbte lige %sx %s til %s \nJobname: %s \nGrade: %s", Player.getName(), source, amount, car, companyName, Player.job.name, Player.job.grade_name))

    getCarData = nil
    getCarDataStock = nil
else
    TriggerClientEvent("notify:client", source, Locales[Lang].notifications.title,Locales[Lang].notifications.notEnoughSocietyMoney, "error")
    end
end)

RegisterNetEvent("send:accept:dialog:to:player")
AddEventHandler("send:accept:dialog:to:player", function(player, modelname, carlabel, numberplate, price, spawncoords, spawnheading, jobName, cardealer)
    TriggerClientEvent("send:accept:dialog:to:player:client", player, carlabel, numberplate, price, modelname, player, spawncoords, spawnheading, jobName, cardealer)
end)

RegisterNetEvent("give:car:to:player")
AddEventHandler("give:car:to:player", function (plate, player, mods, car, company, carprice, cardealer)
    local Owner = ESX.GetPlayerFromId(player)
    local Cardealer = ESX.GetPlayerFromId(cardealer)
    
    Cardealer.addAccountMoney('bank', (carprice / 100 * Config.SalesRewardPercent))
    TriggerClientEvent("notify:client", cardealer, Locales[Lang].notifications.title, ("Du modtog %s DKK for at sælge køretøjet"):format(carprice / 100 * Config.SalesRewardPercent), "success")

    Owner.removeAccountMoney('bank', carprice)
    TriggerClientEvent("notify:client", player, Locales[Lang].notifications.title, Locales[Lang].notifications.congratPlayer, "success")

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..company, function(account)
        local amount = carprice * (1 - Config.SalesRewardPercent / 100) 
        account.addMoney(amount)
    end)

    MySQL.query.await('INSERT INTO `owned_vehicles` (owner, plate, vehicle, stored, parking) VALUES (?, ?, ?, ?, ?)', {
        Owner.identifier,
        plate,
        json.encode(mods),
        1,
        Config.DefaultGarage
    })

    local getCarDataStock = MySQL.query.await('SELECT * FROM `pede-stock` WHERE modelname=?', {
        car
    })
    
    if getCarDataStock[1].stock - 1 <= 0 then
        MySQL.query.await('DELETE FROM `pede-stock` WHERE modelname=? AND company=?', {
            car,
            company
        })
    else
        MySQL.query.await('UPDATE `pede-stock` SET stock=? WHERE modelname=? AND company=?', {
            getCarDataStock[1].stock - 1,
            car,
            company
        })
    end

    Log(string.format("# Vehicle sold \nModelname: %s \nPrice: %s \n Recipient: %s ID: %s \nSeller: %s ID: %s", car, carprice, Owner.getName(), player, Cardealer.getName(), cardealer))
end)

RegisterNetEvent("change:car:price")
AddEventHandler("change:car:price", function (car, company, price)
    MySQL.query.await('UPDATE `pede-stock` SET minprice=? WHERE modelname=? AND company=?', {
        price,
        car,
        company
    })
end)

RegisterNetEvent("send:car:retur")
AddEventHandler("send:car:retur", function (car, company, money, amount)
    local getCarDataStock = MySQL.query.await('SELECT * FROM `pede-stock` WHERE modelname=?', {
        car
    })

    
    if getCarDataStock[1].stock - amount <= 0 then
        MySQL.query.await('DELETE FROM `pede-stock` WHERE modelname=? AND company=?', {
            car,
            company
        })
    else
        MySQL.query.await('UPDATE `pede-stock` SET stock=? WHERE modelname=? AND company=?', {
            getCarDataStock[1].stock - amount,
            car,
            company
        })
    end

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..company, function(account)
        account.addMoney(money)
    end)
end)





function Log(msg)
    local embeds = {
          {
              ["title"] = "Dealership Logs",
              ["description"] = msg,
          }
    }
    PerformHttpRequest(SVConfig.webhookURL, function(err, text, headers) end, 'POST', json.encode({username = 'Pede-Dealerships', embeds = embeds}), { ['Content-Type'] = 'application/json' })
end