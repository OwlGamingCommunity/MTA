-- [[ Part of the tinted vehicles ]]
windowless = { [568]=true, [601]=true, [424]=true, [457]=true, [480]=true, [485]=true, [486]=true, [528]=true, [530]=true, [531]=true, [532]=true, [571]=true, [572]=true }
roofless = { [568]=true, [500]=true, [424]=true, [457]=true, [480]=true, [485]=true, [486]=true, [530]=true, [531]=true, [533]=true, [536]=true, [555]=true, [571]=true, [572]=true, [575]=true }

-- [[ Globals ]]
enginelessVehicle = { [510]=true, [509]=true, [481]=true }
lightlessVehicle = { [592]=true, [577]=true, [511]=true, [548]=true, [512]=true, [593]=true, [425]=true, [520]=true, [417]=true, [487]=true, [553]=true, [488]=true, [497]=true, [563]=true, [476]=true, [447]=true, [519]=true, [460]=true, [469]=true, [513]=true, [472]=true, [473]=true, [493]=true, [595]=true, [484]=true, [430]=true, [453]=true, [452]=true, [446]=true, [454]=true, [510]=true, [509]=true, [481]=true }
locklessVehicle = { [581]=true, [509]=true, [481]=true, [462]=true, [521]=true, [463]=true, [510]=true, [522]=true, [461]=true, [448]=true, [468]=true, [586]=true }
armoredCars = { [427]=true, [528]=true, [432]=true, [601]=true, [428]=true }
platelessVehicles = { [592] = true, [553] = true, [577] = true, [488] = true, [511] = true, [497] = true, [548] = true, [563] = true, [512] = true, [476] = true, [593] = true, [447] = true, [425] = true, [519] = true, [520] = true, [460] = true, [417] = true, [469] = true, [487] = true, [513] = true, [509] = true, [481] = true, 
[510] = true, [472] = true, [473] = true, [493] = true, [595] = true, [484] = true, [430] = true, [453] = true, [452] = true, [446] = true, [454] = true, [571] = true }
bike = { [581]=true, [509]=true, [481]=true, [462]=true, [521]=true, [463]=true, [510]=true, [522]=true, [461]=true, [448]=true, [468]=true, [586]=true, [536]=true, [575]=true, [567]=true, [480]=true, [555]=true }

g_cabriolet = { --Exciter
	--[vehModel] = {variantOpen, variantClosed}
	--Note: -1 = 255
	[500] = {1,0}, --Mesa
	[439] = {255,1}, --Stallion
	[506] = {255,0}, --Super GT
	[555] = {255,0}, --Windsor
}
hasWindows = {
	[573] = true,
}

function getArmoredCars( )
	return armoredCars
end

function isVehicleImpounded(theVehicle)
	if (type(getElementData(theVehicle, "Impounded")) == "number") then
		if (getElementData(theVehicle, "Impounded") ~= 0) then
			return true
		end
	end
	return false
end

function isVehicleWindowUp(theVehicle, real)
	if (hasVehicleWindows(theVehicle)) then
		if (hasVehicleRoof(theVehicle)) or (real) then
			local windowState = getElementData(theVehicle, "vehicle:windowstat")
			if (tonumber(windowState) == 0) then
				return true
			end
		end
	end
	return false
end

function hasVehicleWindows(theVehicle)
	if (getVehicleType(theVehicle) == "Automobile") or hasWindows[getElementModel(theVehicle)] then
		local vehicleModel = getElementModel(theVehicle)
		if not windowless[vehicleModel] then
			return true
		end
	end
	return false
end

function hasVehicleRoof(theVehicle)
	if (getVehicleType(theVehicle) == "Automobile") or hasWindows[getElementModel(theVehicle)] then
		local vehicleModel = getElementModel(theVehicle)
		if not roofless[vehicleModel] then
			return true
		end
	end
	return false
end

function hasVehiclePlates(theVehicle)
	return not (platelessVehicles[theVehicle] or platelessVehicles[getElementModel(theVehicle)] or false)
end

function hasVehicleEngine(theVehicle)
	return not enginelessVehicle[getElementModel(theVehicle)]
end

function hasVehicleLights(theVehicle)
	return not lightlessVehicle[getElementModel(theVehicle)]
end

function isCabriolet(theVehicle) --Exciter
	local model = getElementModel(theVehicle)
	if g_cabriolet[model] then
		local variant, variant2 = getVehicleVariant(theVehicle)
		if(g_cabriolet[model][1] == variant or g_cabriolet[model][2] == variant) then
			return true
		end
	end
	return false
end