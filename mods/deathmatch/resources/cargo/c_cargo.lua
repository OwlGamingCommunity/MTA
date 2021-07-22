localPlayer = getLocalPlayer()
local currentFaction, currentFactionName

local shippingCustomerFactions = {
	--factions that are allowed to import
	74, --JGC Logistics
	104, --SL Incorporated
}

function canUseShippingImport()
	for k,v in ipairs(shippingCustomerFactions) do
		local isMember, rank, isLeader = exports.factions:isPlayerInFaction(localPlayer, v)
		if isMember and isLeader then
			currentFaction = v
			currentFactionName = exports.factions:getFactionName(v)
			return true
		end
	end
	return false
end

function shippingOrderGUI()
	if canUseShippingImport() then
		local width, height = 300, 350
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)
		if shippingOrdersWindow and isElement(shippingOrdersWindow) then
			destroyElement(shippingOrdersWindow)
		end
		shippingOrdersWindow = guiCreateWindow(x, y, width, height, "Shipping Orders", false)

		local label = guiCreateLabel(10, 30, width-20, 20, "Shipping orders for "..tostring(currentFactionName)..".", false, shippingOrdersWindow)

		myInfoGridlist = guiCreateGridList(10, 55, width-20, height-115, false, shippingOrdersWindow)

		b1 = guiCreateButton(10, (height-60)+5, width-20, 20, "New Order", false, shippingOrdersWindow)
		b2 = guiCreateButton(10, (height-60)+5+20+5, width-20, 20, "Close", false, shippingOrdersWindow)
		addEventHandler("onClientGUIClick", b2, closeShippingOrderGUI, false)

		--triggerServerEvent("cargo:getShippingOrders", resourceRoot, currentFaction)
	end
end
addCommandHandler("shipping", shippingOrderGUI)

function closeShippingOrderGUI()
	if shippingOrdersWindow then
		destroyElement(shippingOrdersWindow)
		shippingOrdersWindow = nil
	end
end