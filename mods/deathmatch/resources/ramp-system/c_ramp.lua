function applyMods()
   local txd = engineLoadTXD ( "lifts.txd")
   engineImportTXD ( txd, 2052 )
   local dff = engineLoadDFF("liftposts.dff", 2052 )
   engineReplaceModel(dff, 2052)
   local col = engineLoadCOL ( "liftposts.col")
   engineReplaceCOL ( col, 2052 )
   local txd = engineLoadTXD ( "lifts.txd")
   engineImportTXD ( txd, 2053 )
   local dff = engineLoadDFF("ramps.dff", 2053 )
   engineReplaceModel(dff, 2053)
   local col = engineLoadCOL ( "ramps.col")
   engineReplaceCOL ( col, 2053 )
   
   local txd = engineLoadTXD ( "stand.txd")
   engineImportTXD ( txd, 2365 )
   local dff = engineLoadDFF("stand.dff", 2365 )
   engineReplaceModel(dff, 2365)
   local col = engineLoadCOL ( "stand.col")
   engineReplaceCOL ( col, 2365 )
end

addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), function()
    applyMods()
    setTimer (applyMods, 1000, 2)
end)

function showRampControls(element)
	if rampWindow and isElement(rampWindow) then
		destroyElement(rampWindow)
	else
		rampWindow = guiCreateWindow(200, 500, 353, 93, "Ramp Controls - #" .. getElementData(element, "dbid"), false)
		local rampScroll = guiCreateScrollBar(10, 24, 334, 24, true, false, rampWindow)
		local rampClose = guiCreateButton(10, 58, 334, 25, "Close", false, rampWindow)
		guiScrollBarSetScrollPosition(rampScroll, getElementData(getElementData(element, "lift"), "lift.position"))
		
		addEventHandler("onClientGUIClick", rampClose, function()
			if source == rampClose then
				destroyElement(rampWindow)
			end
		end)
		
		addEventHandler("onClientGUIMouseUp", rampScroll, function()
			if source == rampScroll then
				if not getElementData(element, "lift.moving") then
					triggerServerEvent("moveRamp", getLocalPlayer(), element, guiScrollBarGetScrollPosition(rampScroll))
				else
					guiScrollBarSetScrollPosition(rampScroll, getElementData(getElementData(element, "lift"), "lift.position"))
				end
			end
		end)
	end
end
addEvent("showRampControls", true)
addEventHandler("showRampControls", getRootElement(), showRampControls)