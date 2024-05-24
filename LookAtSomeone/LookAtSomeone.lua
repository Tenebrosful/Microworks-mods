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

-- Default Variation
local function OnBeginMicrogame_default()

end

local function OnMicrogameTick_default(fTimeLeft)

end

local function OnPostMicrogame_default()

end

local defaultVariation = CreateMicrogameVariation("default", OnBeginMicrogame_default,
  OnMicrogameTick_default, OnPostMicrogame_default)

microgame = CreateMicrogame("LookAtSomeone", microgameMusic, { defaultVariation },
  { Difficulty = Difficulty.Easy, Rarity = 8, MinPlayers = 2, Type = MicrogameType.WinBeforeEnd, PlayEffect = true })
