function checkData(dataName, oldValue)
 if getElementType(source) == "player" then
  if dataName == "bankmoney" then
   local newValue = getElementData(source, "bankmoney")
   if oldValue == "nil" then
    local oldValue = "~New Value~"
   end
   if client == "nil" then
    local client = "server"
   end
   if isElement(client) then
    outputDebugString("Old Bankmoney for "..getPlayerName(source).." "..tostring(oldValue).." New value "..tostring(newValue).." changed by: "..tostring(getResourceName(sourceResource)).." User changed by: "..tostring(getPlayerName(client)))
   else
    outputDebugString("Old Bankmoney for "..getPlayerName(source).." "..tostring(oldValue).." New value "..tostring(newValue).." changed by: "..tostring(getResourceName(sourceResource)).." User changed by: "..tostring(client))
   end
  end
 end
end
addEventHandler("onElementDataChange", getRootElement(), checkData)