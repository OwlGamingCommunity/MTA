--[[--------------------------------------------------
	GUI Editor
	client
	tutorial_output_type.lua
	
	tutorial (hopefully) explaining the difference between absolute and relative
--]]--------------------------------------------------


local outputTypeTutorial

function Tutorial.constructors.output()
	local t = Tutorial:create("output", "Output Type Tutorial", true)

	
	local pageIntroduction = t:addPage("What is it all about?")
	
	guiSetText(pageIntroduction.body, "The output type defines how the sizes and positions of the element will be calculated within MTA.\n\nThere are two different output types:\n'Absolute'\nand\n'Relative'\n\nEach type behaves slightly differently under different circumstances.")
	
	
	local pageAbsolute = t:addPage("Absolute")
	
	guiSetText(pageAbsolute.body, "Absolute values are represented in pixels, from the top-left corner of the parent element (or screen).\n\nThey will keep exactly the same pixel size at all times, across all resolutions (they will not stretch or shrink).\n\nAbsolute values are easier and cleaner to tweak by hand.\n\nThey are the preferred output type for most situations.")
	

	local pageRelative = t:addPage("Relative")
	
	guiSetText(pageRelative.body, "Relative values are represented as a fraction of the size of the parent, as a number between 0 and 1.\n\nThey will keep exactly the same fraction of the parent size at all times, across all resolutions (they will stretch and shrink).\n\nThey are difficult to tweak by hand.\n\nGenerally, relative values should only be used when they are specifically required. If in doubt, chose absolute!")

	
	local pageDemo = t:addPage("Demonstration")
	
	guiSetText(pageDemo.body, "Absolute:\nx = 20, y = 20, width = 100, height = 100\n\nRelative:\nx = 0.06, y = 0.63, width = 0.3, height = 0.3\n\nUse the controls below to increase or decrease the preview screen resolution.\n\nNotice how the absolute element remains exactly the same, while the relative one stretches according to the screen size.")
	
	local lblSmaller = guiCreateLabel(10, 195, 120, 25, "-", false, pageDemo.body)
	local lblLarger = guiCreateLabel(130, 195, 120, 25, "+", false, pageDemo.body)
	guiSetFont(lblSmaller, "clear-normal")
	guiSetFont(lblLarger, "clear-normal")
	setRolloverColour(lblSmaller, gColours.primary, gColours.defaultLabel)
	setRolloverColour(lblLarger, gColours.primary, gColours.defaultLabel)
	guiLabelSetHorizontalAlign(lblSmaller, "center")
	guiLabelSetVerticalAlign(lblSmaller, "center")
	guiLabelSetHorizontalAlign(lblLarger, "center")
	guiLabelSetVerticalAlign(lblLarger, "center")
		
	addEventHandler("onClientGUIClick", lblSmaller, 
		function(button, state)
			if button == "left" and state == "up" then
				outputTypeTutorial.resolution.x = math.max(outputTypeTutorial.resolution.x - 100, 100)
				outputTypeTutorial.resolution.y = math.max(outputTypeTutorial.resolution.y - 100, 100)
				resolutionPreview.updateResolution(outputTypeTutorial.resolution.x, outputTypeTutorial.resolution.y)
			end
		end
	, false)
		
	addEventHandler("onClientGUIClick", lblLarger, 
		function(button, state)
			if button == "left" and state == "up" then
				outputTypeTutorial.resolution.x = math.min(outputTypeTutorial.resolution.x + 100, 5000)
				outputTypeTutorial.resolution.y = math.min(outputTypeTutorial.resolution.y + 100, 5000)
				resolutionPreview.updateResolution(outputTypeTutorial.resolution.x, outputTypeTutorial.resolution.y)
			end
		end
	, false)

	local resolutionAreaTopLeft = guiCreateStaticImage(0, 195, 130, 1, "images/dot_white.png", false, pageDemo.body)
	local resolutionAreaTopRight = guiCreateStaticImage(130, 195, 130, 1, "images/dot_white.png", false, pageDemo.body)
	local resolutionAreaBottomLeft = guiCreateStaticImage(0, 220, 130, 1, "images/dot_white.png", false, pageDemo.body)
	local resolutionAreaBottomRight = guiCreateStaticImage(130, 220, 130, 1, "images/dot_white.png", false, pageDemo.body)
	local resolutionAreaDivide = guiCreateStaticImage(130, 195, 1, 25, "images/dot_white.png", false, pageDemo.body)
		
	guiSetProperty(resolutionAreaTopLeft, "ImageColours", string.format("tl:00%s tr:FF%s bl:00%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(resolutionAreaTopRight, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(resolutionAreaBottomLeft, "ImageColours", string.format("tl:00%s tr:FF%s bl:00%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(resolutionAreaBottomRight, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))	
	guiSetProperty(resolutionAreaDivide, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))			

	doOnChildren(pageDemo.body, setElementData, "guieditor.internal:noLoad", true)

	local pageConclusion = t:addPage("Conclusion")
	
	guiSetText(pageConclusion.body, "Absolute elements are always the same pixel size, and pixel distance from the parent.\n\nRelative elements are always the same percentage size of the parent, and the same percentage distance from the parent.\n\nIf in doubt, chose absolute!\n\nSelecting 'Preview in Resolution' from the main menu will activate the resolution preview, so you can experiment on your own elements.")
		
		
	t.onPageChange =
		function(newPage, oldPage)
			if newPage == 4 and oldPage ~= 5 then
				outputDemonstrationStart()
			else
				if oldPage and newPage ~= 4 and newPage ~= 5 then
					outputDemonstrationStop()
				end
			end
		end
		
	t.onStop = 
		function()
			outputDemonstrationStop()
		end
		
	t.demonstration = false
	t.resolution = {x = 300, y = 300}	
		
	outputTypeTutorial = t
