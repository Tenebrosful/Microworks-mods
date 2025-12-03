local microgame
local contentRoot = "\\Microgames\\DancingFloor"
local coordinator = worldInfo:GetCoordinator()
local lPlayer = worldInfo:GetLocalPlayer()
local TowerTilesWrapper = coordinator:GetTowerTiles()

local microgameMusic = {
  LoadResource(contentRoot .. "\\Music\\DancingFloor_100.ogg", ResourceType.Audio), -- That's Microgame 15_01 from the game file
  LoadResource(contentRoot .. "\\Music\\DancingFloor_111.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\DancingFloor_122.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\DancingFloor_133.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\DancingFloor_144.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\DancingFloor_155.ogg", ResourceType.Audio),
}

Import(contentRoot .. "\\Lib.lua")

local currentIndex = 1
local state = true

local nexusTileCount = TowerTilesWrapper:GetNexusTileCount()
local nexusEdgeTileCount = TowerTilesWrapper:GetNexusEdgeTileCount()

print("Nexus Tile total : " .. tostring(nexusTileCount))
print("Nexus Tile Edge total : " .. tostring(nexusEdgeTileCount))

local function handleChat(chatEvent)
  local message = chatEvent:GetMessage()
  local number = tonumber(message)

  if number ~= nil then currentIndex = number end
  if message == "up" then currentIndex = currentIndex + 1 end
  if message == "dw" then currentIndex = currentIndex - 1 end
  if message == "true" then state = true end
  if message == "false" then state = false end
end

ListenFor("Chat", handleChat)

local function VectorToString(vector)
  return string.format("(%f %f %f)", vector.x, vector.y, vector.z)
end

local function NumberToBool(num)
  if num == 0 then return true else return false end
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

local function SetAllNexusTileColor(max, color, presetColor)
  print("From 1 to" .. tostring(max - 1))
  for i = 1, max - 1 do
    TowerTilesWrapper:SetNexusTileColor(i, color, presetColor)
  end
end

local function SetStateNexusTile(max, state)
  for i = 0, max - 1 do
    TowerTilesWrapper:SetNexusTileEnabled(i, state)
  end
end

local function SetStateEdgeNexusTile(max, state)
  for i = 0, max - 1 do
    TowerTilesWrapper:SetNexusEdgeTileEnabled(i, state)
  end
end

local function Reset()
  -- currentIndex = 1
  SetStateNexusTile(nexusTileCount, state)
  SetStateEdgeNexusTile(nexusEdgeTileCount, state)
end

local function OnBeginMicrogame_default()
  Reset()
  SendInfoChatMessageLocal("Current Index : " .. tostring(currentIndex))
  -- currentIndex = currentIndex + 1
end

local function OnMicrogameTick_default(fTimeLeft)
  TowerTilesWrapper:SetNexusTileEnabled(currentIndex, not state)
  local isOnNexusTile = TowerTilesWrapper:IsPlayerPresentOnNexusTile(lPlayer, currentIndex)
  ShowMessageLocal("NexusTile " .. currentIndex .. " " .. lPlayer:GetSteamName() .. " : " .. tostring(isOnNexusTile))

  -- if math.fmod(fTimeLeft, 2) < 1 then
  --   if currentIndex > 10 then
  --     if currentIndex <= nexusTileCount then
  --       SendInfoChatMessageLocal("Enabling " .. tostring(currentIndex - 10) .. " nexustile")
  --       TowerTilesWrapper:SetNexusTileEnabled(currentIndex - 10, false)
  --     end
  --     -- if currentIndex <= nexusEdgeTileCount then
  --     --   SendInfoChatMessageLocal("Enabling " .. tostring(currentIndex - 10) .. " nexusedgetile")
  --     --   TowerTilesWrapper:SetNexusEdgeTileEnabled(currentIndex - 10, false)
  --     -- end
  --   end

  --   if currentIndex < nexusTileCount then
  --     TowerTilesWrapper:SetNexusTileEnabled(currentIndex, true)
  --   end
  --   -- if currentIndex < nexusEdgeTileCount then
  --   --   TowerTilesWrapper:SetNexusEdgeTileEnabled(currentIndex, true)
  --   -- end

  --   ShowMessageLocal("Current Index : " .. "(" ..
  --     tostring(currentIndex) .. " " .. tostring(nexusTileCount) .. "/" .. tostring(nexusEdgeTileCount) .. ")")
  --   currentIndex = currentIndex + 1
  -- end
end

local function OnPostMicrogame_default()
  TowerTilesWrapper:ResetCheckerboardTiles()
  Reset()
end

local defaultVariation = CreateMicrogameVariation("default", OnBeginMicrogame_default,
  OnMicrogameTick_default, OnPostMicrogame_default)

microgame = CreateMicrogame("DancingFloor", microgameMusic,
  { defaultVariation },
  { Difficulty = Difficulty.Easy, Rarity = 8, MinPlayers = 1, Type = MicrogameType.WinAtEnd, PlayEffect = true })
