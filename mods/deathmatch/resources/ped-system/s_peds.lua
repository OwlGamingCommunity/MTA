--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Server side script: Core script with basic functionalities, join/initialize, utility functions, etc.
--Last updated 01.01.2015 by Exciter
--Copyright 2008-2011, The Roleplay Project (www.roleplayproject.com)

local tempPeds = {}
local pedMoveTimer = {}
local pedMoveTimerTO = {}
local null = mysql_null()
local toLoad = { }
local threads = { }

--[[
NPC BEHAVIOURS:
0: immortal	: (almost) never dies
1: scared	: will put hands up or crouch down upon being attacked
2: defending	: will try to shoot back upon being attacked (given it has a weapon, otherwise punch)
3: immortal	: (almost) never dies (duplicate to 0)
4: pannicing	: will run away in pannic upon being attacked
5: public transport user : will enter any operated trams
--]]

--skins to random select from for peds with no set skin id
local skinsMale = {7,14,15,17,20,21,24,25,26,29,35,36,37,44,46,57,58,59,60,68,72,98,147,185,186,187,223,227,228,234,235,240,258,259}
local skinsFemale = {9,11,12,40,41,55,56,69,76,88,89,91,93,129,130,141,148,150,151,190,191,192,193,194,196,211,215,216,219,224,225,226,233,263}


function loadAllPeds(res)
	local mysql = exports.mysql
	-- Reset player in vehicle states
	local players = exports.pool:getPoolElementsByType("player")
	for key, value in ipairs(players) do
		exports.anticheat:changeProtectedElementDataEx(value, "realinvehicle", 0, false)
	end
	

	local result = mysql:query("SELECT id FROM `peds` ORDER BY `id` ASC")
	if result then
		while true do
			local row = mysql:fetch_assoc(result)
			if not row then break end
			
			toLoad[tonumber(row["id"])] = true
		end
		mysql:free_result(result)
		
		for id in pairs( toLoad ) do
			
			local co = coroutine.create(loadOnePed)
			coroutine.resume(co, id, true)
			table.insert(threads, co)
		end
		setTimer(resume, 1000, 4)
	else
		outputDebugString( "loadAllPeds failed" )
	end
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllPeds)

function resume()
	for key, value in ipairs(threads) do
		if coroutine.status(value) ~= 'dead' then
			coroutine.resume(value)
		end
	end
end

function reloadPed(id)
	outputDebugString("reloadPed("..tostring(id)..")")
	local thePed = exports.pool:getElement("ped", tonumber(id))
	outputDebugString("ped = "..tostring(thePed))
	if(thePed) then
		destroyElement(thePed)
	end
	loadOnePed(id, false)
	return true
end

