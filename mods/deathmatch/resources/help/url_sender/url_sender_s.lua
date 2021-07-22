--MAXIME
local coolDownTime = 3 --seconds
local coolDown = {}
function startUrlSender(theSender, cmd, reciever, url)
	

	local printError = function(code)
		if code == 1 then
			outputChatBox("Player is not logged in.", theSender, 255, 0, 0)
		else
			outputChatBox("SYNTAX: /" .. cmd .. " [Partial Player Nick] [URL]", theSender, 255, 194, 14)
		end
	end
	if not reciever or not url then
		printError()
		return false
	end

	local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(theSender, reciever)
	if not targetPlayer then
		return false
	end

	if getElementData(targetPlayer, "loggedin") ~= 1 then
		printError(1)
		return false
	end

	if not coolDown[theSender] then 
		coolDown[theSender] = {}
	end

	if coolDown[theSender][targetPlayer] then
		if getTickCount() - coolDown[theSender][targetPlayer] < coolDownTime*1000 then
			outputChatBox("You can send to a certain player only one URL every "..coolDownTime.." second(s).", theSender, 255, 0, 0)
			return false
		end
	end

	coolDown[theSender][targetPlayer] = getTickCount()

	triggerClientEvent(targetPlayer, "showUrlSender", theSender, url)
end
--Temporarity disabled because it bypass pm blocker.
--addCommandHandler("link", startUrlSender)
--addCommandHandler("url", startUrlSender)