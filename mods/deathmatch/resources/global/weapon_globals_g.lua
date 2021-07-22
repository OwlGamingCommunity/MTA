-- character table string
local b='cfFvbCKeg2zN0mOEhnou5X7lDLS31jdJQipHWaUIyGTs4PkrVZt8BMwqYR6x9A'
--local b = 'AM1KR0B2PEDGUX736ZTQJHILFSYVN5C48OW9'
-- encoding
function weaponenc(data)
    return (data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)
end

-- decoding
function weapondec(data)
    --data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- methodSpawned 1: Admin Spawned
-- methodSpawned 2: /duty
-- methodSpawned 3: Ammunation
-- methodSpawned 4: Faction Drop NPC
local securityNumber = 5
local resetTimer = nil

function createWeaponSerial( methodSpawned, spawnedBy, givenTo  )
	if not givenTo then
		givenTo = spawnedBy
	end
	
	securityNumber = securityNumber + 1
	local buffer = tostring(getRealTime().timestamp - 1314835200)
	buffer = buffer .. "/"
	buffer = buffer .. methodSpawned
	buffer = buffer .. "/"
	buffer = buffer .. spawnedBy
	buffer = buffer .. "/"
	buffer = buffer .. securityNumber
	
	if not resetTimer then
		resetTimer = setTimer(weaponSecurityNumberReset, 60000, 1)
	end
	
	local buff2 = weaponenc(string.reverse(buffer))
	
	return buff2
end

function retrieveWeaponDetails( serialNumber )
	local decodedStr = weapondec( serialNumber )
	local explodedStr = explode("/", string.reverse(decodedStr) )
	return explodedStr
end

function fetchMethodOfSpawningWeapon( methodNumber )
	if not methodNumber or not tonumber(methodNumber) then
		return ''
	end
	
	if tonumber(methodNumber) == 1 then
		return "Admin"
	elseif tonumber(methodNumber) == 2 then
		return "Faction Duty"
	elseif tonumber(methodNumber) == 3 then
		return "Ammunation"
	elseif tonumber(methodNumber) == 4 then
		return "Faction Drop NPC"
	end
	
	return ''
end

function weaponSecurityNumberReset()
	securityNumber = 5
	resetTimer = nil
end
