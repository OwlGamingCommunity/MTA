taSertoStreams = {}
taSertoStreamNumber = 0

function addStream( player, command, url, distance )
	if exports.integration:isPlayerScripter(player) then
		if not url or not distance then
			outputChatBox("TASERTOSYNTAX: /"..command.." [URL] [DISTANCE]!!!!", player, 255, 10, 10)
		else
			local x, y, z = getElementPosition( player )
			local position = { x, y, z }
			local dimension, interior = getElementDimension( player ), getElementInterior( player)
			for k, v in ipairs(getElementsByType('player')) do
				triggerClientEvent( "onClientRenderStream", v, url, position, dimension, interior, distance )
			end
			local streamInformation = { url, position, dimension, interior, distance }
			tableInsert( taSertoStreams, taSertoStreamNumber + 1, streamInformation )
			outputChatBox("You've added ta serto stream #" .. taSertoStreamNumber + 1, player, 0, 255, 0)
			outputChatBox("URL: " .. tostring( url ) .. ", DISTANCE: " .. tostring( distance ) .. ", at your location.", player, 255, 17, 17)
			taSertoStreamNumber = taSertoStreamNumber + 1
		end
	end
end
addCommandHandler("tasertoaddstream", addStream)
addEvent("stream:addDJstream", true)
addEventHandler("stream:addDJstream", getRootElement(), addStream)

function removeStream( player, command, streamID )
	if exports.integration:isPlayerScripter(player) then
		if not streamID then
			outputChatBox("TASERTOSYNTAX: /"..command.." [STREAM ID!!!!]", player, 255, 10, 10)
		else
			streamID = tonumber( streamID )
			if taSertoStreams[streamID] then
				taSertoStreams[streamID] = nil
				for k, v in ipairs(getElementsByType('player')) do
					triggerClientEvent( "onClientRemoveStream", v, streamID )
				end
			else
				outputChatBox("that stream dont exist.", player, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("tasertoremovestream", removeStream)

function listStreams( player, command )
	if exports.integration:isPlayerScripter( player ) then
		outputChatBox("There are " .. #taSertoStreams .. " streams up currently:", player, 255, 194, 14)
		for key, value in pairs(taSertoStreams) do
			outputChatBox("STREAM #"..key..": DIM: " .. value[3] .. ", URL: " .. value[1], player, 255, 194, 14)
		end
	end
end
addCommandHandler("streams", listStreams)

-- smart fix for reconnecting and you dont hear the streams
addEventHandler("onPlayerSpawn", getRootElement(),
	function( posX, posY, posZ, spawnRotation, theTeam, theSkin, theInterior, theDimension )
		for key, value in pairs(taSertoStreams) do
			if key > 0 then
				triggerClientEvent( "onClientRenderStream", source, value[1], value[2], value[3], value[4], value[5], key )
			end
		end
	end
)

function tableInsert(table, index, value)
	table[index] = value
	return table
end