--[[--------------------------------------------------
	GUI Editor
	client
	tutorial_main.lua
	
	main usage tutorial for the editor
--]]--------------------------------------------------


function Tutorial.constructors.main()
	local t = Tutorial:create("main", "Tutorial", true)
	
	local pageIntro = t:addPage("Introduction to the GUI Editor", [[The GUI Editor is a tool to help with the design and creation of GUI.
	
	It allows you to visually create GUI elements, moving and sizing them as you see fit. It presents easy ways for you to manage the various attributes and properties that each element type has, like text and colour.
	
	When your design is finished, it can output your design in Lua code ready for inclusion in your resource scripts.
	
	Things you have previously made can also be loaded into the GUI Editor for further changes.
	]])
	
	local pageTutorial = t:addPage("Tutorial", [[This tutorial will overview the basic functions of the GUI editor.
	
	If you like, you can follow along by creating elements and selecting the relevant right click menu options as you go.
	
	You can close it at any time using the 'Close' button in the top right corner. Almost all windows within the GUI Editor can be closed in a similar way.
	
	There are other tutorials within the GUI Editor that cover specific topics in more detail, so they will not be included in this tutorial.
	]])
	
	local pageElementCreate = t:addPage("Creating a GUI Element", [[To begin, right click on any empty space on the screen to open the main menu.
	
	This menu is the main access point for the GUI Editor; allowing you to create elements, access settings, help and miscellaneous functions.
	
	Using the 'Create' item in the main menu, you can see the sub-menu containing all the GUI element types.
	
	Select one of them to create the element, then click and drag your mouse to size the element.
	]])
	
	local pageElementMove = t:addPage("Moving and Sizing", [[Right clicking on a GUI element will bring up the menu for that specific element. This menu contains items for all the actions that can be applied to that element type.
	
	Selecting 'Move', then clicking and dragging your mouse will allow you to move the element around on the screen.
	
	Selecting 'Resize', then clicking and dragging your mouse will allow you to resize the element.
	
	The 'Move' and 'Resize' sub-menus allow you to make changes along a specific axis only.
	]])
	
	local pageElementSnapping = t:addPage("'Snapping'", [[Element Snapping makes elements automatically snap into alignment with other elements on the same plane (with the same parent element) when they get close.
	
	The snap lines are shown in orange, connecting two different elements when a snap is active.
	
	Snapping can be configured in the settings window.
	
	If snapping is enabled, holding 'Alt' while moving an element will temporarily disable snapping, allowing for finer movement.
	]])
	
	local pageElementOffset = t:addPage("Offset", [[You can offset an element a specific x/y distance from another element using the 'Offset' menu item 
	(in 'Dimensions' > 'Offset from this element').
	
	After entering the x/y distance, left click on any element on the same plane (with the same parent element) to move it to the offset position indicated on the screen.
	
	This allows you to quickly align a group of elements against a certain x/y position pattern.	
	]])
	
	local pageElementDivider = t:addPage("Element Dividers", [[Scrolling the mouse wheel while moving an element allows you to divide the parent of that element into sections, which you can snap the element you are moving onto.
	
	For example: create a button, move the button and scroll up once. This divides the screen into 2 sections, allowing you to easily snap your button to the centre of the screen.
	
	Scrolling up again will divide the window into 3 sections, then 4, then 5 and so on. 
	
	Scrolling back down to 1 section will remove the divider.
	]])
	
	local pageElementPositionCode = t:addPage("Position Code", [[The 'Position Code' option allows you to specify a Lua string that will be used to calculate where the element should be positioned.
	
	There are a selection of words that can be used in the string to represent various unknown values, such as screen size.
	
	This can be used, for example, to always position an element in the middle of the screen, regardless of resolution.
	
	There are several pre-set calculations built in, and you can specify and save your own too.
	]])
	
	local pageElementAttributes = t:addPage("Element Attributes", [[All items in the element menus are represented in different ways.
	
	Alpha, for example, is shown as a draggable slider bar with an editable text field for specific value entry (by double clicking the value).
	
	Variables are an editable text field, with an optional pop-out GUI entry window.
	
	Output type is a radio button, allowing one choice out of a selection of many.
	
	Items like alpha and variable are common to all elements and exist in every element menu.
	]])
	
	local pageElementVariables = t:addPage("Variables", [[The variable attribute of each element is the variable name that the element will have in the code when it is output.
	
	By default, all elements will use the GUI Editor variable table:
	
	GUIEditor.elementName[elementCount]
	
	However keeping this name is highly discouraged and all elements should be given more significant names, indicating what they are or what they will be used for in your design.
	]])
	
	local pageDirectX = t:addPage("Direct X Drawing", [[The 'Drawing' item in the main menu allows you to draw 2D lines, rectangles, text and images onto the screen using Direct X.
	
	Within the GUI Editor, they can be manipulated, loaded, output and handled in the same way as regular GUI elements.

	However, be aware that DX items are NOT GUI elements, and cannot be parented with a GUI element. Any DX you draw is positioned relative to the screen and will not move or share attributes with ANY conventional GUI elements.
	]])
	
	local pageMultipleElement = t:addPage("Multiple Element Selection", [[By Clicking, holding and dragging the middle mouse button you can select multiple elements at once.
	
	This allows you to perform basic actions on groups of items without having to select each one individually.
	
	The actions available are limited to things that are common to all (or almost all) element types (such as movement and alpha).	
	]])
	
	local pageElementCopy = t:addPage("Copy", [[Elements within the GUI Editor can be copied using the 'Copy' menu item.
	
	This will generate an identical copy, created in the same position (on top of) the original.
	
	You can optionally copy child elements as well using the sub-menu of the 'Copy' item, which will copy all elements (and their children) that exist within the selected element.
	]])
	
	local pageUndoRedo = t:addPage("Undo and Redo", [[Most actions done within the GUI Editor (such as moving, resizing, setting alpha or variable) can be undone or redone using the 'Undo' and 'Redo' items in the main menu.
	
	The sub-menus of these items give a visual representation of the previous 10 actions, so you can see exactly what will be done when used.
	
	Some of the more complex actions (like loading) cannot currently be undone.
	]])
	
	local pageElementLoading = t:addPage("Element Loading", [[Existing GUI Elements can be loaded into the GUI Editor by right clicking on them and selecting 'Load'.
	
	This will load basic information about them into the editor, making them manipulatable by the editors controls. Note that this is purely loading the GUI design, it will not modifiy the resource they came from nor will it keep any of the original functionality when output.
	
	Loading elements will not load some of the more obscure settings (such as read-only on a memo) because MTA does not support it.
	
	]])
	
	local pageCodeLoading = t:addPage("Code Loading", [[Lua code can be loaded into the GUI Editor using the main menu item 'Load Code'. This will list all the previously output code samples, allow you specify particular files or paste in the code directly.
	
	The GUI Editor will attempt to keep all of the same GUI settings, including variable names.
	
	Optionally, the GUI Editor will also attempt to keep any maths that is used in the element positioning, such as when elements use maths to always be in the center of the screen. See the settings window for more information.
	]])
	
	local pageSharing = t:addPage("GUI Sharing", [[The 'Share GUI' item in the main menu allows you to share your GUI design with other people on the server. 
	
	Doing this will take a snapshot of your current design and send the player the code to re-create it, which they can then load.
	
	If you make changes to your GUI and want to share them again, you need to re-share your design to update the copy that the other player can see.

	Selecting 'View' lets you see and load code from other players that have shared with you.
	]])
	
	local pageOutput = t:addPage("Code Output", [[When you have finshed using the GUI Editor, selecting the 'Output' option from the main menu will allow you to generate Lua code from your GUI design.
	
	This window allows you to check over the code before being saved to a file, or copied directly from the output window.
	
	Once the code has been generated, you can copy and paste it into your own resources to begin integrating it with your functionality.
	]])
	
	local pageFinish = t:addPage("Help", [[If you ever get stuck, selecting 'Help' from the main menu will open the GUI Editor help window.
	
	This has information on all the right click menu items and what they do, along with further information about some of the concepts and functions used within the GUI Editor.	
	
	For additional help with GUI, see the MTA Wiki, the MTA Forums or the MTA IRC channel.
	]])
