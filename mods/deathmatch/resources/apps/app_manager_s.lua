--MAXIME
appOpened = {}
function openAppsWindow(thePlayer, cmd)
	if thePlayer then
		client = thePlayer
	end
	if not (exports.integration:isPlayerTrialAdmin(client) or exports.integration:isPlayerSupporter(client)) then
		return false
	end

	local apps = {}
	local quests = {}
	local preparedQ = ""
	local mQuery = nil

	preparedQ = "SELECT `a`.`id` AS `id`, `a`.`applicant` AS `username`, `dateposted`, `state`, `datereviewed`, `a`.`reviewer` AS `reviewer` FROM `applications` `a` ORDER BY `dateposted` DESC LIMIT 75"
	mQuery = exports.mysql:query(preparedQ)
	while true do
		local row = exports.mysql:fetch_assoc(mQuery)
		if not row then break end
		row.username = exports.cache:getUsernameFromId(row.username)
		row.reviewer = exports.cache:getUsernameFromId(row.reviewer)
		table.insert(apps, row )
	end
	exports.mysql:free_result(mQuery)

	preparedQ = "SELECT `id`, `part`, `question`, `createDate`, `applications_questions`.`createdBy` AS 'createdBy', `updateDate`, `applications_questions`.`updatedBy` AS 'updatedBy' FROM `applications_questions` ORDER BY `updateDate` DESC "
	mQuery = exports.mysql:query(preparedQ)
	while true do
		local row = exports.mysql:fetch_assoc(mQuery)
		if not row then break end
		row.createdBy = exports.cache:getUsernameFromId(row.createdBy)
		row.updatedBy = exports.cache:getUsernameFromId(row.updatedBy)
		table.insert(quests, row)
		--outputDebugString(row["question"])
	end
	exports.mysql:free_result(mQuery)



	triggerClientEvent(client, "apps:openAppsWindow", client, apps, quests)
end
addEvent("apps:openAppsWindow", true)
addEventHandler("apps:openAppsWindow", root, openAppsWindow)

function updateNumber()
	local mQuery = nil

	preparedQ = "SELECT COUNT(*) AS 'apps' FROM `applications` WHERE `state`=0"
	mQuery = exports.mysql:query_fetch_assoc(preparedQ)
	local apps = tonumber(mQuery["apps"])
	exports.mysql:free_result(mQuery)

	setElementData(getResourceRootElement(), "apps:number", apps)
end
addEvent("apps:requestApps", true)
addEventHandler("onResourceStart", getResourceRootElement(), updateNumber)
addEventHandler("apps:requestApps", getRootElement(), updateNumber)


function openQuestionDetail(id, part)
	local mysqlResult = exports.mysql:query_fetch_assoc("SELECT * FROM `applications_questions` WHERE `id`='"..(id) .."' LIMIT 1")
	triggerClientEvent(client, "apps:openQuestionDetail", client, part, false, true, mysqlResult)
end
addEvent("apps:openQuestionDetail", true)
addEventHandler("apps:openQuestionDetail", root, openQuestionDetail)

