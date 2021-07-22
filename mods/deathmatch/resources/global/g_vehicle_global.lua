--MAXIME
local gvn = getVehicleName
function getVehicleName(theVehicle)
	if not theVehicle or (getElementType(theVehicle) ~= "vehicle") then
		return "?"
	end
	local name = gvn(theVehicle)
	local year = getElementData(theVehicle, "year")
	local brand = getElementData(theVehicle, "brand")
	local model = getElementData(theVehicle, "maximemodel")
	if year and brand and model then
		name = tostring(year).." "..tostring(brand).." "..tostring(model)
	end
	return name
end