end


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		Tutorial.constructors.main()
	end
)


--[[


image


-- original
create window
alpha
text
button + label
offset
alignment
move
snapping

undo redo
checkbox
image
multiple selection
properties
variables
dx
loading
rel/abs
output
help
finish





		setTutorialTitle("Welcome to the GUI Editor Tutorial")
		setTutorialText("In this tutorial you will be shown the basic GUI Editor controls, plus a few more you might not know about.\n\nTo begin, right click anywhere on the screen and select \"Create Window\".\n\nThen, click on the screen, hold down your mouse button and drag your cursor to size the window.\n\nRelease the left mouse button to finish.\n\nNote that instructions relating to your current task will always be shown along the top of your screen.")	
		
	if progress == "window" then
		guieditor_tutorial_allowed["Create Window"] = nil
		
		setTutorialTitle("Setting some attributes")
		setTutorialText("Congratulations! You have just created your first GUI element.\n\nNow we will try setting some attributes.\n\nFirst, right click on the window you just created and select \"Set Alpha\".\n\nFollow the instructions in the box and set a new alpha value of your choice.")
	
		guieditor_tutorial_allowed = {["Set Alpha"] = true}
		guieditor_tutorial_waiting = {["alpha"] = true}	
	elseif progress == "alpha" then
		guieditor_tutorial_allowed["Set Alpha"] = nil
		
		setTutorialText(tostring(insight).."? Nice choice.\n\nNow, we will set the title text of your new window.\n\nRight click on your window and select \"Set Title\".\n\nFollow the instructions in the box and set a new title of your choice.\n\nNotice that setting attributes that require your input will always open up the same input box.\nSimply follow the intructions you are given and you can't go wrong.\n\nAlso note that \"Set Title\" is also used to set the text on some other GUI elements (such as labels).")
	
		guieditor_tutorial_allowed = {["Set Title"] = true}
		guieditor_tutorial_waiting = {["text"] = true}
	elseif progress == "text" then
		guieditor_tutorial_allowed["Set Title"] = nil
	
		setTutorialTitle("Creating more GUI elements")
		setTutorialText("Ok, how about we create some more elements now?\n\nRight click on your window and select a new GUI element to create. A selection of the available elements have been opened up so take your pick.\n\nRemember, just as before, click and hold the mouse button to size the element and release to finish.\n\nAll elements will be created as children of the element you right clicked on, which is shown in purple at the top of the right click menu.")
	
		guieditor_tutorial_allowed = {["AllowedMenu"] = 2,["Create Button"] = "menu",["Create Label"] = "menu",["Create Checkbox"] = "menu",["Create Memo"] = "menu",["Create Edit"] = "menu",["Create Radio Button"] = "menu"}
		guieditor_tutorial_waiting = {["button"] = true, ["label"] = true, ["checkbox"] = true, ["memo"] = true, ["edit"] = true, ["radio"] = true}		
	elseif (progress == "button" and guieditor_tutorial_allowed["Create Label"]) or progress == "label" or (progress == "checkbox" and guieditor_tutorial_allowed["Create Label"]) or progress == "memo" or progress == "edit" or progress == "radio" then
		guieditor_tutorial_allowed["Create Button"] = nil
		guieditor_tutorial_allowed["Create Label"] = nil
		guieditor_tutorial_allowed["Create Checkbox"] = nil
		guieditor_tutorial_allowed["Create Memo"] = nil
		guieditor_tutorial_allowed["Create Edit"] = nil
		guieditor_tutorial_allowed["Create Radio Button"] = nil
		
		guieditor_tutorial_waiting["button"] = nil
		guieditor_tutorial_waiting["label"] = nil
		guieditor_tutorial_waiting["checkbox"] = nil
		guieditor_tutorial_waiting["edit"] = nil
		guieditor_tutorial_waiting["memo"] = nil
		guieditor_tutorial_waiting["radio"] = nil
		

		--setTutorialText("A".. ((progress == "edit") and "n" or "") .." "..progress..", interesting choice. I would have gone for a"..((random == "editbox") and "n" or "") .." "..random.." myself.\n\nNow that you have your second GUI element, you will notice a lot of the right click options are the same.\nThings such as \"Set Alpha\" and \"Set Title\" will exist on almost all GUI elements, as will many other options.\n\n\nNext, we will create another GUI element in the window.\n\nSo, again, right click the window and select \"Create Button\".\n\nPress and hold the mouse to size the button and release to finish.")
		setTutorialText("A".. ((progress == "edit") and "n" or "") .." "..progress..", interesting choice.\n\nNow that you have your second GUI element, you will notice a lot of the right click options are the same.\nThings such as \"Set Alpha\" and \"Set Title\" will exist on almost all GUI elements, as will many other options.\n\n\nNext, we will create another GUI element in the window.\n\nSo, again, right click the window and select \"Create Button\".\n\nPress and hold the mouse to size the button and release to finish.")
	
		guieditor_tutorial_allowed = {["AllowedMenu"] = 2,["Create Button"] = "menu"}
		guieditor_tutorial_waiting = {["button"] = true}	
	elseif progress == "button" then
		guieditor_tutorial_allowed["Create Button"] = nil

		setTutorialTitle("Aligning your GUI elements")
		setTutorialText("Now that you have 2 different elements with the same parent, we can take a look at aligning them.\n\nTo begin with, we will look at the \"Offset\" option.\nThis allows you to 'Offset' one GUI element from another by a certain amount of pixels.\n\nSo lets give it a go.\nRight click on one of your elements and select \"Offset\".\nIn the box, enter \"5,20\", then accept the input box and left click on the OTHER element.\n\nYou will notice the element moves.This will offset that element 5 pixels across and 20 pixels down from the first element.\n\nRight click anywhere to cancel the \"Offset\" mode.")
	
		guieditor_tutorial_allowed = {["Offset"] = true}
		guieditor_tutorial_waiting = {["set offset"] = true}	
	elseif progress == "set offset" then
		guieditor_tutorial_allowed["Offset"] = nil
		guieditor_tutorial_allowed["AllowedMenu"] = nil
		
		setTutorialText("Now lets look at another method for aligning your GUI.\n\nYou can align elements with each other through the Left and Right ctrl keys.\n\nHold ctrl and click on an element to select it. While still holding ctrl, click on other GUI elements to align them with it.\n\nLeft ctrl will align horizontally and Right ctrl vertically, left and right click will align to the left/right side and the top/bottom respectively.\nBe aware that you can only align elements that have the same parent.\n\nFeel free to play around, just click \"Continue\" when you're done.")
		
		showTutorialProgressButton("control_alignment")
	elseif progress == "control_alignment" then
		hideTutorialProgressButton()
		
		setTutorialText("The third method allows you to align GUI elements relative to their parent.\n\nTo begin, right click one of your elements and select \"Move\".\n\nLeft click and hold to move the element around.\nThen, while still holding left click, scroll your mouse wheel.\n\nYou will notice the divider lines pop up, allowing you to split the parent into sections and snap your element into position.\n\nScroll the mouse wheel back down again to return to normal \"Move\" behaviour.\n\nAlso note that holding down Left Shift will enable \"Loose Manipulation\", allowing you to move elements beyond the edges of their parents.")
		
		guieditor_tutorial_allowed = {["Move"] = true}
		guieditor_tutorial_waiting = {["move"] = true}
	elseif progress == "move" then
		guieditor_tutorial_allowed["Move"] = nil
		
		setTutorialText("The final method is disabled by default but accessible once the tutorial is over through the \"Settings\" option in the main right click menu.\n\nThis \"Snapping\" will enable tracking of nearby GUI elements, giving you visual cues and snapping into alignment when close by.\n\nThis can be toggled on and off at any time, or further fine tuned with the settings window.\n\nAlso note that with snapping turned on, you can temporarily bypass its influence by activating \"Loose Manipulation\" (holding down left shift).\n\nClick \"Continue\" to move on.")
		
		showTutorialProgressButton("snapping")
	elseif progress == "snapping" then
		setTutorialTitle("Undo / Redo")
		setTutorialText("If at any time while using the editor you make a mistake, you can use the \"Undo\"/\"Redo\" options to undo the last action you made (and up to 5 actions total).\n\nNot all GUI Editor functions can be undone/redone (especially if you have since deleted the GUI element they relate to), however most functions relating to position/size and visual appearance can be.\n\nClick \"Continue\" to move on.")
		
		hideTutorialProgressButton()
		showTutorialProgressButton("undoredo")	
	elseif progress == "undoredo" then
		hideTutorialProgressButton()
		
		setTutorialTitle("The \"Extra\" menu")
		setTutorialText("Next, we will look at the \"Extra\" menu options.\n\nThis allows you to create GUI elements ontop of other GUI elements that you may not normally think to use, such as creating a checkbox on a button.\n\nSo, right click on your button, select \"Extra\", then in the submenu select \"Create Checkbox\".\n\nThis new checkbox will be created as a child of the button you right clicked on.\n\nAs usual, left click and hold to size your element and release to finish.")
	
		guieditor_tutorial_allowed = {["Create Checkbox"] = "sub"}
		guieditor_tutorial_waiting = {["checkbox"] = true}
	elseif progress == "checkbox" then
		guieditor_tutorial_allowed["Create Checkbox"] = nil	

		setTutorialTitle("Creating Images")	
		setTutorialText("Not only can you create the GUI elements listed in the right click menu, but you can use your own custom made images as well.\n\nTo do this, right click on your window and select \"Create Image\".\nIn the window that opens up, select one of the 2 default images and click accept.\n\nAs usual, left click and hold to size and release to finish.\n\nAs instructed in the image window, you can load your own images into the GUI Editor if you wish.")
	
		guieditor_tutorial_allowed = {["AllowedMenu"] = 2, ["Create Image"] = "menu"}
		guieditor_tutorial_waiting = {["image"] = true}
	elseif progress == "image" then
		guieditor_tutorial_allowed["Create Image"] = nil	
		guieditor_tutorial_allowed["AllowedMenu"] = nil		

		setTutorialTitle("Multiple Element Selection")
		setTutorialText("Now that you have a nice selection of elements, we can look at selecting them all together.\n\nFor this, we will use the middle mouse button.\n\nSo, click and hold the middle mouse button on your window then drag the blue box around all your elements.\nRelease to select them. Now, when you right click you will be presented with a small menu, controlling all your selected elements.\n\nI have opened up some of the controls on this menu, so feel free to play around with them.\n\nJust click \"Continue\" when you're finished.")
	
		guieditor_tutorial_allowed = {["AllowedMenu"] = "captured",["Set Title"] = true,["Move"] = true,["Resize"] = true,["Cancel"] = true}
		
		showTutorialProgressButton("multiple_element")
	elseif progress == "multiple_element" then
		guieditor_tutorial_allowed["Set Title"] = nil	
		guieditor_tutorial_allowed["Move"] = nil	
		guieditor_tutorial_allowed["Resize"] = nil	
		guieditor_tutorial_allowed["Cancel"] = nil	
		guieditor_tutorial_allowed["AllowedMenu"] = nil	

		setTutorialTitle("GUI Element Properties")
		setTutorialText("On top of the basic attributes you can set, such as Alpha and Text, you are also given access to the GUI properties.\n\nThis allows you to set more obscure attributes on your elements.\n\nTo do this you can right click a GUI element and select \"Get Property\" or \"Set Property\".\n\nHowever, be aware, the properties should only be used when you know what you are doing.\n\nMany of the elements listed in the window arent used by MTA so you will need to explore to find combinations that work.\n\nFeel free to do this now. When you are done, hit \"Continue\" to move on.")
		
		guieditor_tutorial_allowed = {["Get Property"] = true, ["Set Property"] = true}
		
		hideTutorialProgressButton()
		showTutorialProgressButton("properties")		
	elseif progress == "properties" then
		guieditor_tutorial_allowed["Get Property"] = nil	
		guieditor_tutorial_allowed["Set Property"] = nil	
		
		setTutorialTitle("GUI Element Variables")
		setTutorialText("Ok, so you've got lots of GUI elements created. What now?\n\nThe next step is to set the variables they will have in the output code.\nThis is not a necessary step, but doing this now rather than once the code is generated will make it far easier.\n\nSo, right click on one of your GUI elements and select \"Set Variable\", then enter the new variable name into the box.\n\nI suggest using something that you can easily recognise later on. For example, as this is a tutorial you might call your window \"exampleWindow\" or \"tutorialWindow\".\n\nFeel free to set variables on all your elements.\n\nJust hit \"Continue\" when you are finished.")
	
		hideTutorialProgressButton()
		showTutorialProgressButton("setting_variables")
		
		guieditor_tutorial_allowed = {["Set Variable"] = true}
	elseif progress == "setting_variables" then
		guieditor_tutorial_allowed["Set Variable"] = nil	

		setTutorialTitle("Direct X Drawing")
		setTutorialText("So thats the GUI covered, but what else is there?\nThe GUI Editor also gives you access to in-game manipulation of the Direct X (DX) drawing functions.\n\nThese allow you more control over what is drawn on your screen, however be aware that they are NOT GUI elements.\n\nWhile the GUI Editor allows you to manipulate DX in a very similar manner to GUI, DX is more complicated to use, implement & maintain, and should only be used if you fully understand the differences.\n\nRefer to the MTA Wiki, MTA forums or MTA irc channel for information on DX vs GUI.\n\nClick \"Continue\" to move on.")

		hideTutorialProgressButton()
		showTutorialProgressButton("dx_items")	
	elseif progress == "dx_items" then		
		setTutorialText("The DX functions can be found under the \"Drawing\" option in the main (screen) right click menu.\n\nThey allow you access to DX Text, Lines (2D), Rectangles and Images.\n\nAll available DX function settings can be accessed through the right click menus as usual.\n\nBe aware that DX cannot be parented with a GUI element. Any DX you draw is positioned relative to the screen and will not move or share attributes with ANY conventional GUI elements.\n\nClick \"Continue\" to move on.")

		hideTutorialProgressButton()
		showTutorialProgressButton("dx_posibilities")		
	elseif progress == "dx_posibilities" then
		setTutorialTitle("A Few Pointers")
		setTutorialText("Ok, we're almost finished. But before we do, just a few last tips.\n\nLoading GUI:\nAny GUI that wasnt created by you, in the GUI editor, since you connected, will not be loaded.\n\nTo be able to manipulate it, right click on the screen and select \"Load GUI\".\nThen, left click on the element you want to load into the GUI editor.That element and all of its children will then be loaded.\n\nAdditionally, using the \"Load Code\" option will directly load your saved GUI's from the GUI Editor code output file.\n\nHit \"Continue\" to move on.")
	
		hideTutorialProgressButton()
		showTutorialProgressButton("loading")	
	elseif progress == "loading" then
		setTutorialText("Relative and Absolute:\n\nThe options \"Rel/Abs Child\" and \"Rel/Abs Screen\" switch between 2 output modes for children GUI elements and Parent GUI elements.\n\nParents are direct children of the root (ie: created on the screen) and children are children of existing GUI elements (ie: created on another element).\n\nThe pros and cons of each type are briefly outlined in the GUI Editor help file, or more thoroughly described on the MTA Wiki.\n\nClick \"Continue\" to move on.")
	
		hideTutorialProgressButton()
		showTutorialProgressButton("rel_abs")	
	elseif progress == "rel_abs" then
		setTutorialText("Help window:\n\nSelecting \"Help\" from the right click menu of the screen will open up the GUI Editor help window.\n\nThis covers all aspects of the GUI Editor, including those covered in this tutorial and should be the first place you look for any problems you have.\n\nFor additional help with GUI, see the MTA Wiki, the MTA Forums or the MTA IRC channel.\n\nClick \"Continue\" to move on.")

		hideTutorialProgressButton()
		showTutorialProgressButton("help_window")	
	elseif progress == "help_window" then
		setTutorialTitle("Getting your code")
		setTutorialText("Now that your GUI is created, your attributes are configured and your variables are set, all thats left is to generate the code.\n\nTo do this, right click on the screen and select \"Print Code\".\n\nThis opens up the code print window, giving you the chance to look over your code before you output it to a file.\n\nIf you are satisfied with it, to output the code click \"Output to File\" or select the \"Output Code\" right click option.\n\nThe code will be saved into GUIEditor_output.txt in your GUIEditor resource folder.\n\nSo go ahead, try it now.")
	
		hideTutorialProgressButton()
	
		guieditor_tutorial_allowed = {["Print Code"] = true, ["Output Code"] = true, ["Rel/Abs Child"] = true, ["Rel/Abs Screen"] = true}
		guieditor_tutorial_waiting = {["output_code"] = true}
	elseif progress == "output_code" then
		guieditor_tutorial_allowed["Print Code"] = nil
		guieditor_tutorial_allowed["Output Code"] = nil
		guieditor_tutorial_allowed["Rel/Abs Child"] = nil
		guieditor_tutorial_allowed["Rel/Abs Screen"] = nil
	
		setTutorialTitle("Congratulations")
		setTutorialText("Well done, you have now completed the GUI Editor tutorial.\n\nThe GUI elements you have created will remain for you to experiment with.\n\nAll right click options will be unlocked, so go and experiment!\n\n\nClick \"Continue\" to finish the tutorial.")

		showTutorialProgressButton("finish")	
	elseif progress == "finish" then
		settings.guieditor_tutorial_completed.value = true
		settings.guieditor_tutorial_version.value = current_tutorial_version
		saveSettingsFile()
		stopTutorial()
	end
	
]]