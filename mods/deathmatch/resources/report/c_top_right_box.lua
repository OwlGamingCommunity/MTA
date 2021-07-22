local localPlayer = getLocalPlayer()
local show = false
local width, height = 500,300

local sx, sy = guiGetScreenSize()
local content = {}
local thisResourceElement = getResourceRootElement(getThisResource())

function drawOverlayTopRight(info, widthNew, woffsetNew, hoffsetNew, cooldown)
	if showTopRightReportBox(localPlayer) then
		content = info
		if tonumber(widthNew) then
			width = tonumber(widthNew)
		end
	end
end
addEvent("report-system:drawOverlayTopRight", true)
addEventHandler("report-system:drawOverlayTopRight", localPlayer, drawOverlayTopRight)

addEventHandler("onClientRender",getRootElement(), function ()
	if showTopRightReportBox(localPlayer) and not getElementData(localPlayer, "integration:previewPMShowing") and exports.hud:isActive() then 
		if (getElementData(localPlayer, "loggedin") == 1) and ( getPedWeapon( localPlayer ) ~= 43 or not getPedControlState( localPlayer, "aim_weapon" ) ) and not isPlayerMapVisible() then
			local woffset, hoffset = 0, 40
			local hudDxHeight = getElementData(localPlayer, "hud:whereToDisplayY") or 0
			if hudDxHeight then
				hoffset = hoffset + hudDxHeight
			end
	
			local heightTemp = 16*(#content)+30
			dxDrawRectangle(sx-width-5+woffset, 5+hoffset, width, heightTemp , tocolor(0, 0, 0, 100), false)
			setElementData(localPlayer, "report-system:dxBoxHeight", heightTemp+hoffset-35, false)
			
			for i=1, #content do
				if content[i] then
					dxDrawText( content[i][1] or "" , sx-width+10+woffset, (16*i)+hoffset, width-5, 15, tocolor ( content[i][2] or 255, content[i][3] or 255, content[i][4] or 255, content[i][5] or 255 ), content[i][6] or 1, content[i][7] or "default" )
				end
			end
		end
	else
		setElementData(localPlayer, "report-system:dxBoxHeight", 0, false)
	end
end, false)

addEventHandler( "onClientElementDataChange", getResourceRootElement(getThisResource()) , 
	function(n)
		if n == "urAdmin" or n == "urGM" or n == "allReports" then
			if getElementData(localPlayer,"report:topRight") == 1 then
				drawOverlayTopRight(getElementData(thisResourceElement, "urAdmin") or false, 550)
			elseif getElementData(localPlayer,"report:topRight") == 2 then
				drawOverlayTopRight(getElementData(thisResourceElement, "urGM") or false, 550)
			elseif getElementData(localPlayer,"report:topRight") == 3 then
				drawOverlayTopRight(getElementData(thisResourceElement, "allReports") or false, 600)
			end
		end
	end, false
)

function startAutoUpdate()
	--[[if exports.integration:isPlayerTrialAdmin(localPlayer) then
		setElementData(localPlayer, "report:topRight", 1, true)
	elseif exports.integration:isPlayerSupporter(localPlayer) then
		setElementData(localPlayer, "report:topRight", 2, true)
	else
		setElementData(localPlayer, "report:topRight", 3, true)
	end]]
	if exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerSupporter(localPlayer) then
        setElementData(localPlayer, "report:topRight", 3, true)
    end
end
addEventHandler("onClientResourceStart", thisResourceElement, startAutoUpdate)