addEvent("fadeCameraOnSpawn", true)
addEventHandler("fadeCameraOnSpawn", getLocalPlayer(),
	function()
		start = getTickCount()
	end
)
local bRespawn = nil
function showRespawnButton(victimDropItem)
	showCursor(true)
	local width, height = 201,54
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/1.1 - (height/2)
	bRespawn = guiCreateButton(x, y, width, height,"Respawn",false)
		guiSetFont(bRespawn,"sa-header")
	addEventHandler("onClientGUIClick", bRespawn, function () 
		if bRespawn then
			destroyElement(bRespawn)
			bRespawn = nil
			showCursor(false)
			guiSetInputEnabled(false)
		end
		triggerServerEvent("es-system:acceptDeath", localPlayer, victimDropItem)
		showCursor(false)
	end, false)
end
addEvent("es-system:showRespawnButton", true)
addEventHandler("es-system:showRespawnButton", getLocalPlayer(),showRespawnButton)

function closeRespawnButton()
	if bRespawn then
		destroyElement(bRespawn)
		bRespawn = nil
		showCursor(false)
		guiSetInputEnabled(false)
	end
end
addEvent("es-system:closeRespawnButton", true)
addEventHandler("es-system:closeRespawnButton", getLocalPlayer(),closeRespawnButton)

