local fireModel = 2023
local isFireOn = false

local fireTable = {
		--  { x, y, z, "Location", "Incident description", "special or regular", carID(or blank) }
		{ 2116.5451660156, -1790.5614013672, 14.370749473572, "Los Santos, Idlewood Pizza Stack", "There is some smoke coming from this bin, it looks like it's going to set alight!", "regular" },
		{ 1892.892578125,-1800.7572021484, 15.758026123047, "Los Santos, Old Idlewood Gas Station", "Some fools were playing with a deodorant can and a lighter, they set this skip on fire!", "regular" },
		{ 1858.4833984375,-1454.541015625, 13.395030975342, "Los Santos, next to the Skate Park", "This box van just swerved away from a bike and crashed into the wall, his car is smoking up. Please help!", "special", 414 },
		{ -76.41796875, -1593.662109375, 2.6171875, "Flint Intersection, trailer park LS South-West.", "There's smoke coming from a trailer park...you guys might want to check this!" },
		{ 1706.869140625,-546.01953125,35.386379241943, "Red County, Interstate 25", "This plane just landed on the highway, its engine is smoking up!", "regular", 513 },
		{ 2499.7451171875,-1670.771484375,13.348224639893, "Los Santos, Grove Street", "This dune buggy just came racing up the street and then the engine blew up, there is a lot of black smoke and can see fire", "regular", 568 },
		{ 2713.423828125,-2049.33984375,13.4275598526, "Los Santos, South Street - Playa Del Seville, near Sun Street", "One of our trucks just left our chemical plant and burst into flames, there is some chemicals in that truck.. Come quick!", "special", 573 },
		{ 1873.32421875,-2497.193359375,13.5546875, "Los Santos International, Runway A!", "We've got an emergency landing, the plane's engine is malfunctioning and the engine is due to set alight! We need an engine here quickly!", "regular", 577 },
		{  2295.1318359375, -1693.37109375, 13.517011642456, "The alleyway behind Ganton Gym!", "Some people just came running out of the alleyway. I can see smoke!, ", "regular", 516 },
		{  1961.8642578125, -1955.6796875, 13.751493453979, "El Corona train tracks", "One of our trains has reported the smell of smoke coming from under the train. We'd like someone to check it out before it turns into something worse.", "special", 538 },
		{  1021.109375, -1916.8505859375, 12.66853427887, "The market stalls South of the DMV.", "Somebody knocked the BBQ over and set the stall alight, the fire isn't huge, but we've got nothing to put it out with!", "regular", },
		{  1303.5419921875, 173.9775390625, 20.4609375, "Montgomery Trailer Park, on the South side.", "Some kids just set some rubbish on fire, it's spread to the trees.", "regular", },
		{  2161.294921875, -99.8544921875, 2.75, "The small beach, Western side of Palamino Creek.", "Some shed is on fire. Pretty big.", "regular", },
		{  2352.0224609375, -650.1396484375, 128.0546875, "North Rock.", "Bonfire gone wrong, it's spread into the wooden shack.", "regular", },
		{  1874.126953125, -1313.33203125, 14.500373840332, "The construction site on the Northern side of the Skate Park.", "Structure fire.", "regular", 524 },
		{ 2116.5451660156, -1790.5614013672, 14.370749473572, "Los Santos, Idlewood Pizza Stack", "There is some smoke coming from this bin, it looks like it's going to set alight!", "regular", },
		{ 1892.892578125, -1800.7572021484, 15.758026123047, "Los Santos, Old Idlewood Gas Station", "Some fools were playing with a deodorant can and a lighter, they set this skip on fire!", "regular", },
		{ 1858.4833984375, -1454.541015625, 13.395030975342, "Los Santos, next to the Skate Park", "This box van just swerved away from a bike and crashed into the wall, his car is smoking up. Please help!", "special", 414 },
		{ -76.41796875, -1593.662109375, 2.6171875, "Flint Intersection, trailer park LS South-West.", "There's smoke coming from a trailer park...you guys might want to check this!" },
		{ 1706.869140625, -546.01953125, 35.386379241943, "Red County, Interstate 25", "This plane just landed on the highway, its engine is smoking up!", "regular", 513 },
		{ 2499.7451171875, -1670.771484375, 13.348224639893, "Los Santos, Grove Street", "This dune buggy just came racing up the street and then the engine blew up, there is a lot of black smoke and can see fire", "regular", 568 },
		{ 2713.423828125, -2049.33984375, 13.4275598526, "Los Santos, South Street - Playa Del Seville, near Sun Street", "One of our trucks just left our chemical plant and burst into flames, there is some chemicals in that truck.. Come quick!", "special", 573 },
		{ 1873.32421875, -2497.193359375, 13.5546875, "Los Santos International, Runway A!", "We've got an emergency landing, the plane's engine is malfunctioning and the engine is due to set alight! We need an engine here quickly!", "regular", 577 },
		{ 595.06, -535.41, 17, "Dillimore, behind the Police Building.", "There's a vehicle smoking, possibly coming on fire!", "regular", 401 },
		{ 658.0908, -439.372, 16, "Dillimore, the bins behind the bar at north!", "We try to extinguish it and it doesn't work! They're on fire!" },
		{ -76.41796875, -1593.662109375, 2.6171875, "Flint Intersection, trailer park LS South-West.", "There's smoke coming from a trailer park...you guys might want to check this!" },
		{ 2351.08984375, -653.4462890625, 128.0546875, "North Rock, the shack on top of the hill!", "I'm not sure, but it's worth checking it out! There's much smoke coming out of there!", "special", 410 },
		{ 2626.9677734375, -846.2607421875, 84.179885864258, "North Rock, by a shack on the hill!", "A tree just got on fire, god damn California sun!" },
		{ 2859.03515625, -598.166015625, 10.928389549255, "Interstate 425 East, by the highway.", "A car seems heavily damaged, smoking, and there's a fire next to it! Hurry!", "regular", 420 },
		{ 392.51171875, -1924.5078125, 10.25, "Santa Monica Pier.", "One of the wood building got on fire!", "special" },
		{ -104.0712890625, -331.7822265625, 1.4296875, "Red county, blueberry warehouse.", "Not sure what hit the tank, but I feel fire will come out soon!", "regular", 403 },
		{ 90.162109375, -286.1953125, 1.578125, "Red county, blueberry warehouse.", "Not sure what hit the tank, but I feel fire will come out soon!", "regular", 403 },
		{ 1368.8466796875, -291.900390625, 1.7080450057983, "Mulholland canal!", "A skimmer just crashed here by the beach!", "regular", 460 },
}

