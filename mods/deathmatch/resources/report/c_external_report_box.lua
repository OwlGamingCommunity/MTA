--MAXIME
local localPlayer = getLocalPlayer()
local show = false
local width, height = 650,300
local woffset, hoffset = 0, 0
local sx, sy = guiGetScreenSize()
local content = {}
local line = 15
local thisResourceElement = getResourceRootElement(getThisResource())
local BizNoteFont18 = dxCreateFont ( ":resources/BizNote.ttf" , 18 )

function updateOverlay(info, widthNew, woffsetNew, hoffsetNew)
	if showExternalReportBox(localPlayer) then
		if info then
			outputConsole(info)
			table.insert(content, info)
			playSoundFrontEnd ( 101 )
		end
		if widthNew then
			width = widthNew
		end
		if woffsetNew then
			woffset = woffsetNew
		end
		if hoffsetNew then
			hoffset = hoffsetNew
		end
	end
end
addEvent("report-system:updateOverlay", true)
addEventHandler("report-system:updateOverlay", localPlayer, updateOverlay)

addEventHandler( "onClientElementDataChange", thisResourceElement , 
	function(n)
		if n == "reportPanel" then
			updateOverlay(getElementData(thisResourceElement, "reportPanel") or false)
		end
	end, false
)

--THIS WERE USED TO AUTO TURN ON REPORT PANEL WHICH IS ANNOYING AS FUCK / MAXIME
--[[addEventHandler( "onClientElementDataChange", localPlayer, 
	function(n)
		if n == "admin_level" or n=="account:gmlevel" or n=="duty_supporter" or n=="duty_admin" then
			if not (exports.integration:isPlayerTrialAdmin(localPlayer) and (getElementData(localPlayer, "duty_admin")==1) ) and not (exports.integration:isPlayerSupporter(localPlayer) and (getElementData(localPlayer, "duty_supporter") == 1))then
				setElementData(localPlayer, "report_panel_mod", false)
				setElementData(localPlayer, "report-system:dxBoxHeight", 0)
			else
				setElementData(localPlayer, "report_panel_mod", true)
			end
		end
	end, false
)

addEventHandler( "onClientResourceStart", thisResourceElement, 
	function()
		if not (exports.integration:isPlayerTrialAdmin(localPlayer) and (getElementData(localPlayer, "duty_admin")==1) ) and not (exports.integration:isPlayerSupporter(localPlayer) and (getElementData(localPlayer, "duty_supporter") == 1))then
			setElementData(localPlayer, "report_panel_mod", false)
			setElementData(localPlayer, "report-system:dxBoxHeight", 0)
		else
			setElementData(localPlayer, "report_panel_mod", true)
		end
	end
, false)
]]

addEventHandler("onClientRender",getRootElement(), function ()
	if showExternalReportBox(localPlayer) and exports.hud:isActive() then 
		if (getElementData(localPlayer, "loggedin") == 1) and( getPedWeapon( localPlayer ) ~= 43 or not getPedControlState( localPlayer, "aim_weapon" ) )  and not isPlayerMapVisible() then
			local w = width
			local h = 16*(line)+30
			local posX = (sx/2)-(w/2)+woffset
			local sy1 = getElementData(localPlayer, "recon:whereToDisplayY") or sy
			if sy1 ~= sy then
				sy1 = sy1 + 25
			end
			local posY = sy1-(h+30)+hoffset 
			
			dxDrawRectangle(posX, posY , w, h , tocolor(0, 0, 0, 100), false)
			
			dxDrawText( "Report Panel" , posX+16, posY+16, w-5, 5, tocolor ( 70, 200, 30, 255 ), 1, BizNoteFont18 )
			--dxDrawText( "(Press F5 to toggle this window)" , posX+110, posY+20, w-5, 5, tocolor ( 250, 250, 250, 255 ), 1 )
			dxDrawText( "RP" , posX+540, posY, w-5, 5, tocolor ( 255, 255, 255, 20 ), 1)
			
			local lastIndex = #content
			local count = 1
			for i = (lastIndex-line+2), (lastIndex) do
				if content[i] then
					dxDrawText( content[i][1] or "" , posX+16, posY+(15*count)+30, w-5, 15, tocolor ( content[i][2] or 255, content[i][3] or 255, content[i][4] or 255, content[i][5] or 255 ), content[i][6] or 1, content[i][7] or "default" )
					count = count + 1
				end
			end
		end
	end
end, false)

--[[
function togAdminPanel()
	if exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerSupporter(localPlayer) then
		local currentState = getElementData(localPlayer, "report_panel_mod") or false
		setElementData(localPlayer, "report_panel_mod", not currentState)
	end
end
bindKey ( "F5", "down" , togAdminPanel)
]]
