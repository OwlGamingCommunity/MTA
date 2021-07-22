
--[[local lamps = {}
local currentflash = 1
local strobeon = false
local style = 2
local timer = nil

presets = {
	-- pattern 1
	{  
		{ 299.359375, 157.779296875, 758.21331787109, 14, 888}, 
		{ 300.560546875, 154.470703125, 759.49578857422, 14, 888},
		{ 298.6396484375, 151.2490234375, 760.88079833984, 14, 888},
		{ 295.15625, 150.568359375, 762.1533203125, 14, 888}, 
		{ 291.84375, 154.6552734375, 764.16265869141, 14, 888}, 
		{ 295.3828125, 157.4765625, 765.51147460938, 14, 888}, 
		{ 299.974609375, 132.4033203125, 757.90637207031, 14, 888}, 
		{ 299.111328125, 131.9990234375, 757.90258789063, 14, 888}, 
		{ 299.119140625, 130.580078125, 757.90252685547, 14, 888}, 
		{ 299.107421875, 129.7880859375, 757.90240478516, 14, 888}, 
		{ 299.0771484375, 127.857421875, 757.90216064453, 14, 888}, 
		{ 299.076171875, 126.1435546875, 757.90203857422, 14, 888}, 
		{ 299.076171875, 124.8564453125, 757.90197753906, 14, 888}, 
		{ 283.6884765625, 124.91796875, 757.83441162109, 14, 888}, 
		{ 282.8994140625, 127.529296875, 757.83111572266, 14, 888}, 
		{ 281.45703125, 130.6435546875, 757.82495117188, 14, 888},
		{ 280.732421875, 132.03125, 757.82189941406, 14, 888},
		{ 278.720703125, 134.9677734375, 757.81323242188, 14, 888},
		{ 276.5048828125, 137.708984375, 757.8037109375, 14, 888},
		{ 275.4345703125, 138.892578125, 757.79907226563, 14, 888},
		{ 272.931640625, 141.037109375, 757.78820800781, 14, 888},
		{ 270.1806640625, 143.1640625, 757.71331787109, 14, 888},
		{ 266.2958984375, 145.1728515625, 757.69152832031, 14, 888},
		{ 269.5517578125, 124.9921875, 762.46630859375, 14, 888},
		{ 268.6220703125, 126.197265625, 762.49151611328, 14, 888},
		{ 267.5732421875, 127.6015625, 762.50402832031, 14, 888},
		{ 266.3779296875, 128.6337890625, 762.48443603516, 14, 888},
		{ 264.9873046875, 129.8564453125, 762.43127441406, 14, 888},
		{ 266.2685546875, 128.7294921875, 762.47796630859, 14, 888},
		{ 267.646484375, 127.484375, 762.50817871094, 14, 888},
		{ 268.6171875, 126.2080078125, 762.49011230469, 14, 888},
		{ 269.6337890625, 124.9765625, 762.43347167969, 14, 888},
		{ 268.8212890625, 125.93359375, 762.49322509766, 14, 888},
		{ 267.66796875, 127.4462890625, 762.51049804688, 14, 888},
		{ 266.517578125, 128.515625, 762.486328125, 14, 888},
		{ 264.916015625, 129.9384765625, 762.41094970703, 14, 888},
		{ 264.9013671875, 154.998046875, 765.82550048828, 14, 888},
		{ 267.7099609375, 155.005859375, 765.8232421875, 14, 888},
		{ 268.107421875, 159.59375, 765.81280517578, 14, 888},
		{ 271.1025390625, 159.6171875, 765.81280517578, 14, 888},
		{ 273.529296875, 156.388671875, 765.81268310547, 14, 888},
		{ 277.6240234375, 156.3525390625, 765.81268310547, 14, 888},
		{ 282.423828125, 156.3994140625, 765.81274414063, 14, 888},
		{ 286.92578125, 156.4482421875, 765.81274414063, 14, 888},
		{ 291.46875, 156.4931640625, 765.81256103516, 14, 888},
		{ 292.2626953125, 152.9921875, 763.54821777344, 14, 888},
		{ 296.8857421875, 150.4853515625, 761.51684570313, 14, 888},
		{ 300.4658203125, 153.908203125, 759.67547607422, 14, 888},
		{ 299.2373046875, 157.9228515625, 758.14837646484, 14, 888}
	} 
}


function loadclub(thePlayer, command, id)
	
	local patternid = tonumber(id)
	if (presets[patternid]) then
		for _, dot in pairs(presets[patternid]) do
			add(dot[1], dot[2], dot[3], dot[5], dot[4])
		end
		outputChatBox(#presets[patternid] .." points loaded", thePlayer)
	else
		outputChatBox("Pattern not found.", thePlayer)
	end
end
addCommandHandler("aloadclubrot", loadclub, false, false)

function clearrot(thePlayer)
	
	local count = #lamps
	for id, theLamp in pairs(lamps) do
		destroyElement(theLamp)
	end
	outputChatBox("destroyed " .. count .. " dots.", thePlayer)
end
addCommandHandler("adelclubrot", clearrot, false, false)


function load(thePlayer, commandName, speed)
	
	if (timer) then
		killTimer(timer)
	end
	speed = speed * 100 or 1000
	timer = setTimer(loop, speed, 0)	
end
addCommandHandler("astartclubrot", load, false, false)

function stylef(thePlayer, commandName, newstyle)
	
	style = tonumber(newstyle) or 1
	
	for id, theLamp in pairs(lamps) do
		setElementAlpha(theLamp, 127)
	end
end
addCommandHandler("aclubrotstyle", stylef, false, false)

function load2(thePlayer, commandName, speed)
	
	if (timer) then
		killTimer(timer)
		outputChatbox("killed", thePlayer)
		timer = nil
	end	
end
addCommandHandler("astopclubrot", load2, false, false)

function addLamp(thePlayer)
	
	local posX, posY, posZ = getElementPosition(thePlayer)
	local posD = getElementDimension(thePlayer)
	local posI = getElementInterior(thePlayer)
	add(posX,posY,posZ,posD,posI)
end
addCommandHandler("aaddclubpoi", addLamp, false, false)

function add(posX,posY,posZ,posD,posI)
	
	--outputDebugString("{ ".. posX .. ", ".. posY .. ", ".. posZ .. ", "..posI..", "..posD.." },", thePlayer)
	local index = #lamps + 1
	lamps[index] = createMarker( posX, posY, posZ, 'corona', 1, math.random( 0, 255 ) , math.random( 0, 255 ), math.random( 0, 255 ), 0 )
	setElementInterior(lamps[ index ], posI)
	setElementDimension(lamps[ index  ], posD)
end

function loop()
	
	local chpos1, chpos2, chpos3, chpos4, chpos5
	--local reset1
	if #lamps > 6 then
		if (style == 1) or (style == 2) then -- maths
			currentflash = currentflash + 1
			if (currentflash > #lamps) then
				currentflash = 1
			end
			
			if currentflash == 1 then -- inclde the last two
				--reset1 = #lamps - 2
				chpos1 = #lamps - 1
				chpos2 = #lamps
				chpos3 = currentflash
				chpos4 = currentflash + 1
				chpos5 = currentflash + 2
			elseif currentflash == 2 then
				--reset1 = #lamps - 1
				chpos1 = #lamps
				chpos2 = currentflash - 1
				chpos3 = currentflash
				chpos4 = currentflash + 1
				chpos5 = currentflash + 2
			elseif currentflash == #lamps - 1 then
				--reset1 = currentflash - 3
				chpos1 = currentflash - 2
				chpos2 = currentflash - 1
				chpos3 = currentflash
				chpos4 = currentflash + 1
				chpos5 = 1
			elseif currentflash == #lamps then
				--reset1 = currentflash - 3
				chpos1 = currentflash - 2
				chpos2 = currentflash - 1
				chpos3 = currentflash
				chpos4 = 1
				chpos5 = 2
			else
				--reset1 = currentflash - 3
				chpos1 = currentflash - 2
				chpos2 = currentflash - 1
				chpos3 = currentflash 
				chpos4 = currentflash + 1
				chpos5 = currentflash + 2
			end
		end
		
		if (style == 1) then
			--for id, theLamp in pairs(lamps) do
				--if (id == chpos1) or (id == chpos5)then
					--setMarkerSize ( theLamp, 1.5 )
				--elseif (id == chpos2) or (id == chpos4) then
					--setMarkerSize ( theLamp, 2 )
				--elseif (id == chpos3) then
					--setMarkerSize ( theLamp, 3 )	
				--else
					--setMarkerSize(theLamp, 1)		
				--end
			--end
			
			setMarkerSize(lamps[chpos1], 1.5)
			setMarkerSize(lamps[chpos2], 2)
			setMarkerSize(lamps[chpos3], 3)
			setMarkerSize(lamps[chpos4], 2)
			setMarkerSize(lamps[chpos5], 1.5)
			
			setMarkerSize(lamps[reset1], 1)
		elseif (style == 2) then
			--for id, theLamp in pairs(lamps) do
				--if (id == chpos1) or (id == chpos5)then
					--setElementAlpha ( theLamp, 75 )
				--elseif (id == chpos2) or (id == chpos4) then
					--setElementAlpha ( theLamp, 120 )
				--elseif (id == chpos3) then
					--setElementAlpha ( theLamp, 200 )	
				--else
					--setElementAlpha (theLamp, 0)		
				--end
			--end
			setElementAlpha(lamps[chpos1], 75)
			setElementAlpha(lamps[chpos2], 120)
			setElementAlpha(lamps[chpos3], 200)
			setElementAlpha(lamps[chpos4], 120)
			setElementAlpha(lamps[chpos5], 75)
			
			--setElementAlpha(lamps[reset1], 0)
		elseif (style == 3) then
			strobeon = not strobeon
			local newvalue 
			if (strobeon) then
				newvalue = 200
			else 
				newvalue = 0
			end
			for id, theLamp in pairs(lamps) do
				setElementAlpha(theLamp,newvalue)
			end
		elseif (style == 4) then
			for id, theLamp in pairs(lamps) do
				setElementAlpha(theLamp,math.random(0,200))
				setMarkerSize(theLamp,math.random(0,3))
			end
		end
	end
end]]