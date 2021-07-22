--Get MaxtrixCam
function onCmd( thePlayer, commandName )
	local cam = {}
	cam[1], cam[2], cam[3], cam[4], cam[5], cam[6], cam[7], cam[8] = getCameraMatrix ()
	local index = 1
	outputChatBox("---Start---")
	local text =""
	while index < 7 do
		text = text..cam[index]..", "
		index = index + 1
	end
	outputChatBox(text)
	outputChatBox("---End---")
end
addCommandHandler('getcam', onCmd)
--Preview Sound Front End
-- Testing 123, abc
function onSoundEvent ( asd, shit )
	fadeCamera ( true , 1, 0,0,0 )
	playSoundFrontEnd ( tonumber(shit) )
end
addCommandHandler("sound", onSoundEvent)

function blackoutfix ( asd, shit )
	outputChatBox("Attempted to fix blackout, did it work?")
	fadeCamera ( true , 1, 0,0,0 )
end
--addCommandHandler("fix", blackoutfix)

function interior ( commandName, interior )
  --Let's see if they gave a interior ID
  if ( interior ) then
    --They did, so let's assign them to that interior and teleport them there (all in 1 function call!)
    setElementInterior ( getLocalPlayer(), interior, 2233.91, 1714.73, 1011.38 )
  else
    --They didn't give one, so set them to the interior they wanted, but don't teleport them.
    setElementInterior ( getLocalPlayer(), 0 )
  end
end
--addCommandHandler ( "maxime", interior )

--THIS IS USED TO GET  PLAYER'S ALL ELEMENT DATA FROM CLIENT
function getAllDataFromPlayer ( player, commandName, playerid )
	local data = getAllElementData ( player )     -- get all the element data of the player who entered the command
    for k, v in pairs ( data ) do                    -- loop through the table that was returned
        outputChatBox ( tostring(k) .. ": " .. tostring(v), player )             -- print the name (k) and value (v) of each element data
    end
end
--addCommandHandler ( "getelementclient", getAllDataFromPlayer )


