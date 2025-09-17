ESX = exports["es_extended"]:getSharedObject()
local houses = {}
local blips = {}

-- Initialize housing system
CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    loadHouses()
    createBlips()
end)

-- Load houses from server
function loadHouses()
    ESX.TriggerServerCallback('housing:getHouses', function(serverHouses)
        houses = serverHouses
        updateBlips()
    end)
end

-- Create blips for houses
function createBlips()
    for houseId, houseData in pairs(Config.Houses) do
        local blip = AddBlipForCoord(houseData.coords.x, houseData.coords.y, houseData.coords.z)
        SetBlipSprite(blip, Config.BlipSprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.BlipScale)
        SetBlipColour(blip, Config.BlipColor)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(houseData.name)
        EndTextCommandSetBlipName(blip)
        
        blips[houseId] = blip
    end
end

-- Update blips based on ownership
function updateBlips()
    for houseId, houseData in pairs(houses) do
        if blips[houseId] then
            if houseData.owned then
                SetBlipColour(blips[houseId], 1) -- Red for owned houses
            else
                SetBlipColour(blips[houseId], Config.BlipColor) -- Green for available houses
            end
        end
    end
end

-- Create house interaction points
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for houseId, houseData in pairs(Config.Houses) do
            local distance = #(playerCoords - houseData.coords)
            
            if distance < 2.0 then
                -- Draw interaction text
                lib.showTextUI('[E] Abrir menú de casa', {
                    position = "top-center",
                    icon = 'home'
                })
                
                if IsControlJustReleased(0, 38) then -- E key
                    openHouseMenu(houseId)
                end
                break
            elseif distance > 2.0 then
                lib.hideTextUI()
            end
        end
        
        Wait(0)
    end
end)

-- Open house menu
function openHouseMenu(houseId)
    local houseData = houses[houseId] or Config.Houses[houseId]
    if not houseData then return end
    
    ESX.TriggerServerCallback('housing:isHouseOwner', function(isOwner)
        local options = {}
        
        -- House information
        table.insert(options, {
            title = houseData.name,
            description = houseData.description,
            icon = 'home',
            disabled = true
        })
        
        table.insert(options, {
            title = string.format(Config.Messages.price, ESX.Math.GroupDigits(houseData.price)),
            description = houseData.owned and Config.Messages.sold or Config.Messages.available,
            icon = 'dollar-sign',
            disabled = true
        })
        
        if houseData.owned then
            table.insert(options, {
                title = string.format(Config.Messages.owner, "Jugador"),
                icon = 'user',
                disabled = true
            })
        end
        
        -- Action buttons
        if not houseData.owned then
            table.insert(options, {
                title = Config.Messages.buy_house,
                description = string.format("Comprar por $%s", ESX.Math.GroupDigits(houseData.price)),
                icon = 'shopping-cart',
                onSelect = function()
                    confirmPurchase(houseId, houseData.price)
                end
            })
        elseif isOwner then
            local sellPrice = math.floor(houseData.price * Config.SellPercentage)
            table.insert(options, {
                title = Config.Messages.sell_house,
                description = string.format("Vender por $%s", ESX.Math.GroupDigits(sellPrice)),
                icon = 'hand-holding-dollar',
                onSelect = function()
                    confirmSale(houseId, sellPrice)
                end
            })
        end
        
        lib.registerContext({
            id = 'house_menu',
            title = Config.Messages.house_menu_title,
            options = options
        })
        
        lib.showContext('house_menu')
    end, houseId)
end

-- Confirm purchase dialog
function confirmPurchase(houseId, price)
    local alert = lib.alertDialog({
        header = Config.Messages.buy_house,
        content = string.format(Config.Messages.confirm_purchase, ESX.Math.GroupDigits(price)),
        centered = true,
        cancel = true
    })
    
    if alert == 'confirm' then
        ESX.TriggerServerCallback('housing:buyHouse', function(success, message)
            if success then
                lib.notify({
                    title = 'Casa Comprada',
                    description = message,
                    type = 'success',
                    duration = 5000
                })
                loadHouses() -- Reload houses data
            else
                lib.notify({
                    title = 'Error',
                    description = message,
                    type = 'error',
                    duration = 5000
                })
            end
        end, houseId)
    end
end

-- Confirm sale dialog
function confirmSale(houseId, sellPrice)
    local alert = lib.alertDialog({
        header = Config.Messages.sell_house,
        content = string.format(Config.Messages.confirm_sale, ESX.Math.GroupDigits(sellPrice)),
        centered = true,
        cancel = true
    })
    
    if alert == 'confirm' then
        ESX.TriggerServerCallback('housing:sellHouse', function(success, message)
            if success then
                lib.notify({
                    title = 'Casa Vendida',
                    description = message,
                    type = 'success',
                    duration = 5000
                })
                loadHouses() -- Reload houses data
            else
                lib.notify({
                    title = 'Error',
                    description = message,
                    type = 'error',
                    duration = 5000
                })
            end
        end, houseId)
    end
end

-- Command to open houses list
RegisterCommand('casas', function()
    openHousesList()
end, false)

-- Open houses list menu
function openHousesList()
    ESX.TriggerServerCallback('housing:getHouses', function(serverHouses)
        houses = serverHouses
        local options = {}
        
        for houseId, houseData in pairs(houses) do
            local status = houseData.owned and "🔴 Vendida" or "🟢 Disponible"
            table.insert(options, {
                title = houseData.name,
                description = string.format("%s - $%s", status, ESX.Math.GroupDigits(houseData.price)),
                icon = 'home',
                onSelect = function()
                    SetNewWaypoint(houseData.coords.x, houseData.coords.y)
                    lib.notify({
                        title = 'GPS Activado',
                        description = 'Ruta marcada hacia ' .. houseData.name,
                        type = 'inform',
                        duration = 3000
                    })
                end
            })
        end
        
        lib.registerContext({
            id = 'houses_list',
            title = 'Lista de Casas Disponibles',
            options = options
        })
        
        lib.showContext('houses_list')
    end)
end

-- Command to open player's houses
RegisterCommand('miscasas', function()
    ESX.TriggerServerCallback('housing:getPlayerHouses', function(playerHouses)
        if #playerHouses == 0 then
            lib.notify({
                title = 'Sin Propiedades',
                description = 'No tienes ninguna casa',
                type = 'inform',
                duration = 3000
            })
            return
        end
        
        local options = {}
        
        for _, houseData in pairs(playerHouses) do
            table.insert(options, {
                title = houseData.name,
                description = string.format("Valor: $%s", ESX.Math.GroupDigits(houseData.price)),
                icon = 'home',
                onSelect = function()
                    SetNewWaypoint(houseData.coords.x, houseData.coords.y)
                    lib.notify({
                        title = 'GPS Activado',
                        description = 'Ruta marcada hacia ' .. houseData.name,
                        type = 'inform',
                        duration = 3000
                    })
                end
            })
        end
        
        lib.registerContext({
            id = 'player_houses',
            title = 'Mis Casas',
            options = options
        })
        
        lib.showContext('player_houses')
    end)
end)

-- Update houses when server triggers it
RegisterNetEvent('housing:updateHouses', function()
    loadHouses()
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, blip in pairs(blips) do
            RemoveBlip(blip)
        end
        lib.hideTextUI()
    end
end)