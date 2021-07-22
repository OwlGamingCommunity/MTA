blackMales = {[0] = true, [7] = true, [14] = true, [15] = true, [16] = true, [17] = true, [18] = true, [20] = true, [21] = true, [22] = true, [24] = true, [25] = true, [28] = true, [35] = true, [36] = true, [50] = true, [51] = true, [66] = true, [67] = true, [78] = true, [79] = true, [80] = true, [83] = true, [84] = true, [102] = true, [103] = true, [104] = true, [105] = true, [106] = true, [107] = true, [134] = true, [136] = true, [142] = true, [143] = true, [144] = true, [156] = true, [163] = true, [166] = true, [168] = true, [176] = true, [180] = true, [182] = true, [183] = true, [185] = true, [220] = true, [221] = true, [222] = true, [249] = true, [253] = true, [260] = true, [262] = true }
whiteMales = {[23] = true, [26] = true, [27] = true, [29] = true, [30] = true, [32] = true, [33] = true, [34] = true, [35] = true, [36] = true, [37] = true, [38] = true, [43] = true, [44] = true, [45] = true, [46] = true, [47] = true, [48] = true, [50] = true, [51] = true, [52] = true, [53] = true, [58] = true, [59] = true, [60] = true, [61] = true, [62] = true, [68] = true, [70] = true, [72] = true, [73] = true, [78] = true, [81] = true, [82] = true, [94] = true, [95] = true, [96] = true, [97] = true, [98] = true, [99] = true, [100] = true, [101] = true, [108] = true, [109] = true, [110] = true, [111] = true, [112] = true, [113] = true, [114] = true, [115] = true, [116] = true, [120] = true, [121] = true, [122] = true, [124] = true, [127] = true, [128] = true, [132] = true, [133] = true, [135] = true, [137] = true, [146] = true, [147] = true, [153] = true, [154] = true, [155] = true, [158] = true, [159] = true, [160] = true, [161] = true, [162] = true, [164] = true, [165] = true, [170] = true, [171] = true, [173] = true, [174] = true, [175] = true, [177] = true, [179] = true, [181] = true, [184] = true, [186] = true, [187] = true, [188] = true, [189] = true, [200] = true, [202] = true, [204] = true, [206] = true, [209] = true, [212] = true, [213] = true, [217] = true, [223] = true, [230] = true, [234] = true, [235] = true, [236] = true, [240] = true, [241] = true, [242] = true, [247] = true, [248] = true, [250] = true, [252] = true, [254] = true, [255] = true, [258] = true, [259] = true, [261] = true, [264] = true, [272] = true }
asianMales = {[49] = true, [57] = true, [58] = true, [59] = true, [60] = true, [117] = true, [118] = true, [120] = true, [121] = true, [122] = true, [123] = true, [170] = true, [186] = true, [187] = true, [203] = true, [210] = true, [227] = true, [228] = true, [229] = true, [294] = true}
blackFemales = {[9] = true, [10] = true, [11] = true, [12] = true, [13] = true, [40] = true, [41] = true, [63] = true, [64] = true, [69] = true, [76] = true, [91] = true, [139] = true, [148] = true, [190] = true, [195] = true, [207] = true, [215] = true, [218] = true, [219] = true, [238] = true, [243] = true, [244] = true, [245] = true, [256] = true, [304] = true }
whiteFemales = {[12] = true, [31] = true, [38] = true, [39] = true, [40] = true, [41] = true, [53] = true, [54] = true, [55] = true, [56] = true, [64] = true, [75] = true, [77] = true, [85] = true, [86] = true, [87] = true, [88] = true, [89] = true, [90] = true, [91] = true, [92] = true, [93] = true, [129] = true, [130] = true, [131] = true, [138] = true, [140] = true, [145] = true, [150] = true, [151] = true, [152] = true, [157] = true, [172] = true, [178] = true, [192] = true, [193] = true, [194] = true, [196] = true, [197] = true, [198] = true, [199] = true, [201] = true, [205] = true, [211] = true, [214] = true, [216] = true, [224] = true, [225] = true, [226] = true, [231] = true, [232] = true, [233] = true, [237] = true, [243] = true, [246] = true, [251] = true, [257] = true, [263] = true, [298] = true }
asianFemales = {[38] = true, [53] = true, [54] = true, [55] = true, [56] = true, [88] = true, [141] = true, [169] = true, [178] = true, [224] = true, [225] = true, [226] = true, [263] = true}

