--MAXIME
--Number, content, secdiff, isIncoming, viewed
messages = {}
--Number, thread
threads = {}
--threadID, thread
sortedThreads = {}
smsThreadInitiated = {}
smsComposerCache = {}
totalUnreadSMSs = {}
smsViewingMode = {}
smsTargetNumber = {}
local smsComposerGUIs = {}


function processMessagesIntoThreads(fromPhone, exclude)
	threads[fromPhone] = {}
	local totalUnread = 0
	if messages[fromPhone] then
		for i, message in ipairs(messages[fromPhone]) do
			if not threads[fromPhone][message[1]] then
				threads[fromPhone][message[1]] = {}
			end

			if exclude and message[1] == exclude then
				message = nil
			else
				table.insert(threads[fromPhone][message[1]], message)
				if message[4] and not message[5] then
					totalUnread = totalUnread + 1
				end
			end
		end
	end
	totalUnreadSMSs[fromPhone] = totalUnread
end

function sortThreadsBySecdiff(fromPhone)
	--rearrange threads into sortable threads
	sortedThreads[fromPhone] = {}
	local index = 1
	for number, thread in pairs(threads[fromPhone]) do
		if thread and type(thread) == "table" then
			sortedThreads[fromPhone][index] = thread
			index = index + 1
		end
	end
	--start sorting
	table.sort(sortedThreads[fromPhone], function(a, b)
		return a[1][3] > b[1][3]
	end)
end

function receiveSMSFromServer(fromPhone, SMSs, forceUpdate)
	fromPhone = tonumber(fromPhone)
	forceUpdate = tonumber(forceUpdate) or forceUpdate

	if fromPhone and SMSs and type(SMSs) == "table" then
		messages[fromPhone] = {}
		for i, SMS in ipairs(SMSs) do
			local from = tonumber(SMS['from'])
			local to = tonumber(SMS['to'])
			local isIncoming = false
			if to == fromPhone then
				to = from
				isIncoming = true
			end
			local content = SMS['content']
			local datesec = tonumber(SMS['datesec'])
			local viewed = tonumber(SMS['viewed']) == 1
			local private = 0
			if isIncoming and tonumber(SMS['private']) == 1 then
				private = 1
			end
			table.insert(messages[fromPhone], {to, content, datesec, isIncoming, viewed, private})
		end
		processMessagesIntoThreads(fromPhone)
		sortThreadsBySecdiff(fromPhone)
	end
	if forceUpdate then
		if smsViewingMode[fromPhone] == "One" then --if update on sending new message then refresh the curent thread if still on screen
			drawOneSMSThread(smsTargetNumber[fromPhone])
			if forceUpdate == smsTargetNumber[fromPhone] then
				if forceUpdate == fromPhone then
					playSound("sounds/ringtones/viberate.mp3")
				else
					smsSending = false
					if wSMSComposer and isElement(wSMSComposer) then
						smsComposerCache[phone][forceUpdate] = nil
						guiSetText(smsComposerGUIs.memo, "")
						guiSetEnabled(wSMSComposer, true)
						guiSetAlpha(wSMSComposer, 1)
						guiSetEnabled(smsComposerGUIs.send, false)
					end
				end
			end
		elseif smsViewingMode[fromPhone] == "All" then
			drawAllSMSThreads()
			if forceUpdate == fromPhone then
				playSound("sounds/ringtones/viberate.mp3")
			end
		else
			outputDebugString('Could not render SMS threads, ' .. tostring(fromPhone) .. ' has viewing mode ' .. tostring(smsViewingMode[fromPhone]), 1)
		end
	end
end
addEvent("phone:receiveSMSFromServer", true)
addEventHandler("phone:receiveSMSFromServer", root, receiveSMSFromServer)

