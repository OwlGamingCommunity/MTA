local singlegatemp3 = nil
local allgatesmp3 = nil

function singleGateSound(x, y, z)
	if not isElement(singlegatemp3) then
		singlegatemp3 = playSound3D( "singlegate.mp3", x, y, z, false)
		setElementDimension(singlegatemp3, gateDim)
		setElementInterior(singlegatemp3, gateInt)
	end
end
addEvent("singleGateSound", true)
addEventHandler("singleGateSound", getLocalPlayer(  ), singleGateSound)

function allGatesSound()
	if not isElement(allgatesmp3) then
		allgatesmp3 = playSound( "buzz.wav", false )
		setTimer( function ()
			allgatesmp3 = playSound( "allgates.mp3", false )
		end, 1400, 1)
	end
end
addEvent("allGatesSound", true)
addEventHandler("allGatesSound", getLocalPlayer(), allGatesSound)
