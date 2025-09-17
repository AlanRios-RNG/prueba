Config = {}

-- Main configuration
Config.SellPercentage = 0.8 -- Players get 80% of house value when selling
Config.BlipSprite = 40 -- House blip sprite
Config.BlipColor = 2 -- House blip color (green)
Config.BlipScale = 0.8 -- House blip scale

-- Houses configuration
Config.Houses = {
    [1] = {
        id = 1,
        name = "Casa en Vinewood Hills",
        price = 250000,
        coords = vector3(-174.2, 497.5, 137.7),
        description = "Una hermosa casa en las colinas con vista panorámica de la ciudad.",
        owned = false,
        owner = nil
    },
    [2] = {
        id = 2,
        name = "Casa en Rockford Hills",
        price = 180000,
        coords = vector3(-912.8, -375.2, 114.3),
        description = "Casa moderna en zona residencial exclusiva.",
        owned = false,
        owner = nil
    },
    [3] = {
        id = 3,
        name = "Casa en Mirror Park",
        price = 120000,
        coords = vector3(1265.5, -648.2, 68.1),
        description = "Casa familiar en barrio tranquilo.",
        owned = false,
        owner = nil
    },
    [4] = {
        id = 4,
        name = "Casa en Sandy Shores",
        price = 85000,
        coords = vector3(1973.9, 3815.3, 33.4),
        description = "Casa sencilla en el desierto, perfecta para empezar.",
        owned = false,
        owner = nil
    },
    [5] = {
        id = 5,
        name = "Apartamento en Del Perro",
        price = 95000,
        coords = vector3(-1447.2, -538.7, 34.7),
        description = "Apartamento cerca de la playa con fácil acceso.",
        owned = false,
        owner = nil
    },
    [6] = {
        id = 6,
        name = "Casa en Paleto Bay",
        price = 75000,
        coords = vector3(-378.1, 6207.5, 31.7),
        description = "Casa rural en el norte, ideal para vida tranquila.",
        owned = false,
        owner = nil
    }
}

-- Notification messages
Config.Messages = {
    house_purchased = "¡Has comprado la casa por $%s!",
    house_sold = "¡Has vendido la casa por $%s!",
    not_enough_money = "No tienes suficiente dinero para comprar esta casa",
    already_owned = "Esta casa ya tiene propietario",
    not_owner = "No eres el propietario de esta casa",
    house_menu_title = "Sistema de Casas",
    buy_house = "Comprar Casa",
    sell_house = "Vender Casa",
    house_info = "Información de la Casa",
    available = "Disponible",
    sold = "Vendida",
    price = "Precio: $%s",
    owner = "Propietario: %s",
    confirm_purchase = "¿Confirmas la compra de esta casa por $%s?",
    confirm_sale = "¿Confirmas la venta de esta casa por $%s?",
    yes = "Sí",
    no = "No"
}