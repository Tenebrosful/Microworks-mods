--- @meta
--- @Tenebrosful
--- Functions about microgames

local chatPrefix = "[TeneLib_Microgame]"

--- Set all players their winner state
--- @param coordinator MicrogameCoordinatorWrapper
--- @param state boolean winner state
worldGlobals["SetAllPlayersWinnerState"] = function(coordinator, state)
  if not worldInfo:IsServer() then return end

  for i, player in ipairs(worldInfo:GetAllActivePlayers()) do
    coordinator:MarkWinner(player:GetNetworkID(), state)
  end
end

--- Mark all players as winners
--- @param coordinator MicrogameCoordinatorWrapper
worldGlobals["MarkAllPlayersAsWinner"] = function(coordinator)
  if not worldInfo:IsServer() then return end

  worldGlobals.SetAllPlayersWinnerState(coordinator, true)
end

--- Mark all players as loosers
--- @param coordinator MicrogameCoordinatorWrapper
worldGlobals["MarkAllPlayersAsLooser"] = function(coordinator)
  if not worldInfo:IsServer() then return end

  worldGlobals.SetAllPlayersWinnerState(coordinator, false)
end