function loadthescript()
    outputDebugString("LeFire Script loaded ...")
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), loadthescript)

function fdfire()
    math.randomseed(getTickCount())
    local randomfire = math.random(1,#fireTable)
    local fX, fY, fZ = fireTable[randomfire][1],fireTable[randomfire][2],fireTable[randomfire][3]
            local playersOnFireTeam = exports.factions:getPlayersInFaction(2)
            for k, v in ipairs (playersOnFireTeam) do
                outputChatBox("[RADIO] This is dispatch. We received an anonymous call regarding a major incident.",v,245, 40, 135)
				outputChatBox("[RADIO] Incident is as follow: "..fireTable[randomfire][5],v,245, 40, 135)
                outputChatBox("[RADIO] Location: "..fireTable[randomfire][4].." Please report there immediately. We added a blip on your GPS.",v,245, 40, 135)
            end

            -- You can get table info like this below, i set the variable above to make it shorter to call from.
            --outputDebugString("x:"..fireTable[randomfire][1].." y:"..fireTable[randomfire][2].." z:"..fireTable[randomfire][3])
			if (fireTable[randomfire][7]) then
				local fireveh = createVehicle(fireTable[randomfire][7], fX, fY, fZ)
				setTimer( function ()
					destroyElement(fireveh)
				end, 1800000, 1)
				blowVehicle(fireveh)
			end
			if (fireTable[randomfire][6] == "special") then
				local fireElem1 = createObject(fireModel,fX+2,fY+2,fZ)
				setElementCollisionsEnabled(fireElem,false)
				local col1 = createColSphere(fX+2,fY+2,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem1)
					destroyElement(col1)
				end, 420000, 1)

				local fireElem2 = createObject(fireModel,fX+4,fY+4,fZ+2)
				setElementCollisionsEnabled(fireElem,false)
				local col2 = createColSphere(fX+4,fY+4,fZ+2,2)
				setTimer ( function ()
					destroyElement(fireElem2)
					destroyElement(col2)
				end, 420000, 1)

				local fireElem3 = createObject(fireModel,fX-2,fY-2,fZ)
				setElementCollisionsEnabled(fireElem,false)
				local col3 = createColSphere(fX-2,fY-2,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem3)
					destroyElement(col3)
				end, 420000, 1)

				local fireElem4 = createObject(fireModel,fX-4,fY-4,fZ+2)
				setElementCollisionsEnabled(fireElem,false)
				local col4 = createColSphere(fX-4,fY-4,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem4)
					destroyElement(col4)
				end, 420000, 1)

				local fireElem5 = createObject(fireModel,fX,fY-4,fZ+2)
				setElementCollisionsEnabled(fireElem,false)
				local col5 = createColSphere(fX,fY-4,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem5)
					destroyElement(col5)
				end, 420000, 1)

				local fireElem6 = createObject(fireModel,fX-4,fY,fZ+2)
				setElementCollisionsEnabled(fireElem,false)
				local col6 = createColSphere(fX-4,fY,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem6)
					destroyElement(col6)
				end, 420000, 1)
			end
            outputDebugString(fX.." "..fY.." "..fZ)
			-- Fire sync
			local fireElem = createObject(fireModel,fX,fY,fZ)
			setElementCollisionsEnabled(fireElem,false)
			local col = createColSphere(fX,fY,fZ+1,2)
			setTimer ( function ()
				destroyElement(fireElem)
				destroyElement(col)
			end, 420000, 1)


            triggerClientEvent("startTheFire", getRootElement(),fX,fY,fZ)
            local blip = createBlip(fX,fY,fZ, 43, 0, 0, 0, 255)
            setTimer ( function ()
                destroyElement(blip)
            end, 900000, 1)

			isFireOn = true
			setTimer ( function ()
				isFireOn = false
			end, 900000, 1)
