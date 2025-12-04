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

CreateMicrogame("DancingFloor", microgameMusic,
  { defaultVariation },
  { Difficulty = Difficulty.Easy, Rarity = 8, MinPlayers = 1, Type = MicrogameType.WinAtEnd, PlayEffect = true })
