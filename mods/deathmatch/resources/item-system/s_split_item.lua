
function resetFrame(player, itemID, itemValue)
	if exports.global:takeItem(player, itemID, itemValue) and exports.global:giveItem(player, 147, 1) then
		outputChatBox("Texture information formatted.", player, 0, 255, 0)
	end
end
addEvent("resetFrame", true)
addEventHandler("resetFrame", getRootElement(), resetFrame)

function splitItem (itemID, amount)
	local player = source
	local itemID = tonumber(itemID)
	local amount = tonumber(amount)
	if itemID and amount then
		if (itemID%1 ~= 0) or (amount%1 ~= 0) then
			outputChatBox("Item ID and Amount must be integer, like 1,2,3,..", player, 255, 0, 0, false)
			return false
		end
		if itemID > 0 and splittableItems[itemID] then
			local isPlayerHasItem, itemSlot, itemValue, noIdeaWhatItis = hasItem(player, itemID)
			if isPlayerHasItem then
				-- ammopack
				if itemID == 116 then 
					local pack = exports.global:explode(':', itemValue)
					local ammo = tonumber(pack[2]) or 0
					if ammo > 0 then
						if ammo > amount then
							local itemRemaining = ammo - amount
							if takeItem(player, itemID, itemValue) and giveItem( player, itemID, exports.weapon:modifyWeaponValue(itemValue, 2, itemRemaining), false , true) then
								-- now we need to create another serial for it. as the ammopack is going to split into 2 different items. Serial can't be the same.
								local serial = pack[3] and exports.global:retrieveWeaponDetails( pack[3] )
								local gun_source = 1
								local gun_creator = getElementData(player, 'dbid')
								if serial then
									if serial[2] and tonumber(serial[2]) then
										gun_source = tonumber(serial[2])
									end
									if serial[3] and tonumber(serial[3]) then
										gun_creator = tonumber(serial[3])
									end
								end
								local new_serial = exports.global:createWeaponSerial( gun_source, gun_creator, getElementData(player, 'dbid') )
								-- update itemValue and give it to player.
								local new_value = exports.weapon:modifyWeaponValue(itemValue, 3, new_serial)
								return giveItem( player, itemID, exports.weapon:modifyWeaponValue(new_value, 2, amount) ,false ,true)
							else
								outputChatBox("Something when wrong when the system trying to split your item. Please report this to admins.", player, 255, 0, 0, false)
								return false
							end
						else
							outputChatBox("The amount to split must be smaller than what you have in your inventory.", player, 255, 0, 0, false)
						end
					end
				else
					local itemValue_ = tonumber((tostring(itemValue):match("%d+")))
					if not itemValue_ then
						outputChatBox("Your item is bugged. Please report to admin to be spawned a new one", player,255,0,0)
						return false
					end
					if amount > 0 then
						if amount < itemValue_ then
							local itemRemaining = itemValue_ - amount
							if takeItem(player, itemID, itemValue) and giveItem( player, itemID, amount, false , true) and giveItem( player, itemID, itemRemaining,false ,true) then
								--It's all good
								return true
							else
								outputChatBox("Something when wrong when the system trying to split your item. Please report this to admins.", player, 255, 0, 0, false)
								return false
							end
						else
							outputChatBox("The amount to split must be smaller than what you have in your inventory.", player, 255, 0, 0, false)
						end
					else
						outputChatBox("Amount must be over zero.", player, 255, 0, 0, false)
					end
				end
			else
				outputChatBox("You do not have that item in your inventory.", player, 255, 0, 0, false)
			end
		end
	end
end
addEvent("splitItem", true)
addEventHandler("splitItem", getRootElement(), splitItem)

function listSplittable(thePlayer, commandName)
	outputChatBox("List of splittable item's names & IDs:",thePlayer, 255, 194, 14)
	for itemID = 1, 150 do
		local itemName = false
		itemName = getItemName(itemID)
		if itemName and splittableItems[itemID] then
			outputChatBox("ID #"..tostring(itemID).." - "..itemName..".",thePlayer, 0, 255, 0)
		end
	end
end
addCommandHandler("splits",listSplittable, false, false )