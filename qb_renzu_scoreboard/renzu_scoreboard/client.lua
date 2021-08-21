local open = false
local loaded = false
Citizen.CreateThread(function()
    Wait(100)
    SendNUIMessage({
        type  = 'css',
        content = config.css
    })
    Wait(2500)
    TriggerServerEvent('renzu_scoreboard:playerloaded')
end)

RegisterNetEvent('renzu_scoreboard:loaded') -- for initial purpose if restarted
AddEventHandler('renzu_scoreboard:loaded', function(xPlayer)
    TriggerServerEvent('renzu_scoreboard:playerloaded')
    loaded = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(500)
	TriggerServerEvent('renzu_scoreboard:playerloaded')
end)

RegisterNUICallback('avatarupload', function(data, cb)
    TriggerServerEvent('renzu_scoreboard:avatarupload',data.url)
    SetNuiFocus(false,false)
    SetNuiFocusKeepInput(false)
end)

function OpenScoreboard()
    QBCore.Functions.TriggerCallback('renzu_scoreboard:playerlist', function(data,jobs,count,admin,myimage)
        for k,v in pairs(config.whitelistedjobs) do
            v.count = 0
            if jobs[v.name] ~= nil then
                v.count = jobs[v.name]
            end
        end
        local showid = true
        if not config.Showid then
            showid = admin
        end
        SendNUIMessage({
            type = 'show',
            content = {players = data, whitelistedjobs = config.whitelistedjobs, count = count, max = GetConvarInt('sv_maxclients', 256), useidentity = config.UseIdentityname, usediscordname = config.useDiscordname, isadmin = admin, showid = showid, showadmins = config.ShowAdmins, showvip = config.ShowVips, showjobs = config.ShowJobs, myimage = myimage, logo = config.logo}
        })
        Wait(50)
        SetNuiFocus(true,true)
        SetNuiFocusKeepInput(true)
    end)
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

RegisterCommand('scoreboard', function()
    if not open then
        OpenScoreboard()
    else
        close()
    end
    open = not open
    while open do
        BlockWeaponWheelThisFrame()
        DisablePlayerFiring(PlayerId(),true)
        Wait(5)
    end
end, false)
RegisterKeyMapping('scoreboard', 'Scoreboard (player online)', 'keyboard', config.keybind)

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