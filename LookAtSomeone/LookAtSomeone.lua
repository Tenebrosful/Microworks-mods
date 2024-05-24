local microgame
local contentRoot = "\\Microgames\\LookAtSomeone"
local coordinator = worldInfo:GetCoordinator()
local microgameMusic = {
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_100.ogg", ResourceType.Audio), -- That's Microgame 15_01 from the game file
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_111.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_122.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_133.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_144.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\LookAtSomeone_155.ogg", ResourceType.Audio),
}

local lPlayer = worldInfo:GetLocalPlayer()

local function VectorToString(vector)
  return string.format("(%f %f %f)", vector.x, vector.y, vector.z)
end

-- Is local player the server?
local function IsServer()
  return worldInfo:IsServer()
end

-- Get a player by their ID
local function GetPlayerByID(playerID)
  return worldInfo:GetPlayerByID(playerID)
end

-- Send Local message
local function ShowMessageLocal(message)
  print(message)
  worldInfo:ShowMessageLocal(message)
end

-- Default Variation
local function OnBeginMicrogame_default()

end

local function OnMicrogameTick_default(fTimeLeft)
  --if coordinator:IsMarkedAWinner(lPlayer:GetNetworkID()) then return end

  ShowMessageLocal("[Player Camera] " ..
    VectorToString(lPlayer:GetCameraPosition()) .. " looking at " .. VectorToString(lPlayer:GetCameraDirection()))
  local hitPoints = CastRayAll(lPlayer:GetCameraPosition(), lPlayer:GetCameraDirection(), 60)
  local playerFound
  if hitPoints ~= nil then
    for i, hitPoint in ipairs(hitPoints) do
      local object = hitPoint:GetHitObject()
      print("[Object looking] " ..
        object:GetObjectName() ..
        " is " ..
        object:GetObjectType() ..
        " tags: " ..
        object:GetTag() ..
        " NetworkID : " .. object:GetNetworkID() .. " at " .. VectorToString(hitPoint:GetHitPosition()))
      if string.find(object:GetTag(), "Player") ~= nil then
        playerFound = GetPlayerByID(object:GetNetworkID())
        ShowMessageLocal("Looking at " .. playerFound:GetSteamName())
        break;
      end
    end
  else
    ShowMessageLocal("[Player looking] Looking at nothing")
  end

  if playerFound ~= nil
  then
    coordinator:MarkWinner(lPlayer:GetNetworkID(), false)
  else
    coordinator:UnmarkWinner(lPlayer:GetNetworkID(), false)
  end
end

local function OnPostMicrogame_default()

end

local defaultVariation = CreateMicrogameVariation("default", OnBeginMicrogame_default,
  OnMicrogameTick_default, OnPostMicrogame_default)

microgame = CreateMicrogame("LookAtSomeone", microgameMusic, { defaultVariation },
  { Difficulty = Difficulty.Easy, Rarity = 8, MinPlayers = 1, Type = MicrogameType.WinBeforeEnd, PlayEffect = false })
