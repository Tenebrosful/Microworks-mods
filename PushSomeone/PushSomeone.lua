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

-- Default Variation
local function OnBeginMicrogame_default()
  if IsServer() then
    pushListenner = ListenFor("PlayerPushed",
      function(pay)
        if coordinator:IsMarkedAWinner(pay:GetPusherPlayer():GetNetworkID()) then return end -- return early if already winner

        coordinator:MarkWinner(pay:GetPusherPlayer():GetNetworkID(), false)
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
local playerAssignement = {} -- Table used by Server to know who must push who

local function assignPlayerTarget(allActivePlayers)
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
end

-- Receive which player you have to push and display it
RPC("PushSomeone_PlayerToPush", SendTo.TargetClient, Delivery.Reliable, function(playerID)
  local playerToPush = GetPlayerByID(playerID):GetSteamName()
  print("[PushSomeone] You have to push " .. playerToPush)
  microgame:SetTranslationData("definedPlayer", playerToPush) -- Works only for the first time then don't works for Client but works for Host
end)

local function OnBeginMicrogame_definedPlayer()
  if IsServer() then
    assignPlayerTarget(worldInfo:GetAllActivePlayers())
    for player, target in pairs(playerAssignement) do
      print("[PushSomeone] " .. GetPlayerByID(player):GetSteamName() .. "->" .. GetPlayerByID(target):GetSteamName())
      worldGlobals.PushSomeone_PlayerToPush(GetPlayerByID(player), target)
    end

    pushListenner = ListenFor("PlayerPushed",
      function(pay)
        if coordinator:IsMarkedAWinner(pay:GetPusherPlayer():GetNetworkID()) then return end -- return early if already winner

        if playerAssignement[pay:GetPusherPlayer():GetNetworkID()] == pay:GetPushedPlayer():GetNetworkID() then
          coordinator:MarkWinner(pay:GetPusherPlayer():GetNetworkID())
        end
      end)
  end
end

local function OnMicrogameTick_definedPlayer(fTimeLeft) end

local function OnPostMicrogame_definedPlayer()
  if IsServer() then RemoveEventListener(pushListenner) end
  microgame:ResetTranslationData()
  playerAssignement = {}
end

-- local definedPlayerVariation = CreateMicrogameVariation("definedPlayer", OnBeginMicrogame_definedPlayer,
-- OnMicrogameTick_definedPlayer, OnPostMicrogame_definedPlayer, 6)

microgame = CreateMicrogame("PushSomeone", microgameMusic, { defaultVariation, definedPlayerVariation },
  { Difficulty = Difficulty.Easy, Rarity = 8, MinPlayers = 2, Type = MicrogameType.WinBeforeEnd, PlayEffect = true })
