local microgame
local contentRoot = "\\Microgames\\LookAtSomeone"
local coordinator = worldInfo:GetCoordinator()
local lPlayer = worldInfo:GetLocalPlayer()

local microgameMusic = {
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_100.ogg", ResourceType.Audio), -- That's Microgame 15_01 from the game file
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_111.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_122.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_133.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_144.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_155.ogg", ResourceType.Audio),
}

local oldLookingState = false

local function VectorToString(vector)
  return string.format("(%f %f %f)", vector.x, vector.y, vector.z)
end

local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

-- Is local player the server?
local function IsServer()
  return worldInfo:IsServer()
end

-- Mark all players as winners at the start
local function MarkAllAsWinner()
  if not IsServer() then return end

  for i, player in ipairs(worldInfo:GetAllActivePlayers()) do
    coordinator:MarkWinner(player:GetNetworkID(), true)
  end
end

-- Get a player by their ID
local function GetPlayerByID(playerID)
  return worldInfo:GetPlayerByID(playerID)
end

-- Send Local message
local function ShowMessageLocal(message)
  -- print(message)
  worldInfo:ShowMessageLocal(message)
end

-- Default Variation
-- Telling the server that playerID user changed his lookingState
RPC("LookAtSomeone_default_LookingChanged", SendTo.Server, Delivery.Reliable,
  function(playerID, isLookingAtSomeone)
    if not IsServer() then return end
    local player = GetPlayerByID(playerID)
    print("[LookAtSomeone] " ..
      player:GetSteamName() .. " is telling that his looking state changed (" .. tostring(isLookingAtSomeone) .. ")")

    if isLookingAtSomeone
    then
      if coordinator:IsMarkedAWinner(playerID) then return end
      coordinator:MarkWinner(playerID, false)
    else
      if not coordinator:IsMarkedAWinner(playerID) then return end
      coordinator:UnmarkWinner(playerID)
    end
  end)

local function OnBeginMicrogame_default() oldLookingState = false end

