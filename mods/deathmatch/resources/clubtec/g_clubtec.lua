--clubtec
--Script that adds functionality for a range of items
--Created by Exciter, 23.06.2014 (DD.MM.YYYY).

---- SETTINGS ----

--define items that are valid video discs
videoDiscItems = { [165] = true }
--define items that are valid video players
videoPlayerItems = { [166] = true }

--define characters to grant access to advanced options
clubTecChars = {
	["Jacob_Goldsmith"] = true,
}

shaderDataDefault = { brightness = -0.25, scrollX = 0, scrollY = 0, xScale = 1, yScale = 1, rotAngle = 0, alpha = 1, grayScale = 0, redColor = 0, grnColor = 0, bluColor = 0, xOffset = 0, yOffset = 0, speed = false }

---- END SETTINGS ----

function isClubtecGuy(thePlayer)
	if getElementData(thePlayer,"loggedin") ~= 1 then return false end
	local charName = getPlayerName(thePlayer)
	if exports.integration:isPlayerScripter(thePlayer) then return true else return false end
end

function isVideoDisc(itemID)
	return videoDiscItems[itemID] or false
end

function isVideoPlayer(element)
	if isElement(element) then
		if getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("item-world")) then
			local itemID = tonumber(getElementData(element, "itemID")) or 0
			if videoPlayerItems[itemID] then
				return true
			end
		end
	else
		local itemID = tonumber(element) or 0
		if videoPlayerItems[itemID] then
			return true
		end
	end
	return false
end

function getVideoPlayerItems()
	return videoPlayerItems
end