function saveQuestion(part, id, question, key, answer1, answer2, answer3)
	if part == 1 then
		if id and tonumber(id) then
			local mQuery1 = exports.mysql:query_free("UPDATE `applications_questions` SET `question`='"..toSQL(question).."', `key`='"..toSQL(key or 1).."', `answer1`='"..toSQL(answer1 or "").."', `answer2`='"..toSQL(answer2 or "").."', `answer3`='"..toSQL(answer3 or "").."', `part`='"..toSQL(part).."', `updatedBy`='"..toSQL(getElementData(client, "account:id")).."', `updateDate`=NOW() WHERE `id`='"..toSQL(id).."' ")
			if not mQuery1 then
				outputDebugString("APPLICATION MANAGER / DATABASE ERROR")
				outputChatBox("[APPLICATION MANAGER] Update question #"..id.." failed.", client, 255,0,0)
				return false
			end

			outputChatBox("[APPLICATION MANAGER] You have updated question #"..id.." successfully.", client, 0,255,0)
			exports.global:sendMessageToAdmins("[APPLICATION-MANAGER]: "..getElementData(client, "account:username").." has updated question #"..id.." (Part "..part..", Question: '"..question.."')")
			openAppsWindow(client)
			return true
		else
			local mQuery1 = exports.mysql:query_insert_free("INSERT INTO `applications_questions` SET `question`='"..toSQL(question).."', `key`='"..toSQL(key or "").."', `answer1`='"..toSQL(answer1 or "").."', `answer2`='"..toSQL(answer2 or "").."', `answer3`='"..toSQL(answer3 or "").."', `part`='"..toSQL(part).."', `updatedby`='"..toSQL(getElementData(client, "account:id")).."', `updateDate`=NOW(), `createdBy`='"..toSQL(getElementData(client, "account:id")).."', `createDate`=NOW() ")
			if not mQuery1 then
				outputDebugString("APPLICATION MANAGER / DATABASE ERROR")
				outputChatBox("[APPLICATION MANAGER] Failed to create question.", client, 255,0,0)
				return false
			end

			outputChatBox("[APPLICATION MANAGER] You have created question #"..mQuery1.." successfully.", client, 0,255,0)
			exports.global:sendMessageToAdmins("[APPLICATION-MANAGER]: "..getElementData(client, "account:username").." has created question #"..mQuery1.." (Part "..part..", Question: '"..question.."')")
			openAppsWindow(client)
			return true
		end
	else
		if id and tonumber(id) then
			local mQuery1 = exports.mysql:query_free("UPDATE `applications_questions` SET `question`='"..toSQL(question).."', `part`='"..toSQL(part).."', `updatedBy`='"..toSQL(getElementData(client, "account:id")).."', `updateDate`=NOW() WHERE `id`='"..toSQL(id).."' ")
			if not mQuery1 then
				outputDebugString("APPLICATION MANAGER / DATABASE ERROR")
				outputChatBox("[APPLICATION MANAGER] Update question #"..id.." failed.", client, 255,0,0)
				return false
			end

			outputChatBox("[APPLICATION MANAGER] You have updated question #"..id.." successfully.", client, 0,255,0)
			exports.global:sendMessageToAdmins("[APPLICATION-MANAGER]: "..getElementData(client, "account:username").." has updated question #"..id.." (Part "..part..", Question: '"..question.."')")
			openAppsWindow(client)
			return true
		else
			local mQuery1 = exports.mysql:query_insert_free("INSERT INTO `applications_questions` SET `question`='"..toSQL(question).."', `part`='"..toSQL(part).."', `updatedby`='"..toSQL(getElementData(client, "account:id")).."', `updateDate`=NOW(), `createdBy`='"..toSQL(getElementData(client, "account:id")).."', `createDate`=NOW() ")
			if not mQuery1 then
				outputDebugString("APPLICATION MANAGER / DATABASE ERROR")
				outputChatBox("[APPLICATION MANAGER] Failed to create question.", client, 255,0,0)
				return false
			end

			outputChatBox("[APPLICATION MANAGER] You have created question #"..mQuery1.." successfully.", client, 0,255,0)
			exports.global:sendMessageToAdmins("[APPLICATION-MANAGER]: "..getElementData(client, "account:username").." has created question #"..mQuery1.." (Part "..part..", Question: '"..question.."')")
			openAppsWindow(client)
			return true
		end
	end
	return false
end
addEvent("apps:saveQuestion", true)
addEventHandler("apps:saveQuestion", root, saveQuestion)

