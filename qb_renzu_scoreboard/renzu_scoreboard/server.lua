local players = {}
local playernames = {}
local GuildID = 1000000000 -- : -- change this to your GuildID
local DiscToken = ".XssX9w." -- change this to your own discord token
local FormattedToken = "Bot " .. DiscToken
local pings = {}
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
                avatar = GetDiscordAvatar(source,f,l)
            else
                avatar = GetAvatar(source,f,l)
            end
            if players[source] == nil then
                players[source] = {id = source, image = avatar, first = f, last = l, name = name, discordname = GetDiscordName(source,f,l), vip = v}
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
            local ping = nil
            if pings[v.id] == nil and config.CheckpingOnce then
                pings[v.id] = GetPlayerPing(v.id)
            elseif not config.CheckpingOnce then
                ping = GetPlayerPing(v.id)
            end
            if config.CheckpingOnce and pings[v.id] ~= nil then
                ping = pings[v.id]
            end
            table.insert(list, {id = v.id, job = Player.PlayerData.job.name, name = v.name, discordname = v.discordname, firstname = v.first, lastname = v.last, image = v.image, ping = ping, admin = isAdmin(v.id), vip = v.vip})
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
    loading[source] = nil
end)

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
    if Userdata ~= nil then
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
