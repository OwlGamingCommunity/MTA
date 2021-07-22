radio = 0
song = ""
lawVehicles = { [416]=true, [433]=true, [427]=true, [528]=true, [407]=true, [544]=true, [523]=true, [598]=true, [596]=true, [597]=true, [599]=true, [432]=true, [601]=true, [509]=true, [481]=true, [510]=true, [462]=true, [448]=true, [581]=true, [522]=true, [461]=true, [521]=true, [523]=true, [463]=true, [586]=true, [468]=true, [471]=true }



local soundElement = nil
local soundElementsOutside = { }

function setVolume(commandname, val)
	if tonumber(val) then
		val = tonumber(val)
		if (val >= 0 and val <= 100) then
			triggerServerEvent("car:radio:vol", getLocalPlayer(), val)
			return
		end
	end
	outputChatBox ( "* ERROR: /setvol 0 - 100", 255, 0, 0, false )
end
addCommandHandler("setvol", setVolume)

function saveRadio(station)
	if getElementData(localPlayer, "streams") == "0" then
		cancelEvent()
		return false
	end

	local radios = 0
	if (station == 0) then
		return
	end

	if exports.scoreboard:isVisible() then
		cancelEvent()
		return
	end

	local vehicle = getPedOccupiedVehicle(getLocalPlayer())

	if (vehicle) then
		if not getVehicleEngineState(vehicle) then
			cancelEvent()
			return
		end
		if getVehicleOccupant(vehicle) == getLocalPlayer() or getVehicleOccupant(vehicle, 1) == getLocalPlayer() then
			if getVehicleType(vehicle) ~= 'BMX' and getVehicleType(vehicle) ~= 'Bike' and getVehicleType(vehicle) ~= 'Quad' then
			--if not (lawVehicles[getElementModel(vehicle)]) then
				if (station == 12) then
					if (radio == 0) then
						radio = #streams + 1
					end

					if (streams[radio-1]) then
						radio = radio-1
					else
						radio = 0
					end
				elseif (station == 1) then
					if (streams[radio+1]) then
						radio = radio+1
					else
						radio = 0
					end
				end
				triggerServerEvent("car:radio:sync", getLocalPlayer(), radio)
			end
		end
		cancelEvent()
	end
end
addEventHandler("onClientPlayerRadioSwitch", getLocalPlayer(), saveRadio)

addEventHandler("onClientPlayerVehicleEnter", getLocalPlayer(),
	function(theVehicle)
		if getElementData(localPlayer, "streams") == "0" then
			return false
		end
		stopStupidRadio()
		radio = getElementData(theVehicle, "vehicle:radio") or 0
		updateLoudness(theVehicle)
	end
)

addEventHandler("onClientPlayerVehicleExit", getLocalPlayer(),
	function(theVehicle)
		stopStupidRadio()
		radio = getElementData(theVehicle, "vehicle:radio") or 0
		updateLoudness(theVehicle)
	end
)

function stopStupidRadio()
	removeEventHandler("onClientPlayerRadioSwitch", getLocalPlayer(), saveRadio)
	setRadioChannel(0)
	addEventHandler("onClientPlayerRadioSwitch", getLocalPlayer(), saveRadio)
end

addEventHandler ( "onClientElementDataChange", getRootElement(),
	function ( dataName )
		if getElementType ( source ) == "vehicle" and dataName == "vehicle:radio" then
			local newStation =  getElementData(source, "vehicle:radio")  or 0
			if (isElementStreamedIn (source)) then
				if newStation ~= 0 then
					if isElement ( soundElementsOutside[source]) then
						stopSound(soundElementsOutside[source])
					end
					if getPedOccupiedVehicle( getLocalPlayer() ) and getPedOccupiedVehicle( getLocalPlayer() ) == source then
						radio = newStation
					end
					local x, y, z = getElementPosition(source)
					local newSoundElement = playSound3D(streams[newStation][2], x, y, z, true)
					soundElementsOutside[source] = newSoundElement
					setElementDimension(newSoundElement, getElementDimension(source))
					setElementInterior(newSoundElement, getElementInterior(source))
					updateLoudness(source)
					attachElements(newSoundElement, source)
				else
					if (soundElementsOutside[source]) then
						stopSound(soundElementsOutside[source])
						soundElementsOutside[source] = nil
					end
				end
			end
		elseif getElementType(source) == "vehicle" and dataName == "vehicle:windowstat" then
			if (isElementStreamedIn (source)) then
				if (soundElementsOutside[source]) then
					updateLoudness(source)
				end
			end
		elseif getElementType(source) == "vehicle" and dataName == "vehicle:radio:volume" then
			if (isElementStreamedIn (source)) then
				if (soundElementsOutside[source]) then
					updateLoudness(source)
				end
			end
		end

		--
	end
)