function receiveOneSMSThreadFromServer(fetchForPhone, messageSentTo, SMSs, outGoing)
	fetchForPhone = tonumber(fetchForPhone)
	messageSentTo = tonumber(messageSentTo)
	local unreads = 0
	if fetchForPhone and messageSentTo and SMSs and type(SMSs) == "table" then
		local msgs = {}
		for i, SMS in ipairs(SMSs) do
			local from = tonumber(SMS['from'])
			local to = tonumber(SMS['to'])
			local isIncoming = false
			if to == fetchForPhone then
				to = from
				isIncoming = true
			end
			local content = SMS['content']
			local datesec = tonumber(SMS['datesec'])
			local viewed = tonumber(SMS['viewed']) == 1
			table.insert(msgs, {to, content, datesec, isIncoming, viewed})
			if isIncoming and not viewed then
				unreads = unreads + 1
			end
		end
		if not threads[fetchForPhone] then threads[fetchForPhone] = {} end
		threads[fetchForPhone][messageSentTo] = {}
		for i, message in ipairs(msgs) do
			table.insert(threads[fetchForPhone][messageSentTo], message)
		end
		sortThreadsBySecdiff(fetchForPhone)
	end

	if smsViewingMode[fetchForPhone] == "One" then --if update on sending new message then refresh the curent thread if still on screen
		--outputChatBox("One")
		drawOneSMSThread(smsTargetNumber[fetchForPhone])
		if not outGoing then
			playSound("sounds/ringtones/viberate.mp3")
		else
			smsSending = false
			if wSMSComposer and isElement(wSMSComposer) then
				smsComposerCache[fetchForPhone][smsTargetNumber[fetchForPhone]] = nil
				guiSetText(smsComposerGUIs.memo, "")
				guiSetEnabled(wSMSComposer, true)
				guiSetAlpha(wSMSComposer, 1)
				guiSetEnabled(smsComposerGUIs.send, false)
			end
		end
	elseif smsViewingMode[fetchForPhone] == "All" then
		--outputChatBox("All")
		drawAllSMSThreads()
		if not outGoing then
			playSound("sounds/ringtones/viberate.mp3")
		end
	else
		--outputChatBox("Update")
		if unreads > 0 then
			addToUnreadSMSs(fetchForPhone, unreads, outGoing)
		end
	end
end
addEvent("phone:receiveOneSMSThreadFromServer", true)
addEventHandler("phone:receiveOneSMSThreadFromServer", root, receiveOneSMSThreadFromServer)

local smsGUI = {}
function drawAllSMSThreads(xoffset, yoffset)
	if not isPhoneGUICreated() then
		return false
	end
	if type(phone) ~= "number" then
		outputDebugString("Phone number ".. tostring(phone) .. " is a " .. type(phone), 2)
	end
	if not xoffset then xoffset = 0 end
	if not yoffset then yoffset = 0 end

	local originXoffset = xoffset
	local originYoffset = yoffset
	closeSMSThreads()

	wSMS = guiCreateScrollPane(30+xoffset, 100+yoffset, 230, 370, false, wPhoneMenu)
	smsViewingMode[phone] = "All"
	smsTargetNumber[phone] = nil
	if sortedThreads[phone] and smsThreadInitiated[phone] then
		sortThreadsBySecdiff(phone)
		if #sortedThreads[phone] > 0 then
			local isEmpty = nil
			for i = 1, #sortedThreads[phone] do
				local thread = sortedThreads[phone][i][1] --Assign first message of each thread to thread's headers.
				if thread then
					smsGUI[thread[1]] = {}
					smsGUI[thread[1]].numberField = guiCreateLabel(10+xoffset, 10+yoffset, 153, 19, getContactNameFromContactNumber(thread[1], phone) or thread[1], false, wSMS)
					guiSetFont(smsGUI[thread[1]].numberField, "default-bold-small")
					guiLabelSetVerticalAlign(smsGUI[thread[1]].numberField, "center")

					smsGUI[thread[1]].latestContent = guiCreateLabel(10+xoffset, 29+yoffset, 150, 16, thread[2], false, wSMS)
					guiSetFont(smsGUI[thread[1]].latestContent, "default-small")
					if thread[4] and not thread[5] then --if incoming and not read yet
						guiLabelSetColor(smsGUI[thread[1]].latestContent, 0, 255, 0)
					end

					guiCreateStaticImage(163+xoffset, 15+yoffset, 48, 14, "images/call.png", false, wSMS)
					smsGUI[thread[1]].call = guiCreateButton(163+xoffset, 14+yoffset, 48, 16, "", false, wSMS)
					guiSetAlpha(smsGUI[thread[1]].call, 0.3)

					yoffset = yoffset + 31 - 14
					guiCreateStaticImage(179+xoffset, 16+yoffset, 17, 12, "images/sms.png", false, wSMS)
					smsGUI[thread[1]].sms = guiCreateButton(163+xoffset, 14+yoffset, 48, 16, "", false, wSMS)
					guiSetAlpha(smsGUI[thread[1]].sms, 0.3)
					yoffset = yoffset - (31 - 14)

					guiSetAlpha(guiCreateStaticImage(10+xoffset, 50+yoffset, 200, 1, ":admin-system/images/whitedot.jpg", false, wSMS), 0.1)
					yoffset = yoffset + 40
				else
					guiCreateLabel(0.5, 0.5, 1, 0.5, "No messages.", true, wSMS)
					isEmpty = true
					break
				end
			end
			if not isEmpty then
				addEventHandler("onClientGUIClick", wSMS, function()
					for i = 1, #sortedThreads[phone] do
						local thread = sortedThreads[phone][i][1]
						if source == smsGUI[thread[1]].numberField or source == smsGUI[thread[1]].latestContent or source == smsGUI[thread[1]].sms then -- Open SMS thread
							--outputChatBox(number)
							drawOneSMSThread(thread[1] ,  originXoffset, originYoffset)
							break
						elseif source == smsGUI[thread[1]].call then
							startDialing(phone, thread[1])
							break
						end
					end
				end)
			end
		else
			guiCreateLabel(0.5, 0.5, 1, 0.5, "No messages.", true, wSMS)
		end
	else
		smsThreadInitiated[phone] = triggerServerEvent("phone:fetchSMS", localPlayer, phone, "All", not contactList[phone])
		guiCreateLabel(0.5, 0.5, 1, 0.5, "Loading...", true, wSMS)
	end