local function OnMicrogameTick_default(fTimeLeft)
  local hitPoints = CastRayAll(lPlayer:GetCameraPosition(), lPlayer:GetCameraDirection(), 60)
  local playerFound = false
  if hitPoints == nil then goto skipHitPoints end

  -- ShowMessageLocal("[LookAtSomeone] Looking at " .. #hitPoints .. " objects")
  for j, hitPoint in ipairs(hitPoints) do
    local object = hitPoint:GetHitObject()
    if string.find(object:GetTag(), "Player") ~= nil then
      -- ShowMessageLocal("[LookAtSomeone] Looking at " .. GetPlayerByID(object:GetNetworkID()):GetSteamName())
      playerFound = true
      break;
    end
  end

  ::skipHitPoints::
  if playerFound == oldLookingState then return end
  print("[LookAtSomeone] Sending changed State " .. tostring(oldLookingState) .. " -> " .. tostring(playerFound))
  worldGlobals.LookAtSomeone_default_LookingChanged(lPlayer:GetNetworkID(), playerFound)
  oldLookingState = playerFound
end

local function OnPostMicrogame_default() oldLookingState = false end

local defaultVariation = CreateMicrogameVariation("default", OnBeginMicrogame_default,
  OnMicrogameTick_default, OnPostMicrogame_default)

-- Defined Player Variation
-- Telling the server that playerID user changed his lookingState
local playerToLook

RPC("LookAtSomeone_definedPlayer_LookingChanged", SendTo.Server, Delivery.Reliable,
  function(playerID, isLookingAtSomeone)
    if not IsServer() then return end
    local player = GetPlayerByID(playerID)
    print("[LookAtSomeone] " ..
      player:GetSteamName() .. " is telling that his looking state changed (" .. tostring(isLookingAtSomeone) .. ")")

    if isLookingAtSomeone
    then
      if coordinator:IsMarkedAWinner(playerID) then return end
      coordinator:MarkWinner(playerID, false)
    else
      if not coordinator:IsMarkedAWinner(playerID) then return end
      coordinator:UnmarkWinner(playerID)
    end
  end)

-- Receive which player you have to look at and display it
RPC("LookAtSomeone_definedPlayer_PlayerToLook", SendTo.TargetClient, Delivery.Reliable, function(playerID)
  playerToLook = GetPlayerByID(playerID)
  print("[LookAtSomeone] You have to look at " .. playerToLook:GetSteamName())
  microgame:SetTranslationData("definedPlayer", playerToLook:GetSteamName())
end)

local function assignPlayerTarget(allActivePlayers)
  local playerAssignement = {}
  if worldInfo:GetActivePlayersCount() == 1 then
    return {
      [allActivePlayers[1]:GetNetworkID()] = allActivePlayers[1]
          :GetNetworkID()
    }
  end
  for i, player in ipairs(allActivePlayers) do
    playerAssignement[player:GetNetworkID()] = allActivePlayers[math.random(#allActivePlayers)]:GetNetworkID()

    if (player:GetNetworkID() == playerAssignement[player:GetNetworkID()]) then
      local preventInfinite = 0
      while player:GetNetworkID() == playerAssignement[player:GetNetworkID()] and preventInfinite < 5 do
        preventInfinite = preventInfinite + 1
        print("[LookAtSomeone] Player have to look at himselft ! Re-assigning (" .. preventInfinite .. ")")
        playerAssignement[player:GetNetworkID()] = allActivePlayers[math.random(#allActivePlayers)]:GetNetworkID()

        if preventInfinite == 5 and player:GetNetworkID() == playerAssignement[player:GetNetworkID()] then -- RNG failed 5 times
          if player:GetNetworkID() ~= allActivePlayers[1]:GetNetworkID() then
            playerAssignement[player:GetNetworkID()] = allActivePlayers[1]:GetNetworkID()                  -- Assign first player in player list
          else
            playerAssignement[player:GetNetworkID()] = allActivePlayers[2]:GetNetworkID()                  -- Assign seconds player in player list because the first one is himselft (probably never happen)
          end
        end
      end
    end
  end

  return playerAssignement
end

local function onPrepareMicrogame_definedPlayer()
  if IsServer() then
    local playerAssignement = assignPlayerTarget(worldInfo:GetAllActivePlayers())
    for player, target in pairs(playerAssignement) do
      print("[PushSomeone] " .. GetPlayerByID(player):GetSteamName() .. "->" .. GetPlayerByID(target):GetSteamName())
      worldGlobals.LookAtSomeone_definedPlayer_PlayerToLook(GetPlayerByID(player), target)
    end
  end
end

local function OnBeginMicrogame_definedPlayer()
  oldLookingState = false
  if playerToLook ~= nil then
    coordinator:AddTargetIndicator(playerToLook:GetTransform(), IndicatorType.Objective)
  end
end

local function OnMicrogameTick_definedPlayer(fTimeLeft)
  local hitPoints = CastRayAll(lPlayer:GetCameraPosition(), lPlayer:GetCameraDirection(), 60)
  local playerFound = false
  if hitPoints == nil then goto skipHitPoints end

  -- ShowMessageLocal("[LookAtSomeone] Looking at " .. #hitPoints .. " objects")
  for j, hitPoint in ipairs(hitPoints) do
    local object = hitPoint:GetHitObject()
    if string.find(object:GetTag(), "Player") ~= nil then
      -- ShowMessageLocal("[LookAtSomeone] Looking at " .. GetPlayerByID(object:GetNetworkID()):GetSteamName())
      if object:GetNetworkID() == playerToLook:GetNetworkID() then playerFound = true end
      break;
    end
  end

  ::skipHitPoints::
  if playerFound == oldLookingState then return end
  print("[LookAtSomeone] Sending changed State " .. tostring(oldLookingState) .. " -> " .. tostring(playerFound))
  worldGlobals.LookAtSomeone_default_LookingChanged(lPlayer:GetNetworkID(), playerFound)
  oldLookingState = playerFound
end

local function OnPostMicrogame_definedPlayer()
  oldLookingState = false
  microgame:ResetTranslationData()
end

local definedPlayerVariation = CreatePreparedMicrogameVariation("definedPlayer", onPrepareMicrogame_definedPlayer,
  OnBeginMicrogame_definedPlayer,
  OnMicrogameTick_definedPlayer, OnPostMicrogame_definedPlayer, 6)

-- Don't Look Variation
-- Telling the server that playerID user changed his lookingState
RPC("LookAtSomeone_dontLook_HasLookedAPlayer", SendTo.Server, Delivery.Reliable, function(playerID, isLookingAtSomeone)
  if not IsServer() then return end
  local player = GetPlayerByID(playerID)
  print("[LookAtSomeone] " .. player:GetSteamName() .. " is telling that he looked a player")
  if not isLookingAtSomeone
  then
    if coordinator:IsMarkedAWinner(playerID) then return end
    coordinator:MarkWinner(playerID, false)
  else
    if not coordinator:IsMarkedAWinner(playerID) then return end
    coordinator:UnmarkWinner(playerID)
  end
end)

local function OnBeginMicrogame_dontLook()
  if IsServer() then MarkAllAsWinner() end
  oldLookingState = false;
end

local function OnMicrogameTick_dontLook(fTimeLeft)
  local hitPoints = CastRayAll(lPlayer:GetCameraPosition(), lPlayer:GetCameraDirection(), 60)
  local playerFound = false
  if hitPoints == nil then goto skipHitPoints end

  -- ShowMessageLocal("[LookAtSomeone] Looking at " .. #hitPoints .. " objects")
  for j, hitPoint in ipairs(hitPoints) do
    local object = hitPoint:GetHitObject()
    if string.find(object:GetTag(), "Player") ~= nil then
      -- ShowMessageLocal("[LookAtSomeone] Looking at " .. GetPlayerByID(object:GetNetworkID()):GetSteamName())
      playerFound = true
      break;
    end
  end

  ::skipHitPoints::
  if playerFound == oldLookingState then return end
  print("[LookAtSomeone] Sending changed State " .. tostring(oldLookingState) .. " -> " .. tostring(playerFound))
  worldGlobals.LookAtSomeone_dontLook_HasLookedAPlayer(lPlayer:GetNetworkID(), playerFound)
  oldLookingState = playerFound
end

local function OnPostMicrogame_dontLook() oldLookingState = false end

local dontLookVariation = CreateMicrogameVariation("dontLook", OnBeginMicrogame_dontLook,
  OnMicrogameTick_dontLook, OnPostMicrogame_dontLook)

microgame = CreateMicrogame("LookAtSomeone", microgameMusic,
  { defaultVariation, definedPlayerVariation, dontLookVariation },
  { Difficulty = Difficulty.Easy, Rarity = 8, MinPlayers = 2, Type = MicrogameType.WinBeforeEnd, PlayEffect = false })
