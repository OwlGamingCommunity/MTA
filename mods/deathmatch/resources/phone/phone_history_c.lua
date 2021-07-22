--MAXIME
local histories = {}
local history_contactName = {}
local history_contactNo = {}
local history_ago = {}
local history_btn_call = {}
local history_btn_sms = {}
local history_btn_save = {}
local requesting_history = nil
function drawHistory(xoffset, yoffset)
	if not xoffset then
		xoffset = 0 
	end
	if not yoffset then
		yoffset = 0
	end

	if not requesting_history and not histories[phone] then
		--outputChatBox("getHistoryData")
		wHistory = guiCreateScrollPane(30+xoffset, 100+yoffset, 221, 370, false, wPhoneMenu)
		guiCreateLabel(0.5, 0.5, 1, 0.5, "Loading..", true, wHistory)
		triggerServerEvent("phone:getHistoryData", localPlayer, phone, not contactList[phone], xoffset, yoffset) 
		requesting_history = true
	else
       	refreshHistory(histories[phone], xoffset, yoffset)
	end
end

function refreshHistory(newHistory, xoffset, yoffset, fromServer)
	if fromServer then
		requesting_history = nil
	end
	if newHistory then
		histories[tonumber(phone)] = newHistory
	end

	if wHistory and isElement(wHistory) then
		destroyElement(wHistory)
	end
			
	wHistory = guiCreateScrollPane(30+xoffset, 100+yoffset, 221, 370, false, wPhoneMenu)
	--outputChatBox(#histories[tonumber(phone)])
	if #histories[tonumber(phone)] > 0 then
		for i = 1, #histories[tonumber(phone)] do 
    		local history_name, history_number, history_unixtime, flow, private = analyzeHistory(histories[tonumber(phone)][i])
		    history_contactName[i] = guiCreateLabel(10+xoffset, 10+yoffset, 153, 19, history_name, false, wHistory)
		    guiSetFont(history_contactName[i], "default-bold-small")
		    guiLabelSetVerticalAlign(history_contactName[i], "center")
		    guiCreateStaticImage(10+xoffset, 29+yoffset, 16, 16, "images/"..flow..".png", false, wHistory)
		    history_contactNo[i] = guiCreateLabel(30+xoffset, 29+yoffset, 40, 16, history_number, false, wHistory)
		    guiSetFont(history_contactNo[i], "default-small")
		    history_ago[i] = guiCreateLabel(86+xoffset, 29+yoffset, 64, 16, history_unixtime, false, wHistory)
		    guiSetFont(history_ago[i], "default-small")
		    guiLabelSetHorizontalAlign(history_ago[i], "right")
		    if private == 0 then
			    guiCreateStaticImage(163+xoffset, 15+yoffset, 48, 14, "images/call.png", false, wHistory)
			    history_btn_call[i] = guiCreateButton(163+xoffset, 14+yoffset, 48, 16, "", false, wHistory)
			    guiSetAlpha(history_btn_call[i], 0.3)
		    
			    if tonumber(history_number) then
				    yoffset = yoffset + 31 - 14
				    guiCreateStaticImage(179+xoffset, 16+yoffset, 17, 12, "images/sms.png", false, wHistory)
				    history_btn_sms[i] = guiCreateButton(163+xoffset, 14+yoffset, 48, 16, "", false, wHistory)
				    guiSetAlpha(history_btn_sms[i], 0.3)
				    yoffset = yoffset - (31 - 14)
				else
					guiCreateStaticImage(167+xoffset, 33+yoffset, 15, 10, "images/sms.png", false, wHistory)
				    history_btn_sms[i] = guiCreateButton(163+xoffset, 31+yoffset, 24, 15, "", false, wHistory)
				    guiSetAlpha(history_btn_sms[i], 0.3)

				    guiCreateStaticImage(191+xoffset, 31+yoffset, 14, 14, "images/save.png", false, wHistory)  
				    history_btn_save[i] = guiCreateButton(187+xoffset, 31+yoffset, 24, 14, "", false, wHistory)    
				    guiSetAlpha(history_btn_save[i], 0.3)
				end
			end
			guiSetAlpha(guiCreateStaticImage(10+xoffset, 50+yoffset, 200, 1, ":admin-system/images/whitedot.jpg", false, wHistory), 0.1)
		    yoffset = yoffset + 40 
		end
		addEventHandler("onClientGUIClick", wHistory, function()
			for i = 1, #histories[tonumber(phone)] do
				if source == history_btn_call[i] then
					local history_name_or_number, posible_number = analyzeHistory(histories[tonumber(phone)][i])
					startDialing(phone, tonumber(history_name_or_number) or tonumber(posible_number))
					break
				elseif source == history_btn_sms[i] then
					local history_name_or_number, posible_number = analyzeHistory(histories[tonumber(phone)][i])
					toggleOffEverything()
					drawOneSMSThread(tonumber(history_name_or_number) or tonumber(posible_number), nil)
					break
				elseif source == history_btn_save[i] then
					local history_name_or_number, posible_number = analyzeHistory(histories[tonumber(phone)][i])
					openPhoneContacts()
					guiNewContact(tonumber(history_name_or_number))
					break
				end
			end
		end)
	else
		guiCreateLabel(0.5, 0.5, 1, 0.5, "It's lonely here..", true, wHistory)
	end
end
addEvent("phone:refreshHistory", true)
addEventHandler("phone:refreshHistory", root, refreshHistory)

function analyzeHistory(his)
	local history_id = his['id']
	local history_to = tonumber(his['to'])
	local history_from = tonumber(his['from'])
	local datesec = tonumber(his['datesec'])
	local history_state = tonumber(his['state'])
	local flow = ""
	local private = tonumber(his['private'])
	local history_number = nil
	if history_from == tonumber(phone) then
		flow = "Outgoing"
		history_number = history_to
		private = 0
	else
		history_number = history_from
		if history_state == 1 then
			flow = "Missed"
		elseif history_state == 3 then
			flow = "Incoming"
		end
	end
	local history_name = "Private"
	if private == 0 then
		history_name = getContactNameFromContactNumber(history_number, phone)
		if not history_name then
			history_name = history_number
			history_number = flow
		end
	else
		history_number = flow
	end
	--outputChatBox("datesec - "..datesec)
	--outputChatBox("exports.datetime:formatTimeInterval( datesec ) - "..exports.datetime:formatTimeInterval( datesec ))
	return history_name, history_number, exports.datetime:formatTimeInterval( datesec ), flow, private
end

function toggleHistory(state)
	if state then
		drawHistory()
	else
		closeHistory()
	end
end

function closeHistory()
	if wHistory and isElement(wHistory) then
		destroyElement(wHistory)
		wHistory = nil
	end
end

local function sortHistoryByDate(a,b)
  	return a['datesec'] < b['datesec']
end

function resetHistory(fromPhone)
	fromPhone = tonumber(fromPhone)
	if fromPhone and histories then
		histories[fromPhone] = nil
	else
		histories = {}
	end
end


	