-- Xenius
local sx,sy = guiGetScreenSize()
local resStat = false
local serverStats = nil
local serverColumns, serverRows = {}, {}
local timer
addCommandHandler("stat", function()
	resStat = not resStat
	if resStat then
		if exports.integration:isPlayerScripter(localPlayer) or exports.integration:isPlayerTester(localPlayer) then
			resStat = true
			addEventHandler("onClientRender", root, resStatRender)
			triggerServerEvent("getServerStat", localPlayer)
			timer = setTimer(updateClientStat, 2000, 0)
		else
			resStat = false
		end
	else
		if isTimer(timer) then
			killTimer(timer)
		end
		removeEventHandler("onClientRender", root, resStatRender)
		serverStats = false
		serverColumns, serverRows = {}, {}
		triggerServerEvent("destroyServerStat", localPlayer)
	end
end)

function updateClientStat()
	_, clientRows = getPerformanceStats("Lua timing")
end

addEvent("receiveServerStat", true)
addEventHandler("receiveServerStat", root, function(stat1,stat2)
	serverStats = true
	serverColumns, serverRows = stat1,stat2
end)

local thisRes = getResourceName(getThisResource())
function resStatRender()
	local x = sx-300
	if #serverRows == 0 then
		x = sx-140
	end
	local height = (15*#clientRows)
	local y = sy/2-height/2
	if #serverRows == 0 then
		dxDrawText("Client (res:cpu)",sx-75,y-20,sx-75,y-20,tocolor(255,255,255,255),1.2,"default_bold","center")
	else
		dxDrawText("Client (res:cpu)",sx-235,y-20,sx-235,y-20,tocolor(255,255,255,255),1.2,"default_bold","center")
	end
	dxDrawRectangle(x-10,y,150,height,tocolor(0,0,0,150))
	y = y + 5
	for i, row in ipairs(clientRows) do
		if row[1] ~= thisRes then
			local text = row[1]:sub(0,15)..": "..row[2]
			dxDrawText(text,x+1,y+1,150,15,tocolor(0,0,0,255),1,"default_bold")
			dxDrawText(text,x,y,150,15,tocolor(255,255,255,255),1,"default_bold")
		end
		y = y + 15
	end
	
	if #serverRows ~= 0 then
		local x = sx-140
		local height = (15*#serverRows)
		local y = sy/2-height/2
		dxDrawText("Server (res:cpu)",sx-75,y-20,sx-75,y-20,tocolor(255,255,255,255),1.2,"default_bold","center")
		dxDrawRectangle(x-10,y,150,height+15,tocolor(0,0,0,150))
		y = y + 5
		for i, row in ipairs(serverRows) do
			if row[1] ~= thisRes then
				local text = row[1]:sub(0,15)..": "..row[2]
				dxDrawText(text,x+1,y+1,150,15,tocolor(0,0,0,255),1,"default_bold")
				dxDrawText(text,x,y,150,15,tocolor(255,255,255,255),1,"default_bold")
			end
			y = y + 15
		end
	end
end