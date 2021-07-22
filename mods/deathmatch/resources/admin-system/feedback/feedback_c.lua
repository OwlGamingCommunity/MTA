--MAXIME / 2015.1.29
local gui = {
    edit = {},
    button = {},
    window = {},
    label = {},
    radiobutton = {},
    gridlist = {},
    gridcol = {},
    memo = {},
}
local playerSource = nil
function openFeedBackForm(target)
	closeFeedbackForm()

	if target then source = target end 
	if source == localPlayer then return false end --Prevent someone sending feedback about themselves.
	playerSource = source

	local sw, sh = guiGetScreenSize()
	local margin = 5
	local w, h = 337, 358
	local x, y = sw - w - margin, sh - h - margin - 23

	gui.window[1] = guiCreateWindow(x, y, w, h, "We'd love your feedback so we can improve!", false)
	guiWindowSetMovable(gui.window[1], false)
	guiWindowSetSizable(gui.window[1], false)

	gui.label[1] = guiCreateLabel(10, 28, 319, 33, "What is your overall satisfaction rating with the assistance from "..exports.global:getPlayerFullIdentity(playerSource or localPlayer, 1, true).."?", false, gui.window[1])
	guiLabelSetHorizontalAlign(gui.label[1], "left", true)
	gui.edit[1] = guiCreateEdit(14, 196, 313, 29, "Additional comment or opinions..", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[1], 500)

	gui.radiobutton[5] = guiCreateRadioButton(14, 67, 313, 15, "Very satisfied", false, gui.window[1])
	gui.radiobutton[4] = guiCreateRadioButton(14, 92, 313, 15, "Somewhat satisfied", false, gui.window[1])
	gui.radiobutton[3] = guiCreateRadioButton(14, 117, 313, 15, "Neither satisfied nor dissatisfied", false, gui.window[1])
	gui.radiobutton[2] = guiCreateRadioButton(14, 142, 313, 15, "Somewhat dissatisfied", false, gui.window[1])
	gui.radiobutton[1] = guiCreateRadioButton(14, 167, 313, 15, "Very dissatisfied", false, gui.window[1])
	
	
	guiRadioButtonSetSelected(gui.radiobutton[3], true)
	
	gui.label[2] = guiCreateLabel(14, 299, 313, 53, "Your time and efforts to complete this feedback form are much appreciated. Your input will be kept strictly confidential, and will be used to continuously improve the staff team's service and support you receive from the OwlGaming Community.", false, gui.window[1])
	guiSetAlpha(gui.label[2], 0.35)
	guiSetFont(gui.label[2], "default-small")
	guiLabelSetHorizontalAlign(gui.label[2], "left", true)
	gui.button[1] = guiCreateButton(14, 240, 150, 49, "Close (Right Alt)", false, gui.window[1])
	gui.button[2] = guiCreateButton(174, 240, 148, 49, "Submit (Right Ctrl)", false, gui.window[1])
	addEventHandler("onClientKey", root, keyPress)
	addEventHandler("onClientGUIFocus", gui.edit[1], onClientGUIFocus_editbox, true)
	addEventHandler("onClientGUIBlur", gui.edit[1], onClientGUIBlur_editbox, true)
	addEventHandler("onClientGUIClick", gui.button[1], function () 
		if source == gui.button[1] then
			closeFeedbackForm()
		end
	end, true)
	addEventHandler("onClientGUIClick", gui.button[2], function ()
		if source == gui.button[2] then
			submitFeedback()
		end
	end, true)

	exports["item-system"]:playSoundInvOpen()
end
addEvent("feedback:form", true)
addEventHandler("feedback:form", root, openFeedBackForm)

function closeFeedbackForm()
	if gui.window[1] and isElement(gui.window[1]) then
		destroyElement(gui.window[1])
		gui.window[1] = nil
		removeEventHandler("onClientKey", root, keyPress)
		exports["item-system"]:playSoundInvClose()
		showCursor(false)
		guiSetInputEnabled ( false )
		playerSource = nil
	end
end

function submitFeedback()
	local rating = 3
	for i = 1, 5 do 
		if guiRadioButtonGetSelected(gui.radiobutton[i]) then
			rating = i
			break
		end
	end
	local comment = guiGetText(gui.edit[1])
	if comment == "Additional comment or opinions.." or comment == ""  then
		comment = nil
	end
	triggerServerEvent("feedback:formSubmit", localPlayer, getElementData(playerSource or localPlayer, "account:id"), rating, comment)
	closeFeedbackForm()
end

function keyPress(button, press)
	if press then
		--outputChatBox(button)
		if button == "rctrl" then
			submitFeedback()
			cancelEvent()
		elseif button == "ralt" then
			closeFeedbackForm()
			cancelEvent()
		end
	end
end

function onClientGUIFocus_editbox()
	if source == gui.edit[1] then
		if guiGetText(gui.edit[1]) == "Additional comment or opinions.." then
			guiSetText(gui.edit[1], "")
		end
		guiSetInputEnabled ( true )
		showCursor(true)
	end
end
 
