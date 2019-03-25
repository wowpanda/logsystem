local connections = {}
local kills = {}
local vehicles = {}
local weapons = {}
local chat = {}


function initLogs()

  local resourceName = GetCurrentResourceName()

  if(resourceName:lower() ~= resourceName) then
    print('^1'..getString("resourceContainsCapital")..'^0')
  end

  connections = json.decode(LoadResourceFile(GetCurrentResourceName(), "logs/connections.json") or "[]")
  kills = json.decode(LoadResourceFile(GetCurrentResourceName(), "logs/kills.json") or "[]")
  vehicles = json.decode(LoadResourceFile(GetCurrentResourceName(), "logs/vehicles.json") or "[]")
  weapons = json.decode(LoadResourceFile(GetCurrentResourceName(), "logs/weapons.json") or "[]")
  chat = json.decode(LoadResourceFile(GetCurrentResourceName(), "logs/chat.json") or "[]")
end

Citizen.CreateThread(function()
  initLogs()
end)

function getDate()
  return os.date("%x - %X")
end



AddEventHandler("playerDropped", function(reason)
  local _source = source
	if(config.LogDisconnect) then

    local disconnectReason = getString("disconnectedByUser")

    if(reason=="Timed out after 60 seconds.") then
      disconnectReason = getString("timeout")
    elseif(reason=="Exiting") then
      disconnectReason = getString("disconnectedQuitCommand")
    end

    local log = {
      name=GetPlayerName(_source),
      info= getString("disconnected").." ("..disconnectReason..")",
      date=getDate(),
      steamID=GetPlayerIdentifiers(_source)[1]
    }

    table.insert(connections, log)
    SaveResourceFile(GetCurrentResourceName(), "logs/connections.json", json.encode(connections), -1)
    TriggerClientEvent("logs:updateConnections", -1, connections)
	end
end)


RegisterServerEvent("logs:playerConnected")
AddEventHandler("logs:playerConnected", function()
  local _source = source
  local pIdentifier = GetPlayerIdentifiers(_source)[1]
  if(config.LogConnect) then
    local log = {
      name=GetPlayerName(_source),
      info= getString("connected"),
      date=getDate(),
      steamID=pIdentifier
    }

    table.insert(connections, log)
    SaveResourceFile(GetCurrentResourceName(), "logs/connections.json", json.encode(connections), -1)
    TriggerClientEvent("logs:updateConnections", -1, connections)
  end


  local cpt=1
  while(cpt<=#config.admins and (config.admins[cpt]:lower() ~= pIdentifier:lower())) do
    cpt=cpt+1
  end

  TriggerClientEvent("logs:setAdmin", _source, (cpt<=#config.admins))


  if(cpt<=#config.admins or config.debug) then
    TriggerClientEvent("logs:updateConnections", _source, connections)
    TriggerClientEvent("logs:updateKills", _source, kills)
    TriggerClientEvent("logs:updateVehicles", _source, vehicles)
    TriggerClientEvent("logs:updateWeapons", _source, weapons)
    TriggerClientEvent("logs:updateChat", _source, chat)
  end
end)


RegisterServerEvent("logs:addKill")
AddEventHandler("logs:addKill", function(killerSource, targetSource, killerCoords, targetCoords)
  local killerName = nil
  local targetName = GetPlayerName(targetSource)
  local identifier = nil

  if(killerSource ~= -1) then
    killerName = GetPlayerName(killerSource)
    identifier = GetPlayerIdentifiers(killerSource)[1]
  end


  if(killerName ~= nil or config.LogPnjKills) then
    if(killerName==nil) then
      killerName = getString("pnjsuicide")
      identifier = GetPlayerIdentifiers(targetName)[1]
    end

    local log = {
      name=killerName,
      target=targetName,
      killerCoords=json.encode(killerCoords),
      targetCoords=json.encode(targetCoords),
      date=getDate(),
      steamID=identifier
    }

    table.insert(kills, log)
    SaveResourceFile(GetCurrentResourceName(), "logs/kills.json", json.encode(kills), -1)
    TriggerClientEvent("logs:updateKills", -1, kills)
  end
end)








RegisterServerEvent("logs:addVehicle")
AddEventHandler("logs:addVehicle", function(vehicleTarget, coords)
  local _source = source


  local log = {
    name=GetPlayerName(_source),
    target=vehicleTarget,
    coords=json.encode(coords),
    date=getDate(),
    steamID=GetPlayerIdentifiers(_source)[1]
  }

  table.insert(vehicles, log)
  SaveResourceFile(GetCurrentResourceName(), "logs/vehicles.json", json.encode(vehicles), -1)
  TriggerClientEvent("logs:updateVehicles", -1, vehicles)
end)








RegisterServerEvent("logs:addWeapon")
AddEventHandler("logs:addWeapon", function(weaponTarget)
  local _source = source

  local log = {
    name=GetPlayerName(_source),
    target=weaponTarget,
    date=getDate(),
    steamID=GetPlayerIdentifiers(_source)[1]
  }

  table.insert(weapons, log)
  SaveResourceFile(GetCurrentResourceName(), "logs/weapons.json", json.encode(weapons), -1)
  TriggerClientEvent("logs:updateWeapons", -1, weapons)
end)









RegisterServerEvent('_chat:messageEntered')
AddEventHandler('_chat:messageEntered', function(author, color, message)
  local _source = source
  if(config.LogChat) then
    local log = {
      name=GetPlayerName(_source),
      target=message,
      date=getDate(),
      steamID=GetPlayerIdentifiers(_source)[1]
    }

    table.insert(chat, log)
    SaveResourceFile(GetCurrentResourceName(), "logs/chat.json", json.encode(chat), -1)
    TriggerClientEvent("logs:updateChat", -1, chat)
  end
end)
