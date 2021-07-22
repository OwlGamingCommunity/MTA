--MAXIME
local phoneLogs = {}

function writeCellphoneLog(thePlayer, theOtherPlayer, type, message, starting )
	if starting or (message and string.len(message) > 0) and type then

		local charId1 = nil
		local number1 = nil
		local number2Test = nil

		local charId2 = nil
		local number2 = nil
		local number1Test = nil

		if thePlayer and getElementData(thePlayer, "cellphone_log") ~= "0" then
			charId1 = getED(thePlayer, "dbid")
			number1 = getED(thePlayer, "callingwith")
			number2Test = getED(thePlayer, "calling")

		end

		if tonumber(charId1) and tonumber(number1) and tonumber(number2Test) then

			if not phoneLogs[charId1] then
				phoneLogs[charId1] = {}
			end

			if not phoneLogs[charId1][number1] then
				phoneLogs[charId1][number1] = {}
			end
			if not phoneLogs[charId1][number1][type] then
				phoneLogs[charId1][number1][type] = {}
			end
			if not phoneLogs[charId1][number1][type][number2Test] then 
				phoneLogs[charId1][number1][type][number2Test] = {}
			end

			local message1 = ""
			if starting then
				message1 = "\nOUTGOING "..(type == "Calls" and "CALL" or "SMS").." FROM #"..number1.." ("..string.upper(exports.global:getPlayerName(thePlayer))..") TO #"..number2Test.." ("..(theOtherPlayer and string.upper(exports.global:getPlayerName(theOtherPlayer)) or string.upper(getHotlineName(number2Test)))..") AT ".. getCurrentDateTimeText()..":"
			else
				message1 = "-> "..message
			end
			outputDebugString("wrote "..charId1.."->"..number1.."->"..type.."->"..number2Test.."-> '"..message1.."'")
			table.insert(phoneLogs[charId1][number1][type][number2Test], message1)

			if theOtherPlayer and getElementData(theOtherPlayer, "cellphone_log") ~= "0" then
				charId2 = getED(theOtherPlayer, "dbid")
				number2 = getED(theOtherPlayer, "callingwith")
				number1Test = getED(theOtherPlayer, "calling")
			end

			if tonumber(charId2) and tonumber(number2) and tonumber(number1Test) and tonumber(number1Test) == tonumber(number1) and tonumber(number2Test) == tonumber(number2) then
				
				if not phoneLogs[charId2] then
					phoneLogs[charId2] = {}
				end

				if not phoneLogs[charId2][number2] then
					phoneLogs[charId2][number2] = {}
				end

				if not phoneLogs[charId2][number2][type] then
					phoneLogs[charId2][number2][type] = {}
				end

				if not phoneLogs[charId2][number2][type][number1] then
					phoneLogs[charId2][number2][type][number1] = {}
				end

				local message2 = ""
				if starting then
					message2 = "\nINCOMING "..(type == "Calls" and "CALL" or "SMS").." FROM #"..number1.." ("..string.upper(exports.global:getPlayerName(thePlayer))..") TO #"..number2Test.." ("..string.upper(exports.global:getPlayerName(theOtherPlayer))..") AT ".. getCurrentDateTimeText()..":"
				else
					message2 = "<- "..message
				end
				outputDebugString("wrote "..charId2.."->"..number2.."->"..type.."->"..number1.."-> '"..message2.."'")
				table.insert(phoneLogs[charId2][number2][type][number1], message2)
			end
		end
	end
end

function writeCellphoneLogToClient(thePlayer)
	local cellphone_log = getED(thePlayer, "cellphone_log")
	if cellphone_log == "0" then
		return false
	end
	local charId = getED(thePlayer, "dbid")
	local number = getED(thePlayer, "callingwith")
	local toNumber = getED(thePlayer, "calling")
	
	if phoneLogs[charId] and phoneLogs[charId][number] then
		if phoneLogs[charId][number]["Calls"] then
			if phoneLogs[charId][number]["Calls"][toNumber] then
				local convs = phoneLogs[charId][number]["Calls"][toNumber]
				triggerClientEvent(thePlayer, "phone:writeCellphoneLog", thePlayer, convs, number, "Calls", toNumber)
				phoneLogs[charId][number]["Calls"][toNumber] = nil
			end
		end
		if phoneLogs[charId][number]["SMS"] then
			if phoneLogs[charId][number]["SMS"][toNumber] then
				local convs = phoneLogs[charId][number]["SMS"][toNumber]
				triggerClientEvent(thePlayer, "phone:writeCellphoneLog", thePlayer, convs, number, "SMS", toNumber)
				phoneLogs[charId][number]["SMS"][toNumber] = nil
			end
		end
	end
end
addCommandHandler("writephonelogs", writeCellphoneLogToClient)

function getCurrentDateTimeText()
	local time = getRealTime()
	yearday = time.yearday
	hour = time.hour
	local timeResult = ( "%02d:%02d %02d/%02d/%04d" ):format(time.hour, time.minute, time.monthday, time.month + 1, time.year + 1900 )
	return timeResult
end