blips = { }

local localPlayer = getLocalPlayer()

local showAtcVision = false

function doVision()
	if not inATCsphere(localPlayer) then
		leaveATCTowerSphere(localPlayer, true)
		return
	end
	local px, py, pz = getElementPosition(localPlayer)
	-- vehicles
	for key, value in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(value) and (isElementOnScreen(value)) then
			local model = getElementModel(value)
			if getVehicleEngineState(value) and model ~= 509 and model ~= 481 then
				local x, y, z = getElementPosition(value)

				--if (isLineOfSightClear(px, py, pz, x, y, z, true, false, false, true, false, false, true, localPlayer)) then
					local tx, ty = getScreenFromWorldPosition(x, y, z, 5000, false)

					if (tx) then
						dxDrawLine(tx, ty, tx+150, ty+150, tocolor(255, 255, 255, 200), 2, false) 

						local vehicleType = getVehicleType(value)

						local aircraft = false
						if(vehicleType == "Plane" or vehicleType == "Helicopter") then
							aircraft = true
						end

						local text
						if(aircraft) then
							local callsign = getElementData(value, "aircallsign")
							if callsign then
								text = callsign
							else
								text = getVehiclePlateText(value)
							end
						elseif(vehicleType == "Boat") then
							text = "Boat"
						elseif(vehicleType == "BMX") then
							text = "Bicycle"
						elseif(vehicleType == "Bike") then
							text = "Motorbike"
						elseif(vehicleType == "Train") then
							text = "Train"
						elseif(vehicleType == "Trailer") then
							text = "Trailer"
						else
							text = "Vehicle"
						end

						local size

						size = dxGetTextWidth(tostring(text), 1, "bankgothic") + 170
						dxDrawLine(tx+150, ty+150, tx+size, ty+150,  tocolor(255, 255, 255, 200), 2, false)
						dxDrawText(tostring(text), tx+150, ty, tx+size, ty+260, tocolor(255, 255, 255, 200), 1, "bankgothic", "center", "center")

						size = dxGetTextWidth(tostring(getVehicleName(value)), 0.10, "bankgothic") --+ 170
						dxDrawText(tostring(getVehicleName(value)), tx+150+20, ty+30, tx+size, ty+260, tocolor(255, 255, 255, 200), 0.5, "bankgothic", "left", "center")

						if aircraft then
							local tyBase = ty+55
							local linePlus = 20
							local airbourne = not isVehicleOnGround(value)

							if airbourne then
								local altitude = "ALT: "..tostring(math.floor(z)).." ft"
								size = dxGetTextWidth(tostring(altitude), 0.10, "bankgothic")
								dxDrawText(tostring(altitude), tx+150+20, tyBase, tx+size, ty+260, tocolor(255, 255, 255, 200), 0.5, "bankgothic", "left", "center")
								tyBase = tyBase + linePlus
							end

							local speed = "SPD: "..tostring(math.floor(exports.global:getVehicleVelocity(value))).." KIAS"
							size = dxGetTextWidth(tostring(speed), 0.10, "bankgothic")
							dxDrawText(tostring(speed), tx+150+20, tyBase, tx+size, ty+260, tocolor(255, 255, 255, 200), 0.5, "bankgothic", "left", "center")
							tyBase = tyBase + linePlus

							if airbourne then
								local distance = "DST: "..tostring(math.floor(getDistanceBetweenPoints3D(px, py, pz, x, y, z))).." nm"
								size = dxGetTextWidth(tostring(distance), 0.10, "bankgothic")
								dxDrawText(tostring(distance), tx+150+20, tyBase, tx+size, ty+260, tocolor(255, 255, 255, 200), 0.5, "bankgothic", "left", "center")
								tyBase = tyBase + linePlus
							end

						end
					end
				--end
			end
		end
	end
	
	-- players
	for key, value in ipairs(getElementsByType("player")) do
		if isElementStreamedIn(value) and (isElementOnScreen(value)) and (localPlayer~=value) then
			if(not isPedInVehicle(value) and not inATCsphere(value)) then
				local x, y, z = getPedBonePosition(value, 6)
				local skin = getElementModel(value)
				local recon = getElementData(value, "reconx") or getElementAlpha(value) ~= 255
				--if (isLineOfSightClear(px, py, pz, x, y, z, true, false, false, true, false, false, true, localPlayer)) then
					local text

					local race = getElementData(value, "race")
					local gender = getElementData(value, "gender")
					if race and gender then
						race = tonumber(race)
						gender = tonumber(gender)
						local raceString
						if race == 0 then
							raceString = "Black"
						elseif race == 1 then
							raceString = "White"
						elseif race == 2 then
							raceString = "Asian"
						end
						local genderString
						if gender == 0 then
							genderString = "Male"
						elseif gender == 1 then
							genderString = "Female"
						end
						if raceString and genderString then
							text = raceString.." "..genderString
						end
					end

					if not text then
						if (blackMales[skin]) then text = "Black Male"
						elseif (whiteMales[skin]) then text = "White Male"
						elseif (asianMales[skin]) then text = "Asian Male"
						elseif (blackFemales[skin]) then text = "Black Female"
						elseif (whiteFemales[skin]) then text = "White Female"
						elseif (asianFemales[skin]) then text = "Asian Female"
						else text = "Person"
						end
					end

					local tx, ty = getScreenFromWorldPosition(x, y, z+0.2, 5000, false)

					if (tx) and not (recon) then
						dxDrawLine(tx, ty, tx+150, ty-150, tocolor(255, 255, 255, 200), 2, false)
						local size = dxGetTextWidth(text, 1, "bankgothic") -- + 170
						dxDrawLine(tx+150, ty-150, tx+size, ty-150,  tocolor(255, 255, 255, 200), 2, false)
						dxDrawText(text, tx+150, ty-180, tx+size, ty-160, tocolor(255, 255, 255, 200), 1, "bankgothic", "center", "bottom")
					end
				--end
			end
		end
	end
