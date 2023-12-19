local ox_target = exports.ox_target

local targetInfo = {
    cars = {
        icon = "fa-solid fa-car-side",
    },
    bikes = {
        icon = "fa-solid fa-motorcycle",
    },
    boats = {
        icon = "fa-solid fa-sailboat",
    },
    all = {
        icon = "fa-solid fa-book-open-reader",
    },
}

for _, v in pairs(Config.Dealerships) do
    local jobMenuLabel = Locales[Lang].targets.openDealermenu[v.Category]
    local targetIcons = targetInfo[v.Category].icon

    ox_target:addBoxZone({
        coords = v.VehicleDeleteCoords,
        size = vec3(3.5, 3.5, 3.5),
        rotation = 45,
        drawSprite = true,
        options = {
            {
                name = 'delete_vehicle:'..v.jobName,
                onSelect = function ()
                    local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    ESX.Game.DeleteVehicle(currentVehicle)
                end,
                icon = 'fa-solid fa-trash',
                label = Locales[Lang].targets.removeCar,
                canInteract = function()
                    if ESX.PlayerData.job.name == v.jobName and IsPedInAnyVehicle(PlayerPedId(), true) then
                        return true
                    end
                    return false
                end,
            }
        }
    })

    ox_target:addBoxZone({
        coords = v.Bossmenu,
        size = vec3(2.5, 2.5, 2.5),
        rotation = 45,
        drawSprite = true,
        options = {
            {
                name = 'boss_menu:'..v.jobName,
                onSelect = function ()
                    TriggerEvent('esx_society:openBossMenu', v.jobName, function (data, menu) end, {wash = false})
                end,
                icon = 'fa-solid fa-paperclip',
                label = (Locales[Lang].targets.openBossmenu):format(v.CompanyLabel),
                canInteract = function()
                    if ESX.PlayerData.job.grade_name == Config.bossName and ESX.PlayerData.job.name == v.jobName  then
                        return true
                    end
                    return false
                end,
            }
        }
    })

        ox_target:addBoxZone({
            coords = v.CatalogCoords,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 45,
            drawSprite = true,
            options = {
                {
                    name = 'catalog:'..v.CatalogCoords,
                    onSelect = function ()
                        CatalogMenu(v.Category, v.CatalogCoords)
                    end,
                    icon = targetIcons,
                    label = (Locales[Lang].targets.watchCatalog):format(v.CompanyLabel),
                }
            }
        })

    for _, vMenuTargets in ipairs(v.MenuTargets) do
        ox_target:addBoxZone({
            coords = vMenuTargets,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 45,
            drawSprite = true,
            options = {
                {
                    name = 'main_menu:'..vMenuTargets,
                    onSelect = function ()
                        OpenDealerMenu(v.CompanyLabel, v.jobName, v.Category, v.BoughtVehicleSpawnPos, v.BoughtVehicleSpawnHeading, v.TestCarCoords, v.TestCarHeading)
                    end,
                    icon = 'fa-solid fa-user',
                    label = jobMenuLabel,
                    groups = {[v.jobName]=0}
                }
            }
        })
    end

    for _, vDisplayTargets in pairs(v.DisplayCarTargets) do
        ox_target:addBoxZone({
            coords = vDisplayTargets.target,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 45,
            drawSprite = true,
            options = {
                {
                    name = 'display:'..vDisplayTargets.target,
                    onSelect = function ()
                        SpawnDemoVehicle(vDisplayTargets.spawnPos, v.jobName)
                    end,
                    icon = 'fa-solid fa-book-open',
                    label = Locales[Lang].targets.showcaseCar,
                    groups = {[v.jobName]=0}
                } 
            }
        })
    end

end