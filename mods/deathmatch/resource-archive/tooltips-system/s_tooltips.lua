-- Triggers
------------

-- Vehicles
addEventHandler("onVehicleEnter",getRootElement(),
	function(thePlayer)
		triggerClientEvent(thePlayer,"tooltips:showHelp",getRootElement(),2)
	end)

-- Interiors
addEventHandler("onPickupHit",getRootElement(),
	function(thePlayer)
		if (getElementDimension(thePlayer)==0)then
			if (getElementModel(source)==1318) then
				triggerClientEvent(thePlayer,"tooltips:showHelp",getRootElement(),4) -- Interiors
			else
				triggerClientEvent(thePlayer,"tooltips:showHelp",getRootElement(),15) -- House buying & renting
			end
		end
	end)