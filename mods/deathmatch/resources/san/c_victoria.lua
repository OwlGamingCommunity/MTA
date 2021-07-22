--local victoria = createPed(141, 2469.90625, -1730.3955078125, 200.01393127441)
--setElementInterior(victoria, 1)
--setElementDimension(victoria, 1200)

local victoria = createPed(141, 1426.1455078125, 1366.763671875, 11.328600883484)
setPedRotation(victoria, 269.60037231445)
setElementFrozen(victoria, true)
setElementDimension(victoria, 1455)
setElementInterior(victoria, 3)
setElementData( victoria, "talk", 1 )
setElementData( victoria, "name", "Victoria Greene", false )

local width, height = 150, 100
local scrWidth, scrHeight = guiGetScreenSize()
local x = scrWidth/2 - (width/2)
local y = scrHeight/2 - (height/2)

local open = false
function SANVictoriaGreeting()
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if (open) then return end
	
	sanOptionMenu = guiCreateWindow(x, y, width, height, "How can we help you?", false)

	bContactUs = guiCreateButton(0.05, 0.3, 0.87, 0.25, "Contact Someone", true, sanOptionMenu)
	addEventHandler("onClientGUIClick", bContactUs, SANContactReason, false)

	bJob = guiCreateButton(0.05, 0.6, 0.87, 0.25, "Work For Us", true, sanOptionMenu)
	addEventHandler("onClientGUIClick", bJob, startJob, false)

	showCursor(true)
	guiSetInputEnabled(true)
	open = true
end
addEvent("cSANGreeting", true)
addEventHandler("cSANGreeting", getRootElement(), SANVictoriaGreeting)

function SANContactReason()
	destroyElement(sanOptionMenu)

	sanReasonBox = guiCreateWindow(x, y, width+100, height, "What do you need to talk about?", false)
	
	editReason = guiCreateEdit(0.05, 0.3, 1, 0.25, "", true, sanReasonBox)
	bSubmit = guiCreateButton(0.25, 0.6, 0.5, 0.25, "Give Answer!", true, sanReasonBox)
	addEventHandler("onClientGUIClick", bSubmit, startContact, false)

end
addEvent("cContactBox", true)
addEventHandler("cContactBox", getLocalPlayer(), SANContactReason)


function startContact()
	local reason = guiGetText(editReason)
	destroyElement(sanReasonBox)
	guiSetInputEnabled(false)
	triggerServerEvent("SAN:CU", getLocalPlayer(), getElementData(victoria, "name"), reason)
	showCursor(false)
	open = false
end

function startJob()
	destroyElement(sanOptionMenu)
	guiSetInputEnabled(false)
	triggerServerEvent("SAN:Job", getLocalPlayer(), getElementData(victoria, "name"))
	showCursor(false)
	open = false
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
function()
	guiSetInputMode("no_binds_when_editing") --Calls guiSetInputMode once and for all to not have to handle binds state dynamically
end)