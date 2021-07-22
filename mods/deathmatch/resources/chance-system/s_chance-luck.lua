function tryLuck(thePlayer, commandName , pa1, pa2)
	local p1, p2, p3 = nil
	p1 = tonumber(pa1)
	p2 = tonumber(pa2)
	if pa1 == nil and pa2 == nil and pa3 == nil then
		exports.global:sendLocalText(thePlayer, "((OOC Luck)) "..getPlayerName(thePlayer):gsub("_", " ").." tries their luck from 1 to 100 and gets "..math.random(100)..".", 255, 51, 102, 30, {}, true)
	elseif pa1 ~= nil and p1 ~= nil and pa2 == nil then
		exports.global:sendLocalText(thePlayer, "((OOC Luck)) "..getPlayerName(thePlayer):gsub("_", " ").." tries their luck from 1 to "..p1.." and gets "..math.random(p1)..".", 255, 51, 102, 30, {}, true)
	else
		outputChatBox("SYNTAX: /" .. commandName.."                  - Get a random number from 1 to 100", thePlayer, 255, 194, 14)
		outputChatBox("SYNTAX: /" .. commandName.." [max]         - Get a random number from 1 to [max]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("luck", tryLuck)

function tryChance(thePlayer, commandName , pa1, pa2)
	local p1, p2, p3 = nil
	p1 = tonumber(pa1)
	p2 = tonumber(pa2)
	if pa1 ~= nil then 
		if pa2 == nil and p1 ~= nil then
			if p1 <= 100 and p1 >=0 then
				if math.random(100) >= p1 then
					exports.global:sendLocalText(thePlayer, "((OOC Chance at "..p1.."%)) "..getPlayerName(thePlayer):gsub("_", " ").."'s attempt has failed.", 255, 51, 102, 30, {}, true)
				else
					exports.global:sendLocalText(thePlayer, "((OOC Chance at "..p1.."%)) "..getPlayerName(thePlayer):gsub("_", " ").."'s attempt has succeeded.", 255, 51, 102, 30, {}, true)
				end
			else
				outputChatBox("Probability must range from 0 to 100%.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("SYNTAX: /" .. commandName.." [0-100%]                 - Chance you will succeed at probability of [0-100%]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("SYNTAX: /" .. commandName.." [0-100%]                 - Chance you will succeed at probability of [0-100%]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("chance", tryChance)

function oocCoin(thePlayer)
	if  math.random( 1, 2 ) == 2 then
		exports.global:sendLocalText(thePlayer, " ((OOC Coin)) " .. getPlayerName(thePlayer):gsub("_", " ") .. " flips an coin, landing on tail.", 255, 51, 102)
	else
		exports.global:sendLocalText(thePlayer, " ((OOC Coin)) " .. getPlayerName(thePlayer):gsub("_", " ") .. " flips an coin, landing on head.", 255, 51, 102)
	end
end
addCommandHandler("flipcoin", oocCoin)