end

local atcTowerSpheres = {
	createColSphere (-1275.6984863281, 53.451759338379, 65.855865478516, 10), --San Fierro airport
	createColSphere (1818.8610839844, -2359.8723144531, 46.555511474609, 10), --Los Santos airport
	createColSphere (1292.84765625, 1579.4052734375, 43.3359375, 10), --Las Venturas airport
	createColSphere (-4365.3037109375, 2358.29296875, 28.49843788147, 10), --Oceana airport
	createColSphere (2104.6999511719, -2339.3000488281, 17.89999961853, 5), --LS Tactical Air Command
	createColSphere (1994.5, -2229.3000488281, 14.39999961853, 5), --LS Aero Club
	createColSphere (220.099609375, 1822.9794921875, 7.5236320495605, 10), --BCA command bunker
	createColSphere (211.203125, 1810.994140625, 21.8671875, 5), --BCA south cabin
	
}
function inATCsphere(element)
	for k, v in ipairs(atcTowerSpheres) do
		if isElementWithinColShape(element, v) then
			return true
		end
	end
end
function hitATCTowerSphere(theElement, matchingDimension)
	if(theElement == getLocalPlayer() and matchingDimension) then
		showAtcVision = true
		addEventHandler("onClientRender", getRootElement(), doVision)
		if not radarBlipsShowing then
			showRadarBlips()
			triggerServerEvent("atcradar:addListener", getResourceRootElement(getThisResource()))
		end
	end
end
function leaveATCTowerSphere(theElement, matchingDimension)
	if(theElement == getLocalPlayer() and matchingDimension) then
		showAtcVision = false
		removeEventHandler("onClientRender", getRootElement(), doVision)
		if radarBlipsShowing then
			hideRadarBlips()
			triggerServerEvent("atcradar:removeListener", getResourceRootElement(getThisResource()))
		end
	end
end
for k,v in ipairs(atcTowerSpheres) do
	addEventHandler("onClientColShapeHit",v,hitATCTowerSphere)
	addEventHandler("onClientColShapeLeave",v,leaveATCTowerSphere)
end

function toggleVision()
	if showAtcVision then
        	showAtcVision = false
        	removeEventHandler("onClientRender", getRootElement(), doVision)
        	outputChatBox("Hiding ATC vision")
	else
		if inATCsphere(localPlayer) then
			showAtcVision = true
			addEventHandler("onClientRender", getRootElement(), doVision)
			outputChatBox("Showing ATC vision")
		end
	end
end
addCommandHandler("atcvision", toggleVision)

