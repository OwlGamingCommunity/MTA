blackMales = {[0] = true, [7] = true, [14] = true, [15] = true, [16] = true, [17] = true, [18] = true, [20] = true, [21] = true, [22] = true, [24] = true, [25] = true, [28] = true, [35] = true, [36] = true, [50] = true, [51] = true, [66] = true, [67] = true, [78] = true, [79] = true, [80] = true, [83] = true, [84] = true, [102] = true, [103] = true, [104] = true, [105] = true, [106] = true, [107] = true, [134] = true, [136] = true, [142] = true, [143] = true, [144] = true, [156] = true, [163] = true, [166] = true, [168] = true, [176] = true, [180] = true, [182] = true, [183] = true, [185] = true, [220] = true, [221] = true, [222] = true, [249] = true, [253] = true, [260] = true, [262] = true }
whiteMales = {[23] = true, [26] = true, [27] = true, [29] = true, [30] = true, [32] = true, [33] = true, [34] = true, [35] = true, [36] = true, [37] = true, [38] = true, [43] = true, [44] = true, [45] = true, [46] = true, [47] = true, [48] = true, [50] = true, [51] = true, [52] = true, [53] = true, [58] = true, [59] = true, [60] = true, [61] = true, [62] = true, [68] = true, [70] = true, [72] = true, [73] = true, [78] = true, [81] = true, [82] = true, [94] = true, [95] = true, [96] = true, [97] = true, [98] = true, [99] = true, [100] = true, [101] = true, [108] = true, [109] = true, [110] = true, [111] = true, [112] = true, [113] = true, [114] = true, [115] = true, [116] = true, [120] = true, [121] = true, [122] = true, [124] = true, [127] = true, [128] = true, [132] = true, [133] = true, [135] = true, [137] = true, [146] = true, [147] = true, [153] = true, [154] = true, [155] = true, [158] = true, [159] = true, [160] = true, [161] = true, [162] = true, [164] = true, [165] = true, [170] = true, [171] = true, [173] = true, [174] = true, [175] = true, [177] = true, [179] = true, [181] = true, [184] = true, [186] = true, [187] = true, [188] = true, [189] = true, [200] = true, [202] = true, [204] = true, [206] = true, [209] = true, [212] = true, [213] = true, [217] = true, [223] = true, [230] = true, [234] = true, [235] = true, [236] = true, [240] = true, [241] = true, [242] = true, [247] = true, [248] = true, [250] = true, [252] = true, [254] = true, [255] = true, [258] = true, [259] = true, [261] = true, [264] = true, [272] = true }
asianMales = {[49] = true, [57] = true, [58] = true, [59] = true, [60] = true, [117] = true, [118] = true, [120] = true, [121] = true, [122] = true, [123] = true, [170] = true, [186] = true, [187] = true, [203] = true, [210] = true, [227] = true, [228] = true, [229] = true, [294] = true}
blackFemales = {[9] = true, [10] = true, [11] = true, [12] = true, [13] = true, [40] = true, [41] = true, [63] = true, [64] = true, [69] = true, [76] = true, [91] = true, [139] = true, [148] = true, [190] = true, [195] = true, [207] = true, [215] = true, [218] = true, [219] = true, [238] = true, [243] = true, [244] = true, [245] = true, [256] = true, [304] = true }
whiteFemales = {[12] = true, [31] = true, [38] = true, [39] = true, [40] = true, [41] = true, [53] = true, [54] = true, [55] = true, [56] = true, [64] = true, [75] = true, [77] = true, [85] = true, [86] = true, [87] = true, [88] = true, [89] = true, [90] = true, [91] = true, [92] = true, [93] = true, [129] = true, [130] = true, [131] = true, [138] = true, [140] = true, [145] = true, [150] = true, [151] = true, [152] = true, [157] = true, [172] = true, [178] = true, [192] = true, [193] = true, [194] = true, [196] = true, [197] = true, [198] = true, [199] = true, [201] = true, [205] = true, [211] = true, [214] = true, [216] = true, [224] = true, [225] = true, [226] = true, [231] = true, [232] = true, [233] = true, [237] = true, [243] = true, [246] = true, [251] = true, [257] = true, [263] = true, [298] = true }
asianFemales = {[38] = true, [53] = true, [54] = true, [55] = true, [56] = true, [88] = true, [141] = true, [169] = true, [178] = true, [224] = true, [225] = true, [226] = true, [263] = true}

