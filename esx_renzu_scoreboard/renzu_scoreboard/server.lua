local players = {}
local playernames = {}
local GuildID = 1000000000 -- : -- change this to your GuildID
local DiscToken = ".XssX9w." -- change this to your own discord token
local FormattedToken = "Bot " .. DiscToken
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

function UploadAvatar(identifier, avatar)
    Database(config.Mysql,'execute','UPDATE users SET avatar = @avatar WHERE identifier = @identifier',
        {
            ['@avatar'] = avatar,
            ['@identifier'] = identifier
    })
end

RegisterServerEvent('renzu_scoreboard:avatarupload')
AddEventHandler('renzu_scoreboard:avatarupload', function(url)
    local source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if players[source] ~= nil then
        UploadAvatar(xPlayer.identifier, url)
        players[source].image = url
    end
end)

function GetAvatar(source,first,last)
    local source = source
    local image = nil
    local steamhex = GetPlayerIdentifier(source, 0)
    local initials = math.random(1,#config.RandomAvatars)
    local letters = config.RandomAvatars[initials]
    if steamhex ~= nil and steamhex ~= '' then
        local steamid = tonumber(string.gsub(steamhex, 'steam:', ''), 16)
        if steamid ~= nil then
            PerformHttpRequest('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. GetConvar('steam_webApiKey') .. '&steamids=' .. steamid, function(e, data, h)
                local data = json.decode(data) or {}
                if data and data.response and data.response.players[1] then
                    avatar = data.response.players[1].avatarfull
                    if avatar ~= nil then
                        image = avatar
                    end
                end
            end)
        end
        local c = 0
        while steamid ~= nil and image == nil and c < 100 do c = c + 1 Wait(1) end
        if image == nil then image = 'https://ui-avatars.com/api/?name='..first..'+'..last..'&background='..letters.background..'&color='..letters.color..'' end
        return image
    else
        return 'https://ui-avatars.com/api/?name='..first..'+'..last..'&background='..letters.background..'&color='..letters.color..''
    end
end

local loading = {}
local qued = {}
RegisterServerEvent('renzu_scoreboard:setjob')
AddEventHandler('renzu_scoreboard:setjob', function()
    PopulatePlayer(source)
end)

RegisterServerEvent('renzu_scoreboard:playerloaded')
AddEventHandler('renzu_scoreboard:playerloaded', function()
    local source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local initials = math.random(1,#config.RandomAvatars)
    local letters = config.RandomAvatars[initials]
    if xPlayer ~= nil and playernames[xPlayer.identifier] ~= nil and playernames[xPlayer.identifier].firstname ~= nil and playernames[xPlayer.identifier].firstname ~= '' then
        CreatePlayer(source,xPlayer)
    elseif xPlayer ~= nil and playernames[xPlayer.identifier] == nil then
        CreatePlayer(source,xPlayer,true)
    else
        print('Xplayer is nil or player is not register in server table',playernames[xPlayer.identifier],playernames[xPlayer.identifier].firstname)
    end
end)

local quedplayer = {}
function CreatePlayer(source,xPlayer,quee)
    local source = source
    local initials = math.random(1,#config.RandomAvatars)
    local letters = config.RandomAvatars[initials]
    CreateThread(function()
        if quee then
            print("id# "..source.."  QUED")
            quedplayer[source] = 0
            if xPlayer ~= nil and playernames[xPlayer.identifier] == nil then playernames[xPlayer.identifier] = {} end
            while playernames[xPlayer.identifier].firstname == nil and quedplayer[source] ~= nil and quedplayer[source] < 20 or playernames[v.identifier].firstname ~= nil and playernames[v.identifier].firstname:len() >= 3 and quedplayer[source] ~= nil and quedplayer[source] < 20 do 
                Wait(10000)
                quedplayer[source] = quedplayer[source] + 1
                print("id# "..source.."  CHECKING PLAYER INFO")
                local playerinfo = Database(config.Mysql,'fetchAll','SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
                if #playerinfo > 0 and playerinfo[1] ~= nil and playerinfo[1].firstname ~= nil and playerinfo[1].firstname ~= '' and playerinfo[1].firstname ~= 'null' then
                    for k,v in pairs(playerinfo) do
                        playernames[v.identifier] = v
                    end
                    print("id# "..source.." PLAYER IS REGISTERED Successfully",playernames[xPlayer.identifier].firstname)
                    -- you can pass any client events here once the player is loaded ex. playerloaded event
                    break
                elseif xPlayer.source then
                    print('id# '..source..' is requed, still creating character?')
                    if quedplayer[source] >= 20 then
                        break
                    end
                else
                    print('id# '..source..' is not online anymore, removing from qued list')
                    break
                end
            end
        end
        if players[source] == nil and xPlayer ~= nil and loading[source] == nil then
            loading[source] = true
            playerdata = nil
            local f,l,v = '', '', false
            if playernames[xPlayer.identifier] ~= nil and playernames[xPlayer.identifier].firstname ~= nil then
                f = playernames[xPlayer.identifier].firstname
                l = playernames[xPlayer.identifier].lastname
            end
            if config.ShowVips and playernames[xPlayer.identifier] ~= nil then
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
            if config.UseSelfUploadAvatar and playernames[xPlayer.identifier] ~= nil then
                if playernames[xPlayer.identifier].avatar ~= nil and playernames[xPlayer.identifier].avatar ~= '' then
                    avatar = playernames[xPlayer.identifier].avatar
                else
                    avatar = 'https://ui-avatars.com/api/?name='..f..'+'..l..'&background='..letters.background..'&color='..letters.color..''
                end
            elseif config.UseDiscordAvatar then
                avatar = GetDiscordAvatar(source,f,l)
            else
                avatar = GetAvatar(source,f,l)
            end
            if players[source] == nil then
                players[source] = {identifier = xPlayer.identifier, id = source, image = avatar, first = f, last = l, name = name, discordname = GetDiscordName(source,f,l), vip = v}
            end
        end
        PopulatePlayer(source)
    end)
end

local pings = {}

function PopulatePlayer(source)
    local source = source
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
            local ping = nil
            if pings[v.id] == nil and config.CheckpingOnce then
                pings[v.id] = GetPlayerPing(v.id)
            elseif not config.CheckpingOnce then
                ping = GetPlayerPing(v.id)
            end
            if config.CheckpingOnce and pings[v.id] ~= nil then
                ping = pings[v.id]
            end
            table.insert(list, {id = v.id, job = xPlayer.job.label, name = v.name, discordname = v.discordname, firstname = v.first, lastname = v.last, image = v.image, ping = ping, admin = xPlayer.getGroup() ~= 'user', vip = v.vip})
        end
    end
    local count = 0
    for k,v in pairs(players) do count = count + 1 end
    xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil and players[source] ~= nil then
        GlobalState.Player_list = list
        GlobalState.Whitelistedjobs = whitelistedjobs
        GlobalState.PlayerCount = count
        Player(source).state.isAdmin = xPlayer.getGroup() ~= 'user'
        Player(source).state.Avatar = players[source].image
        Player(source).state.Loaded = true
    end
end

RegisterServerEvent('playerDropped')
AddEventHandler('playerDropped', function()
    local source = tonumber(source)
    for k,v in pairs(players) do
        if v.id == source then
            playernames[v.identifier] = nil
        end
    end
    for k,v in pairs(quedplayer) do
        if source == k then
            quedplayer[k] = nil
        end
    end
    players[source] = nil
    loading[source] = nil
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

function DiscordRequest(method, endpoint, jsondata)
    local data = nil

    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
        data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
    end

    return data
end

function DiscordUserData(id)

    local member = DiscordRequest("GET", ("guilds/%s/members/%s"):format(GuildID, id), {})
    if member.code == 200 then
        local Userdata = json.decode(member.data)
        return Userdata.user
    end

end

function GetDiscordAvatar(user,f,l)
    local id = string.gsub(ExtractIdentifiers(user).discord, "discord:", "")
    local Userdata = DiscordUserData(id)
    if Userdata ~= nil and Userdata.avatar ~= nil then
        if (Userdata.avatar:sub(1, 1) and Userdata.avatar:sub(2, 2) == "_") then 
            imgURL = "https://cdn.discordapp.com/avatars/" .. id .. "/" .. Userdata.avatar .. ".gif";
        else 
            imgURL = "https://cdn.discordapp.com/avatars/" .. id .. "/" .. Userdata.avatar .. ".png"
        end
    else
        local initials = math.random(1,#config.RandomAvatars)
        local letters = config.RandomAvatars[initials]
        imgURL = 'https://ui-avatars.com/api/?name='..f..'+'..l..'&background='..letters.background..'&color='..letters.color..''
    end

    return imgURL
end

function GetDiscordName(user,f,l)
    if config.useDiscordname then
        local id = string.gsub(ExtractIdentifiers(user).discord, "discord:", "")
        local Userdata = DiscordUserData(id)
        if Userdata ~= nil then
            return Userdata.username
        else
            return GetPlayerName(user) or ''..f..' '..l..'' -- default
        end
    else
        return GetPlayerName(user) -- default
    end
end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }
    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end