end

function drawOneSMS(content, date, incoming, viewed, drawOnto, xoffset, yoffset)
	if not content or string.len(content) < 1 or not date or string.len(date) < 1 or not drawOnto or not isElement(drawOnto) then
		return false
	end
	if not xoffset then xoffset = 0 end
	if not yoffset then yoffset = 0 end
	local margin = 5
	local boxW, boxH = 200, 50
	local headTailSize = 8
	if incoming then
		yoffset = yoffset+headTailSize
	end
	local body = guiCreateStaticImage(xoffset, yoffset, boxW, boxH, "images/sms_bubble_body.png", false, drawOnto)
	local text = guiCreateLabel(xoffset+margin, xoffset+margin, boxW-margin*2, boxH-margin*2, removeNewLine(content), false, body)
	if incoming and not viewed then
		return false, true
	end
	guiSetFont(text, "default")
	guiLabelSetHorizontalAlign(text, "left", true)
	guiLabelSetVerticalAlign(text, "top", true)
	local contentW, contentH = guiLabelGetTextExtent ( text ), guiLabelGetFontHeight ( text )
	if contentW < 100 then
		contentW = 100
	end
	local newContentH = contentH
	if contentW > boxW-margin*2 then
		--outputChatBox(newContentH)
		newContentH = math.ceil(contentW/(boxW-margin*2))*(contentH+5)
		contentW = boxW-margin*2
	end
	guiSetSize ( text, contentW, newContentH, false )
	local date = guiCreateLabel(xoffset+margin, xoffset+margin*2+newContentH, boxW-margin*2, boxH-margin*2, exports.datetime:formatTimeInterval( date ), false, body)
	guiSetFont(date, "default-small")
	guiLabelSetColor(date, 100,100,100)
	guiSetSize ( body, contentW+margin*2, newContentH+margin*2+contentH, false )

	---Draw the head or tail of the bubble
	if incoming then
		guiCreateStaticImage(xoffset+headTailSize, yoffset-headTailSize, headTailSize, headTailSize, "images/sms_bubble_head.png", false, drawOnto)
	else
		local shiftX = 0
		if contentW < boxW-margin*2 then
			local bodyX, bodyY = guiGetPosition(body, false)
			shiftX = (boxW-margin*2)-contentW
			bodyX = bodyX + shiftX
			guiSetPosition(body, bodyX, bodyY, false)
		end
		guiCreateStaticImage(xoffset+contentW+margin*2-headTailSize*2+shiftX, yoffset+newContentH+margin*2+contentH, headTailSize, headTailSize, "images/sms_bubble_tail.png", false, drawOnto)
	end

	return yoffset+newContentH+margin*2+contentH, somethingUnread
end