local watchedAreas = {
	--createColRectangle(-1724.49609375, -621.3701171875, 1119, 680)
	createColPolygon(-1352.2998046875, -227.8154296875,  -1712.6044921875, -552.4931640625, -1736.03125, -552.4765625, -1732.73828125, -233.1494140625, -1727.3349609375, -214.173828125, -1719.2216796875, -195.5498046875, -1708.41015625, -178.0146484375, -1696.3095703125, -162.8056640625, -1039.703125, 493.3203125, -999.287109375, 453.1201171875, -1228.5390625, 223.65234375, -1184.439453125, 179.5283203125, -1243.5537109375, 120.4091796875, -1153.58984375, 30.3232421875, -1212.1240234375, -28.1611328125, -1177.837890625, -62.607421875, -1136.123046875, -111.1513671875, -1102.837890625, -163.6796875, -1077.515625, -219.462890625, -1134.2822265625, -241.8076171875, -1120.095703125, -292.1513671875, -1115.3095703125, -351.703125, -1121.587890625, -406.4326171875, -1138.15234375, -450.1962890625, -1160.181640625, -484.5234375, -1186.4560546875, -515.763671875,  -1227.0498046875, -552.3701171875, -1227.197265625, -696.4404296875, -1624.08984375, -695.654296875, -1671.8681640625, -657.666015625, -1724.4970703125, -621.4169921875, -1725.173828125, -600.046875, -1678.076171875, -599.451171875, -1569.62890625, -549.1806640625, -1664.9765625, -453.830078125)
}
function inAnyColShape( element )
	for k, v in ipairs( watchedAreas ) do
		if isElementWithinColShape( element, v ) then
			return true
		end
	end
end

local areWeVisible = false
local startedInWatchedArea = false
setTimer(
	function( )
		local vehicle = getPedOccupiedVehicle( localPlayer )
		if vehicle and getVehicleOccupant( vehicle ) == localPlayer then
			local vehtype = getVehicleType(vehicle)
			if(vehtype == "Plane" or vehtype == "Helicopter") then
				if getVehicleEngineState(vehicle) then
					if not areWeVisible then
						triggerServerEvent( "sfia:airtrack:on", vehicle )
						areWeVisible = true
					end
					return
				end
			end
		elseif inATCsphere(localPlayer) then
			--outputDebugString("in tower")
			triggerServerEvent("sfia:airtrack:onTower", localPlayer)
			areWeVisible = true
			return
		end
		
		if areWeVisible then
			triggerServerEvent( "sfia:airtrack:off", localPlayer )
			areWeVisible = false
			
			for vehicle, blip in pairs( blips ) do
				destroyElement( blip )
				blips[ vehicle ] = nil
			end
		end
	end,
	5000,
	0
)

addEventHandler( "onClientPlayerVehicleEnter", localPlayer,
	function( vehicle, seat )
		if seat == 0 then
			startedInWatchedArea = inAnyColShape
		end
	end
)

--
-- the blips
--

addEvent( "sfia:airtrack:blips", true )
addEventHandler( "sfia:airtrack:blips", root,
	function( t )
		for player, vehicle in pairs( t ) do
			if not blips[ vehicle ] then
				if(getElementType(vehicle) == "vehicle") then
					blips[ vehicle ] = createBlipAttachedTo( vehicle, 0, 3, 0, 255, 255, 127 )
				end
			end
		end
	end
)

addEvent( "sfia:airtrack:on", true )
addEventHandler( "sfia:airtrack:on", root,
	function( )
		if not blips[ source ] then
			if(getElementType(source) == "vehicle") then
				blips[ source ] = createBlipAttachedTo( source, 0, 3, 0, 255, 255, 127 )
			end
		end
	end
)

addEvent( "sfia:airtrack:off", true )
addEventHandler( "sfia:airtrack:off", root,
	function( )
		if blips[ source ] then
			destroyElement( blips[ source ] )
			blips[ source ] = nil
		end
	end
)

--Remove ATC HUD and ATC radar when player goes to char selection screen
addEventHandler( "account:character:select", localPlayer,
	function(characterName, factionID)
		if showAtcVision then
			removeEventHandler("onClientRender", getRootElement(), doVision)
			showAtcVision = false
			outputDebugString("Hiding ATC vision")
		end
		if radarBlipsShowing then
			hideRadarBlips()
			--triggerServerEvent("atcradar:removeListener", getResourceRootElement(getThisResource()))
		end
	end
)