function deleteQuestion(id, part)
	if id and tonumber(id) and part and tonumber(part) then
		local sumQuests = exports.mysql:query_fetch_assoc("SELECT COUNT(*) AS 'num' FROM `applications_questions` WHERE `part`='"..part.."' ")
		local limit = 6
		if tonumber(part) == 2 then
			limit = 4
		end
		if tonumber(sumQuests["num"]) <= 6 then
			outputChatBox("[APPLICATION MANAGER] At least "..limit.." questions must be in part "..part.."'s bank, please add more questions to be able to delete.", client, 255,0,0)
			return false
		end
		local mQuery1 = exports.mysql:query_free("DELETE FROM `applications_questions` WHERE `id`='"..toSQL(id).."' ")
		if not mQuery1 then
			outputDebugString("APPLICATION MANAGER / DATABASE ERROR")
			outputChatBox("[APPLICATION MANAGER] Delete question #"..id.." failed.", client, 255,0,0)
			return false
		end

		outputChatBox("[APPLICATION MANAGER] You have deleted question #"..id.." successfully.", client, 0,255,0)
		exports.global:sendMessageToAdmins("[APPLICATION-MANAGER]: "..getElementData(client, "account:username").." has deleted question #"..id..".")
		openAppsWindow(client)
		return true
	else
		outputDebugString("APPLICATION MANAGER / DATABASE ERROR")
		outputChatBox("[APPLICATION MANAGER] Failed to delete question #"..mQuery1..".", client, 255,0,0)
		return false
	end
	return false
end
addEvent("apps:deleteQuestion", true)
addEventHandler("apps:deleteQuestion", root, deleteQuestion)

function openAppDetail(id, readOnly)
	if id and tonumber(id) then
		id = tonumber(id)
		if appOpened[id] and isElement(appOpened[id]) and getElementType(appOpened[id]) == "player" and not readOnly then
			if client ~= appOpened[id] then
				outputChatBox("[APPLICATION MANAGER] This application is currently being reviewed by "..exports.global:getAdminTitle1(appOpened[id])..".", client, 255,0,0)
			end
			return false
		end
		local appData = exports.mysql:query_fetch_assoc("SELECT `a`.`id` AS `id`, `a`.`applicant` AS `username`, `question1`, `question2`, `question3`, `question4`, `answer1`, `answer2`, `answer3`, `answer4`, `dateposted`, `state`, `reviewer`, `note`, `datereviewed`, `applicant` FROM `applications` `a` WHERE `a`.`id`='"..id.."' ")

		if appData and appData.id then
			appData.reviewer = exports.cache:getUsernameFromId(appData.reviewer)
			appData.username = exports.cache:getUsernameFromId(appData.username)
			if not readOnly then
				local staffName = exports.global:getAdminTitle1(client)
				appOpened[id] = client
				exports.mysql:query_free("UPDATE `applications` SET `reviewer`='"..getElementData(client, "account:id").."', `datereviewed`=NOW() WHERE `id`='"..id.."'")
				sendMsgToStaff(staffName.." has opened and reviewing "..appData.username.."'s application ID#"..id..".")
				sendMsgToApplicant(appData.applicant, staffName.." has opened and is currently reviewing your application.\nPlease stand by..")
			end
			triggerClientEvent(client, "apps:openAppDetail",client, appData, readOnly)
		end
	end
end
addEvent("apps:openAppDetail", true)
addEventHandler("apps:openAppDetail", root, openAppDetail)

function cleanUpOpenedApps()
	for i, openedApp in pairs(appOpened) do
		if openedApp == source then
			openedApp = nil
			appOpened[i] = nil
		end
	end
end
addEventHandler ( "onPlayerQuit", getRootElement(), cleanUpOpenedApps )
addEventHandler ( "accounts:characters:change", getRootElement(), cleanUpOpenedApps )