function drawOneSMSThread(contact, xoffset, yoffset)
	if not isPhoneGUICreated() then
		return false
	end

	closeSMSThreads()

	smsTargetNumber[phone] = tonumber(contact)
	smsViewingMode[phone] = "One"

	if not xoffset then xoffset = 0 end
	if not yoffset then yoffset = 0 end

	local originXoffset = xoffset
	local originYoffset = yoffset

	local w,h = 230, 290
	wSMS = guiCreateScrollPane(30+xoffset, 100+yoffset, w, h , false, wPhoneMenu)
	if not threads[phone] then
		triggerServerEvent("phone:fetchOneSMSThread", localPlayer, phone, contact, true, not contactList[phone])
		guiCreateLabel(0.5, 0.5, 1, 0.5, "Loading..", true, wSMS)
		return false
	end

	if not threads[phone][contact] then
		threads[phone][contact] = {}
	end


	local backBtnSize = 12
	local spacing = 10
	guiCreateStaticImage(xoffset, 10+yoffset, backBtnSize, backBtnSize, "images/arrow_left_white.png", false, wSMS)
	local backToThreads = guiCreateButton(xoffset, 10+yoffset, backBtnSize, backBtnSize, "", false, wSMS)
	guiSetAlpha(backToThreads, 0.1)
	addEventHandler("onClientGUIClick", backToThreads, function ()
		if source == backToThreads then
			drawAllSMSThreads(originXoffset, originYoffset)
		end
	end)
	local contactName = guiCreateLabel(xoffset+backBtnSize+spacing, 8+yoffset, 170, 19, getContactNameFromContactNumber(contact, phone) or contact, false, wSMS)
	guiSetFont(contactName, "default-bold-small")
	guiLabelSetVerticalAlign(contactName, "top")
	yoffset = yoffset + 30

	for i, message in ipairs(threads[phone][contact]) do
		local new_yoffset, somethingUnread = drawOneSMS(message[2], message[3], message[4], message[5], wSMS,xoffset, yoffset)
		if somethingUnread then
			triggerServerEvent("phone:updateSMSViewedState", localPlayer, phone, contact)
		 	return false
		end
		yoffset = new_yoffset + spacing
		if not message[5] then
			somethingUnread = true
		end
	end
	drawSMSComposer(originXoffset, originYoffset+h+spacing )
end


function drawSMSComposer(xoffset, yoffset)
	if isPhoneGUICreated() then
		if not xoffset then xoffset = 0 end
		if not yoffset then yoffset = 0 end
		if wSMSComposer and isElement(wSMSComposer) then
			closeSMSComposer()
		end

		local function onClientGUIFocus_editbox()
			if source == smsComposerGUIs.memo then
				guiSetInputEnabled(true)
			end
		end

		local function onClientGUIBlur_editbox()
			if source == smsComposerGUIs.memo then
				guiSetInputEnabled(false)
			end
		end

		if not smsComposerCache[phone] then
			smsComposerCache[phone] = {}
		end

		limit = 120
		wSMSComposer = guiCreateScrollPane(30+xoffset, 100+yoffset, 210, 65, false, wPhoneMenu)
		smsComposerGUIs.memo = guiCreateMemo(0, 0, 0.8, 1, smsComposerCache[phone][smsTargetNumber[phone]] or "", true, wSMSComposer)
		--guiSetFont(smsComposerGUIs.memo, "default-small")
		guiCreateStaticImage(0.8, 0, 0.2, 0.5, "images/sms_send.png", true, wSMSComposer)
		smsComposerGUIs.send = guiCreateButton(0.8, 0, 0.2, 0.5, "", true, wSMSComposer)
		guiSetAlpha(smsComposerGUIs.send, 0.5)
		guiBringToFront ( wSMSComposer )
		smsComposerGUIs.limiter = guiCreateLabel(0.8,0.55,0.2,0.4,(string.len(guiGetText(smsComposerGUIs.memo))-1).."/"..limit, true, wSMSComposer)
		guiLabelSetVerticalAlign(smsComposerGUIs.limiter, "center", true)
		guiLabelSetHorizontalAlign(smsComposerGUIs.limiter, "center", true)
		guiSetFont(smsComposerGUIs.limiter, "default-small")
		addEventHandler("onClientGUIFocus", smsComposerGUIs.memo, onClientGUIFocus_editbox)
		addEventHandler("onClientGUIBlur", smsComposerGUIs.memo, onClientGUIBlur_editbox)

		addEventHandler("onClientGUIChanged", smsComposerGUIs.memo, function()
			guiSetText(smsComposerGUIs.limiter, string.len(tostring(guiGetText(smsComposerGUIs.memo)))-1 .. "/"..limit)
			if string.len(guiGetText(smsComposerGUIs.memo))-1>limit or string.len(guiGetText(smsComposerGUIs.memo))-1<1 then
				guiLabelSetColor(smsComposerGUIs.limiter, 255, 0, 0)
				guiSetEnabled(smsComposerGUIs.send, false)
			else
				smsComposerCache[phone][smsTargetNumber[phone]] = guiGetText(smsComposerGUIs.memo)
				guiLabelSetColor(smsComposerGUIs.limiter, 255, 255, 255)
				guiSetEnabled(smsComposerGUIs.send, true)
			end
		end)

		addEventHandler("onClientGUIClick", smsComposerGUIs.send, function()
			if source == smsComposerGUIs.send and smsTargetNumber[phone] then
				guiSetEnabled(wSMSComposer, false)
				guiSetAlpha(wSMSComposer, 0.5)
				sendSMS(phone, smsTargetNumber[phone], guiGetText(smsComposerGUIs.memo):gsub("\n", " "))
			end
		end)
		guiSetEnabled(wSMSComposer, not smsSending)
		guiSetEnabled(smsComposerGUIs.send, string.len(guiGetText(smsComposerGUIs.memo))-1<limit and string.len(guiGetText(smsComposerGUIs.memo))-1>1)
	end
