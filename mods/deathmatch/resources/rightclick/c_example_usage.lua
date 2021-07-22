function clickObject(button, state, absX, absY, wx, wy, wz, element)
	if (element) and (getElementType(element)=="object") and (button=="right") and (state=="down") then --if it's a right-click on a object
		local model = getElementModel(element)
		local rcMenu
		if(model == 2517) then --If the object is a shower model
			rcMenu = exports.rightclick:create("Shower")
			local row = exports.rightclick:addRow("Take a shower")
			addEventHandler("onClientGUIClick", row,  function (button, state)
				takeShower(element)
			end, true)
		elseif(model == 2964) then --If the object is a pool table model
			rcMenu = exports.rightclick:create("Pool Table")
			local row = exports.rightclick:addRow("New Game")
			addEventHandler("onClientGUIClick", row,  function (button, state)
				triggerServerEvent("pool-game:newGame", getLocalPlayer(), getLocalPlayer())			
			end, true)
		end

		if(getElementData(element, "deleteable")) then --if object has element data "deleteable" set
			if not rcMenu then rcMenu = exports.rightclick:create("A Deleteable Object") end --create a new context menu only if we didn't already
			local row = exports.rightclick:addRow("Delete") --add a row
			addEventHandler("onClientGUIClick", row,  function (button, state) --define what happens when user clicks the row
				destroyElement(element) --destroy object
			end, true)			
		end

	end
end
addEventHandler("onClientClick", getRootElement(), clickObject, true)