function onClientGUIBlur_editbox()
	if source == gui.edit[1] then
		if guiGetText(gui.edit[1]) == "" then
			guiSetText(gui.edit[1], "Additional comment or opinions..")
		end
		showCursor(false)
		guiSetInputEnabled ( false )
	end
end

function openFeedBackDetails(data)
	if data then
		local feedbacks = data[1]
		local name = data[2]
		if #feedbacks > 0 then
			closeFeedbackDetails()
			gui.window[2] = guiCreateWindow(632, 385, 700, 335, "Feedbacks received for "..name, false)
			guiWindowSetSizable(gui.window[2], false)
			exports.global:centerWindow(gui.window[2])

			gui.gridlist[1] = guiCreateGridList(14, 30, 667, 261, false, gui.window[2])
			gui.gridcol.date = guiGridListAddColumn(gui.gridlist[1], "Date", 0.25)
		    gui.gridcol.rating = guiGridListAddColumn(gui.gridlist[1], "Rating (out of 5)", 0.2)
		    gui.gridcol.comment = guiGridListAddColumn(gui.gridlist[1], "Comment", 0.3)
		    gui.gridcol.from = guiGridListAddColumn(gui.gridlist[1], "From", 0.2)

		    local function formatRating(rating)
				if not rating or not tonumber(rating) then
					return 0
				else
					return exports.global:round(rating, 2)
				end
			end

			local function formatFrom(from)
				if not from then
					return "(Unknown)"
				else
					return exports.integration:isPlayerLeadAdmin(localPlayer) and from or "(Hidden)"
				end
			end

			local sum = 0
		    for i, feedback in ipairs(feedbacks) do
				local row = guiGridListAddRow(gui.gridlist[1])
				guiGridListSetItemText(gui.gridlist[1], row, gui.gridcol.date, feedback.date, false, false)
				guiGridListSetItemText(gui.gridlist[1], row, gui.gridcol.rating, formatRating(feedback.rating), false, true)
				guiGridListSetItemText(gui.gridlist[1], row, gui.gridcol.comment, feedback.comment or "N/A", false, true)
				guiGridListSetItemText(gui.gridlist[1], row, gui.gridcol.from, formatFrom(feedback.username), false, false)
				sum = sum + tonumber(feedback.rating)
			end

			addEventHandler( "onClientGUIDoubleClick", gui.gridlist[1], function(button, state)
	            if button == "left" then
	            	local selectedRow, selectedCol = guiGridListGetSelectedItem( gui.gridlist[1] ) -- get double clicked item in the gridlist
	            	local date = guiGridListGetItemText( gui.gridlist[1], selectedRow, 1 )
	               	local rating = guiGridListGetItemText( gui.gridlist[1], selectedRow, 2 )
					local comment = guiGridListGetItemText( gui.gridlist[1], selectedRow, 3 )
					local from = guiGridListGetItemText( gui.gridlist[1], selectedRow, 4 )
					openFeedbackEntry("From: "..from.."\nRating: "..rating.."\nData: "..date.."\nComment: "..comment)
	            end
	        end, false )

			guiSetText(gui.window[2], "Feedbacks received for "..name.." | Overall rating: "..formatRating(sum/#feedbacks))

			gui.button[99] = guiCreateButton(14, 301, 668, 24, "Close", false, gui.window[2])
			addEventHandler("onClientGUIClick", gui.button[99] , function ()
				if source == gui.button[99] then 
					closeFeedbackDetails()
				end
			end)
		else
			outputChatBox(name.." doesn't have any feedbacks at the moment.")
		end
	end
end
addEvent("feedback:openFeedBackDetails", true)
addEventHandler("feedback:openFeedBackDetails", root, openFeedBackDetails)

function closeFeedbackDetails()
	if gui.window[2] and isElement(gui.window[2]) then
		destroyElement(gui.window[2])
		gui.window[2] = nil
		closeFeedbackEntry()
	end
end

function openFeedbackEntry(text)
	if text then
		closeFeedbackEntry()
		if gui.window[2] and isElement(gui.window[2]) then
			guiSetEnabled(gui.window[2], false)
		end
		gui.window[3] = guiCreateWindow(632, 385, 700, 335, "Feedback details", false)
		guiWindowSetSizable(gui.window[3], false)
		exports.global:centerWindow(gui.window[3])
		gui.memo[1] = guiCreateMemo(14, 30, 667, 261, text ,false, gui.window[3])
		guiMemoSetReadOnly(gui.memo[1], true)
		gui.button[100] = guiCreateButton(14, 301, 668, 24, "Close", false, gui.window[3])
		addEventHandler("onClientGUIClick", gui.button[100] , function ()
			if source == gui.button[100] then 
				closeFeedbackEntry()
			end
		end)
	end
end

function closeFeedbackEntry()
	if gui.window[3] and isElement(gui.window[3]) then
		destroyElement(gui.window[3])
		gui.window[3] = nil
		if gui.window[2] and isElement(gui.window[2]) then
			guiSetEnabled(gui.window[2], true)
		end
	end
end
