local players = {}
local playernames = {}
ESX = nil
local loaded = false
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
CreateThread(function()
    Wait(200)
    playerinfo = Database(config.Mysql,'fetchAll','SELECT * FROM users', {})
    for k,v in pairs(playerinfo) do
        playernames[v.identifier] = v
    end
    loaded = true
    print("SCOREBOARD LOADED")
    TriggerClientEvent("renzu_scoreboard:loaded",-1)
end)

RegisterNetEvent('renzu_scoreboard:playerloaded')
AddEventHandler('renzu_scoreboard:playerloaded', function()
    local source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if players[source] == nil and xPlayer ~= nil then
        playerdata = nil
        local steamid = tonumber(string.gsub(GetPlayerIdentifier(source, 0), 'steam:', ''), 16)
        PerformHttpRequest('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. GetConvar('steam_webApiKey') .. '&steamids=' .. steamid, function(e, data, h)
            local data = json.decode(data)
            local avatar = data.response.players[1].avatarfull
            local f,l,v = '', '', false
            if playernames[xPlayer.identifier] ~= nil and playernames[xPlayer.identifier].firstname ~= nil and config.UseIdentityname then
                f = playernames[xPlayer.identifier].firstname
                l = playernames[xPlayer.identifier].lastname
            end
            if config.ShowVips then
                if playernames[xPlayer.identifier].vip ~= nil then
                    v = playernames[xPlayer.identifier].vip ~= nil
                end
            end
            local name = GetPlayerName(source)
            if (name:find("src") ~= nil) then
                name = "Blacklisted name"
            end
            if (name:find("script") ~= nil) then
                name = "Blacklisted name"
            end
            if players[source] == nil then
                players[source] = {id = source, image = avatar, first = f, last = l, name = name, vip = v}
            end
        end)
    end
end)

ESX.RegisterServerCallback('renzu_scoreboard:playerlist', function (source, cb)
    local list = {}
    local whitelistedjobs = {}
    local source = tonumber(source)
    for k,v in pairs(players) do
        local xPlayer = ESX.GetPlayerFromId(tonumber(v.id))
        for _, job in pairs(config.whitelistedjobs) do
            local job = job.name
            if whitelistedjobs[job] == nil then
                whitelistedjobs[job] = 0
            end
            if xPlayer ~= nil and xPlayer.job.name == job then
                whitelistedjobs[job] = whitelistedjobs[job] + 1
                break
            end
        end
        if xPlayer ~= nil then
            table.insert(list, {id = v.id, job = xPlayer.job.name, name = v.name, firstname = v.first, lastname = v.last, image = v.image, ping = GetPlayerPing(v.id), admin = xPlayer.getGroup() == 'superadmin', vip = v.vip})
        end
    end
    local count = 0
    for k,v in pairs(players) do count = count + 1 end
    xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        cb(list, whitelistedjobs, count, xPlayer.getGroup() == 'superadmin')
    end
end)

RegisterServerEvent('playerDropped')
AddEventHandler('playerDropped', function()
    local source = tonumber(source)
    players[source] = nil
end)

function Database(plugin,type,query,var)
    local query = query
    local type= type
    local var = var
    local plugin = plugin
    if type == 'fetchAll' and plugin == 'mysql-async' then
        return MySQL.Sync.fetchAll(query, var)
    end
    if type == 'execute' and plugin == 'mysql-async' then
        MySQL.Sync.execute(query,var) 
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        local data = nil
        exports.ghmattimysql:execute(query, var, function(result)
            data = result
        end)
        while data == nil do Wait(0) end
        return data
    end
end