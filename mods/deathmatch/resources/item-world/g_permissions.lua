mysql = exports.mysql
anticheat = exports.anticheat
items = exports['item-system']
global = exports.global
integration = exports.integration



function canEditItemProperties(thePlayer, object)
	if not object then return false end
	local interiorID = getElementDimension(object)
	if exports.global:hasItem(localPlayer, 3, interiorID - 20000) or exports.global:hasItem(localPlayer, 4, interiorID) or exports.global:hasItem(localPlayer, 5, interiorID) or (exports.integration:isPlayerTrialAdmin(thePlayer) and exports.global:isAdminOnDuty(thePlayer)) or exports.integration:isPlayerScripter(thePlayer) then
		return true
	end
	return false
end
permissionTypes = {
	--name, id, hasData
	{"No-one", 0, false},
	{"Everyone", 1, false},
	{"Interior key holders", 2, false},
	{"Admin only", 3, false},
	{"Factions", 4, true},
	{"Characters", 5, true},
	{"Interior owner", 6, false},
	{"Item placer", 7, false},
	{"Exciter Query String", 8, true},
}
function getPermissionTypeIDFromName(name)
	for k,v in ipairs(permissionTypes) do
		if name == v[1] then
			return v[2]
		end
	end
	return false
end

function can(player, action, element)
	global = exports.global
	integration = exports.integration
	if not action or not element or not player then return false end
	local perm = getPermissions(element)
	if not perm then return false end
	local usePerm, useData
	if action == "use" then
		usePerm = perm.use
		useData = perm.useData
	elseif action == "move" then
		usePerm = perm.move
		useData = perm.moveData
	elseif action == "pickup" then
		usePerm = perm.pickup
		useData = perm.pickupData
	else
		return false
	end
	if usePerm == 0 then --no-one
		return false
	elseif usePerm == 1 then --everyone
		return true
	elseif usePerm == 2 then --interior/property owner
		local dimension = getElementDimension(element)
		if global:hasItem(player, 4, dimension) or global:hasItem(player, 5, dimension) then
			return true
		end
	elseif usePerm == 3 then --admin only
		if (integration:isPlayerAdmin(player) and global:isAdminOnDuty(player)) then
			return true
		end
	elseif usePerm == 4 then --factions
		if not useData then return false end
		for k,v in ipairs(useData) do
			local faction = tonumber(v)
			if exports.factions:isPlayerInFaction(player, faction) then
				return true
			end
		end
	elseif usePerm == 5 then --char names
		if not useData then return false end
		local playerName = exports.global:getPlayerName(player)
		for k,v in ipairs(useData) do
			if v == playerName then
				return true
			end
		end
	elseif usePerm == 6 then --interior owner
		local thisInterior = getElementDimension(element)
		local interiorElement = getElementByID("int"..tostring(thisInterior))
		if interiorElement and isElement(interiorElement) then
			local interiorData = getElementData(interiorElement, "status")
			local interiorOwner = interiorData.owner
			if interiorOwner and interiorOwner > 0 then
				local thisCharacterID = tonumber(getElementData(player, "dbid"))
				if thisCharacterID then
					if thisCharacterID == interiorOwner then
						return true
					end
				end
			end
		end
	elseif usePerm == 7 then --item placer
		local creator = tonumber(getElementData(element, "creator"))
		if creator then
			local charid = tonumber(getElementData(player, "dbid"))
			if charid then
				if charid == creator then
					return true
				end
			end
		end
	elseif usePerm == 8 then --exciter query string
		local querystring = useData[1]
		if not querystring then return false end
		return exports.global:exciterQueryString(player, querystring)
	end
	return false
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function isNumeric(a)
	if tonumber(a) ~= nil then return true else return false end
end