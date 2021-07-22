function cPayDay(faction, pay, profit, interest, donatormoney, tax, incomeTax, vtax, ptax, rent, totalInsFee, grossincome, Perc)
	local cPayDaySound = playSound("mission_accomplished.mp3")
	local bankmoney = getElementData(getLocalPlayer(), "bankmoney")
	local moneyonhand = getElementData(getLocalPlayer(), "money")
	local wealthCheck = moneyonhand + bankmoney
	setSoundVolume(cPayDaySound, 0.7)
	local info = {}
	-- output payslip
	--outputChatBox("-------------------------- PAY SLIP --------------------------", 255, 194, 14)
	table.insert(info, {"Payslip"})	
	table.insert(info, {""})
	--table.insert(info, {""})
	-- state earnings/money from faction
	if not (faction) then
		if (pay + tax > 0) then
			--outputChatBox(, 255, 194, 14, true)
			table.insert(info, {"  State Benefits: $" .. exports.global:formatMoney(pay+tax)})	
		end
	else
		if (pay + tax > 0) then
			--outputChatBox(, 255, 194, 14, true)
			table.insert(info, {"  Wage Paid: $" .. exports.global:formatMoney(pay+tax)})
		end
	end
	
	-- business profit
	if (profit > 0) then
		--outputChatBox(, 255, 194, 14, true)
		table.insert(info, {"  Business Profit: $" .. exports.global:formatMoney(profit)})
	end
	
	-- bank interest
	if (interest > 0) then
		--outputChatBox(,255, 194, 14, true)
		table.insert(info, {"  Bank Interest: $" .. exports.global:formatMoney(interest) .. " (≈" ..("%.2f"):format(Perc) .. "%)"})
	end
	
	-- donator money (nonRP)
	if (donatormoney > 0) then
		--outputChatBox(, 255, 194, 14, true)
		table.insert(info, {"  Donator Money: $" .. exports.global:formatMoney(donatormoney)})
	end
	
	-- Above all the + stuff
	-- Now the - stuff below
	
	-- income tax
	if (tax > 0) then
		--outputChatBox(, 255, 194, 14, true)
		table.insert(info, {"  Income Tax of " .. (math.ceil(incomeTax*100)) .. "%: $" .. exports.global:formatMoney(tax)})
	end
	
	if (vtax > 0) then
		--outputChatBox(, 255, 194, 14, true)
		table.insert(info, {"  Vehicle Tax: $" .. exports.global:formatMoney(vtax)})
	end

	if (totalInsFee > 0) then
		table.insert(info, {"  Vehicle Insurance: $" .. exports.global:formatMoney(totalInsFee)})
	end
	
	if (ptax > 0) then
		--outputChatBox(, 255, 194, 14, true )
		table.insert(info, {"  Property Expenses: $" .. exports.global:formatMoney(ptax)})
	end
	
	if (rent > 0) then
		--outputChatBox(, 255, 194, 14, true)
		table.insert(info, {"  Apartment Rent: $" .. exports.global:formatMoney(rent)})
	end
	
	--outputChatBox("------------------------------------------------------------------", 255, 194, 14)
	
	if grossincome == 0 then
		--outputChatBox(,255, 194, 14, true)
		table.insert(info, {"  Gross Income: $0"})
	elseif (grossincome > 0) then
		--outputChatBox(,255, 194, 14, true)
		--outputChatBox(, 255, 194, 14)
		table.insert(info, {"  Gross Income: $" .. exports.global:formatMoney(grossincome)})
		table.insert(info, {"  Remark(s): Transferred to your bank account."})
	else
		--outputChatBox(, 255, 194, 14, true)
		--outputChatBox(, 255, 194, 14)
		table.insert(info, {"  Gross Income: $" .. exports.global:formatMoney(grossincome)})
		table.insert(info, {"  Remark(s): Taking from your bank account."})
	end
	
	
	if (pay + tax == 0) then
		if not (faction) then
			--outputChatBox(, 255, 0, 0)
			table.insert(info, {"  The government could not afford to pay you your state benefits."})
		else
			--outputChatBox(, 255, 0, 0)
			table.insert(info, {"  Your employer could not afford to pay your wages."})
		end
	end
	
	if (rent == -1) then
		--outputChatBox(, 255, 0, 0)
		table.insert(info, {"  You were evicted from your apartment, as you can't pay the rent any longer."})
	end

	if (totalInsFee == -1) then
		table.insert(info, {"  Your insurance has been removed because you failed to pay for it."})
	end
	
	--outputChatBox("------------------------------------------------------------------", 255, 194, 14)
	-- end of output payslip
	if exports.hud:isActive() then
		triggerEvent("hudOverlay:drawOverlayTopRight", localPlayer, info ) 
	end
	triggerEvent("updateWaves", getLocalPlayer())

	-- trigger one event to run whatever functions anywhere that needs to be executed hourly
	triggerEvent('payday:run', resourceRoot)
end
addEvent("cPayDay", true)
addEventHandler("cPayDay", getRootElement(), cPayDay)

function startResource()
	addEvent('payday:run', true)
end
addEventHandler("onClientResourceStart", getResourceRootElement(), startResource)