--- Dev tool to help with nexus times
--- Depends :
---   - TeneLib_NexusTile.lua

local contentRoot = "\\Scripts\\AutoRun\\TeneDevTool_NexusTile"

local chatPrefix = "[TeneDevTool_NexusTile]"

local coordinator = worldInfo:GetCoordinator()
local towerTilesWrapper = coordinator:GetTowerTiles()

local initialized = false
local isChatReading = false
local debugInfoEnabled = false

local debugInfo
local backgroundTransform
local textPosition = Vector3(0, 100, 0)

ListenFor("OnStep", function(payload)
  if not initialized or not debugInfoEnabled then
    return
  end

  local indexNexus = worldGlobals.GetNexusTileIndexFromPlayer(towerTilesWrapper, worldInfo:GetLocalPlayer())
  local indexNexusEdge = worldGlobals.GetNexusEdgeTileIndexFromPlayer(towerTilesWrapper, worldInfo:GetLocalPlayer())

  debugInfo:SetText(
    "<b>Index of current nexus tile : " .. tostring(indexNexus) .. "</b>\n" ..
    "<b>Index of current nexus edge tile : " .. tostring(indexNexusEdge) .. "</b>"
  )
end)

ListenFor("Chat", function(payload)
  local message = string.lower(payload:GetMessage())

  if message:find("^/tdt_nexustile") ~= nil then
    isChatReading = not isChatReading
    worldInfo:SendInfoChatMessageLocal(chatPrefix .. " Listing for commands : " .. tostring(isChatReading))
  end

  if isChatReading then
    if message:find("^enable ") ~= nil then
      local arg = string.gsub(message, "enable ", "")
      local index = tonumber(arg)
      towerTilesWrapper:SetNexusTileEnabled(index, true)
    elseif message:find("^disable ") ~= nil then
      local arg = string.gsub(message, "disable ", "")
      local index = tonumber(arg)
      towerTilesWrapper:SetNexusTileEnabled(index, false)
    elseif message:find("^reset") then
      worldGlobals.ResetAllTiles(towerTilesWrapper)
    elseif message:find("^enablealledge") ~= nil then
      worldGlobals.SetAllNexusEdgeTileState(towerTilesWrapper, true)
    elseif message:find("^disablealledge") ~= nil then
      worldGlobals.SetAllNexusEdgeTileState(towerTilesWrapper, false)
    elseif message:find("^enableall") ~= nil then
      worldGlobals.SetAllNexusTileState(towerTilesWrapper, true)
    elseif message:find("^disableall") ~= nil then
      worldGlobals.SetAllNexusTileState(towerTilesWrapper, false)
    elseif message:find("^getstandingnexustile") ~= nil then
      local index = worldGlobals.GetNexusTileIndexFromPlayer(towerTilesWrapper, worldInfo:GetLocalPlayer())

      if index ~= nil then
        worldInfo:ShowMessageLocal(tostring(index))
      else
        worldInfo:ShowMessageLocal("None")
      end
    elseif message:find("^debuginfo") ~= nil then
      debugInfoEnabled = not debugInfoEnabled
      debugInfo:GetGameObject():SetActive(debugInfoEnabled)
      backgroundTransform:GetGameObject():SetActive(debugInfoEnabled)
      worldInfo:SendInfoChatMessageLocal(chatPrefix .. " Debug info : " .. tostring(debugInfoEnabled))
    end
  end
end)

local function Initialize()
  RunAsync(function()
    Wait(Seconds(1))

    local background = worldInfo:CreateEntity(Entity.UIImage)
    background:SetColor(Color(0, 0, 0, 0.8))

    backgroundTransform = background:GetRectTransform()
    backgroundTransform:SetPivot(Vector3(0.5, 0.5, 0.5))
    backgroundTransform:SetAnchorMin(Vector3(0.5, 0, 0))
    backgroundTransform:SetAnchorMax(Vector3(0.5, 0, 0))
    backgroundTransform:SetSizeDelta(Vector3(400, 100, 0))

    debugInfo = worldInfo:CreateEntity(Entity.UIText)
    debugInfo:SetTextAlignment(2)
    debugInfo:SetWordWrapping(false)
    debugInfo:SetFontSize(24)
    debugInfo:SetOutlineWidth(0.15)
    debugInfo:SetOutlineColor(Color(0, 0, 0, 150))
    debugInfo:SetColor(Color(1, 0.882, 0.25, 1))
    debugInfo:SetFontSize(12)

    local textTransform = debugInfo:GetRectTransform()
    textTransform:SetPivot(Vector3(0.5, 0, 0.5))
    textTransform:SetAnchorMin(Vector3(0.5, 0, 0))
    textTransform:SetAnchorMax(Vector3(0.5, 0, 0))
    textTransform:SetSizeDelta(Vector3(0, 0, 0))

    debugInfo:GetRectTransform():SetAnchoredPosition(textPosition)
    local backgroundPos = Vector3(textPosition.x, textPosition.y - 20, textPosition.z)
    backgroundTransform:SetAnchoredPosition(backgroundPos)

    debugInfo:GetGameObject():SetActive(debugInfoEnabled)
    backgroundTransform:GetGameObject():SetActive(debugInfoEnabled)

    initialized = true
  end)
end

Initialize()
