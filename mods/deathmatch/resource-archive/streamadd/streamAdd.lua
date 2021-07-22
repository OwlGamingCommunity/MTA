taSertoStreams = {}
taSertoStreamNumber = 0
localPlayer = getLocalPlayer()
streamAddWnd = nil

function addClientStream( url, position, dimension, interior, distance, specialKey )
	if specialKey then
		streamNumber = specialKey
	else
		streamNumber = taSertoStreamNumber + 1
	end
	taSertoStreams[streamNumber] = playSound3D(tostring( url ), unpack( position ))
	setSoundMaxDistance( taSertoStreams[streamNumber], distance )
	setElementDimension( taSertoStreams[streamNumber], dimension )
	setElementInterior( taSertoStreams[streamNumber], interior )
	if specialKey then
		taSertoStreamNumber = streamNumber + 1
	else
		taSertoStreamNumber = taSertoStreamNumber + 1
	end
end
addEvent("onClientRenderStream", true)
addEventHandler("onClientRenderStream", getLocalPlayer( ), addClientStream)

function removeClientFromStream( streamID )
	if taSertoStreams[ streamID ] then
		destroyElement(taSertoStreams[streamID])
		taSertoStreams[streamID] = nil
	end
end
addEvent("onClientRemoveStream", true)
addEventHandler("onClientRemoveStream", getLocalPlayer( ), removeClientFromStream)
		
--[[
addCommandHandler( "tasertostream",
	function( )
		local sound = playSound3D("http://82.197.165.139:80", 1448.9775390625, 1401.7822265625, 10.841726303101) 
		setSoundMaxDistance( sound, 40 )
		setElementDimension(sound, 422)
		setElementInterior(sound, 1)
		outputChatBox("ta serto stream", 255, 194, 14)
	end
)
--]]

local function isnan(x)
	math.inf = 1/0
	if x == math.inf or x == -math.inf or x ~= x then
		return true
	end
	return false
end
function streamAdd()
	local gui = {}
	gui._placeHolders = {}
	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 308, 148
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Stream Configuration", false)
	streamAddWnd = gui["_root"]
	guiWindowSetSizable(gui["_root"], false)
	
	gui["label"] = guiCreateLabel(40, 25, 61, 16, "Stream link", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label"], "left", false)
	guiLabelSetVerticalAlign(gui["label"], "center")
	
	gui["lineEdit"] = guiCreateEdit(20, 45, 113, 20, "", false, gui["_root"])
	guiEditSetMaxLength(gui["lineEdit"], 32767)
	
	gui["label_2"] = guiCreateLabel(200, 25, 46, 13, "Distance", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_2"], "center")
	
	gui["lineEdit_2"] = guiCreateEdit(170, 45, 113, 20, "", false, gui["_root"])
	guiEditSetMaxLength(gui["lineEdit_2"], 32767)
	
	gui["pushButton"] = guiCreateButton(20, 85, 75, 23, "Add stream", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["pushButton"], 
		function()
			local url = guiGetText(gui["lineEdit"])
			local distance = guiGetText(gui["lineEdit_2"])
			if(string.len(url) < 10) then
				outputChatBox("Enter a valid URL for the stream.",255,0,0)
				return
			end
			if(isnan(distance)) then
				outputChatBox("Enter a valid number for streaming distance.",255,0,0)
				return
			else
				distance = tonumber(distance) or 0
			end
			if(distance < 1 or distance > 9000) then
				outputChatBox("Distance must be a number between 1 and 9000.",255,0,0)
			end
			triggerServerEvent("stream:addDJstream", localPlayer, localPlayer, "romer", url, distance)
		end
	, false)
	gui["pushButton_2"] = guiCreateButton(100, 85, 75, 23, "Close", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["pushButton_2"], closeStreamAddWnd, false)
end
addCommandHandler("addstream", streamAdd, false, false)
function closeStreamAddWnd()
	if streamAddWnd then
		if isElement(streamAddWnd) then
			destroyElement(streamAddWnd)
			streamAddWnd = nil
		end
	end
end