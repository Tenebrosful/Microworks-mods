--- @meta
--- @Tenebrosful
--- Functions about messages

local chatPrefix = "[TeneLib_Message]"

--- Convert a Vector3 to a string
---@param vector Vector3
---@return string
worldGlobals["Vector3ToString"] = function(vector)
  return string.format("(%f %f %f)", vector.x, vector.y, vector.z)
end
