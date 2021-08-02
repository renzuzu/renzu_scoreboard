local players = {}
local playernames = {}
local loaded = false
CreateThread(function()
    Wait(200)
    print("SCOREBOARD LOADED")
    TriggerClientEvent("renzu_scoreboard:loaded",-1)
end)

function UploadAvatar(citizenid, avatar)
    Player.PlayerData.metadata["avatar"] = avatar
    Player.Functions.SetMetaData("avatar", Player.PlayerData.metadata["avatar"])
    exports.ghmattimysql:execute('UPDATE players SET metadata=@metadata WHERE citizenid=@citizenid', {['@metadata'] = json.encode(Player.PlayerData.metadata), ['@citizenid'] = citizenid})
end

RegisterNetEvent('renzu_scoreboard:avatarupload')
AddEventHandler('renzu_scoreboard:avatarupload', function(url)
    local source = tonumber(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if players[source] ~= nil then
        UploadAvatar(Player.PlayerData.citizenid, url)
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
        PerformHttpRequest('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. GetConvar('steam_webApiKey') .. '&steamids=' .. steamid, function(e, data, h)
            local data = json.decode(data)
            local avatar = data.response.players[1].avatarfull
            image = avatar
        end)
        local c = 0
        while image == nil and c < 100 do c = c + 1 Wait(1) end
        if image == nil then image = 'https://ui-avatars.com/api/?name='..first..'+'..last..'&background='..letters.background..'&color='..letters.color..'' end
        return image
    else
        return 'https://ui-avatars.com/api/?name='..first..'+'..last..'&background='..letters.background..'&color='..letters.color..''
    end
end

function GetDiscordAvatar(source)
    local source = source
    return exports.Badger_Discord_API:GetDiscordAvatar(source);
end

local loading = {}
RegisterNetEvent('renzu_scoreboard:playerloaded')
AddEventHandler('renzu_scoreboard:playerloaded', function()
    local source = tonumber(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local initials = math.random(1,#config.RandomAvatars)
    local letters = config.RandomAvatars[initials]
    if players[source] == nil and Player ~= nil and loading[source] == nil then
        loading[source] = true
        playerdata = nil
        local f,l,v = '', '', false
            if Player.PlayerData ~= nil and Player.PlayerData.charinfo.firstname ~= nil and config.UseIdentityname then
                f = Player.PlayerData.charinfo.firstname
                l = Player.PlayerData.charinfo.lastname
            end
            if config.ShowVips then
                if Player.PlayerData.metadata['vip'] ~= nil then
                    v = Player.PlayerData.metadata['vip'] ~= nil and Player.PlayerData.metadata['vip'] ~= false
                end
            end
            local name = GetPlayerName(source)
            if (name:find("src") ~= nil) then
                name = "Blacklisted name"
            end
            if (name:find("script") ~= nil) then
                name = "Blacklisted name"
            end
            if config.UseSelfUploadAvatar then
                if Player.PlayerData.metadata['avatar'] ~= nil and Player.PlayerData.metadata['avatar'] ~= '' then
                    avatar = Player.PlayerData.metadata['avatar']
                else
                    avatar = 'https://ui-avatars.com/api/?name='..f..'+'..l..'&background='..letters.background..'&color='..letters.color..''
                end
            elseif config.UseDiscordAvatar then
                avatar = GetDiscordAvatar(source)
            else
                avatar = GetAvatar(source,f,l)
            end
            if players[source] == nil then
                players[source] = {id = source, image = avatar, first = f, last = l, name = name, vip = v}
            end
    end
end)

function isAdmin(source)
    local source = source
    return QBCore.Functions.IsOptin(source)
end

QBCore.Functions.CreateCallback('renzu_scoreboard:playerlist', function(source, cb)
    local list = {}
    local whitelistedjobs = {}
    local source = tonumber(source)
    for k,v in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(tonumber(v.id))
        for _, job in pairs(config.whitelistedjobs) do
            local job = job.name
            if whitelistedjobs[job] == nil then
                whitelistedjobs[job] = 0
            end
            if Player ~= nil and Player.PlayerData.job.name == job then
                whitelistedjobs[job] = whitelistedjobs[job] + 1
                break
            end
        end
        if Player ~= nil then
            table.insert(list, {id = v.id, job = Player.PlayerData.job.name, name = v.name, firstname = v.first, lastname = v.last, image = v.image, ping = GetPlayerPing(v.id), admin = isAdmin(v.id), vip = v.vip})
        end
    end
    local count = 0
    for k,v in pairs(players) do count = count + 1 end
    Player = QBCore.Functions.GetPlayer(source)
    if Player ~= nil then
        cb(list, whitelistedjobs, count, isAdmin(source),players[source].image)
    end
end)

RegisterServerEvent('playerDropped')
AddEventHandler('playerDropped', function()
    local source = tonumber(source)
    players[source] = nil
end)