addEventHandler( "onClientInteriorChange", getRootElement(),
	function(client)
		if soundElementsOutside ~= nil then
			local veh = getPedOccupiedVehicle(client)
			if veh and soundElementsOutside[veh] then
				setElementInterior(soundElementsOutside[veh], getElementInterior(veh))
				setElementDimension(soundElementsOutside[veh], getElementDimension(veh))
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
	function()
		local vehicles = getElementsByType("vehicle", true)
		for _, theVehicle in ipairs(vehicles) do
			spawnSound(theVehicle)
		end
	end
)

function spawnSound(theVehicle)
	if getElementData(localPlayer, "streams") == "0" then
		return false
	end

    if getElementType( theVehicle ) == "vehicle" then
		local radioStation = getElementData(theVehicle, "vehicle:radio") or 0
		if radioStation ~= 0 and streams[radioStation] then
			if (soundElementsOutside[theVehicle]) then
				stopSound(soundElementsOutside[theVehicle])
			end
			local x, y, z = getElementPosition(theVehicle)
			local newSoundElement = playSound3D(streams[radioStation][2], x, y, z, true)
			soundElementsOutside[theVehicle] = newSoundElement
			setElementDimension(newSoundElement, getElementDimension(theVehicle))
			setElementInterior(newSoundElement, getElementInterior(theVehicle))
			attachElements(newSoundElement, theVehicle)
			updateLoudness(theVehicle)
		end
    end
end

function updateLoudness(theVehicle)
	local carVolume = getElementData(theVehicle, "vehicle:radio:volume") or 60

	if getElementData(localPlayer, "streams") == "0" then
		carVolume = 0
	else
		carVolume = carVolume / 100
	end


	if isElement ( soundElementsOutside[theVehicle] ) then

		--  ped is inside
		if (getPedOccupiedVehicle( getLocalPlayer() ) == theVehicle) then
			setSoundMinDistance(soundElementsOutside[theVehicle], 25)
			setSoundMaxDistance(soundElementsOutside[theVehicle], 70)
			setSoundVolume(soundElementsOutside[theVehicle], 1*carVolume)
		elseif not exports.vehicle:isVehicleWindowUp(theVehicle) then -- window is open, ped outside
			setSoundMinDistance(soundElementsOutside[theVehicle], 25)
			setSoundMaxDistance(soundElementsOutside[theVehicle], 70)
			setSoundVolume(soundElementsOutside[theVehicle], 0.1*carVolume)
		else -- outside with closed windows
			setSoundMinDistance(soundElementsOutside[theVehicle], 3)
			setSoundMaxDistance(soundElementsOutside[theVehicle], 10)
			setSoundVolume(soundElementsOutside[theVehicle], 0.05*carVolume)
		end

	end

end

addEventHandler( "onClientElementStreamIn", getRootElement( ),
    function ( )
		spawnSound(source)
    end
)

addEventHandler( "onClientElementStreamOut", getRootElement( ),
    function ( )
        if getElementType( source ) == "vehicle" then
			if (soundElementsOutside[source]) then
				if isElement(soundElementsOutside[source]) then
					stopSound(soundElementsOutside[source])
				end
				soundElementsOutside[source] = nil
			end
        end
    end
)

