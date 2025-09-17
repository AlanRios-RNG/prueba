ESX = exports["es_extended"]:getSharedObject()

-- Create houses table in database if it doesn't exist
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS houses (
            id INT AUTO_INCREMENT PRIMARY KEY,
            house_id INT NOT NULL UNIQUE,
            owner VARCHAR(60) DEFAULT NULL,
            owned BOOLEAN DEFAULT FALSE,
            INDEX(house_id),
            INDEX(owner)
        )
    ]])
    
    -- Insert default houses if they don't exist
    for houseId, houseData in pairs(Config.Houses) do
        MySQL.insert('INSERT IGNORE INTO houses (house_id, owner, owned) VALUES (?, ?, ?)', {
            houseId,
            nil,
            false
        })
    end
end)

-- Load houses data from database
ESX.RegisterServerCallback('housing:getHouses', function(source, cb)
    local houses = {}
    
    MySQL.query('SELECT * FROM houses', {}, function(result)
        for i = 1, #result do
            local houseId = result[i].house_id
            if Config.Houses[houseId] then
                houses[houseId] = {
                    id = houseId,
                    name = Config.Houses[houseId].name,
                    price = Config.Houses[houseId].price,
                    coords = Config.Houses[houseId].coords,
                    description = Config.Houses[houseId].description,
                    owned = result[i].owned == 1,
                    owner = result[i].owner
                }
            end
        end
        cb(houses)
    end)
end)

-- Buy house callback
ESX.RegisterServerCallback('housing:buyHouse', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local house = Config.Houses[houseId]
    
    if not house then
        cb(false, "Casa no encontrada")
        return
    end
    
    -- Check if house is already owned
    MySQL.scalar('SELECT owned FROM houses WHERE house_id = ?', {houseId}, function(owned)
        if owned then
            cb(false, "Esta casa ya tiene propietario")
            return
        end
        
        -- Check if player has enough money
        if xPlayer.getMoney() < house.price then
            cb(false, "No tienes suficiente dinero")
            return
        end
        
        -- Process purchase
        xPlayer.removeMoney(house.price)
        
        MySQL.update('UPDATE houses SET owner = ?, owned = ? WHERE house_id = ?', {
            xPlayer.identifier,
            true,
            houseId
        }, function(affectedRows)
            if affectedRows > 0 then
                cb(true, string.format(Config.Messages.house_purchased, ESX.Math.GroupDigits(house.price)))
                TriggerClientEvent('housing:updateHouses', -1)
            else
                -- Refund money if database update failed
                xPlayer.addMoney(house.price)
                cb(false, "Error al procesar la compra")
            end
        end)
    end)
end)

-- Sell house callback
ESX.RegisterServerCallback('housing:sellHouse', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local house = Config.Houses[houseId]
    
    if not house then
        cb(false, "Casa no encontrada")
        return
    end
    
    -- Check if player owns the house
    MySQL.scalar('SELECT owner FROM houses WHERE house_id = ? AND owned = ?', {houseId, true}, function(owner)
        if not owner or owner ~= xPlayer.identifier then
            cb(false, "No eres el propietario de esta casa")
            return
        end
        
        -- Calculate sell price
        local sellPrice = math.floor(house.price * Config.SellPercentage)
        
        -- Process sale
        xPlayer.addMoney(sellPrice)
        
        MySQL.update('UPDATE houses SET owner = ?, owned = ? WHERE house_id = ?', {
            nil,
            false,
            houseId
        }, function(affectedRows)
            if affectedRows > 0 then
                cb(true, string.format(Config.Messages.house_sold, ESX.Math.GroupDigits(sellPrice)))
                TriggerClientEvent('housing:updateHouses', -1)
            else
                -- Refund money if database update failed
                xPlayer.removeMoney(sellPrice)
                cb(false, "Error al procesar la venta")
            end
        end)
    end)
end)

-- Get player houses
ESX.RegisterServerCallback('housing:getPlayerHouses', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerHouses = {}
    
    MySQL.query('SELECT * FROM houses WHERE owner = ?', {xPlayer.identifier}, function(result)
        for i = 1, #result do
            local houseId = result[i].house_id
            if Config.Houses[houseId] then
                table.insert(playerHouses, {
                    id = houseId,
                    name = Config.Houses[houseId].name,
                    price = Config.Houses[houseId].price,
                    coords = Config.Houses[houseId].coords,
                    description = Config.Houses[houseId].description
                })
            end
        end
        cb(playerHouses)
    end)
end)

-- Check if player owns a specific house
ESX.RegisterServerCallback('housing:isHouseOwner', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.scalar('SELECT COUNT(*) FROM houses WHERE house_id = ? AND owner = ?', {
        houseId, 
        xPlayer.identifier
    }, function(count)
        cb(count > 0)
    end)
end)