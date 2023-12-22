Config = {}

Config.Language = "dk"

Config.CalculateSpeed = 3.6 -- 3.6 for kmh and 2.23694 for mph

Config.MinSellPercent = 10 -- How many percent added to the buy price is the minimum sell price. (When changing this you'll need to wipe the dealership databases before it works optimal so make sure to get this right the first time!)
Config.AllowTurning = true -- Wether the companys should be able to turn their vehicles in the showroom.
Config.Plates = "DK" -- DK, SWE, GER 
Config.DefaultGarage = "depotLot" -- Which garage it should be put in first time.

Config.SalesRewardPercent = 20 -- How many percent of the sale price the individual person who sells the car gets (The rest goes to the society account.)
Config.CatalogSpawn = vector3(-544.0206, -2225.301, 122.3656)
Config.bossName = "boss"
Config.SendBackReward = 70 -- How many percent of the buy price of a vehicle the company should get back after sending it back to the manufacturer
Config.AllowedToBuyStock = 1 -- Smallest grade that can buy cars to the stock

Config.Dealerships = {
    ["PDM"] = {
        CompanyLabel = "Luxury PDM", -- Label on the cardealer
        jobName = "police", -- Jobname of the dealer

        blip = {
            id = 674,
            color = 44,
            size = 0.9,
        },

        Category = "cars", -- Either 'all' for all category's. 'cars' for only cars. 'bike' for only bikes. 'boats' for only boats
        
        Bossmenu = vector3(-806.4951, -204.8651, 41.6335),
        BoughtVehicleSpawnPos = vector3(-774.5132, -229.9516, 36.9975),
        BoughtVehicleSpawnHeading = 208.1747,

        VehicleDeleteCoords = vector3(-769.3365, -233.6901, 36.9976), -- Where youre going to park testcars (Using target)

        TestCarCoords = vector3(-772.8605, -228.3127, 36.9975),
        TestCarHeading = 206.2735, -- Need to have a . number in the heading

        CatalogCoords = vector3(-783.5587, -225.1305, 36.9975),

        MenuTargets = {
            vector3(-781.4059, -233.3287, 36.7987),
            vector3(-30.4717,-1106.775,26.426),
        },
        DisplayCarTargets = {
            [1] = { target = vector3(-785.0050, -238.4798, 38.3146-1), spawnPos = vector3(-786.2864, -242.8497, 37.1612) },
            [2] = { target = vector3(-789.2405, -231.1040, 38.3741-1), spawnPos = vector3(-790.2445, -235.5101, 37.1612) },
            [3] = { target = vector3(-793.3830, -223.9079, 38.3078-1), spawnPos = vector3(-794.8561, -228.2933, 37.1612) },
            [4] = { target = vector3(-796.7291, -217.2274, 38.2579-1), spawnPos = vector3(-791.9578, -217.7204, 37.1612) },
            [5] = { target = vector3(-801.2618, -210.0662, 38.3234-1), spawnPos = vector3(-802.6846, -214.3426, 37.1612) },
            [6] = { target = vector3(-800.5759, -202.7343, 38.2713-1), spawnPos = vector3(-805.6403, -201.7321, 37.1612) },
        }
    },

    ["Sanders MC"] = {
        CompanyLabel = "Sanders MC Forhandler", -- Label on the cardealer
        jobName = "cardealer", -- Jobname of the dealer

        blip = {
            id = 348,
            color = 38,
            size = 0.9,
        },

        Category = "cars", -- Either 'all' for all category's. 'cars' for only cars. 'bike' for only bikes. 'boats' for only boats
        
        Bossmenu = vector3(-32.3454,-1115.0773,26.4223),
        BoughtVehicleSpawnPos = vector3(-31.1693,-1090.6241,26.4222),
        BoughtVehicleSpawnHeading = 20,

        VehicleDeleteCoords = vector3(-37.1153,-1088.1819,26.4223), -- Where youre going to park testcars (Using target)
        
        TestCarCoords = vector3(-31.9247,-1091.3849,26.4223),
        TestCarHeading = 334.6456, -- Need to have a . number in the heading

        CatalogCoords = vector3(-43.9336,-1104.5879,26.4223),

        MenuTargets = {
            vector3(-55.6051,-1098.1056,26.4224),
            vector3(-30.4717,-1106.775,26.426),
        },
        DisplayCarTargets = {
            [1] = { target = vector3(-50.7351,-1091.6746,26.4223), spawnPos = vector3(-39.7972,-1102.7212,26.4223) },
            [2] = { target = vector3(-46.2481,-1104.4904,26.4223), spawnPos = vector3(-47.3,-1093.6865,26.4223) },
        }
    },
}

Config.Menus = {

    sellcar = {
        title = "Sælg et køretøj fra lageret",

        choosePriceDialog = {
            title = "Vælg salgspris af %s",
            label = "Salgspris",
            description = "Salgspris af køretøjet",
            icon = "hashtag",
        },
        sellerConfirm = {
            header = "Godkend",
            content = "Godkend salget af %s\n\nTil %s DKK\n\nTil personen %s",
        },
    },

    buystock = {
        description = "Indkøbspris: %s DKK",
        dialog = {
            title = "Hvor mange %s vil du købe til lageret?",
            label = "Antal",
            description = "Antal køretøjer du vil købe hjem",
            icon = "hashtag"
        },
    },

    openstock = {
        title = "%s | %sx",
        description = "Minimums salgspris %s DKK\nTryk for at sende køretøjet retur",
        dialog = {
            title = "Antal %s at sende retur",
            label = "Antal",
            description = "Hvor mange %s skal sendes retur?",
            icon = "hashtag",
        },
        acceptreturn = {
            header = "Accepter returnering",
            content = "Du er ved at sende %sx %s retur. \n\nFirmaet vil modtage: %s DKK "
        },
    },

    changeprices = {
        description = "Nuværende minimums salgspris: %s DKK\nTryk for at ændre priser",
        dialog = {
            title = "Ændre prisen på | %s",
            label = "Ny salgspris",
            description = "Indtast ny pris på dette køretøj",
            icon = "hashtag",
        },
    },

    mainmenu = {
        title = "Job Menu",
        
        testcars = {
            title = "Tag køretøj ud til prøvekørsel",
            icon = "fa-solid fa-user",
        },
        sellcars = {
            title = "Sælg køretøj",
            description = "Sælg et køretøj fra lageret til nærmeste person",
            icon = "fa-solid fa-handshake",
            metadata = "Nærmeste spiller"
        },
        stock = {
            title = "Lager",
            description = "Tjek %s's nuværende lager",
            icon = "fa-solid fa-warehouse",
            metadata = "Værdi af %s's nuværende lager"
        },
        buystock = {
            title = "Køb lager hjem",
            description = "Køb køretøjer hjem til %s's lager",
            icon = "fa-solid fa-cart-shopping",
        },
        editprices = {
            title = "Administér Priser",
            description = "Administrer priser på %s's køretøjer",
            icon = "fa-solid fa-coins",
        }
    },

}

