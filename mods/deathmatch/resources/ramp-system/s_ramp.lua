-- Made with love by Shmorf
-- Copyright (c), Immersion Gaming.

mysql = exports.mysql

local radius = 3

function ramp_add ( p, cmd )
    if exports.integration:isPlayerTrialAdmin(p) then
		local x, y, z = getElementPosition ( p )
		local _, _, rz = getElementRotation ( p )
		local interior = getElementInterior ( p )
		local dimension = getElementDimension ( p )
		local tx = x + - ( radius ) * math.sin ( math.rad ( rz ) )
		local ty = y + radius * math.cos ( math.rad ( rz ) )
    
		local id = SmallestID ( )
		local position = toJSON ( { tx, ty, z - 1.15 } )
		local creator = getElementData(p, "account:username")
		local query = mysql:query_free ( "INSERT INTO ramps SET id=" .. id .. ",position='" .. position .. "',interior='" .. interior .. "',dimension='" .. dimension .. "',rotation=" .. math.ceil ( rz ) .. ",creator='" .. creator .. "'" )
		
		if query then
			ramp_load ( id )
			outputChatBox ( "Created Ramp with ID " .. id ..".", p, 0, 255, 0, false )
			exports.global:giveItem ( p, 151, id )
			exports.global:sendMessageToAdmins ( "AdmWarn: " .. creator .. " created a ramp with ID " .. id )
		else
			outputChatBox ( "Failed to create ramp.", p, 255, 0, 0, false )
		end
	end
end
addCommandHandler ( "addramp", ramp_add )

function ramp_delete ( p, cmd, id )
	if exports.integration:isPlayerTrialAdmin(p) then
		local query = mysql:query_free ( "DELETE FROM ramps WHERE id = " .. id )
        
		if query then
			local deleter = getElementData(p, "account:username")
				
			for i,v in ipairs ( getElementsByType ( "object" ) ) do
				if isElement ( v ) and getElementData ( v, "garagelift" ) and getElementData ( v, "dbid" ) == tonumber ( id ) then
					local lift = getElementData ( v, "lift" )
					destroyElement ( lift )
					destroyElement ( v )
				end
			end
			
			outputChatBox ( "Deleted Ramp with ID " .. id ..".", p, 255, 0, 0, false )
			exports.global:sendMessageToAdmins ( "AdmWarn: " .. deleter .. " deleted a ramp with ID " .. id )
		else
			outputChatBox ( "Invalid ramp ID specified.", p, 255, 0, 0, false )
		end
	end
end
addCommandHandler ( "delramp", ramp_delete )

function ramp_move(p, cmd, id)
	if exports.integration:isPlayerTrialAdmin(p) then
		if not id then
			outputChatBox("Syntax: /" .. cmd .. " (ID)", p)
		else
			local x, y, z = getElementPosition ( p )
			local _, _, rz = getElementRotation ( p )
			local interior = getElementInterior ( p )
			local dimension = getElementDimension ( p )
			local tx = x + - ( radius ) * math.sin ( math.rad ( rz ) )
			local ty = y + radius * math.cos ( math.rad ( rz ) )
			local position = toJSON ( { tx, ty, z - 1.15 } )
			
			local query = mysql:query_free ( "UPDATE ramps SET position = '" .. position .. "', rotation = '" .. rz .. "', dimension = '" .. dimension .. "', interior = '" .. interior .. "' WHERE id = '" .. id .. "'")
			if query then
				for i,v in ipairs ( getElementsByType ( "object" ) ) do
					if isElement ( v ) and getElementData ( v, "garagelift" ) and getElementData ( v, "dbid" ) == tonumber ( id ) then
						local lift = getElementData ( v, "lift" )
						destroyElement ( lift )
						destroyElement ( v )
					end
				end
				ramp_load ( id )
			end
		end
	end
end
addCommandHandler("moveramp", ramp_move)

function SmallestID ( )
    local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM ramps AS e1 LEFT JOIN ramps AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
    if result then
        local id = tonumber(result["nextID"]) or 1
        return id
    end
    return false
end

function ramp_init ( )
    local result = mysql:query ( "SELECT * FROM ramps" )
    
    if result then
       while true do
            local row = mysql:fetch_assoc ( result )
            if not row then break end
            
            ramp_load ( row.id )
        end
        
        mysql:free_result ( result )
    else
        exports.global:sendMessageToAdmins ( "AdmWarn: Failed to select ramps from MySQL Database, please panic." )
    end
	
	removeWorldModel(2053, 10000, 0, 0, 0)
	removeWorldModel(2054, 10000, 0, 0, 0)
