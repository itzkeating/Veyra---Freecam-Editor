fx_version 'cerulean'
game 'gta5'

author 'Veyra Studios -- ItzKeating & ItzMiro'
description 'Freecam Editor Script'
version '1.0.0'

dependency 'screenshot-basic'

shared_script 'veyra_webhook.lua'

server_script 'server.lua'

client_scripts {
    'client.lua',
    'ui.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
