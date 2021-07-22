--[[--------------------------------------------------
	GUI Editor
	client
	tutorial_properties.lua
	
	tutorial explaining properties in more depth
--]]--------------------------------------------------


function Tutorial.constructors.properties()
	local t = Tutorial:create("properties", "Properties", true)
	
	local pageIntro = t:addPage("What are properties?", [[Properties are an advanced feature exposing extra settings that can be applied to a GUI element.
	
	They allow you to make changes to an element that are not managed by default MTA functions.
	
	As a result, some of them do not work and many often require much more complex inputs than regular MTA functions.
	
	You should experiment to find out what they all do, and which ones do not work.
	]]
	)
	
	local pageExample = t:addPage("How about an example", [[
	Using the property "NormalTextColour" you can change the text colour of a Button, even when there is no specific MTA function to do so.
	
	Unlike most colour-related functions, this property takes a colour as a string, with each alpha/red/green/blue component represented in hexadecimal format.
	
	For example, red would be set as "FFFF0000"
	(meaning '[alpha][red][green][blue]') 
	]]
	)
	
	local btnExample = guiCreateButton(60, 190, 140, 25, "Example", false, pageExample.body)
	guiSetProperty(btnExample, "NormalTextColour", "FFFF0000")
	setElementData(btnExample, "guieditor.internal:noLoad", true)
	
	
	local pageConclusion = t:addPage("Conclusion", [[
	While some are unsupported or simply do not work, properties are a great way to find extra functionality that you otherwise might not have. 
	
	Right clicking on any element within the GUI Editor and selecting 'Properties' will allow you to inspect and manipulate the properties for that element.
	
	You can get to this information again by clicking 'Help' in the top-right of the properties window.
	]]
	)
end


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		Tutorial.constructors.properties()
	end
)