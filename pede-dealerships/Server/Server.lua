-- Making global variable to use Lang from Config to locale files.
Lang = Config.Language

-- Function to check if the players job is in one of the dealerships jobs
function CheckIfPlayerIsAllowed(player)
    if player == nil then
    player = source
    end

    local xPlayer = ESX.GetPlayerFromId(player)
    local hasJob = false

    for _, v in pairs(Config.Dealerships) do
        if v.jobName ==  xPlayer.job.name then
                hasJob = true
            break
        end
    end

    return hasJob
end

-- Checking if the society in the Config is already existing if not then it will create it.
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

-- Divide number into thousand 1.000.000
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

-- Callbacks

-- Callback to get given players fist and lastname.
ESX.RegisterServerCallback('pede:getPlayerName', function(source, cb, player)
    if CheckIfPlayerIsAllowed(source) then 
        local playerName

        if player == nil then
            playerName = Locales[Lang].noPlayersNearby
        else
            local xPlayer = ESX.GetPlayerFromId(player)
            playerName = xPlayer.getName()
        end
            
        cb(playerName)
    end
end)

-- Callback to get the nearest players money.
ESX.RegisterServerCallback('pede:getPlayerMoney', function(source, cb, player)
    if CheckIfPlayerIsAllowed(source) then 
        local xPlayer = ESX.GetPlayerFromId(player)
        local playerMoney = xPlayer.getAccount('bank')
            
        cb(playerMoney)
    end
end)

-- Callback to check if the plate already exist.
ESX.RegisterServerCallback('pede:getNumberPlate', function(source, cb, numberplate)
    if CheckIfPlayerIsAllowed(source) then 
        local numberPlate = MySQL.query.await('SELECT plate FROM `owned_vehicles` WHERE plate=?', {
            numberplate
        })

        cb(numberPlate)
    end
end)

-- Get the given companys stock of vehicles.
ESX.RegisterServerCallback('pede:getStock', function(source, cb, name)
    if CheckIfPlayerIsAllowed(source) then 
        local stockCars = MySQL.query.await('SELECT * FROM `pede-stock` WHERE company=?', {
            name
        })

        cb(stockCars)
    end
end)

-- Get the cars price from the individual company.
ESX.RegisterServerCallback('pede:getCarStockPrice', function(source, cb, name, modelname)
    if CheckIfPlayerIsAllowed(source) then 
        local stockCars = MySQL.query.await('SELECT * FROM `pede-stock` WHERE company=? AND modelname=?', {
            name,
            modelname
        })

        cb(stockCars)
    end
end)

ESX.RegisterServerCallback('pede:changePrices:minprice', function(source, cb, name)
    if CheckIfPlayerIsAllowed(source) then 
        local minBuyPrice = MySQL.query.await('SELECT * FROM `pede-vehicles` WHERE modelname=?', {
            name
        })
        local minPrice = minBuyPrice[1].buyprice

        cb(minPrice)
    end
end)

ESX.RegisterServerCallback('pede:getBuyPrice', function(source, cb, name)
    if CheckIfPlayerIsAllowed(source) then 
        local buyPrice = MySQL.query.await('SELECT * FROM `pede-vehicles` WHERE modelname=?', {
            name
        })
        local price = buyPrice[1]

        local stock = MySQL.query.await('SELECT * FROM `pede-stock` WHERE modelname=?', {
            name
        })
        local stock = stock[1]

        cb(price, stock)
    end
end)

ESX.RegisterServerCallback('pede:getStockWorth', function(source, cb, name)
    if CheckIfPlayerIsAllowed(source) then 
        local worth = 0
        local stockCars = MySQL.query.await('SELECT * FROM `pede-stock` WHERE company=?', {
            name
        })
        for k, v in pairs(stockCars) do
            worth = worth + v.minprice * tonumber(v.stock)
        end
        cb(worth)
    end
end)

ESX.RegisterServerCallback('pede:getBuyableStock', function(source, cb, category)
    if CheckIfPlayerIsAllowed(source) then 
        local stockCars
        if category == "all" then
            stockCars = MySQL.query.await('SELECT * FROM `pede-vehicles`')
        else
            stockCars = MySQL.query.await('SELECT * FROM `pede-vehicles` WHERE companycategory=?', {
                category
            })
        end

        cb(stockCars)
    end
end)

-- Events

RegisterNetEvent("pede:buyStock")
AddEventHandler("pede:buyStock", function(companyName, car, amount) -- Company is actualy just the jobname but companyName sounds nicer
    local source = source
    local Player = ESX.GetPlayerFromId(source)

    if CheckIfPlayerIsAllowed(source) then
        local getCarData = MySQL.query.await('SELECT * FROM `pede-vehicles` WHERE modelname=?', {
            car
        })

        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..companyName, function(account)
            if account.money > tonumber(getCarData[1].buyprice)*amount then
                account.removeMoney(tonumber(getCarData[1].buyprice)*amount)

                local minsellprice = tonumber(getCarData[1].buyprice) / 100 * Config.MinSellPercent
                local currentStock = 1
        
        
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
                TriggerClientEvent("pededealerships:notify:client", source, Locales[Lang].notifications.title,string.format(Locales[Lang].notifications.boughtStock, amount, getCarData[1].label, tonumber(getCarData[1].buyprice)*amount), "success")
                Log(string.format("Name: %s ID: %s \nkøbte lige %sx %s til %s \nJobname: %s \nGrade: %s", Player.getName(), source, amount, car, companyName, Player.job.name, Player.job.grade_name))
        
                getCarData = nil
                getCarDataStock = nil
            else
                TriggerClientEvent("pededealerships:notify:client", source, Locales[Lang].notifications.title,Locales[Lang].notifications.notEnoughSocietyMoney, "error")
            end
        end)
    else
        DropPlayer(source, "Prøvede at exploite: "..GetCurrentResourceName())
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

    
    if CheckIfPlayerIsAllowed(cardealer) then 
    Cardealer.addAccountMoney('bank', (carprice / 100 * Config.SalesRewardPercent))
    TriggerClientEvent("pededealerships:notify:client", cardealer, Locales[Lang].notifications.title, ("Du modtog %s DKK for at sælge køretøjet"):format(SplitNumber(carprice / 100 * Config.SalesRewardPercent)), "success")

    Owner.removeAccountMoney('bank', carprice)
    TriggerClientEvent("pededealerships:notify:client", player, Locales[Lang].notifications.title, Locales[Lang].notifications.congratPlayer, "success")

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
    else
        DropPlayer(source, "Prøvede at exploite: "..GetCurrentResourceName())
    end
end)

RegisterNetEvent("change:car:price")
AddEventHandler("change:car:price", function (car, company, price)
    local source = source

    if CheckIfPlayerIsAllowed(source) then 
        MySQL.query.await('UPDATE `pede-stock` SET minprice=? WHERE modelname=? AND company=?', {
            price,
            car,
            company
        })
        TriggerClientEvent("pededealerships:notify:client", source, Locales[Lang].notifications.title, string.format("Du ændrede prisen på %s \n til %s DKK", car, price), "success")
    else
        DropPlayer(source, "Prøvede at exploite: "..GetCurrentResourceName())
    end
end)

RegisterNetEvent("send:car:retur")
AddEventHandler("send:car:retur", function (car, company, money, amount)
    local source = source

    if CheckIfPlayerIsAllowed(source) then 
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
    else
        DropPlayer(source, "Prøvede at exploite: "..GetCurrentResourceName())
    end
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