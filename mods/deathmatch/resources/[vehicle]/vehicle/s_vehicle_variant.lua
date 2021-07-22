local variants =
{
	-- [model] = {{first variations}, {second variations}}
	[416] = {{0,1}}, -- Ambulance
	[435] = {{-1,0,1,2,3,4,5}}, -- Trailer
	[450] = {{-1,0}}, -- Trailer 2
	[607] = {{-1,0,1,2}}, -- Baggage Trailer
	[485] = {{-1,0,1,2}}, -- Baggage
	[433] = {{-1,0,1}}, -- Barracks
	[499] = {{-1,0,1,2,3}}, -- Benson
	[581] = {{0,1,2},{3,4}}, -- BF-400
	[424] = {{-1,0}}, -- BF Injection
	[504] = {{0,1,2,3,4,5}}, -- Bloodring
	[422] = {{-1,0,1}}, -- Bobcat
	[482] = {{-1,0}}, -- Burrito
	[457] = {{-1,0,1,2},{-1,3,4,5}}, -- Caddy
	[483] = {{-1,1}}, -- Camper
	[415] = {{-1,0,1}}, -- Cheetah
	[437] = {{0,1}}, -- Coach
	[472] = {{-1,0,1,2}}, -- Coast Guard
	[521] = {{0,1,2},{3,4}}, -- FCR900
	[407] = {{0,1,2}}, -- Firetruck
	[455] = {{-1,0,1,2}}, -- Flatbed
	[434] = {{-1,0}}, -- Hotknife
	[502] = {{0,1,2,3,4,5}}, -- Hotring A
	[503] = {{0,1,2,3,4,5}}, -- Hotring B
	[571] = {{0}}, -- Kart
	[595] = {{-1,0,1}}, -- Launch
	[484] = {{-1,0}}, -- Marquis
	[500] = {{-1,0,1}}, -- Mesa
	[556] = {{-1,0,1,2}}, -- Monster A
	[557] = {{-1,1}}, -- Monster B
	[423] = {{-1,0,1}}, -- Mr. Whoopee
	[414] = {{-1,0,1,2,3}}, -- Mule
	[522] = {{0,1,2},{3,4}}, -- NRG-500
	[470] = {{-1,0,1,2}}, -- Patriot
	[404] = {{-1,0}}, -- Perennial
	[600] = {{-1,0,1}}, -- Picador
	[413] = {{-1,0}}, -- Pony
	[453] = {{-1,0,1}}, -- Reefer
	[442] = {{-1,0,1,2}}, -- Romero
	[440] = {{-1,0,1,2,3,4,5}}, -- Rumpo
	[543] = {{-1,0,1,2,3}}, -- Sadler
	[605] = {{-1,0,1,2,3}}, -- Sadler (shit)
	[428] = {{-1,0,1}}, -- Securicar
	[535] = {{0,1}}, -- Slamvan
	[439] = {{-1,0,1,2}}, -- Stallion
	[506] = {{-1,0}}, -- Super GT
	[601] = {{0,1,2,3}}, -- SWAT Van
	[459] = {{-1,0}}, -- ?
	[408] = {{-1,0}}, -- Trashmaster
	[583] = {{-1,0,1}}, -- Tug
	[552] = {{-1,0,1}}, -- Utility Van
	[478] = {{-1,0,1,2}}, -- Walton
	[555] = {{-1,0}}, -- Windsor
	[456] = {{-1,0,1,2,3}}, -- Yankee
	[477] = {{-1,0}}, -- ZR350
}

local function uc(num)
	return num == -1 and 255 or num
end

local function nuc(num)
	return num == 255 and -1 or num
end

function getRandomVariant(model)
	local data = variants[model] or {}
	local first = data[1] or {-1}
	local second = data[2] or {-1}
	
	return uc(first[math.random(1, #first)]), uc(second[math.random(1, #second)])
end

function isValidVariant(model, a, b)
	a,b = nuc(a),nuc(b)
	
	-- Can't have a part double
	if a ~= -1 and a == b then
		return false
	end
	
	local data = variants[model] or {}
	local first = data[1] or {-1}
	local second = data[2] or {-1}
	
	-- check if first variant is okay
	local found = false
	for k, v in ipairs(first) do
		if v == a then
			found = true
			break
		end
	end
	if not found then return false end
	
	-- check if second variant is okay
	for k, v in ipairs(second) do
		if v == b then
			return true
		end
	end
	return false
end

function cabrioletToggleRoof(theVehicle) --Exciter
	if isCabriolet(theVehicle) then
		local data = g_cabriolet[getElementModel(theVehicle)]
		local currentVariant, currentVariant2 = getVehicleVariant(theVehicle)
		local newVariant
		if(currentVariant == data[1]) then
			newVariant = data[2] --set closed
		else
			newVariant = data[1] --set open
		end
		local engineState = getVehicleEngineState(theVehicle)
		setVehicleVariant(theVehicle,newVariant,255)

		--fix for vehicles auto-starting engine when variant is changed
		setVehicleEngineState(theVehicle, engineState)
	end
end
addEvent("vehicle:toggleRoof", true)
addEventHandler("vehicle:toggleRoof", getRootElement( ), cabrioletToggleRoof)