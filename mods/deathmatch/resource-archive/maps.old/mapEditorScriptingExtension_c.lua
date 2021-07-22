-- FILE: 	mapEditorScriptingExtension_c.lua
-- PURPOSE:	Prevent the map editor feature set being limited by what MTA can load from a map file by adding a script file to maps
-- VERSION:	RemoveWorldObjects (v1) AutoLOD (v1) BreakableObjects (v1)

function requestLODsClient()
	triggerServerEvent("requestLODsClient", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, requestLODsClient)

function setLODsClient(lodTbl)
	for i, model in ipairs(lodTbl) do
		engineSetModelLODDistance(model, 300)
	end
end
addEvent("setLODsClient", true)
addEventHandler("setLODsClient", resourceRoot, setLODsClient)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		--setTimer(setOcclusionsEnabled, 10000, 1, false)
	end)

addEventHandler('onClientElementStreamIn', resourceRoot,
	function()
		if getElementType(source) == "object" then
			local breakable = getElementData(source, "breakable")
			if type(breakable) == "boolean" then
				setObjectBreakable(source, breakable)
			end
			local collisions = getElementData(source, "collisions")
			if type(collisions) == "string" then
				if collisions == "false" then
					setElementCollisionsEnabled(source, false)
				else
					setElementCollisionsEnabled(source, true)
				end
			else
				setElementCollisionsEnabled(source, true)
			end
		end
	end)

addEventHandler('onClientElementStreamOut', resourceRoot,
	function()
		if getElementType(source) == "object" then
			setObjectBreakable(source, false)
		end
	end)
