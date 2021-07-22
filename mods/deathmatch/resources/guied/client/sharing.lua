--[[--------------------------------------------------
	GUI Editor
	client
	sharing.lua
	
	manages code sharing
--]]--------------------------------------------------


Share = {
    gui = {},
	players = {},
	received = {},
}

addEvent("guieditor:client_receiveShareNotification", true)
addEventHandler("guieditor:client_receiveShareNotification", root,
	function(from)
		if from and exists(from) then
			if not Share.players[from] then
				Share.players[from] = {}
			end
							
			Share.players[from].viewing = true
			
			Share.populate()
		end
	end
)


addEvent("guieditor:client_receiveShare", true)
addEventHandler("guieditor:client_receiveShare", root,
	function(from, chunk, chunkID, chunks)
		if not Share.received[from] then
			Share.received[from] = {parts = {[chunkID] = chunk}, start = getTickCount()}
		else
			-- if all the chunks have not arrived in 5 seconds, assume they never will
			if (Share.received[from].start + 5000) < getTickCount() then
				Share.received[from] = {parts = {[chunkID] = chunk}, start = getTickCount()}
			else
				Share.received[from].parts[chunkID] = chunk
			end
		end

		if #Share.received[from].parts == chunks then
			if Share.gui.wndShare then
				guiSetText(Share.gui.memShare, table.concat(Share.received[from].parts, ""))
				guiSetText(Share.gui.wndShare, "Shared by "..getPlayerName(from))
				return
			end
			
			Share.gui.wndShare = guiCreateWindow((gScreen.x - 600) / 2, (gScreen.y - 400) / 2, 600, 400, "Shared by "..getPlayerName(from), false)
			guiWindowTitlebarButtonAdd(Share.gui.wndShare, "Close", "right", function() destroyElement(Share.gui.wndShare) Share.gui.wndShare = nil end)
			guiWindowTitlebarButtonAdd(Share.gui.wndShare, "Load this code", "left", 
				function() 
					local ran, e = loadGUICode(guiGetText(Share.gui.memShare))
					
					if not ran then
						local mbox = MessageBox_Info:create("Error", "Could not properly load code\n\n"..tostring(e))
					else
						ContextBar.add("Successfully loaded shared GUI code")
					end					
				end
			)				
			guiWindowTitlebarButtonAdd(Share.gui.wndShare, "Copy all", "left", 
				function()
					guiSetProperty(Share.gui.memShare, "CaratIndex", 0)
					guiSetProperty(Share.gui.memShare, "SelectionLength", guiGetText(Share.gui.memShare):len())
					setClipboard(guiGetText(Share.gui.memShare))
					ContextBar.add("Code copied to clipboard")
				end
			)						
			setElementData(Share.gui.wndShare, "guiSizeMinimum", {w = 350, h = 200})
						
			Share.gui.memShare = guiCreateMemo(10, 25, 580, 375, table.concat(Share.received[from].parts, ""), false, Share.gui.wndShare)
			guiSetReadOnly(Share.gui.memShare, true)
			setElementData(Share.gui.memShare, "guiSnapTo", {[gGUISides.left] = 10, [gGUISides.right] = 10, [gGUISides.top] = 25, [gGUISides.bottom] = 10})
		
			guiBringToFront(Share.gui.wndShare)
			doOnChildren(Share.gui.wndShare, setElementData, "guieditor.internal:noLoad", true)
		end
	end
)


