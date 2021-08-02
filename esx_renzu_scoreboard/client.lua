ESX = nil
local open = false
local loaded = false
Citizen.CreateThread(function()
	while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Citizen.Wait(0) end
    Wait(2500)
    TriggerServerEvent('renzu_scoreboard:playerloaded')
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

function OpenScoreboard()
    ESX.TriggerServerCallback("renzu_scoreboard:playerlist",function(data,jobs,count,admin)
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
            content = {players = data, whitelistedjobs = config.whitelistedjobs, count = count, max = GetConvarInt('sv_maxclients', 256), useidentity = config.UseIdentityname, isadmin = admin, showid = showid, showadmins = config.ShowAdmins, showvip = config.ShowVips, showjobs = config.ShowJobs}
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
end, false)
RegisterKeyMapping('scoreboard', 'Scoreboard (player online)', 'keyboard', 'F10')

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