local microgame
local contentRoot = "\\Microgames\\PushSomeone"
local microgameMusic = {
  LoadResource(contentRoot .. "\\Music\\PushSomeone_100.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_111.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_122.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_133.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_144.ogg", ResourceType.Audio),
  LoadResource(contentRoot .. "\\Music\\PushSomeone_155.ogg", ResourceType.Audio),
}

local defaultVariation = CreateMicrogameVariation("default", OnBeginMicrogame_default, OnMicrogameTick_default,
  OnPostMicrogame_default)

function OnBeginMicrogame_default()
  print("Microgame has begun!")
end

function OnMicrogameTick_default(fTimeLeft)
  print("Microgame has ticked! There are " .. tostring(fTimeLeft) .. " seconds")
end

function OnPostMicrogame_default()
  print("Microgame has ended!")
end

local definedPlayerVariation = CreateMicrogameVariation("definedPlayer", OnBeginMicrogame_definedPlayer,
  OnMicrogameTick_definedPlayer, OnPostMicrogame_definedPlayer)

function OnBeginMicrogame_definedPlayer()
  print("Microgame has begun!")
end

function OnMicrogameTick_definedPlayer(fTimeLeft)
  print("Microgame has ticked! There are " .. tostring(fTimeLeft) .. " seconds")
end

function OnPostMicrogame_definedPlayer()
  print("Microgame has ended!")
end

microgame = CreateMicrogame("PushSomeone", microgameMusic, { defaultVariation, definedPlayerVariation },
  { Difficulty = Difficulty.Easy, Rarity = 8, MinPlayers = 1, Type = MicrogameType.WinBeforeEnd, PlayEffect = true })
