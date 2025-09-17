fx_version 'cerulean'
game 'gta5'

author 'AlanRios-RNG'
description 'ESX Legacy Housing System with ox_lib integration'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql'
}

lua54 'yes'