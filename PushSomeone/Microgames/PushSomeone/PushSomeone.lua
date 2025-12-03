local microgame
local contentRoot = "\\Microgames\\PushSomeone"
local coordinator = worldInfo:GetCoordinator()
local microgameMusic = {
  LoadResource(contentRoot .. "\\Music\\PushSomeone_100.ogg", ResourceType.Audio), -- That's Microgame 15_01 from the game file
  LoadResource(contentRoot .. "\\Music\\PushSomeone_111.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_122.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_133.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_144.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_155.ogg", ResourceType.Audio),
}

local pushListenner

-- Is local player the server?
local function IsServer()
  return worldInfo:IsServer()
end

-- Get a player by their ID
local function GetPlayerByID(playerID)
  return worldInfo:GetPlayerByID(playerID)
end

-- Mark all players as winners at the start
local function MarkAllAsWinner()
  if not IsServer() then return end

  for i, player in ipairs(worldInfo:GetAllActivePlayers()) do
    coordinator:MarkWinner(player:GetNetworkID(), true)
  end
end

-- Default Variation
local function OnBeginMicrogame_default()
  if IsServer() then
    pushListenner = ListenFor("PlayerPushed",
      function(pay)
        if coordinator:IsMarkedAWinner(pay:GetPusherPlayer():GetNetworkID()) then return end -- return early if already winner

        coordinator:MarkWinner(pay:GetPusherPlayer():GetNetworkID(), false)
        pay:GetPushedPlayer():PlayWinEffect(WinState.Pass)
      end)
  end
end

local function OnMicrogameTick_default(fTimeLeft) end

local function OnPostMicrogame_default()
  if IsServer() then RemoveEventListener(pushListenner) end
end

local defaultVariation = CreateMicrogameVariation("default", OnBeginMicrogame_default,
  OnMicrogameTick_default, OnPostMicrogame_default)

-- Defined player Variation
local playerToPush

local function assignPlayerTarget(allActivePlayers)
  local playerAssignement = {}
  if worldInfo:GetActivePlayersCount() == 1 then return { [allActivePlayers[1]:GetNetworkID()] = allActivePlayers[1]
    :GetNetworkID() } end
  for i, player in ipairs(allActivePlayers) do
    playerAssignement[player:GetNetworkID()] = allActivePlayers[math.random(#allActivePlayers)]:GetNetworkID()

    if (player:GetNetworkID() == playerAssignement[player:GetNetworkID()]) then
      local preventInfinite = 0
      while player:GetNetworkID() == playerAssignement[player:GetNetworkID()] and preventInfinite < 5 do
        preventInfinite = preventInfinite + 1
        print("[PushSomeone] Player have to push himselft ! Re-assigning (" .. preventInfinite .. ")")
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

-- Receive which player you have to push and display it
RPC("PushSomeone_PlayerToPush", SendTo.TargetClient, Delivery.Reliable, function(playerID)
  playerToPush = GetPlayerByID(playerID)
  print("[PushSomeone] You have to push " .. playerToPush:GetSteamName())
  microgame:SetTranslationData("definedPlayer", playerToPush:GetSteamName())
end)

local function onPrepareMicrogame_definedPlayer()
  if IsServer() then
    local playerAssignement = assignPlayerTarget(worldInfo:GetAllActivePlayers())
    for player, target in pairs(playerAssignement) do
      print("[PushSomeone] " .. GetPlayerByID(player):GetSteamName() .. "->" .. GetPlayerByID(target):GetSteamName())
      worldGlobals.PushSomeone_PlayerToPush(GetPlayerByID(player), target)
    end

    pushListenner = ListenFor("PlayerPushed",
      function(pay)
        if coordinator:IsMarkedAWinner(pay:GetPusherPlayer():GetNetworkID()) then return end -- return early if already winner

        if playerAssignement[pay:GetPusherPlayer():GetNetworkID()] == pay:GetPushedPlayer():GetNetworkID() then
          coordinator:MarkWinner(pay:GetPusherPlayer():GetNetworkID())
          pay:GetPushedPlayer():PlayWinEffect(WinState.Pass)
        end
      end)
  end
end

local function OnBeginMicrogame_definedPlayer()
  if playerToPush ~= nil then
    coordinator:AddTargetIndicator(playerToPush:GetTransform(), IndicatorType.Objective)
  end
end

local function OnMicrogameTick_definedPlayer(fTimeLeft) end

local function OnPostMicrogame_definedPlayer()
  if IsServer() then RemoveEventListener(pushListenner) end
  microgame:ResetTranslationData()
end

local definedPlayerVariation = CreatePreparedMicrogameVariation("definedPlayer", onPrepareMicrogame_definedPlayer,
  OnBeginMicrogame_definedPlayer, OnMicrogameTick_definedPlayer, OnPostMicrogame_definedPlayer, 6)

-- Don't get pushed Variation

local function OnBeginMicrogame_dontGetPushed()
  if IsServer() then
    MarkAllAsWinner()

    pushListenner = ListenFor("PlayerPushed",
      function(pay)
        if not coordinator:IsMarkedAWinner(pay:GetPushedPlayer():GetNetworkID()) then return end -- return early if already looser

        coordinator:UnmarkWinner(pay:GetPushedPlayer():GetNetworkID())
        pay:GetPushedPlayer():PlayWinEffect(WinState.Fail)
      end)
  end
end

local function OnMicrogameTick_dontGetPushed(fTimeLeft) end

local function OnPostMicrogame_dontGetPushed()
  if IsServer() then RemoveEventListener(pushListenner) end
end

local dontGetPushedVariation = CreateMicrogameVariation("dontGetPushed", OnBeginMicrogame_dontGetPushed,
  OnMicrogameTick_dontGetPushed, OnPostMicrogame_dontGetPushed)

microgame = CreateMicrogame("PushSomeone", microgameMusic,
  { defaultVariation, definedPlayerVariation, dontGetPushedVariation },
  { Difficulty = Difficulty.Easy, Rarity = 8, MinPlayers = 2, Type = MicrogameType.WinBeforeEnd, PlayEffect = false })