local localPlayer = getLocalPlayer()

function doVision()

	local tV = getPedOccupiedVehicle(getLocalPlayer()) 
	if not (tV) then
		removeEventHandler("onClientRender", getRootElement(), doVision)
		return
	end
	local px, py, pz = getElementPosition(localPlayer)
	-- vehicles
	for key, value in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(value) and (isElementOnScreen(value)) and (tV~=value) then
			local x, y, z = getElementPosition(value)
			
			if (isLineOfSightClear(px, py, pz, x, y, z, true, false, false, true, false, false, true, tV)) then
				local tx, ty = getScreenFromWorldPosition(x, y, z, 5000, false)
				
				if (tx) then
					dxDrawLine(tx, ty, tx+150, ty+150, tocolor(255, 255, 255, 200), 2, false) 
					
					local size = dxGetTextWidth(getVehicleName(value), 1, "bankgothic") + 170
					dxDrawLine(tx+150, ty+150, tx+size, ty+150,  tocolor(255, 255, 255, 200), 2, false)
					dxDrawText(getVehicleName(value), tx+150, ty, tx+size, ty+260, tocolor(255, 255, 255, 200), 1, "bankgothic", "center", "center")
				end
			end
		end
	end
	
	-- players
	for key, value in ipairs(getElementsByType("player")) do
		if isElementStreamedIn(value) and (isElementOnScreen(value)) and (localPlayer~=value) and tV ~= getPedOccupiedVehicle(value) then
			local x, y, z = getPedBonePosition(value, 6)
			local skin = getElementModel(value)
			local recon = getElementData(value, "reconx") or getElementAlpha(value) ~= 255
			if (isLineOfSightClear(px, py, pz, x, y, z, true, false, false, true, false, false, true, tV)) then
				local text

				-- needs fixing
				if (blackMales[skin]) then text = "Black Male"
				elseif (whiteMales[skin]) then text = "White Male"
				elseif (asianMales[skin]) then text = "Asian Male"
				elseif (blackFemales[skin]) then text = "Black Female"
				elseif (whiteFemales[skin]) then text = "White Female"
				elseif (asianFemales[skin]) then text = "Asian Female"
				else text = "White Male"
				end
				
				local tx, ty = getScreenFromWorldPosition(x, y, z+0.2, 5000, false)
				
				if (tx) and not (recon) then
					dxDrawLine(tx, ty, tx+150, ty-150, tocolor(255, 255, 255, 200), 2, false)
					local size = dxGetTextWidth(text, 1, "bankgothic") -- + 170
					dxDrawLine(tx+150, ty-150, tx+size, ty-150,  tocolor(255, 255, 255, 200), 2, false)
					dxDrawText(text, tx+150, ty-180, tx+size, ty-160, tocolor(255, 255, 255, 200), 1, "bankgothic", "center", "bottom")
				end
			end
		end
	end
end


function applyVision(thePlayer, seat, setVehicle)
	if setVehicle then
		source = setVehicle
	end
	if (thePlayer==localPlayer) then
		if (getElementModel(source)==497 or getElementModel(source)==487) then
			local playerFaction = getElementData(source, "faction")
			if (playerFaction == 1 or playerFaction == 2 or playerFaction == 87) then	
				if (seat == 0 or seat == 1) then
					addEventHandler("onClientRender", getRootElement(), doVision)
				end
			end
		end
	end
end
addEventHandler("onClientVehicleEnter", getRootElement(), applyVision)

function removeVision(thePlayer, seat)
	if (thePlayer==localPlayer) then
		if (getElementModel(source)==497 or getElementModel(source)==487) then
			local playerFaction = getElementData(source, "faction")
			if (playerFaction == 1 or playerFaction == 2) then	
				if (seat == 0 or seat == 1) then
					removeEventHandler("onClientRender", getRootElement(), doVision)
				end
			end
		end
	end
end
addEventHandler("onClientVehicleExit", getRootElement(), removeVision)

addEventHandler( "onClientResourceStart", getResourceRootElement( ),
    function ( startedRes )
		local setVehicle = getPedOccupiedVehicle( getLocalPlayer() )
		if setVehicle then
        applyVision(getLocalPlayer(), 0, setVehicle)
		end
    end
);