end


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		Tutorial.constructors.output()
	end
)



function outputDemonstrationStart()
	if outputTypeTutorial.demonstration then
		return
	end

	outputTypeTutorial.demonstration = true
	
	if resolutionPreview.active then
		resolutionPreview.undo()
	end
	

	for _, element in ipairs(guiGetScreenElements()) do	
		if relevant(element) then
			guiSetVisible(element, false)
		end
	end
	
	
	outputTypeTutorial.btnDemonstrationAbsolute = guiCreateButton(20, 20, 100, 100, "Absolute", false)
	setupGUIElement(outputTypeTutorial.btnDemonstrationAbsolute)
	--setElementData(outputTypeTutorial.btnDemonstrationAbsolute, "guieditor.internal:noLoad", true)
	outputTypeTutorial.btnDemonstrationRelative = guiCreateButton(0.06, 0.631, 0.333, 0.333, "Relative", true)
	setupGUIElement(outputTypeTutorial.btnDemonstrationRelative)
	setElementData(outputTypeTutorial.btnDemonstrationRelative, "guieditor:relative", true)
	--setElementData(outputTypeTutorial.btnDemonstrationRelative, "guieditor.internal:noLoad", true)

	resolutionPreview.setResolution(outputTypeTutorial.resolution.x, outputTypeTutorial.resolution.y)
	resolutionPreview.fadeColour = tocolor(0, 0, 0, 80)
	resolutionPreview.setup()
end


function outputDemonstrationStop()
	if outputTypeTutorial.demonstration then
		if resolutionPreview.active then
			resolutionPreview.undo()
			resolutionPreview.setResolution(gScreen.x, gScreen.y)
			resolutionPreview.fadeColour = tocolor(0, 0, 0, 180)
		end
		
		
		for _, element in ipairs(guiGetScreenElements()) do	
			if relevant(element) then
				guiSetVisible(element, true)
			end
		end

		if exists(outputTypeTutorial.btnDemonstrationAbsolute) then
			destroyElement(outputTypeTutorial.btnDemonstrationAbsolute)
			destroyElement(outputTypeTutorial.btnDemonstrationRelative)
			outputTypeTutorial.btnDemonstrationAbsolute = nil
			outputTypeTutorial.btnDemonstrationRelative = nil
		end
		outputTypeTutorial.demonstration = false
	end
end