end

function ramp_load ( id )
    local row = mysql:query_fetch_assoc ( "SELECT * FROM ramps WHERE id = " .. id )
    
    if row then
        for k, v in pairs( row ) do
            if v == null then
                row[k] = nil
            else
                row[k] = tonumber(v) or v
            end
        end
        
        local x, y, z = unpack ( fromJSON ( row.position ) )
        local rz = row.rotation
		local int = row.interior
		local dim = row.dimension
        
        local frame = createObject ( 2052, x, y, z, 0, 0, rz )
        local lift = createObject ( 2053, x, y, z+0.15+(2.33/100*tonumber(row.liftposition)), 0, 0, rz )
		
		setElementDimension(frame, dim)
		setElementDimension(lift, dim)
		setElementInterior(frame, int)
		setElementInterior(lift, int)
		
		setElementData(lift, "lift.position", tonumber(row.liftposition) or 0)
        
        setElementData ( frame, "garagelift", true )
        setElementData ( frame, "lift", lift )
        setElementData ( frame, "dbid", tonumber ( id ) )
        setElementData ( frame, "creator", row.creator )
    end
end

function getNearbyRamps ( p )
	if exports.integration:isPlayerTrialAdmin(p) then
    
		local px, py, pz = getElementPosition ( p )
		local dimension = getElementDimension ( p )
		local count = 0
		
		outputChatBox ( "Nearby Ramps:", p, 255, 126, 0, false )
		
		for i,v in ipairs ( getElementsByType ( "object" ) ) do
			if getElementData ( v, "garagelift" ) and getElementDimension ( v ) == dimension then
				local x, y, z = getElementPosition ( v )
				local distance = getDistanceBetweenPoints3D ( px, py, pz, x, y, z )
				
				if distance < 11 then
					local dbid = getElementData ( v, "dbid" )
					local creator = getElementData ( v, "creator" )
					
					outputChatBox ( " ID " .. dbid .. " | Creator: " .. creator, p, 255, 126, 0, false )
					count = count + 1
				end
			end
		end
		
		if count == 0 then
			outputChatBox ( "   None.", p, 255, 126, 0, false )
		end
	end
end
addCommandHandler ( "nearbyramps", getNearbyRamps )

function gotoRamp ( p, commandName, target )
    if exports.integration:isPlayerTrialAdmin(p) then
	if not target then
		outputChatBox("SYNTAX: /" .. commandName .. " [Ramp ID]", p, 255, 194, 14)
		else
		for i,v in ipairs ( getElementsByType ( "object" ) ) do
			if getElementData ( v, "garagelift" ) then
				local dbid = getElementData ( v, "dbid" )
				if (tonumber(target) == tonumber(dbid)) then
				local x, y, z = getElementPosition ( v )
				local int = getElementInterior ( v )
				local dim = getElementDimension ( v )
					
				setElementPosition(p, x, y, z)
				setElementInterior(p, int)
				setElementDimension(p, dim)
				
				outputChatBox ( "Teleported to ramp ID " .. dbid .. ".", p, 255, 126, 0, false )
				end
			end
		end
	end
	end
end
addCommandHandler ( "gotoramp", gotoRamp )

addEventHandler ( "onResourceStart", resourceRoot, ramp_init )

function moveRamp(element, position)
	local lift = getElementData(element, "lift")
    local lx, ly, lz = getElementPosition(lift)
    setElementData(element, "lift.moving", true)
	
	local difference = 0
	if getElementData(lift, "lift.position") > position then
		difference = getElementData(lift, "lift.position")-position
		moveObject(lift, ((4000/100*difference) > 50 and (4000/100*difference)) or 50, lx, ly, lz - (2.33/100*difference))
		triggerEvent('sendAme', source, "presses the button on the ramp controls lowering the car lift.")
	else
		difference = position-getElementData(lift, "lift.position")
		moveObject(lift, ((4000/100*difference) > 50 and (4000/100*difference)) or 50, lx, ly, lz + (2.33/100*difference))
		triggerEvent('sendAme', source, "presses the button on the ramp controls raising the car lift.")
	end
		
	mysql:query_free("UPDATE `ramps` SET `liftposition`='" .. position .. "' WHERE `id`='" .. getElementData(element, "dbid" ) .. "'")
	setElementData(lift, "lift.position", position)
	setTimer(setElementData, ((4000/100*difference) > 50 and (4000/100*difference)) or 50, 1, element, "lift.moving", false)
end
addEvent("moveRamp", true)
addEventHandler("moveRamp", getRootElement(), moveRamp)