local app_fail_attempts = {}
function updateAppState(id, applicantID, applicationName, state, reason)
	if id and tonumber(id) then
		id = tonumber(id)
		state = tonumber(state)
		local reviewer = getElementData(client, "account:id")
		local appData = exports.mysql:query_free("UPDATE `applications` SET `reviewer`='"..reviewer.."', `datereviewed`=NOW(), `state`='"..state.."', `note`='"..toSQL(reason).."' WHERE `id`='"..id.."' ")
		openAppsWindow(client)
		if appData then
			local staffName = exports.global:getAdminTitle1(client)
			sendMsgToStaff(staffName.." has "..(state == 1 and "accepted" or "declined").." "..applicationName.."'s application ID#"..id..". Reason: "..reason)
			if state == 1 then -- accepted
				app_fail_attempts[applicantID] = nil
				sendMsgToApplicant(applicantID, "Congratulations! Your application has been reviewed and accepted by "..staffName..".\nReason: "..reason.."\nJoining the game...")
				exports.mysql:query_free("UPDATE `account_details` SET `appstate`='3' WHERE `account_id`='"..applicantID.."' ")
				setTimer(movePlayerToSelectionScreen, 10000, 1, applicantID)
				exports['report']:updateStaffReportCount(client)
			elseif state == 2 then
				if not app_fail_attempts[applicantID] then
					app_fail_attempts[applicantID] = 1
				end
				if app_fail_attempts[applicantID] >= 3 then
					exports.mysql:query_free("DELETE FROM `force_apps` WHERE `account`='" .. applicantID .. "' ")
					exports.mysql:query_free("INSERT INTO `force_apps` SET `account`='" .. applicantID .. "' ")
					exports.mysql:query_free("UPDATE `account_details` SET `appstate`='0' WHERE `account_id`='" .. applicantID .. "' ")
					for i, player in pairs(getElementsByType("player")) do
						if getElementData(player, "account:id") == tonumber(applicantID) and (getElementData(player, "loggedin") ~= 1) then
							redirectPlayer ( player, "" , 0 )
							break
						end
					end
					app_fail_attempts[applicantID] = nil
					sendMsgToStaff(applicationName.." has been 24 hours banned from retaking application as it has been declined 3 times in a row.")
					exports['report']:updateStaffReportCount(client)
					updateNumber()
					return true
				else
					sendMsgToApplicant(applicantID, "Unfortunately, your application has been declined by "..staffName..".\nReason: "..reason.."\nReturning to application section 2..\n\nYou have "..tostring(3-app_fail_attempts[applicantID]).." chance(s) left to re-submit another application.")
					app_fail_attempts[applicantID] = app_fail_attempts[applicantID] + 1
					exports.mysql:query_free("UPDATE `account_details` SET `appstate`='1' WHERE `account_id`='"..applicantID.."' ")
					setTimer(movePlayerBackToStep2, 10000, 1, applicantID)
				end
				exports['report']:updateStaffReportCount(client)
			end
			updateNumber()
			triggerEvent("apps:closeAppDetail",client, id)
		end
	end
end
addEvent("apps:updateAppState", true)
addEventHandler("apps:updateAppState", root, updateAppState)

function closeAppDetail(id)
	if source and isElement(source) and getElementType(source) == "player" then
		client = source
	end
	if id and tonumber(id) then
		id = tonumber(id)
		appOpened[id] = nil
		--exports.mysql:query_free("UPDATE `applications` SET `reviewer`='0' WHERE `id`='"..id.."'")
		triggerClientEvent(client, "apps:closeAppDetail",client)
	end
end
addEvent("apps:closeAppDetail", true)
addEventHandler("apps:closeAppDetail", root, closeAppDetail)

function movePlayerToSelectionScreen(id)
	if id and tonumber(id) then
		id = tonumber(id)
		local players = getElementsByType("player")
		for i, player in pairs(players) do
			if getElementData(player, "account:id") == id then
				triggerEvent("accounts:playerFinishApps", player)
				return true
			end
		end
	end
end

function movePlayerBackToStep2(id)
	if id and tonumber(id) then
		id = tonumber(id)
		local players = getElementsByType("player")
		for i, player in pairs(players) do
			if getElementData(player, "account:id") == id then
				triggerClientEvent (player,"apps:destroyGUIPart3",player)
				triggerEvent("apps:retakeApplicationPart2", player)
				return true
			end
		end
	end
end

function toSQL(stuff)
	return exports.mysql:escape_string(stuff)
end

function sendMsgToStaff(msg)
	if msg then
		exports.global:sendWrnToStaffOnDuty(msg, "APPLICATION", 255, 0, 0)
	end
end

function sendMsgToApplicant(applicant, msg)
	local players = getElementsByType("player")
	for i, player in pairs(players) do
		if getElementData(player, "account:id") == tonumber(applicant) and (getElementData(player, "loggedin") ~= 1) then
			triggerClientEvent(player, "apps:startStep3", player, msg)
		end
	end
end
