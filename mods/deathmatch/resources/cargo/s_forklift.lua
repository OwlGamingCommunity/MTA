--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Server-side script: Forklift features
--Last updated 23.02.2011 by Exciter
--Copyright 2008-2011, The Roleplay Project (www.roleplayproject.com)

local forklifts = {} --[vehicle] = {object, slot}

function loadForklift(element, slot)
	local forklift = source
	if not forklifts[forklift] then
		local result, errormsg = exports['item-system']:moveItem(element, forklift, slot)
		if result then
			--local newSlot = tonumber(errormsg)
			local newSlot = 1
			--outputChatBox("Slot "..tostring(newSlot), client)
			if newSlot then
				setElementData(forklift, "cargo.forklift.carrying", true)
				forklifts[forklift] = {}
				forklifts[forklift][1] = createObject(1271,0,0,0)
				forklifts[forklift][2] = newSlot
				setElementInterior(forklifts[forklift][1], getElementInterior(forklift))
				setElementDimension(forklifts[forklift][1], getElementDimension(forklift))
				attachElements(forklifts[forklift][1], forklift, 0, 0.5, 0.28)
				--triggerClientEvent(client, "cargo:loadForkliftResponse", client, newSlot)
			else
				outputChatBox("Error: Missing slot ID.", client, 255, 0, 0)
			end
		else
			outputChatBox("Error: "..tostring(errormsg), client, 255, 0, 0)
		end
	end
	triggerClientEvent(client, "hideLoading", client)
end
addEvent("cargo:loadForklift", true )
addEventHandler("cargo:loadForklift", getRootElement(), loadForklift)

function unloadForklift(element)
	local forklift = source
	--outputDebugString("server element = "..tostring(element))
	if forklifts[forklift] then
		local slot = forklifts[forklift][2]
		
		local result, errormsg = exports['item-system']:moveItem(forklift, element, slot)	
		if result then
			setElementData(forklift, "cargo.forklift.carrying", false)
			destroyElement(forklifts[forklift][1])
			forklifts[forklift] = false
			--triggerClientEvent(client, "cargo:unloadForkliftResponse", client)
		else
			outputChatBox("Error: "..tostring(errormsg), client, 255, 0, 0)
		end
	else
		setElementData(forklift, "cargo.forklift.carrying", false)
	end
	triggerClientEvent(client, "hideLoading", client)
end
addEvent("cargo:unloadForklift", true )
addEventHandler("cargo:unloadForklift", getRootElement(), unloadForklift)

function initialize()
	for k,v in ipairs(getElementsByType("Vehicle")) do
		if(getElementModel(v) == 530) then --forklift
			if getElementData(v, "cargo.forklift.carrying") then
				setElementData(v, "cargo.forklift.carrying", false)
			end
		end
	end
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), initialize)
--addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), initialize)