end

function sendSMS(fromPhone, toPhone, content)
	smsSending = triggerServerEvent("phone:sendSMS", localPlayer, fromPhone, toPhone, content, getPhoneSettings(fromPhone, "isSecret") or 0)
end

function closeSMSComposer()
	if wSMSComposer and isElement(wSMSComposer) then
		destroyElement(wSMSComposer)
		wSMSComposer = nil
	end
end


function addToUnreadSMSs(fromPhone, newValue, outGoing)
	totalUnreadSMSs[fromPhone] = (totalUnreadSMSs[fromPhone]) or 0 + newValue
	if not smsViewingMode[fromPhone] and not outGoing then
		triggerServerEvent("phone:startRingingSMS", localPlayer, fromPhone, getPhoneSettings(fromPhone, "sms_tone"), getPhoneSettings(fromPhone, "tone_volume"))
	end
end

function closeSMSThreads()
	if wSMS and isElement(wSMS) then
		destroyElement(wSMS)
		wSMS = nil
		closeSMSComposer()
		smsViewingMode[phone] = nil
		smsTargetNumber[phone] = nil
	end
end

function resetSMSThreads(fromPhone)
	fromPhone = tonumber(fromPhone)
	if threads[fromPhone] then
		threads[fromPhone] = nil
	end
	if messages[fromPhone] then
		messages[fromPhone] = nil
	end
	smsThreadInitiated[fromPhone] = nil
end

local smsWindow = nil
local function closeSMSWindow()
	destroyElement(smsWindow)
	smsWindow = nil
end

function drawNewSMSWindow(fromNumber, toNumber, message)
	local margin = 40
	local w, h = 257, 93
	local x, y = sx-w-margin+20, sy-h-margin*1.5

	if smsWindow then
		closeSMSWindow()
	end

	smsWindow = guiCreateWindow(x,y,w,h, "Your phone #" .. toNumber .. " received a message!", false)
	guiWindowSetMovable(smsWindow, false)
	guiWindowSetSizable(smsWindow, false)

	local lFrom = guiCreateLabel(10, 25, w  - 20, 20, "SMS from " .. fromNumber .. ".", false, smsWindow)
	guiLabelSetHorizontalAlign(lFrom, "center", false)

	local lMessage = guiCreateLabel(10, 45, w - 20, 20, message, false, smsWindow)

	bReply = guiCreateButton(10, 68, 117, 35, "Reply", false, smsWindow)
	bClose = guiCreateButton(129, 68, 118, 35, "Close", false, smsWindow)
	addEventHandler("onClientGUIClick", bClose, closeSMSWindow, false)

	addEventHandler("onClientGUIClick", bReply, function()
		triggerSlidingPhoneIn(toNumber, false, false, fromNumber)
		closeSMSWindow()
	end, false)
end
addEvent("newSMSReceived", true)
addEventHandler("newSMSReceived", resourceRoot, drawNewSMSWindow)