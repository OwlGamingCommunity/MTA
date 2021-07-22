addEvent ( "frames:fetchTexture", true )

mysql = exports.mysql

function frames_fetchTexture ( itemSlot, url )
	if url:sub(1, 4) == "cef+" then
		triggerClientEvent ( client, "frames:showTextureSelection", client, itemSlot, url, false )
	else
		fetchRemote ( url, "textures", frames_callback, "", false, { player = client, url = url, slot = itemSlot } )
	end
end

function frames_callback ( imgData, error, data )
	if error == 0 then
		triggerClientEvent ( data.player, "frames:showTextureSelection", data.player, data.slot, data.url, imgData )
	end
end

addEventHandler ( "frames:fetchTexture", root, frames_fetchTexture )