end

-- /randomfire - Start a random fire from the table
function randomfire (thePlayer)
	if ( exports.integration:isPlayerTrialAdmin ( thePlayer ) ) then
		outputDebugString(isFireOn)
		if (isFireOn) then
			outputChatBox ("AdmCMD: There is already a fire. Use /cancelfire or wait 30 minutes.", thePlayer,255,0,0)
		else
			fdfire()
			outputChatBox ("AdmCMD: You have random triggered a fire for FD!", thePlayer,255,0,0)
			outputChatBox ("AdmCMD: Type /cancelfire to cancel it!", thePlayer,255,0,0)
		end
	end
end
addCommandHandler("randomfire", randomfire)

-- /cancelfire - Stops the whole fire process (restarts the resource)
function cancelrandomfire (thePlayer)
	if ( exports.integration:isPlayerTrialAdmin ( thePlayer ) ) then
		outputDebugString(isFireOn)
		if (isFireOn) then
			local thisResource = getThisResource()
			outputChatBox ("AdmCMD: You have stopped the random fire for FD!", thePlayer,255,0,0)
			outputChatBox ("AdmCMD: It may take up to five minutes before it is fully cancelled.", thePlayer,255,0,0)
			restartResource(thisResource)
			isFireOn = false
		else
			outputChatBox ("AdmCMD: There is no fire started. Use /randomfire to start it.", thePlayer,255,0,0)
		end
	end
end
addCommandHandler("cancelfire", cancelrandomfire)
