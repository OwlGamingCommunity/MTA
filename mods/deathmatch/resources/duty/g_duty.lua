DutyColShapes = { }
function createDutyColShape(posX, posY, posZ, size, interior, dimension, factionID, locationID)
    if type(DutyColShapes[tonumber(factionID)]) ~= "table" then
        DutyColShapes[tonumber(factionID)] = { }
    end

    if not DutyColShapes[tonumber(factionID)][tonumber(locationID)] then
       tempShape = createColSphere(tonumber(posX), tonumber(posY), tonumber(posZ), tonumber(size))
	   setElementDimension(tempShape, tonumber(dimension) or 0)
	   setElementInterior(tempShape, tonumber(interior) or 0)
	   if tempShape then
    	   DutyColShapes[tonumber(factionID)][tonumber(locationID)] = tempShape
    	   setElementData(resourceRoot, "DutyColShapes", DutyColShapes)
    	   return true
        end
    end
end

function destroyDutyColShape(factionID, locationID)
	if DutyColShapes[tonumber(factionID)] and DutyColShapes[tonumber(factionID)][tonumber(locationID)] then
		destroyElement(DutyColShapes[tonumber(factionID)][tonumber(locationID)])
		DutyColShapes[tonumber(factionID)][tonumber(locationID)] = nil
		setElementData(resourceRoot, "DutyColShapes", DutyColShapes)
		return true
	end
end

-- -------------------------- --
-- General checking functions -- Revised by Chaos for OwlGaming < Old way was shitty less loops now
-- -------------------------- --

function fetchAvailablePackages( targetPlayer )
    local availablePackages = { }
    local allowList = { }
    local faction = getElementData(targetPlayer, "faction")
    local factionDuty = getElementData(resourceRoot, "factionDuty")
    local factionLocations = getElementData(resourceRoot, "factionLocations")
    local DutyColShapes = getElementData(resourceRoot, "DutyColShapes") or {}

    local resource = getResourceRootElement(getResourceFromName("factions"))
    if resource then
        allowListTemp = getElementData(resource, "dutyAllowTable")
    end

    for factionID, _ in pairs(faction) do
        if factionDuty[factionID] then
            for i, factionPackage in pairs ( factionDuty[factionID] ) do -- Loop all the faction packages
                local found = false
                for index, v in pairs ( factionPackage[4] ) do -- Loop all the colshapes of the factionpackage
                    if type(DutyColShapes[factionID]) ~= 'table' then
                        DutyColShapes[factionID] = {}
                    end

                	if isElement(DutyColShapes[factionID][tonumber(index)]) then
                    	if isElementWithinColShape( targetPlayer, DutyColShapes[factionID][tonumber(index)] ) then
                      	  found = true
                      	  break  -- We found this package already, no need to search the other colshapes
                   	 	end
                   	end
                end

                local veh = getPedOccupiedVehicle(targetPlayer) -- Still can't find it? Lets see if they are in a duty vehicle
                if not found and veh then
                	local vehid = getElementData(veh, "dbid")
                	for k,v in pairs(factionLocations[factionID]) do
                		if tonumber(vehid) == tonumber(v[9]) then -- Yep vehicle ID matches!
                    		found = true
                    	end
                    end
                end

                if found and canPlayerUseDutyPackage(targetPlayer, i, factionID) then
                    factionPackage.factionID = factionID
                    table.insert(availablePackages, factionPackage)
                end
            end
        table.insert(allowList, allowListTemp[factionID][3])
        end
    end
    return availablePackages, allowList
end

function getGrant(thePlayer, grantID, factionID)
	local factionID = tonumber(factionID)
	local factionDuty = getElementData(resourceRoot, "factionDuty")
    if factionDuty[factionID] then
	   return factionDuty[factionID][tonumber(grantID)]
    end
end

function canPlayerUseDutyPackage(targetPlayer, packageID, factionID)
	local package = tonumber(packageID)
    local playerPackagePermission = getElementData(targetPlayer, "faction")[factionID].perks
    if playerPackagePermission then
        for index, permissionID in ipairs(playerPackagePermission) do
            if (tonumber(permissionID) == tonumber(package)) then
                return true
            end
        end
    end
    return false
end

function getFactionPackages( factionID )
    if not factionID or not tonumber( factionID ) then
        return false
    end
    local factionDuty = getElementData(resourceRoot, "factionDuty")

    if type(factionDuty) ~= 'table' then
        factionDuty = {}
        factionDuty[tonumber(factionID)] = {}
    end

    return factionDuty[tonumber(factionID)]
end
addEvent("onPlayerDuty", true)
