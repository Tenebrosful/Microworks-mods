--- @meta
--- @Tenebrosful
--- Functions about nexus tiles

local chatPrefix = "[TeneLib_NexusTile]"

--- Set the color of all nexus tiles
---@param towerTilesWrapper TowerTilesWrapper
---@param color any
---@param presetColor any
worldGlobals["SetAllNexusTileColor"] = function(towerTilesWrapper, color, presetColor)
  for i = 0, towerTilesWrapper:GetNexusTileCount() - 1 do
    towerTilesWrapper:SetNexusTileColor(i, color, presetColor)
  end
end

--- Set the state of all nexus tiles
---@param towerTilesWrapper TowerTilesWrapper
---@param enabled boolean
worldGlobals["SetAllNexusTileState"] = function(towerTilesWrapper, enabled)
  for i = 0, towerTilesWrapper:GetNexusTileCount() - 1 do
    towerTilesWrapper:SetNexusTileEnabled(i, enabled)
  end
end

--- Set the color of all nexus edge tiles
---@param towerTilesWrapper TowerTilesWrapper
---@param color any
---@param presetColor any
worldGlobals["SetAllNexusEdgeTileColor"] = function(towerTilesWrapper, color, presetColor)
  for i = 0, towerTilesWrapper:GetNexusEdgeTileCount() - 1 do
    towerTilesWrapper:SetNexusEdgeTileColor(i, color, presetColor)
  end
end

--- Set the state of all nexus edge tiles
---@param towerTilesWrapper TowerTilesWrapper
---@param enabled boolean
worldGlobals["SetAllNexusEdgeTileState"] = function(towerTilesWrapper, enabled)
  for i = 0, towerTilesWrapper:GetNexusEdgeTileCount() - 1 do
    towerTilesWrapper:SetNexusEdgeTileEnabled(i, enabled)
  end
end

--- Reset the state and the color of all tiles
--- @param towerTilesWrapper TowerTilesWrapper
worldGlobals["ResetAllTiles"] = function(towerTilesWrapper)
  worldGlobals.SetAllNexusTileState(towerTilesWrapper, false)
  worldGlobals.SetAllNexusEdgeTileState(towerTilesWrapper, false)
end

--- Get the nexus tile index from where a player is standing
---@param towerTilesWrapper TowerTilesWrapper
---@param player PlayerControllerWrapper
---@return nil|integer
worldGlobals["GetNexusTileIndexFromPlayer"] = function(towerTilesWrapper, player)
  local index = nil

  for i = 0, towerTilesWrapper:GetNexusTileCount() - 1 do
    local isPresent = towerTilesWrapper:IsPlayerPresentOnNexusTile(player, i)

    if isPresent then
      index = i
      break
    end
  end

  return index
end

--- Get the nexus edge tile index from where a player is standing
---@param towerTilesWrapper TowerTilesWrapper
---@param player PlayerControllerWrapper
---@return nil|integer
worldGlobals["GetNexusEdgeTileIndexFromPlayer"] = function(towerTilesWrapper, player)
  local index = nil

  for i = 0, towerTilesWrapper:GetNexusEdgeTileCount() - 1 do
    local isPresent = towerTilesWrapper:IsPlayerPresentOnNexusEdgeTile(player, i)

    if isPresent then
      index = i
      break
    end
  end

  return index
end