-- Shmorf ( 27/7/2013 21:41 )
local sw, sh = guiGetScreenSize ( )
local mp3Station = nil
local mp3Sound = nil
local BizNoteFont20 = dxCreateFont ( ":resources/BizNote.ttf" , 20 )
local widthToDraw, widthToDraw2 = 0, 0
local heightToDraw, heightToDraw2 = 50, 50
local mp3_w = 200
local mp3_h = 300
local mp3_x = math.floor(sw * 0.0215) - 10
local mp3_y = sh * 0.89 - 10 - mp3_h

addEventHandler ( "onClientRender", root,
function ( )
	local left = math.floor(sw * 0.0215)
	local top = sh - 100
	if isPedInVehicle ( localPlayer ) and getElementData(localPlayer, "hide_hud") ~= "0" then
		if getElementData(localPlayer, "streams") == "0" then
			return false
		end
		local vehicle = getPedOccupiedVehicle ( localPlayer )

		if not vehicle then return end

		local radioID = getElementData ( vehicle, "vehicle:radio" )

		if radioID and radioID >= 0 and streams[radioID] and getVehicleType(vehicle) ~= 'BMX' and getVehicleType(vehicle) ~= 'Bike' and getVehicleType(vehicle) ~= 'Quad' then

			local sound = soundElementsOutside[vehicle]
			if isElement(sound) and sound and getSoundMetaTags ( sound ) then
				song = getSoundMetaTags ( sound )["stream_title"]
			else
				song = "Fetching song name..."
			end

			local text = "          #" .. radioID .. " - " .. streams[radioID][1]
			local size = dxGetTextWidth( text, 1, BizNoteFont20 or "default-bold" )

			--dxDrawText ( text, left, sh * 0.911, sw, sh, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
			dxDrawRectangle(left-10, top - 2, widthToDraw+20, heightToDraw, tocolor(0, 0, 0, 100), false)
			dxDrawImage ( left-10, top - 2, 50, 50, ":hud/images/radio.png" ,0, 0, 0, tocolor(255,255,255), true )
			dxDrawText ( text, left - 1, top + 10 , sw, sh, tocolor ( 70, 200, 14, 255 ), 1, BizNoteFont20 or "default-bold" )
			if radioID ~= 0 and type ( song ) == "string" then
				heightToDraw = 70
				text = "Now playing: " .. song
				local size1 = dxGetTextWidth( text )
				if size < size1 then
					widthToDraw = size1
				else
					widthToDraw = size
				end
				--dxDrawText ( text, left, sh * 0.932, sw, sh, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
				dxDrawText ( text, left - 1, top + 50, sw, sh, tocolor ( 255, 255, 255, 255 ), 1, "default-default" )
			else
				widthToDraw = size
				heightToDraw = 50
			end

			left = left + widthToDraw + 20*2
		end
	end

	-- this is intentionally so you get both car radio + mp3 player if you're stupid enough to listen to both in a car.
	if mp3Station and mp3Station ~= nil then
		local song = 'Fetching song name...'
		if mp3Sound and isElement(mp3Sound) and getSoundMetaTags(mp3Sound) then
			song = getSoundMetaTags(mp3Sound)['stream_title'] or 'Fetching song name...'
		end

		local text = "          #" .. mp3Station .. " - " .. streams[mp3Station][1]
		local size = dxGetTextWidth( text, 1, BizNoteFont20 or "default-bold" )

		heightToDraw2 = 70
		dxDrawRectangle(left-10, top - 2, widthToDraw2+20, heightToDraw2, tocolor(0, 0, 0, 100), false)
		dxDrawImage ( left-10, top - 2, 50, 50, ":hud/images/radio.png" ,0, 0, 0, tocolor(255,255,255), true )
		dxDrawText ( text, left - 1, top, sw, sh, tocolor ( 70, 200, 14, 255 ), 1, BizNoteFont20 or "default-bold" )

		text = "MP3: " .. song
		local size1 = dxGetTextWidth( text )
		if size < size1 then
			widthToDraw2 = size1
		else
			widthToDraw2 = size
		end
		--dxDrawText ( text, left, sh * 0.932, sw, sh, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
		dxDrawText ( text, left - 1, top + 50, sw, sh, tocolor ( 255, 255, 255, 255 ), 1, "default-default" )
	end
end )

function updateCarRadio()
	local state = getElementData(localPlayer, "streams")
	if (state == "0") then
		setRadioChannel(0)

		-- kill all readio channels
		for _, value in pairs(soundElementsOutside) do
			stopSound(value)
		end
		soundElementsOutside = {}

		-- kill the mp3 player
		if mp3Sound then
			stopSound(mp3Sound)
			mp3Sound = nil
			mp3Station = nil
		end
	else
		-- repopulate all radio channels
		local vehicles = getElementsByType("vehicle", true)
		for _, theVehicle in ipairs(vehicles) do
			spawnSound(theVehicle)
		end
	end
end
addEvent("accounts:settings:updateCarRadio", false)
addEventHandler("accounts:settings:updateCarRadio", getRootElement(), updateCarRadio)

--

local mp3Window = nil
local width, height = mp3_w, mp3_h

function destroyMP3Window()
	if mp3Window then
		destroyElement(mp3Window)
		mp3Window = nil
	end
end

addEventHandler('onClientChangeChar', root,
	function()
		if mp3Sound then
			stopSound(mp3Sound)
			mp3Sound = nil
			mp3Station = nil
		end

		destroyMP3Window()
	end)


function showMP3GUI()
	destroyMP3Window()
	mp3Window = guiCreateWindow(mp3_x, mp3_y, mp3_w, mp3_h, "MP3", false)

	local grid = guiCreateGridList(10, 20, 180, 205, false, mp3Window)
	local col = guiGridListAddColumn(grid, 'Station', 0.85)
	for k, v in ipairs(streams) do
		if k ~= 0 then
			local row = guiGridListAddRow(grid)
			guiGridListSetItemText(grid, row, col, v[1], false, false)
			guiGridListSetItemData(grid, row, col, tostring(k))
		end
	end

	volSlider = guiCreateScrollBar(10, 235, 180, 19, true, false, mp3Window)

	if mp3Sound then 
		local setBar = (getSoundVolume(mp3Sound) * 100)
		guiScrollBarSetScrollPosition(volSlider, setBar)
	else
		guiScrollBarSetScrollPosition(volSlider, 100)
	end

	addEventHandler('onClientGUIScroll', volSlider, 
		function()
			if volSlider then 
				local sliderPos = guiScrollBarGetScrollPosition(volSlider)
				local volumeMath = sliderPos / 100
				setSoundVolume(mp3Sound, volumeMath)
			end
		end
	)

	addEventHandler('onClientGUIClick', grid,
		function()
			local item = guiGridListGetSelectedItem(grid)
			if item ~= -1 then
				local station = tonumber(guiGridListGetItemData(grid, item, col))

				if mp3Sound then
					stopSound(mp3Sound)
					mp3Sound = nil
				end

				mp3Sound = playSound(streams[station][2], true)
				local sliderPos = guiScrollBarGetScrollPosition(volSlider)
				local volumeMath = sliderPos / 100
				setSoundVolume(mp3Sound, volumeMath)

				mp3Station = station
			end
		end, false)

	local off = guiCreateButton(10, height - 35, 85, 25, 'Turn Off', false, mp3Window)
	addEventHandler('onClientGUIClick', off,
		function()
			if mp3Sound then
				stopSound(mp3Sound)
				mp3Sound = nil
				mp3Station = nil
			end
		end, false)

	local close = guiCreateButton(105, height - 35, 85, 25, 'Close', false, mp3Window)
	addEventHandler('onClientGUIClick', close, destroyMP3Window, false)
end

addEvent('realism:mp3:off', true)
addEventHandler('realism:mp3:off', root,
	function()
		if mp3Sound then
			stopSound(mp3Sound)
			mp3Sound = nil
			mp3Station = nil
		end
	end)
