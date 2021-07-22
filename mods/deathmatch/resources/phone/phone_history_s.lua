--MAXIME
--[[
state = 1 | caller = outgoing | called = missed
state = 2 | caller = outgoing | called = not exited or out of service or turned off so do not list
state = 3 | caller = outgoing | called = incoming.
]]
addedPhoneHistories = {}
function addPhoneHistory(from, to, state, private)
	from = tonumber(from)
	to = tonumber(to)
	state = tonumber(state)
	private = tonumber(private) == 1 and 1 or 0
	addedPhoneHistories[to] = mysql:query_insert_free("INSERT INTO `phone_history` SET `from`='"..from.."', `to`='"..to.."', `state`='"..state.."', private="..private)
end

function updatePhoneHistoryState(to, state)
	to = tonumber(to)
	state = tonumber(state)
	if mysql:query_free("UPDATE `phone_history` SET `state`='"..state.."' WHERE `to`='"..to.."'   ") then
		addedPhoneHistories[to] = nil
	end
end

function getHistoryData(fromPhone, forceUpdateContactList1, xoffset, yoffset)
	fromPhone = tonumber(fromPhone)
	if forceUpdateContactList1 then
		forceUpdateContactList(source, fromPhone)
	end
	local limit = 9
	local results = {}
	local condition = "(`from`='"..fromPhone.."' OR `to`='"..fromPhone.."') AND !(`state`=2 AND `to`='"..fromPhone.."') "
	local result = mysql:query("SELECT *, TO_SECONDS(`date`) AS `datesec` FROM `phone_history` WHERE "..condition.." ORDER BY `date` DESC LIMIT "..limit)
	while true do
		local row = mysql:fetch_assoc(result)
		if not row then break end
		table.insert(results, row)
	end
	mysql:free_result(result)
	triggerClientEvent(source, "phone:refreshHistory", source, results, xoffset, yoffset, true)
	mysql:query_free("DELETE FROM `phone_history` WHERE DATEDIFF(NOW(),`date`) > 30")
end
addEvent("phone:getHistoryData", true)
addEventHandler("phone:getHistoryData", root, getHistoryData)