function getMedicalBill(amount, insurance, faction, issuedBy, date, rankName)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	local width, height = 390, 298
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)
	if medicalBillWindow and isElement(medicalBillWindow) then
		destroyElement(medicalBillWindow)
		medicalBillWindow = nil
	end
	medicalBillWindow = guiCreateWindow(x, y, width, height, "Medical Bill", false)
		guiWindowSetSizable(medicalBillWindow, false)

	if faction == 164 then
		local logo = guiCreateStaticImage(24, 20, 111, 73, "ash.png", false, medicalBillWindow)

		local label5 = guiCreateLabel(20, 103, 140, 22, "Bill to:", false, medicalBillWindow)
			guiSetFont(label5, "default-bold-small")

		local label6 = guiCreateLabel(20, 120, 140, 22, exports.global:getPlayerName(localPlayer), false, medicalBillWindow)
			guiSetFont(label6, "default-small")

		local label7 = guiCreateLabel(20, 147, 140, 22, "Pay to:", false, medicalBillWindow)
			guiSetFont(label7, "default-bold-small")

		local label8 = guiCreateLabel(20, 164, 140, 22, exports.factions:getFactionName(faction), false, medicalBillWindow)
			guiSetFont(label8, "default-small")

		local label9 = guiCreateLabel(20, 191, 140, 22, "Issued by:", false, medicalBillWindow)
			guiSetFont(label9, "default-bold-small")

		--local rank = exports.factions:getPlayerFactionRank(issuedBy, faction)
		--local team = exports.factions:getFactionFromID(faction)
		--local factionRanks = getElementData(team, "ranks")
		--local rankName = factionRanks[rank]

		local label10, label13
		if rankName then
			local label13 = guiCreateLabel(20, 208, 140, 22, tostring(rankName), false, medicalBillWindow)
				guiSetFont(label13, "default-small")
			local label10 = guiCreateLabel(20, 225, 140, 22, exports.global:getPlayerName(issuedBy), false, medicalBillWindow)
				guiSetFont(label10, "default-small")
		else
			local label10 = guiCreateLabel(20, 208, 140, 22, exports.global:getPlayerName(issuedBy), false, medicalBillWindow)
				guiSetFont(label10, "default-small")			
		end

		local label11 = guiCreateLabel(20, 252, 140, 22, "Issued date:", false, medicalBillWindow)
			guiSetFont(label11, "default-bold-small")

		local now = date
		local datetime = string.format("%04d-%02d-%02d %02d:%02d", now.year+1900, now.month+1, now.monthday, now.hour, now.minute)

		local label12 = guiCreateLabel(20, 269, 140, 22, datetime, false, medicalBillWindow)
			guiSetFont(label12, "default-small")
	else
		local label5 = guiCreateLabel(20, 30, 140, 22, "Bill to:", false, medicalBillWindow)
			guiSetFont(label5, "default-bold-small")

		local label6 = guiCreateLabel(20, 52, 140, 22, exports.global:getPlayerName(localPlayer), false, medicalBillWindow)
			guiSetFont(label6, "default-small")

		local label7 = guiCreateLabel(20, 74, 140, 22, "Pay to:", false, medicalBillWindow)
			guiSetFont(label7, "default-bold-small")

		local label8 = guiCreateLabel(20, 96, 140, 22, exports.factions:getFactionName(faction), false, medicalBillWindow)
			guiSetFont(label8, "default-small")

		local label9 = guiCreateLabel(20, 118, 140, 22, "Issued by:", false, medicalBillWindow)
			guiSetFont(label9, "default-bold-small")

		--local rank = exports.factions:getPlayerFactionRank(issuedBy, faction)
		--local team = exports.factions:getFactionFromID(faction)
		--local factionRanks = getElementData(team, "ranks")
		--local rankName = factionRanks[rank]

		local label10, label13
		if rankName then
			local label10 = guiCreateLabel(20, 140, 140, 22, exports.global:getPlayerName(issuedBy), false, medicalBillWindow)
				guiSetFont(label10, "default-small")
			local label13 = guiCreateLabel(20, 162, 140, 22, tostring(rankName), false, medicalBillWindow)
				guiSetFont(label13, "default-small")
		else
			local label10 = guiCreateLabel(20, 140, 140, 22, exports.global:getPlayerName(issuedBy), false, medicalBillWindow)
				guiSetFont(label10, "default-small")			
		end

		local label11 = guiCreateLabel(20, 184, 140, 22, "Issued date:", false, medicalBillWindow)
			guiSetFont(label11, "default-bold-small")

		local now = date
		local datetime = string.format("%04d-%02d-%02d %02d:%02d", now.year+1900, now.month+1, now.monthday, now.hour, now.minute)

		local label12 = guiCreateLabel(20, 206, 140, 22, datetime, false, medicalBillWindow)
			guiSetFont(label12, "default-small")
	end

	local bg = guiCreateStaticImage(160, 25, 210, 103, ":computers-system/websites/colours/1.png", false, medicalBillWindow)
	if bg then
		local label1 = guiCreateLabel(40, 5, 170, 22, "MEDICAL BILL", false, bg)
			guiSetFont(label1, "default-bold-small")
			guiLabelSetColor(label1, 0, 0, 0)

		local label2 = guiCreateLabel(40, 37, 170, 22, "Total fees: $ "..tostring(exports.global:formatMoney(amount)), false, bg)
			guiLabelSetColor(label2, 170, 0, 0)
			local label2_2 = guiCreateLabel(18, 32, 22, 22, "", false, bg)
				guiLabelSetColor(label2_2, 0, 0, 0)

		local label3 = guiCreateLabel(40, 54, 170, 22, "Insurance: $ "..tostring(exports.global:formatMoney(insurance)), false, bg)
			guiLabelSetColor(label3, 0, 100, 0)
			local label3_2 = guiCreateLabel(18, 54, 22, 22, "-", false, bg)
				guiLabelSetColor(label3_2, 0, 0, 0)

		local line = guiCreateStaticImage(18, 73, 150, 1, ":computers-system/websites/colours/36.png", false, bg)

		local label4 = guiCreateLabel(40, 76, 170, 22, "TOTAL DUE: $ "..tostring(exports.global:formatMoney(amount-insurance)), false, bg)
			guiSetFont(label4, "default-bold-small")
			guiLabelSetColor(label4, 170, 0, 0)
			local label3_2 = guiCreateLabel(18, 76, 22, 22, "=", false, bg)
				guiLabelSetColor(label3_2, 0, 0, 0)
	else
		local label1 = guiCreateLabel(200, 30, 170, 22, "MEDICAL BILL", false, medicalBillWindow)
			guiSetFont(label1, "default-bold-small")

		local label2 = guiCreateLabel(200, 62, 170, 22, "Total fees: $ "..tostring(exports.global:formatMoney(amount)), false, medicalBillWindow)

		local label3 = guiCreateLabel(200, 84, 170, 22, "Insurance: - $ "..tostring(exports.global:formatMoney(insurance)), false, medicalBillWindow)

		local label4 = guiCreateLabel(200, 106, 170, 22, "TOTAL DUE: $ "..tostring(exports.global:formatMoney(amount-insurance)), false, medicalBillWindow)
			guiSetFont(label4, "default-bold-small")
	end

	b1 = guiCreateButton(160, 138, 210, 40, "Pay by Cash", false, medicalBillWindow)
	addEventHandler("onClientGUIClick", b1, function()
		closeMedicalBillWindow()
		triggerServerEvent("es-system:payMedicalBill", getResourceRootElement(), localPlayer, issuedBy, faction, amount, insurance, 1)
	end, false)

	b2 = guiCreateButton(160, 188, 210, 40, "Pay by Bank", false, medicalBillWindow)
	addEventHandler("onClientGUIClick", b2, function()
		closeMedicalBillWindow()
		triggerServerEvent("es-system:payMedicalBill", getResourceRootElement(), localPlayer, issuedBy, faction, amount, insurance, 2)
	end, false)

	b3 = guiCreateButton(160, 238, 210, 40, "Refuse to pay", false, medicalBillWindow)
	addEventHandler("onClientGUIClick", b3, function()
		closeMedicalBillWindow()
		outputChatBox("You refused to pay the medical bill.", 255, 0, 0)
		triggerServerEvent("es-system:payMedicalBill", getResourceRootElement(), localPlayer, issuedBy, faction, amount, insurance, 3)
	end, false)
end
addEvent("es-system:medicalBillClient", true)
addEventHandler("es-system:medicalBillClient", getLocalPlayer(), getMedicalBill)

function closeMedicalBillWindow()
	if medicalBillWindow and isElement(medicalBillWindow) then
		destroyElement(medicalBillWindow)
		medicalBillWindow = nil
	end
end