ESX = nil
local open = false
local loaded = false
PlayerData = {}
Citizen.CreateThread(function()
    Wait(100)
	while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Citizen.Wait(0) end
    SendNUIMessage({
        type  = 'css',
        content = config.css
    })
    Wait(2500)
    TriggerServerEvent('renzu_scoreboard:playerloaded')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	TriggerServerEvent('renzu_scoreboard:setjob',PlayerData.job.name)
end)

RegisterNetEvent('renzu_scoreboard:loaded') -- for initial purpose if restarted
AddEventHandler('renzu_scoreboard:loaded', function(xPlayer)
    TriggerServerEvent('renzu_scoreboard:playerloaded')
    loaded = true
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    Wait(500)
	TriggerServerEvent('renzu_scoreboard:playerloaded')
end)

RegisterNUICallback('avatarupload', function(data, cb)
    TriggerServerEvent('renzu_scoreboard:avatarupload',data.url)
    SetNuiFocus(false,false)
    SetNuiFocusKeepInput(false)
end)

function OpenScoreboard()
    for k,v in pairs(config.whitelistedjobs) do
        v.count = 0
        if GlobalState.Whitelistedjobs[v.name] ~= nil then
            v.count = GlobalState.Whitelistedjobs[v.name]
        end
    end
    local showid = true
    if not config.Showid then
        showid = LocalPlayer.state.isAdmin
    end
    local bobo = {}
    for k,v in pairs(GlobalState.Player_list) do
        table.insert(bobo, v)
    end
    SendNUIMessage({
        type = 'show',
        content = {players = bobo, whitelistedjobs = config.whitelistedjobs, count = GlobalState.PlayerCount, max = GetConvarInt('sv_maxclients', 256), useidentity = config.UseIdentityname, usediscordname = config.useDiscordname, isadmin = LocalPlayer.state.isAdmin, showid = showid, showadmins = config.ShowAdmins, showvip = config.ShowVips, showjobs = config.ShowJobs, myimage = LocalPlayer.state.Avatar, logo = config.logo}
    })
    Wait(50)
    SetNuiFocus(true,true)
end

function close()
    SendNUIMessage({
        type  = 'close'
    })
    SetNuiFocus(false,false)
    SetNuiFocusKeepInput(false)
end

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false,false)
    SetNuiFocusKeepInput(false)
    open = not open
end)

RegisterCommand(config.keybind, function()
    if not open and LocalPlayer.state.Loaded then
        OpenScoreboard()
        open = not open
    else
        open = not open
        close()
    end
    while open and LocalPlayer.state.isAdmin do
        BlockWeaponWheelThisFrame()
        DisablePlayerFiring(PlayerId(),true)
        Wait(0)
    end
end, false)
RegisterKeyMapping(config.keybind, 'Scoreboard (player online)', 'keyboard', config.keybind)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1500)

		if IsPauseMenuActive() and not IsPaused then
			IsPaused = true
			SendNUIMessage({
				type  = 'close'
			})
		elseif not IsPauseMenuActive() and IsPaused then
			IsPaused = false
		end
	end
end)