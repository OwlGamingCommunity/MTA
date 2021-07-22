-- table to save all info to
data = {}

-- load JSON from file
function loadJSONData( filename )
	local file = fileExists( filename ) and fileOpen( filename, true ) or fileCreate( filename )
	local size = fileGetSize(file) or 0
	local str = fileRead( file, size )
	if str then
		t = fromJSON( str )
	else
		t = {resolution = {}}
	end
	fileClose( file )
	return t
end

-- saves a table to a JSON-formatted file
function saveJSONData( filename, data )
	if fileExists( filename ) then
		fileDelete( filename )
	end
	
	local file = fileCreate( filename )
	fileWrite( file, toJSON( data ) )
	fileClose( file )
end

-- loading of stuff
addEventHandler( "onResourceStart", resourceRoot,
	function( )
		data = loadJSONData( "hws.json" )
	end
)

addEvent( "hws", true )
addEventHandler( "hws", root,
	function( key, value )
		if not data[ key ] then
			return
		end
		
		data[ key ][ value ] = ( data[ key ][ value ] or 0 ) + 1
		saveJSONData( "hws.json", data )
	end
)

--

addCommandHandler("hws",
	function( player, command, key )
		if exports.integration:isPlayerAdmin( player ) then
			if not key or not data[ key ] then
				outputChatBox( "/" .. command .. " resolution", player )
			else
				outputChatBox( "--start " .. key .. "--", player )
				for k, v in pairs( data[ key ] ) do
					outputChatBox( k .. " = " .. v, player )
				end
				outputChatBox( "--end--", player )
			end
		end
	end
)