function loadOnePed(id, hasCoroutine)
	local mysql = exports.mysql
	if (hasCoroutine==nil) then
		hasCoroutine = false
	end
	
	local row = mysql:query_fetch_assoc("SELECT * FROM peds WHERE id = " .. mysql:escape_string(id) .. " LIMIT 1" )
	if row then
		
		if (hasCoroutine) then
			coroutine.yield()
		end
		
		for k, v in pairs( row ) do
			if v == null then
				row[k] = nil
			else
				row[k] = tonumber(row[k]) or row[k]
			end
		end
		
		--set/get gender
		local gender = row.gender

		--set/get skin
		local skin = row.skin
		if skin then
			if not gender then
				gender = getGenderFromSkin(skin)
			end
		else
			if not gender then	
				gender = getRandomName("gender")
			end
			if(gender == 0) then
				skin = skinsMale[math.random(#skinsMale)]
			elseif(gender == 1) then
				skin = skinsFemale[math.random(#skinsFemale)]
			end
		end
		
		local ped = createPed(skin, row.x, row.y, row.z, row.rotation, row.synced == 1)
		if ped then
			exports.anticheat:changeProtectedElementDataEx(ped, "dbid", row.id)
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.dbid", row.id)
			exports.pool:allocateElement(ped, row.id, true)
								
			setElementDimension(ped, row.dimension)
			setElementInterior(ped, row.interior)
			
			--for ped respawning purposes - Only needed for non-dbid peds!
			--exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.spawnpos", row.x..","..row.y..","..row.z..","..row.rotation..","..row.interior..","..row.dimension)
		
			--set/get name
			local pedname = row.name
			if not pedname then
				pedname = getRandomName("full", gender)
			end
			
			if row.type then
				exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.type", row.type)
			end
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.name", pedname)
			exports.anticheat:changeProtectedElementDataEx(ped, "ped:name", pedname) -- For chat system
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.gender", gender)
			exports.anticheat:changeProtectedElementDataEx(ped, "name", pedname) --for owl
			if row.nametag then
				exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.nametag", true)
				exports.anticheat:changeProtectedElementDataEx(ped, "nametag", true) --for owl
			end
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.behav", row.behaviour)
			if row.money then --if ped have money, set the amount
				exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.money", row.money)
			else --if ped does not have money but has a owner, set it so any expenses for the ped is subtracted from the owner
				if(row.owner_type ~= 0 and row.owner ~= 0) then
					exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.owner_type", row.owner_type)
					exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.owner", row.owner)
				end
			end
			
			if(tonumber(row.frozen) == 1) then
				setElementFrozen(ped, true)
			end
			
			if row.animation then
				exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.animation", row.animation)
				--outputDebugString(tostring(row.animation))
				local animTable = exports.global:split(row.animation, ";")
				local animBlock = animTable[1]
				local anim = animTable[2]
				if animBlock and anim then
					setPedAnimation(ped, animBlock, anim)
				end
			end
			
			local badges = {}
			badges = exports['item-system']:getBadges()
			--outputDebugString(tostring(#badges).." badges")
			for k,v in pairs(badges) do
				local hasItem = exports['item-system']:hasItem(ped, k)
				if hasItem then
					local itemresult = exports['item-system']:npcUseItem(ped, k)
					--outputDebugString("ped itemresult = "..tostring(itemresult))
					break;
				end
			end
			local masks = {}
			masks = exports['item-system']:getMasks()
			for k,v in pairs(masks) do
				local hasItem = exports['item-system']:hasItem(ped, k)
				if hasItem then
					local itemresult = exports['item-system']:npcUseItem(ped, k)
					--outputDebugString("ped itemresult = "..tostring(itemresult))
					break;
				end
			end
			--exports['item-system']:updateLocalGuns(ped)
			exports.anticheat:changeProtectedElementDataEx(ped, "languages.lang1" , 1, false)
			exports.anticheat:changeProtectedElementDataEx(ped, "languages.lang1skill", 100, false)
			exports.anticheat:changeProtectedElementDataEx(ped, "languages.lang2" , 2, false)
			exports.anticheat:changeProtectedElementDataEx(ped, "languages.lang2skill", 100, false)
			exports.anticheat:changeProtectedElementDataEx(ped, "languages.current", 1, false)	
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.createdBy", row.created_by)
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.createdByUsername", exports.cache:getUsernameFromId(row.created_by))
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.createdAt", row.created_at)
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.comment", row.comment)
			exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.synced", tonumber(row.synced) == 1 or false)
			
			--DEBUG / TESTING ONLY:
			--[[
			local itemID = 65
			
			local itemresult = exports['item-system']:npcUseItem(ped, itemID)
			outputDebugString("ped itemresult = "..tostring(itemresult))
			--]]
		end
	end
end

function savePed(id)
	local mysql = exports.mysql
	if id then
		local thePed = exports.pool:getElement("ped", tonumber(id))
		if thePed then
			local money = getElementData(thePed, "rpp.npc.money")
			if money then
				local query = mysql:query_free("UPDATE peds SET money = '" .. mysql:escape_string(money) .. "' WHERE id='" .. mysql:escape_string(id) .. "'")
				if query then
					return true
				end
			end
		end
	end
	return false
end

--[[
function createPeds()
	--local nametags = getResourceState(getResourceFromName("nametags"))
	
	peds[1] = createPed(276, -2669, 637, 15, 180, false)
	setElementData(peds[1], "rpp.npc.type", "medic")
	setElementData(peds[1], "rpp.npc.name", "Dr. "..getRandomName("last"))
	setElementData(peds[1], "rpp.npc.nametag", "true")
	--if(nametags == "running") then
	--	exports.nametags:addNametag(peds[1])
	--end
	
	peds[2] = createPed(296, -1973.736328125,160.9580078125,27.694049835205,187.09727478027, false)
	setElementData(peds[2], "rpp.npc.type", "shop.clothes")
	setElementData(peds[2], "rpp.npc.name", getRandomName("full","male"))
	setElementData(peds[2], "rpp.npc.nametag", "true")
	setElementData(peds[2], "rpp.npc.behav", "1")
	--if(nametags == "running") then
	--	exports.nametags:addNametag(peds[2])
	--end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), createPeds)
--]]

function reloadWeaponForPed(ped)
	if ped then
		reloadPedWeapon(ped)
		--outputDebugString("reloaded weapon")
	end
end
addEvent("clientReloadPedWeapon", true)
addEventHandler("clientReloadPedWeapon", getRootElement(), reloadWeaponForPed)

function makeTempPed(thePlayer, command, behav, gender, skin, name) --create temporary ped (no dbid)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		if not behav then
			behav = 1
		else
			behav = tonumber(behav)
		end
		if(gender == "male") then gender = 0 elseif(gender == "female") then gender = 1 end
		if(gender ~= 1 and gender ~= 0) then
			gender = getRandomName("gender")
		end
		if not skin then
			if(gender == 0) then
				skin = skinsMale[math.random(#skinsMale)]
			elseif(gender == 1) then
				skin = skinsFemale[math.random(#skinsFemale)]
			end
		end
		local x,y,z = getElementPosition(thePlayer)
		local rx,ry,rz = getElementRotation(thePlayer)
		local int = getElementInterior(thePlayer)
		local dim = getElementDimension(thePlayer)
		local i = #tempPeds + 1
		tempPeds[i] = createPed(skin, x, y, z, rz, false)
		outputConsole("PED: "..tostring(skin)..","..tostring(x)..","..tostring(y)..","..tostring(z)..","..tostring(rz),thePlayer)
		setElementInterior(tempPeds[i], int)
		setElementDimension(tempPeds[i], dim)
		if name then
			local splitname = exports.global:split(name, "_")
			if(#splitname >= 2) then
				name = splitname[1].." "..splitname[2]
			end
		else
			name = getRandomName("full",gender)
		end
		setElementData(tempPeds[i], "dbid", -i)
		setElementData(tempPeds[i], "rpp.npc.dbid", -i)
		setElementData(tempPeds[i], "rpp.npc.name", tostring(name))
		setElementData(tempPeds[i], "rpp.npc.nametag", true)
		setElementData(tempPeds[i], "rpp.npc.behav", tostring(behav))
		setElementData(tempPeds[i], "rpp.npc.spawnpos", {x, y, z, rz, int, dim})
		setElementData(tempPeds[i], "rpp.npc.spawnpos2", tostring(x)..","..tostring(y)..","..tostring(z)..","..tostring(rz)..","..tostring(int)..","..tostring(dim))
		if(behav == 2) then
			giveWeapon(tempPeds[i], 22)
			setPedStat(tempPeds[i], 69, 999)
			setPedStat(tempPeds[i], 76, 999)
		end
		if(behav == 5) then
			local shape = createMarker(x, y, z, "cylinder", 20)
			setMarkerColor(shape, 0, 0, 0, 0)
			local result = addEventHandler("onMarkerHit", shape, npcEnterPCT)
			--outputDebugString(tostring(result).." ("..tostring(shape)..")")
			attachElements(shape, tempPeds[i], 0, 0, -1, 0, 0, 0)
		end
	end
end
addCommandHandler("ped", makeTempPed)

function createPermPed(thePlayer, command, interact) --create temporary ped (no dbid)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		local mysql = exports.mysql
		local x,y,z = getElementPosition(thePlayer)
		local rx,ry,rz = getElementRotation(thePlayer)
		local int = getElementInterior(thePlayer)
		local dim = getElementDimension(thePlayer)
		local name = "Unnamed Ped"
		local behav = 1
		local gender = 0
		local skin = 264
		local userID = getElementData(thePlayer, "account:id")
		if not interact then
			interact = ""
		end

		mysql:query_free("INSERT INTO `peds` (`name`, `type`, `x`, `y`, `z`, `rotation`, `interior`, `dimension`, `skin`, `gender`, `created_by`, `created_at`) VALUES ('"..name.."', '"..mysql:escape_string(interact).."', '"..x.."', '"..y.."', '"..z.."', '"..rz.."', '"..int.."', '"..dim.."', '"..skin.."', '"..gender.."', '"..userID.."', NOW());")
		local insertid = mysql:insert_id()

		setElementPosition(thePlayer, x+0.5, y, z)

		loadOnePed(insertid)
	end
end
addCommandHandler("makeped", createPermPed)

--[[
function makeFuelPed(thePlayer, command) --Create temporary fuel ped (no dbid)
	if global:isPlayerAdmin(thePlayer) then
		local x,y,z = getElementPosition(thePlayer)
		local rx,ry,rz = getElementRotation(thePlayer)
		local int = getElementInterior(thePlayer)
		local dim = getElementDimension(thePlayer)
		theNewPed = createPed (50, x, y, z)
		exports.pool:allocateElement(theNewPed)
		setPedRotation (theNewPed, rz)
		setElementFrozen(theNewPed, true)
		--setPedAnimation(theNewPed, "FOOD", "FF_Sit_Loop",  -1, true, false, true)
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "rpp.npc.type", "fuel", true)
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "rpp.npc.name", getRandomName("full", "male"), true)
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "rpp.npc.nametag", "true", true)
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "rpp.npc.behav", "1", true)

		exports.anticheat:changeProtectedElementDataEx(theNewPed, "fuel:priceratio" , 100, false)

		-- For the language system
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "languages.lang1" , 1, false)
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "languages.lang1skill", 100, false)
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "languages.lang2" , 2, false)
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "languages.lang2skill", 100, false)
		exports.anticheat:changeProtectedElementDataEx(theNewPed, "languages.current", 1, false)
	end
end
addCommandHandler("fuelped", makeFuelPed)
--]]

function pedMoveTowardsElement(ped, element)
	local x,y,z = getElementPosition(element)
	local px,py,pz = getElementPosition(ped)
	local rot = 0
	if ( x >= px ) and ( y > py ) then -- north-east
		rot = 90 - rot
	elseif ( x <= px ) and ( y > py ) then -- north-west
		rot = 270 + rot
	elseif ( x >= px ) and ( y <= py ) then -- south-east
		rot = 90 + rot
	elseif ( x < px ) and ( y <= py ) then -- south-west
		rot = 270 - rot
	end
	setPedRotation(ped, rot)
	--setPedLookAt(ped, x, y, z + 0.5)
	setPedAnimation(ped, "ped", "run_civi", -1, true, true, true, true)
end
function pedMoveTowardsCoordinates(ped, x, y, z, px, py, pz)
	--local x,y,z = getElementPosition(element)
	if not px and py and pz then px,py,pz = getElementPosition(ped) end
	local rot = 0
	if ( x >= px ) and ( y > py ) then -- north-east
		rot = 90 - rot
	elseif ( x <= px ) and ( y > py ) then -- north-west
		rot = 270 + rot
	elseif ( x >= px ) and ( y <= py ) then -- south-east
		rot = 90 + rot
	elseif ( x < px ) and ( y <= py ) then -- south-west
		rot = 270 - rot
	end
	setPedRotation(ped, rot)
	--setPedLookAt(ped, x, y, z + 0.5)
	setPedAnimation(ped, "ped", "run_civi", -1, true, true, true, true)
end
function pedMoveTimeout(ped)
	--outputDebugString("timeout")
	killTimer(pedMoveTimer[ped])
	pedMoveTimer[ped] = nil
	setPedAnimation(ped)
	pedMoveTimerTO[ped] = nil
end
function pedMoveToTram(ped, tram)
	--outputDebugString("pedMoveToTram")
	x,y,z = getElementPosition(tram)
	px,py,pz = getElementPosition(ped)
	local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
	--if distance > 20 then
	--	outputDebugString("moving")
	--	pedMoveTowardsCoordinates(ped, x, y, z, px, py, pz)
	--else
		--outputDebugString("close enough")
		killTimer(pedMoveTimerTO[ped])
		pedMoveTimerTO[ped] = nil
		killTimer(pedMoveTimer[ped])
		pedMoveTimer[ped] = nil
		setPedAnimation(ped)
		exports.trams:npcEnterTramPassenger(ped, tram)
	--end
end
function npcEnterPCT(hitElement, matchingDimension, marker)
	if not source then
		source = marker
	end
	--outputDebugString("triggered")
	if matchingDimension then
		if(getElementType(hitElement) == "vehicle") then
			if(getElementModel(hitElement) == 449) then
				outputDebugString("is tram")
				if(getVehicleController(hitElement)) then
					if(getResourceState(getResourceFromName("trams")) == "running") then
						outputDebugString("all good")
						local ped = getElementParent(source)
						pedMoveTimer[ped] = setTimer(pedMoveToTram, 100, 0, ped, hitElement)
						pedMoveTimerTO[ped] = setTimer(pedMoveTimeout, 10000, 1, ped)
					end
				end
			end
		end
	end
end

function respawnPed(player, ped)
	if(getElementType(ped) == "ped") then
		if getElementData(ped, "dbid") then
			local dbid = getElementData(ped, "dbid")
			--if(ped == exports.pool:getElement("ped", tonumber(dbid))) then --extra security check
				local result = reloadPed(tonumber(dbid))
				if result then
					outputDebugString("Successfully respawned ped with dbid "..tostring(dbid))
					return true
				else
					outputDebugString("Failed to respawn ped with dbid "..tostring(dbid).." (#2)")
					return false
				end
			--else
			--	outputDebugString("Failed to respawn ped with dbid "..tostring(dbid).." (#1) ("..tostring(ped).." = "..tostring(exports.pool:getElement("ped", tonumber(dbid)))..")")
			--	return false
			--end
		elseif getElementData(ped, "rpp.npc.spawnpos") then
			local spawnpos = getElementData(ped, "rpp.npc.spawnpos")
			new = createPed(getElementModel(ped),spawnpos[1],spawnpos[2],spawnpos[3],spawnpos[4])
			setPedRotation(new, spawnpos[4])
			setElementInterior(new, tonumber(spawnpos[5]))
			setElementDimension(new, tonumber(spawnpos[6]))
		elseif getElementData(ped, "rpp.npc.spawnpos2") then
			local posstring = getElementData(ped, "rpp.npc.spawnpos2")
			local pos = exports.global:split(posstring, ",")
			new = createPed(getElementModel(ped),pos[1],pos[2],pos[3],pos[4])
			setPedRotation(new, getElementData(ped,"rotation"))
			setElementInterior(new, tonumber(pos[5]))
			setElementDimension(new, tonumber(pos[6]))
		else
			new = createPed(getElementModel(ped),getElementPosition(ped))
			local rz, ry, rx = getElementRotation(ped)
			setElementRotation(new, rz, ry, rx)
			setElementInterior(new, getElementInterior(ped))
			setElementDimension(new, getElementDimension(ped))
		end

		for k, v in next, getAllElementData(ped) do
			exports.anticheat:changeProtectedElementDataEx(new, k, v)
		end
		exports.anticheat:changeProtectedElementDataEx(new, "activeConvo", 0)
		destroyElement(ped) --destroy old ped
		
		--[[
		local posstring = getElementData(ped, "rpp.npc.spawnpos")
		if posstring then
			local pos = exports.global:split(posstring, ",")
			local nametag = getElementData(ped, "rpp.npc.nametag")
			local name
			if nametag == "true" then
				name = getElementData(ped, "rpp.npc.name")
			end
			local behav = getElementData(ped, "rpp.npc.behav")
			local ptype = getElementData(ped, "rpp.npc.type")
			local fuelPriceratio
			if(ptype == "fuel") then
				fuelPriceratio = getElementData(ped, "fuel:priceratio")
			end
			local skin = getElementModel(ped)
			
			local newPed = createPed(skin, pos[1], pos[2], pos[3], pos[4], false)
			if newPed then
				if nametag and name then
					setElementData(newPed, "rpp.npc.name", tostring(name))
					setElementData(newPed, "rpp.npc.nametag", "true")
				end
				setElementData(newPed, "rpp.npc.behav", tostring(behav))
				setElementData(newPed, "rpp.npc.type", tostring(ptype))
				if(ptype == "fuel") then
					setElementData(newPed, "fuel:priceratio", tostring(fuelPriceratio))
				end
				
				destroyElement(ped) --destroy old ped
			end
		end
		--]]
	end
end
addEvent("peds:respawnPed", true)
addEventHandler("peds:respawnPed", getRootElement(), respawnPed)

function healPed(player, ped)
	if(getElementType(ped) == "ped") then
		if not (exports.factions:isInFactionType(player, 4)) then
			outputChatBox("You have no basic medic skills, contact the ES.", player, 255, 0, 0)
		else
			local foundkit, slot, itemValue = exports.global:hasItem(player, 70)
			if foundkit then
				if isPedDead(ped) then
					respawnPed(player, ped)
				else
					setElementHealth(ped, 100)
					local name = getPlayerName(player)
					local pedName = getElementData(ped, "rpp.npc.name")
					local message
					if pedName then
						message = "opens his medical kit and treats "..tostring(pedName)
					else
						message = "opens his medical kit and treats the person"
					end
					exports.global:sendLocalText(source, " *" ..  string.gsub(name, "_", " ").. ( message:sub( 1, 1 ) == "'" and "" or " " ) .. message, 255, 51, 102)
					if itemValue > 1 then
						exports['item-system']:updateItemValue(player, slot, itemValue - 1)
					else
						exports.global:takeItem(thePlayer, 70, itemValue)
						if not exports.global:hasItem(thePlayer, 70) then
							outputChatBox("Warning, you're out of first aid kits. re /duty to get new ones.", player, 255, 0, 0)
						end
					end
					local tax = exports.global:getTaxAmount()
					local price = 100									
					exports.global:giveMoney( getTeamFromName("San Fierro Emergency Services"), math.ceil((1-tax)*price) )
					exports.global:giveMoney( getTeamFromName("Government of San Fierro"), math.ceil(tax*price) )
					if pedName then
						outputChatBox("You healed " ..pedName.. " (NPC).", player, 0, 255, 0)
					else
						outputChatBox("You healed a NPC.", player, 0, 255, 0)
					end
					exports.logs:dbLog(player, 35, ped, "HEAL NPC FOR $" .. price)
				end
			else
				outputChatBox("You need a first aid kit to heal people.", player, 255, 0, 0)
			end
		end
	end
end
addEvent("peds:healPed", true)
addEventHandler("peds:healPed", getRootElement(), healPed)

local allowedFunctionPeds = {
	--["function"] = true/false
}
function deletePed(player, ped)
	if(getElementType(ped) == "ped") then
		if exports.integration:isPlayerAdmin(player) then
			local dbid = tonumber(getElementData(ped, "rpp.npc.dbid")) or 0
			if dbid > 0 then
				local pedFunction = getElementData(ped, "rpp.npc.type")
				if pedFunction then
					--if(allowedFunctionPeds[pedFunction] or exports.global:isPlayerHeadAdmin(player)) then
						deleteDbPed(player, dbid, ped)
					--end
				else
					deleteDbPed(player, dbid, ped)
				end
			else
				local pedName = getElementData(ped, "rpp.npc.name")
				if not pedName then
					pedName = getElementData(ped, "name")
				end
				if not pedName then
					pedName = "Unnamed"
				end
				destroyElement(ped)
				exports.global:sendMessageToAdmins("[Peds] Temp NPC '"..tostring(pedName).."' was deleted by " .. getPlayerName(player) .. ".")
			end
		end
	end
end
addEvent("peds:deletePed", true)
addEventHandler("peds:deletePed", getRootElement(), deletePed)

function deleteDbPed(player, pedID, ped)
	local mysql = exports.mysql
	if exports.integration:isPlayerTrialAdmin(player) then
		if not ped then
			ped = exports.global:getPoolElement("ped", pedID)
		end
		if not ped then
			outputChatBox("Ped not found!", player, 255, 0, 0)
			return false
		end
		local pedType = getElementData(ped, "rpp.npc.type")
		if pedType then
			if(not allowedFunctionPeds[pedFunction]) then
				if not exports.integration:isPlayerAdmin(player) then
					outputChatBox("Only Admin+ can delete this ped type.", player, 255, 0, 0)
					return false
				end
			end
		end
		mysql:query_free("DELETE FROM peds WHERE id='"..mysql:escape_string(pedID).."'")
		destroyElement(ped)
	else
		outputChatBox("Only admins can delete permanent peds.", player, 255, 0, 0)
	end
end

function savePedToDB(arguments, element)
	if exports.integration:isPlayerTrialAdmin(source) then
		local mysql = exports.mysql
		local dbid = tonumber(arguments[1]) or false
		--argument = {}
		--for i = 1, #arguments do -- 16 arguments
		--	argument[i] = mysql:escape_string(arguments[i])
		--end

		local keys = {"dbid", "name", "type", "behaviour", "x", "y", "z", "rotation", "interior", "dimension", "skin", "animation", "synced", "nametag", "frozen", "comment"}

		if dbid then
			argument = {}
			for i = 1, #arguments do
				local v = arguments[i]
				if(type(v) == "boolean" and not v) then
					argument[i] = "NULL"
				elseif(type(v) == "boolean" and v) then
					argument[i] = "'1'"
				elseif(type(v) == "string") then
					argument[i] = "'"..mysql:escape_string(v).."'"
				elseif(type(v) == "number") then
					argument[i] = "'"..tostring(v).."'"
				else
					outputChatBox("Error saving ped (invalid value '"..tostring(v).."' for '"..tostring(keys[i]).."').", source, 255, 0, 0)
					return
				end
			end

			--outputConsole("UPDATE peds SET id="..argument[1]..", name="..argument[2]..", type="..argument[3]..", behaviour="..argument[4]..", x="..argument[5]..", y="..argument[6].."', z="..argument[7].."', rotation="..argument[8].."', interior="..argument[9]..", dimension="..argument[10]..", skin="..argument[11]..", animation="..argument[12]..", synced="..argument[13]..", nametag="..argument[14]..", frozen="..argument[15]..", comment="..argument[16]..";", source)
			mysql:query_free("UPDATE peds SET name="..argument[2]..", type="..argument[3]..", behaviour="..argument[4]..", x="..argument[5]..", y="..argument[6]..", z="..argument[7]..", rotation="..argument[8]..", interior="..argument[9]..", dimension="..argument[10]..", skin="..argument[11]..", animation="..argument[12]..", synced="..argument[13]..", nametag="..argument[14]..", frozen="..argument[15]..", comment="..argument[16].." WHERE id="..argument[1]..";")
			
			--outputDebugString("behaviour="..tostring(argument[4]))
			outputDebugString("(frozen="..tostring(arguments[15])..")")
			outputDebugString("frozen="..tostring(argument[15]))

			outputChatBox("Updated ped #"..tostring(argument[1]).." in the database.", source, 0, 255, 0)
			reloadPed(dbid)
			return
		elseif(not dbid and element) then		
			local name = arguments[2]
			local pedType = arguments[3]
			local behaviour = arguments[4]
			local x = arguments[5]
			local y = arguments[6]
			local z = arguments[7]
			local rotation = arguments[8]
			local interior = arguments[9]
			local dimension = arguments[10]
			local skin = arguments[11]
			local animation = arguments[12]
			local synced = arguments[13]
			local nametag = arguments[14]
			local frozen = arguments[15] == 1
			local comment = arguments[16]
			if not gender then
				gender = getRandomName("gender")
			end
			if not skin then
				if(gender == 0) then
					skin = skinsMale[math.random(#skinsMale)]
				elseif(gender == 1) then
					skin = skinsFemale[math.random(#skinsFemale)]
				end			
			end

			setElementPosition(element, x, y, z)
			setElementInterior(element, interior)
			setElementDimension(element, dimension)
			setElementRotation(element, 0, 0, rotation)
			setElementModel(element, skin)
			if not name then
				name = getRandomName("full",gender)
			end
			setElementData(element, "rpp.npc.name", tostring(name))
			setElementData(element, "rpp.npc.nametag", nametag)
			setElementData(element, "rpp.npc.behav", behaviour)
			setElementData(element, "rpp.npc.spawnpos", {x, y, z, rotation, interior, dimension})
			setElementData(element, "rpp.npc.spawnpos2", tostring(x)..","..tostring(y)..","..tostring(z)..","..tostring(rotation)..","..tostring(interior)..","..tostring(dimension))
			if(behav == 2) then
				giveWeapon(element, 22)
				setPedStat(element, 69, 999)
				setPedStat(element, 76, 999)
			else

			end
			--[[if(behav == 5) then
				local shape = createMarker(x, y, z, "cylinder", 20)
				setMarkerColor(shape, 0, 0, 0, 0)
				local result = addEventHandler("onMarkerHit", shape, npcEnterPCT)
				--outputDebugString(tostring(result).." ("..tostring(shape)..")")
				attachElements(shape, tempPeds[i], 0, 0, -1, 0, 0, 0)
			end--]]

			setElementFrozen(element, frozen)

			outputChatBox("Updated the temporary ped.", source, 0, 255, 0)
		else
			outputChatBox("No ped to edit.", source, 255, 0, 0)
		end
	end
end
addEvent("peds:saveeditped", true)
addEventHandler("peds:saveeditped", getRootElement( ), savePedToDB)

function hideMyID(thePlayer, command)
	if(exports.integration:isPlayerScripter(thePlayer)) then
		local hideMyID = getElementData(thePlayer, "hidemyid")
		if hideMyID then
			setElementData(thePlayer, "hidemyid", false)
			outputChatBox("Showing ID",thePlayer)
		else
			setElementData(thePlayer, "hidemyid", true)
			outputChatBox("Hiding ID",thePlayer)
		end
	end
end
addCommandHandler("hidemyid", hideMyID)

function giveFakeName(thePlayer, command)
	if(exports.integration:isPlayerScripter(thePlayer)) then
		local fakename = getElementData(thePlayer, "fakename")
		if fakename then
			setElementData(thePlayer, "fakename", false)
			outputChatBox("Fake name removed.",thePlayer)
		else
			local gender = tonumber(getElementData("gender",thePlayer)) or 0
			local fakenameName = getRandomName("full", gender)
			setElementData(thePlayer, "fakename", tostring(fakenameName))
			outputChatBox("Fake name set to "..tostring(fakenameName)..".",thePlayer)
		end
	end
end
addCommandHandler("givemefakename", giveFakeName)