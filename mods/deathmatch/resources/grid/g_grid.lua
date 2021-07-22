--Shared script: The grid
--Last updated 11.12.2017 by Exciter

function isSimDimension(dimension)
	dimension = tonumber(dimension)
	if not dimension then return false end
	if dimension == 0 or dimension > 100 and dimension < 10000 then --only dimensions 101-9999 and 0, are considered sims
		return true
	else
		return false
	end
end

function getElementCurrentSim(element, outsideOnly)
	if not isElement(element) then return false end
	local interior = getElementInterior(element)
	local dimension = getElementDimension(element)
	if interior == 0 then --outside world
		if isSimDimension(dimension) then
			return dimension
		else
			return false
		end
	elseif(dimension > 20000 and not outsideOnly) then --vehicle interior
		return getVehicleInteriorSim(dimension)
	elseif(dimension > 0 and not outsideOnly) then --property interior
		return getInteriorSim(dimension)
	else
		return false --none or unknown sim
	end
end

function getInteriorSim(dimension)
	if dimension > 20000 then return getVehicleInteriorSim(dimension) end
	if dimension < 1 then return false end
	local dbid, entrance = exports.interior_system:findProperty(nil, dimension)
	if entrance then
		if getElementInterior(entrance) == 0 then
			return getElementDimension(entrance)
		else
			local dim = getElementDimension(entrance)
			if dim > 20000 then
				return getVehicleInteriorSim(dim)
			elseif dim < 1 then
				return false --not found
			end
			local maxExecution = 10
			local i = 0
			local parent = entrance
			while parent do
				i = i + 1
				parent = exports.interior_system:findParent(parent)
				if getElementInterior(parent) == 0 then
					return getElementDimension(parent)
				else
					dim = getElementDimension(parent)
					if dim > 20000 then
						return getVehicleInteriorSim(dim)
					elseif dim < 1 then
						return false --not found
					end
				end
				if i > maxExecution then
					outputDebugString("[GRID] Interior ID "..tostring(dim)..": Maximum number of parent interiors reached ("..tostring(maxExecution+3)..").", 2)
					return false --abort, max attempts reached (don't want to spend too much time)
				end
			end
		end
	else
		return false --interior entrance not found
	end
end

function getVehicleInteriorSim(dimension)
	if dimension < 20001 then return getInteriorSim(dimension) end
	local vin = dimension - 20000
	local vehicle = exports.pool:getElement("vehicle", vin)
	if vehicle then
		if getElementInterior(vehicle) == 0 then
			return getElementDimension(vehicle)
		else
			return getInteriorSim(getElementDimension(vehicle))
		end
	else
		return false --vehicle not found
	end
end

function isSimCrossingRequiredForTeleport(source, target)
	-- source: element to teleport
	-- target: element to teleport to OR integer of sim to teleport to
	if isElement(source) then
		local sourceSim = getElementCurrentSim(source)
		local targetSim
		if isElement(target) then
			targetSim = getElementCurrentSim(element)
		elseif tonumber(target) then
			targetSim = tonumber(target)
		else
			return false
		end
		if sourceSim and targetSim then
			if targetSim ~= sourceSim then
				return true
			end
		end
	end
	return false
end

function getSimName(sim)
	if sim == 0 or sim == 5050 then
		return "San Andreas"
	else
		if isSimDimension(sim) then
			return "Region "..tostring(sim)
		else
			return false
		end
	end
end