function Share.create()
	Share.gui.wndMain = guiCreateWindow(gScreen.x - 250 - 10, (gScreen.y - 390) / 2, 250, 390, "GUI Share", false)
	guiWindowSetSizable(Share.gui.wndMain, false)
	guiWindowTitlebarButtonAdd(Share.gui.wndMain, "Close", "right", Share.close)

	Share.gui.grdMain = guiCreateGridList(10, 25, 230, 330, false, Share.gui.wndMain)
	guiGridListAddColumn(Share.gui.grdMain, "Players", 0.5)
	guiGridListAddColumn(Share.gui.grdMain, "Shared", 0.18)
	guiGridListAddColumn(Share.gui.grdMain, "Viewing", 0.18)
	guiSetProperty(Share.gui.grdMain, "ColumnsSizable", "False")
	guiSetProperty(Share.gui.grdMain, "ColumnsMovable", "False")
	
	Share.gui.lblCover = guiCreateLabel(0, 0, 230, 25, "", false, Share.gui.grdMain)
	guiSetProperty(Share.gui.lblCover, "AlwaysOnTop", "True")
	
	Share.gui.btnView = guiCreateButton(10, 360, 90, 20, "View", false, Share.gui.wndMain)
	
	addEventHandler("onClientGUIClick", Share.gui.btnView, 
		function(button, state)
			if button == "left" and state == "up" then
				local row, col = guiGridListGetSelectedItem(Share.gui.grdMain)
				
				if row and col and row ~= -1 and col ~= -1 then		
					local name = guiGridListGetItemText(Share.gui.grdMain, row, col)
					
					if name then
						local player = getPlayerFromName(name)
						
						if player and exists(player) and Share.players[player] and Share.players[player].viewing then
							triggerServerEvent("guieditor:server_requestShare", localPlayer, player)
						else
							local mbox = MessageBox_Info:create("Error", "'"..name.."'\nis not sharing their\nGUI with you")
						end
					end
				end				
			end
		end
	, false)
	
	Share.gui.btnShare = guiCreateButton(150, 360, 90, 20, "Share", false, Share.gui.wndMain)
	
	addEventHandler("onClientGUIClick", Share.gui.btnShare, 
		function(button, state)
			if button == "left" and state == "up" then
				local row, col = guiGridListGetSelectedItem(Share.gui.grdMain)
				
				if row and col and row ~= -1 and col ~= -1 then		
					local name = guiGridListGetItemText(Share.gui.grdMain, row, col)
					
					if name then
						local player = getPlayerFromName(name)
						
						if player and exists(player) then
							local genLua = Generation.usingBasicCode
							Generation.usingBasicCode = false
							
							local code = Generation.generateCode()
							
							Generation.usingBasicCode = genLua
						
							local chunks = Output.chunkText(code)
						
							for i,chunk in ipairs(chunks) do
								triggerServerEvent("guieditor:server_sendShare", localPlayer, player, chunk, i, #chunks)
							end
							
							if not Share.players[player] then
								Share.players[player] = {}
							end
							
							Share.players[player].shared = true
							
							Share.populate()

							-- doesn't work without the timer
							setTimer(
								function()
									guiGridListSetSelectedItem(Share.gui.grdMain, row, col)
								end, 
							50, 1)
						end
					end
				end
			end
		end
	, false)	
	
	guiSetVisible(Share.gui.wndMain, false)
	doOnChildren(Share.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
end



function Share.populate()
	if not Share.gui.wndMain then
		return
	end
	
	if not guiGetVisible(Share.gui.wndMain) then
		return
	end
	
	guiGridListClear(Share.gui.grdMain)

	for i,v in ipairs(getElementsByType("player")) do
		local row = guiGridListAddRow(Share.gui.grdMain)
		
		guiGridListSetItemText(Share.gui.grdMain, row, 1, getPlayerName(v), false, false)
		
		if Share.players[v] then
			if Share.players[v].shared then
				guiGridListSetItemText(Share.gui.grdMain, row, 2, "yes", false, false)
			end
			
			if Share.players[v].viewing then
				guiGridListSetItemText(Share.gui.grdMain, row, 3, "yes", false, false)
			end
		end
	end	
end


function Share.open()
	if not Share.gui.wndMain then
		Share.create()
	end
	
	guiSetVisible(Share.gui.wndMain, true)
	
	Share.populate()
end


function Share.close()
	if not Share.gui.wndMain then
		return
	end
	
	guiSetVisible(Share.gui.wndMain, false)
	
	if Share.gui.wndShare then
		destroyElement(Share.gui.wndShare) 
		Share.gui.wndShare = nil
	end
end


addEventHandler("onClientPlayerQuit", root,
	function()
		if Share.players[source] then
			Share.players[source] = nil
			
			Share.populate()
		end
	end
)


addEventHandler("onClientPlayerJoin", root,
	function()
		Share.populate()
	end
)