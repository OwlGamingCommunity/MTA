function hwSurvey( key, value )
	-- create a unique hash for this key/value pair
	local hash = md5( key .. "//" .. value )
	if fileExists("@" .. hash) then
		return
	end
	
	-- create our file to avoid double results from one pc with yet the same config.
	fileClose( fileCreate( "@" .. hash ) )
	
	-- Send the data
	triggerServerEvent( "hws", localPlayer, key, value )
end

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		-- display resolution
		hwSurvey( "resolution", table.concat( { guiGetScreenSize( ) }, "x" ) )
	end
)
