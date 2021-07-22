--MAXIME
function canPlayerCall(thePlayer)
	local phoneState = getElementData(thePlayer, "phonestate") or 0
	local restrain = getElementData(thePlayer, "restrain") or 0
	local injuriedanimation = getElementData(thePlayer, "injuriedanimation")
	local reconx = getElementData(thePlayer, "reconx") 
	local calling = getElementData(thePlayer, "calling")
	local loggedin = getElementData(thePlayer, "loggedin")
	local jailed = getElementData(thePlayer, "jailed") or 0
	local adminjailed = getElementData(thePlayer, "adminjailed")
	if restrain ~= 0 or phoneState > 0 or injuriedanimation or reconx or calling or isPedDead(thePlayer) or loggedin~=1 or jailed > 0 or adminjailed then
		return false
	end 
	return true
end

function canPlayerPhoneRing(thePlayer)
	local phoneState = getElementData(thePlayer, "phonestate") or 0
	local reconx = getElementData(thePlayer, "reconx") 
	local calling = getElementData(thePlayer, "calling")
	if phoneState > 0 or reconx or calling then
		return false
	end 
	return true
end
function canPlayerAnswerCall(thePlayer)
	local phoneState = getElementData(thePlayer, "phonestate") or 0
	local restrain = getElementData(thePlayer, "restrain") or 0
	local injuriedanimation = getElementData(thePlayer, "injuriedanimation")
	local reconx = getElementData(thePlayer, "reconx") 
	local called = getElementData(thePlayer, "called")
	local loggedin = getElementData(thePlayer, "loggedin")
	--outputDebugString(tostring(restrain))
	if restrain ~= 0 or phoneState ~= 3 or injuriedanimation or reconx or not called or isPedDead(thePlayer) or loggedin~=1 then
		return false
	end 
	return true
end

function canPlayerSlidePhoneIn(thePlayer)
	local phoneState = getElementData(thePlayer, "phonestate") or 0
	local restrain = getElementData(thePlayer, "restrain") or 0
	local injuriedanimation = getElementData(thePlayer, "injuriedanimation")
	local reconx = getElementData(thePlayer, "reconx") 
	local called = getElementData(thePlayer, "called")
	local loggedin = getElementData(thePlayer, "loggedin")
	--outputDebugString(tostring(restrain))
	if restrain ~= 0 or injuriedanimation or isPedDead(thePlayer) or loggedin~=1 then
		return false
	end 
	return true
end

function setED(e, i, n, s) 
	return setElementData(e, i, n, s)
end

function getED(e, i)
	return getElementData(e, i)
end

function isQuitType(action)
	return action == "Unknown" or action == "Quit" or action == "Kicked" or action == "Banned" or action == "Bad Connection" or action == "Timed out"
end

ringtones = {
	[1]	= "sounds/ringtones/viberate.mp3",
	[2]	= "sounds/ringtones/iphone_5s.mp3",
	[3] = "sounds/ringtones/iphone_6.mp3",
	[4] = "sounds/ringtones/minion_ring_ring.mp3",
	[5] = "sounds/ringtones/perfect_ring_tone.mp3",
	[6] = "sounds/ringtones/sending_you_an_sms.mp3",
	[7] = "sounds/ringtones/sms.mp3",
	[8] = "sounds/ringtones/sms_new.mp3",
	[9] = "sounds/ringtones/sony_xperia_z3.mp3",
	[10] = "sounds/ringtones/sweetest_tone_ever.mp3",
	[11] = "sounds/ringtones/turn_down_for_what.mp3",
	[12] = "sounds/ringtones/vertu_new_tone.mp3",
	[13] = "sounds/ringtones/winggle_wiggle.mp3",
	[14] = "sounds/ringtones/apple_ring.mp3",
	[15] = "sounds/ringtones/google.mp3",
}

function removeNewLine(string)
	return string.gsub(string, "\n", " ")
end