function sendBottomNotification(thePlayer, title, content, cooldown, widthNew, woffsetNew, hoffsetNew )--Client-side	
	local info = {
		{title or "", 70,200,14,255,1},
		{""},
	}
	if type(content) == "table" then 
		for i = 1, 20 do 
			if not content[i] then break end
			table.insert(info, {" "..content[i][1] or ""} )
		end
	else
		table.insert(info, {" "..content or ""} )
	end
	triggerEvent("hudOverlay:drawOverlayBottomCenter", thePlayer, info , widthNew, woffsetNew, hoffsetNew, cooldown)
end

function sendTopRightNotification(contentArray, thePlayer, widthNew, posXOffset, posYOffset, cooldown) --Client-side
	triggerEvent("hudOverlay:drawOverlayTopRight", thePlayer, contentArray, widthNew, posXOffset, posYOffset, cooldown)
end