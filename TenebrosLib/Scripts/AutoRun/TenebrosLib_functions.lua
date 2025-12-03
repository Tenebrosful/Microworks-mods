print("Tenebros's lib is loaded !")

-- Send Local message
local function ShowMessageLocal(message)
  -- print(message)
  worldInfo:ShowMessageLocal(message)
end

local function SendInfoChatMessageLocal(message)
  worldInfo:SendInfoChatMessageLocal(message)
end

local function SendInfoChatMessageToAll(message)
  worldInfo:SendInfoChatMessageToAll(message)
end

worldGlobals["ShowMessageLocal"] = ShowMessageLocal
worldGlobals["SendInfoChatMessageLocal"] = SendInfoChatMessageLocal

SendInfoChatMessageToAll("Tenebros' lib is loaded !")
