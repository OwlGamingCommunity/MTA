--[[--------------------------------------------------
	GUI Editor
	client
	output.lua
	
	create the code output window
--]]--------------------------------------------------


Output = {
	gui = {},
	restoreData = {},
}

local GenerateBasicLuaCode = true


addEvent("guieditor:client_saveSuccess", true)
addEventHandler("guieditor:client_saveSuccess", root,
	function(filename)
		ContextBar.add("Successfully saved to file '"..tostring(filename).."'")
	end
)


addEvent("guieditor:client_saveFailure", true)
addEventHandler("guieditor:client_saveFailure", root,
	function(filename)
		local mbox = MessageBox_Info:create("Could not save", "Could not save to file\n'"..tostring(filename).."'\n\nPlease check ACL permissions")
		ContextBar.add("Could not save to file '"..tostring(filename).."'")
	end
)


function Output.create()
	Output.gui.wndMain = guiCreateWindow((gScreen.x - 550) / 2, (gScreen.y - 350) / 2, 550, 350, "Output", false)
	guiWindowTitlebarButtonAdd(Output.gui.wndMain, "Close", "right", Output.close)
	guiWindowTitlebarButtonAdd(Output.gui.wndMain, "Refresh", "left", Output.generateCode)
	guiWindowTitlebarButtonAdd(Output.gui.wndMain, "Copy all", "left", 
		function()
			guiSetProperty(Output.gui.memOutput, "CaratIndex", 0)
			guiSetProperty(Output.gui.memOutput, "SelectionLength", guiGetText(Output.gui.memOutput):len())
			setClipboard(guiGetText(Output.gui.memOutput))
			ContextBar.add("Output code copied to clipboard")
		end
	)
	guiWindowTitlebarButtonAdd(Output.gui.wndMain, "Maximise", "right",
		function(label)
			-- we are maximise, so restore to saved state
			if Output.restoreData.x then
				guiWindowSetSizable(Output.gui.wndMain, true)
				Output.sizeAndMove(Output.restoreData.w, Output.restoreData.h, Output.restoreData.x, Output.restoreData.y)
				Output.restoreData = {}
				guiSetText(label, "Maximise")
				return
			end
			
			-- otherwise store current state and maximise
			Output.restoreData.x, Output.restoreData.y = guiGetPosition(Output.gui.wndMain, false)
			Output.restoreData.w, Output.restoreData.h = guiGetSize(Output.gui.wndMain, false)
			
			Output.sizeAndMove(gScreen.x, gScreen.y, 0, 0)
			guiWindowSetSizable(Output.gui.wndMain, false)
			
			guiSetText(label, "Restore")
		end, "__self"
	)
	setElementData(Output.gui.wndMain, "guiSizeMinimum", {w = 460, h = 300})
	-- the getter/setter pair for this only works on managed() elements, so just bypass
	setElementData(Output.gui.wndMain, "guieditor:windowSizable", true)
	
	Output.gui.memOutput = guiCreateMemo(10, 25, 530, 275, "", false, Output.gui.wndMain)
	guiMemoSetReadOnly(Output.gui.memOutput, true)
	setElementData(Output.gui.memOutput, "guiSnapTo", {[gGUISides.left] = 10, [gGUISides.right] = 10, [gGUISides.top] = 25, [gGUISides.bottom] = 50})
	

	Output.gui.imgWarningBackground = guiCreateStaticImage(0, 250, 530, 25, "images/dot_white.png", false, Output.gui.memOutput)
	guiSetProperty(Output.gui.imgWarningBackground, "MousePassThroughEnabled", "True")
	setElementData(Output.gui.imgWarningBackground, "guiSnapTo", {[gGUISides.left] = 0, [gGUISides.right] = 0, [gGUISides.bottom] = 0})
	guiSetProperty(Output.gui.imgWarningBackground, "ImageColours", string.format("tl:00%s tr:00%s bl:FF%s br:FF%s", unpack(gAreaColours.darkPacked)))

	Output.gui.lblWarning = guiCreateLabel(20, 260, 490, 15, "Note: Some of your GUI elements are still using default variable names.", false, Output.gui.memOutput)
	guiLabelSetHorizontalAlign(Output.gui.lblWarning, "center", false)
	guiLabelSetVerticalAlign(Output.gui.lblWarning, "top")
	guiSetColour(Output.gui.lblWarning, unpack(gColours.primary))
	setRolloverColour(Output.gui.lblWarning, gColours.secondary, gColours.primary)
	guiSetFont(Output.gui.lblWarning, "default-bold-small")
	--guiSetProperty(Output.gui.lblWarning, "MousePassThroughEnabled", "True")
	setElementData(Output.gui.lblWarning, "guiSnapTo", {[gGUISides.left] = 20, [gGUISides.right] = 20, [gGUISides.bottom] = 0})	
	
	addEventHandler("onClientGUIClick", Output.gui.lblWarning,
		function(button, state)
			if button == "left" and state == "up" then
				if #Generation.elementsUsingDefaultVariables > 0 then
					for i,element in ipairs(Generation.elementsUsingDefaultVariables) do
						addToSelectionList(element, 20)
					end	
					
					if Output.gui.lblWarningTimer and isTimer(Output.gui.lblWarningTimer) then
						killTimer(Output.gui.lblWarningTimer)
					end
					
					Output.gui.lblWarningTimer = setTimer(
						function() 
							for i,element in ipairs(Generation.elementsUsingDefaultVariables) do
								removeFromSelectionList(element)
							end	
						end, 
					3000, 1) 
				end
			end
		end
	, false)

	Output.hideWarning()
	
	
	Output.gui.btnOutput = guiCreateButton(450, 310, 90, 30, "Output to file", false, Output.gui.wndMain)
	setElementData(Output.gui.btnOutput, "guiSnapTo", {[gGUISides.bottom] = 10, [gGUISides.right] = 10})
	
	addEventHandler("onClientGUIClick", Output.gui.btnOutput,
		function(button, state)
			if button == "left" and state == "up" then
				local filepath = guiGetText(Output.gui.edtFileName)
				
				if filepath ~= "" then
					local chunks = Output.chunkText(guiGetText(Output.gui.memOutput))
					
					for i,chunk in ipairs(chunks) do
						triggerServerEvent("guieditor:server_output", localPlayer, filepath, chunk, i, #chunks)
					end
				else
					local mbox = MessageBox_Info:create("Output file", "You have not entered an output filename")
				end
			end
		end
	,false)	
	
	Output.gui.edtFileName = guiCreateEdit(200, 313, 200, 24, ":"..tostring(getResourceName(resource)).."/output/GUI_output", false, Output.gui.wndMain)
	setElementData(Output.gui.edtFileName, "guiSnapTo", {[gGUISides.bottom] = 13, [gGUISides.left] = 200, [gGUISides.right] = 150})

	Output.gui.lblFileName = guiCreateLabel(135, 309, 60, 30, "Filename:", false, Output.gui.wndMain)
	guiLabelSetHorizontalAlign(Output.gui.lblFileName, "right", false)
	guiLabelSetVerticalAlign(Output.gui.lblFileName, "center")
	setElementData(Output.gui.lblFileName, "guiSnapTo", {[gGUISides.bottom] = 11})
	
	Output.gui.chkGenerateLua = guiCreateCheckBox(10, 310, 100, 30, "Generate basic\nlua code", GenerateBasicLuaCode, false, Output.gui.wndMain)
	setElementData(Output.gui.chkGenerateLua, "guiSnapTo", {[gGUISides.bottom] = 10})
	
	addEventHandler("onClientGUIClick", Output.gui.chkGenerateLua,
		function(button, state)
			if button == "left" and state == "up" then
				Generation.usingBasicCode = guiCheckBoxGetSelected(source)
				Output.generateCode()
			end
		end
	,false)
	
	Output.gui.imgDividerLeftTop = guiCreateStaticImage(125, 310, 1, 15, "images/dot_white.png", false, Output.gui.wndMain)
	Output.gui.imgDividerLeftBottom = guiCreateStaticImage(125, 325, 1, 15, "images/dot_white.png", false, Output.gui.wndMain)
	setElementData(Output.gui.imgDividerLeftTop, "guiSnapTo", {[gGUISides.bottom] = 25})
	setElementData(Output.gui.imgDividerLeftBottom, "guiSnapTo", {[gGUISides.bottom] = 10})
	guiSetProperty(Output.gui.imgDividerLeftTop, "ImageColours", string.format("tl:55%s tr:55%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Output.gui.imgDividerLeftBottom, "ImageColours", string.format("tl:FF%s tr:FF%s bl:55%s br:55%s", unpack(gAreaColours.primaryPacked)))
	
	Output.gui.imgDividerRightTop = guiCreateStaticImage(425, 310, 1, 15, "images/dot_white.png", false, Output.gui.wndMain)
	Output.gui.imgDividerRightBottom = guiCreateStaticImage(425, 325, 1, 15, "images/dot_white.png", false, Output.gui.wndMain)
	setElementData(Output.gui.imgDividerRightTop, "guiSnapTo", {[gGUISides.bottom] = 25, [gGUISides.right] = 125})
	setElementData(Output.gui.imgDividerRightBottom, "guiSnapTo", {[gGUISides.bottom] = 10, [gGUISides.right] = 125})
	guiSetProperty(Output.gui.imgDividerRightTop, "ImageColours", string.format("tl:55%s tr:55%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Output.gui.imgDividerRightBottom, "ImageColours", string.format("tl:FF%s tr:FF%s bl:55%s br:55%s", unpack(gAreaColours.primaryPacked)))	
	
	guiSetVisible(Output.gui.wndMain, false)
	doOnChildren(Output.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
end



function Output.show(text, defaultVariables)
	if not Output.gui.wndMain then
		Output.create()
	end
	
	guiSetText(Output.gui.memOutput, text or "")

	-- don't try to resize if resizing is turned off, usually means that the window is maximised
	if Settings.loaded.output_window_autosize.value and guiWindowGetSizable(Output.gui.wndMain) then	
		if not guiGetVisible(Output.gui.wndMain) then
			local w, h = guiGetSize(Output.gui.wndMain, false)
			local x, y = guiGetPosition(Output.gui.wndMain, false)
			local centered = x == (gScreen.x - w) / 2 and y == (gScreen.y - h) / 2
			
			-- 20 for gap between memo and window, 20 for memo internal borders (including scrollbar), 10 for good measure
			if (Generation.biggestWidth + 50) > w then		
				Output.sizeAndMove(Generation.biggestWidth + 50, h, centered and (gScreen.x - (Generation.biggestWidth + 50)) / 2 or x, centered and (gScreen.y - h) / 2 or y)
			end
		end
	end
	
	if defaultVariables then
		Output.showWarning()
	else
		Output.hideWarning()
	end
	
	guiSetVisible(Output.gui.wndMain, true)
	guiBringToFront(Output.gui.wndMain)
end	


function Output.close()
	guiSetVisible(Output.gui.wndMain, false)
end


function Output.showWarning()
	guiSetVisible(Output.gui.lblWarning, true)
	guiSetVisible(Output.gui.imgWarningBackground, true)
end


function Output.hideWarning()
	guiSetVisible(Output.gui.lblWarning, false)
	guiSetVisible(Output.gui.imgWarningBackground, false)
end


function Output.generateCode()
	if not Output.gui.wndMain then
		Generation.usingBasicCode = GenerateBasicLuaCode
	end
	
	local code, defaultVariables = Generation.generateCode()
	
	Output.show(code, defaultVariables)
end


function Output.chunkText(text)
	local chunks = {}
	local size = 65500
				
	while text:len() > size do
		chunks[#chunks + 1] = text:sub(0, size)
		text = text:sub(size + 1)
	end
						
	chunks[#chunks + 1] = text
	
	return chunks
end

function Output.sizeAndMove(w, h, x, y)
	guiSetSize(Output.gui.wndMain, w, h, false)
	-- trigger this event to force all the child elements to reposition properly
	triggerEvent("onClientGUISize", Output.gui.wndMain)
	
	if x and y then
		guiSetPosition(Output.gui.wndMain, x, y, false)
	end
end

--[[
addEventHandler("onClientKey", root,
	function()
		if Output.gui.wndMain and guiGetVisible(Output.gui.wndMain) then
			
		end
	end
)]]