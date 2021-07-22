function vehicleBlown()
    exports.anticheat:changeProtectedElementDataEx(source, "lspd:siren", false)
    setVehicleSirensOn ( source , false )
end
addEventHandler("onVehicleRespawn", getRootElement(), vehicleBlown)

--[[

1 - PD Wail
2 - PD/Firetruck Priority
3 - PD/Firetruck Yelp
4 - Horn
5 - Firetruck Wail
6 - Ambulance Wail
7 - Ambulance Priority
8 - Ambulance Yelp

]]

function setSirenState(type)
    if exports.global:hasItem(source, 85) or exports.global:hasItem(source, 261) or exports.global:hasItem(source, 269) then -- sirens
    	if type == "horn" then
            exports.anticheat:changeProtectedElementDataEx(source, "lspd:siren", 4)
            return
        elseif type == "wail" then
            setVehicleSirensOn (source, true)
            exports.anticheat:changeProtectedElementDataEx(source, "lspd:siren", (exports.global:hasItem(source, 269) and 6) or (exports.global:hasItem(source, 261) and 5) or 1)
            return
        elseif type == "priority" then
            exports.anticheat:changeProtectedElementDataEx(source, "lspd:siren", (exports.global:hasItem(source, 269) and 7) or 2)
            setVehicleSirensOn (source, true)
            return
        elseif type == "yelp" then
            exports.anticheat:changeProtectedElementDataEx(source, "lspd:siren", (exports.global:hasItem(source, 269) and 8) or 3)
            setVehicleSirensOn (source, true)
            return
    	end
        exports.anticheat:changeProtectedElementDataEx(source, "lspd:siren", false)
        setVehicleSirensOn ( source , false )
    end
end
addEvent( "lspd:setSirenState", true )
addEventHandler( "lspd:setSirenState", getRootElement(), setSirenState )

addEventHandler( "onVehicleExit", getRootElement(), function()
	if getElementData(source, "lspd:siren") and getElementData(source, "lspd:siren") ~=  1 and getElementData(source, "lspd:siren") ~= 5 then
		exports.anticheat:changeProtectedElementDataEx(source, "lspd:siren", (exports.global:hasItem(source, 269) and 6) or (exports.global:hasItem(source, 261) and 5) or 1)
        setVehicleSirensOn (source, true)
    end
end)

function isOwnedByFactionType(vehicle, factiontypes)
	local vehicleFactionID = getElementData(vehicle, "faction")
	local vehicleFactionElement = exports.pool:getElement("team", vehicleFactionID)
	if vehicleFactionElement then
		local vehicleFactionType = getElementData(vehicleFactionElement, "type")
		for key, factionType in ipairs(factiontypes) do
			if factionType == vehicleFactionType then
				return true
			end
		end
	end
	return false
end

function addSirens (player, seat)
    if player and (seat==0) then
		if (exports.global:hasItem(source, 140)) and not (exports.global:hasItem(source, 61)) then -- Orange siren lights
			local veh_model = getVehicleName(source)
			local orangeStrobes = getOrangeStrobes()
			if (orangeStrobes[veh_model] == nil) then
				--vehicle doesn't have strobes scripted
			else
				local total = orangeStrobes[veh_model]["total"]
				addVehicleSirens(source,total,2, false, true, true, true)
				for id, desc in pairs(orangeStrobes[veh_model]) do
					if (id~="total") then
						setVehicleSirens(source, id, desc[1], desc[2], desc[3], desc[4], desc[5], desc[6], desc[7], desc[8])
					end
				end
			end
		elseif (exports.global:hasItem(source, 61)) and not (exports.global:hasItem(source, 140)) then -- Emergency siren lights
			local veh_model = getVehicleName(source)
			local emergencyStrobes = getEmergencyStrobes()
			if (emergencyStrobes[veh_model] == nil) then
				--vehicle doesn't have strobes scripted
			else
				local total = emergencyStrobes[veh_model]["total"]
				addVehicleSirens(source,total,2, false, true, true, true)
				for id, desc in pairs(emergencyStrobes[veh_model]) do
					if (id~="total") then
						setVehicleSirens(source, id, desc[1], desc[2], desc[3], desc[4], desc[5], desc[6], desc[7], desc[8])
					end
				end
			end
		else -- PreInstalled sirens such as police cruisers, fire engines and ambulances.
			local veh_model = getVehicleName(source)
			local installedStrobes = getPreInstalledStrobes()
			if (installedStrobes[veh_model] == nil) then
				--vehicle doesn't have strobes scripted
			else
				local total = installedStrobes[veh_model]["total"]
				addVehicleSirens(source,total,2, false, true, true, true)
				for id, desc in pairs(installedStrobes[veh_model]) do
					if (id~="total") then
						setVehicleSirens(source, id, desc[1], desc[2], desc[3], desc[4], desc[5], desc[6], desc[7], desc[8])
					end
				end
			end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), addSirens)
