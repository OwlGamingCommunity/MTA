--Interior settings //Exciter

local interiorSettings = {
	--label, id, type
	{"Set time", "time", "options", options={"auto", "day", "night"} },
	{"Disable local OOC chat", "ooc", "bool"},
}

function openSettingsGui(element, playerInterior, interiorID, data)
	if window then destroySettingsGui() end
	local localPlayerInterior = getElementInterior(localPlayer)
	local localPlayerDimension = getElementDimension(localPlayer)
	if(localPlayerInterior == playerInterior and localPlayerDimension == interiorID) then
		if(playerInterior > 0 and interiorID > 0) then --doublecheck valid interior
			if(interiorID > 20000) then
				isVehicleInterior = true
			end
			local sx, sy = guiGetScreenSize()
			local w, h = 200, 10
			for k,v in ipairs(interiorSettings) do
				h = h + 30
			end

			window = guiCreateWindow(223, 185, 324, 503, "Interior Settings", false)
			guiWindowSetSizable(window, false)

			options = {}
			local y = 20
			for k,v in ipairs(interiorSettings) do
				if(v[3] == "bool") then
					local selected = data[v[2]] or false
					options[v[2]] = guiCreateCheckBox(10, y, w-20, 20, tostring(v[1]), selected, false, window)
					y = y + 30
					h = h + 30
				elseif(v[3] == "options") then
					local label = guiCreateLabel(10, y, w-20, 20, tostring(v[1]), false, window)
					y = y + 20
					local comboHeight = 20
					h = h + comboHeight + 10
					local combo = guiCreateComboBox(10, y, w-20, comboHeight, "", false, window)
					y = y + comboHeight + 10
					options[v[2]] = combo
					for k,v in ipairs(v.options) do
						guiComboBoxAddItem(combo, v)
						comboHeight = comboHeight + 20
					end
					guiSetSize(combo, w-20, comboHeight, false)
					local currentValue = tonumber(data[v[2]]) or false
					if currentValue and currentValue >= 0 then
						guiComboBoxSetSelected(combo, currentValue)
					else
						guiComboBoxSetSelected(combo, 0)
					end
				end
			end

			local btn = guiCreateButton(10, h-30, w-20, 20, "Save & Close", false, window)
			addEventHandler("onClientGUIClick", btn, function()
				local newData = {}
				for k, v in ipairs(interiorSettings) do
					if(v[3] == "bool") then
						newData[v[2]] = guiCheckBoxGetSelected(options[v[2]])
					elseif(v[3] == "options") then
						newData[v[2]] = guiComboBoxGetSelected(options[v[2]])
					end
				end
				destroySettingsGui()
				triggerServerEvent("interior:saveSettings", resourceRoot, element, interiorID, isVehicleInterior, newData)
			end, false)

			guiSetSize(window, w, h, false)
			wx = (sx / 2) - (w / 2)
			wy = (sy / 2) - (h / 2)
			guiSetPosition(window, wx, wy, false)
		end
	end
end
addEvent("interior:settingsGui", true)
addEventHandler("interior:settingsGui", getLocalPlayer(), openSettingsGui)

function destroySettingsGui()
	if window then
		destroyElement(window)
		window = nil
	end
end