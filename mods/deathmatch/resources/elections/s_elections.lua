local function reloadElection(qh)
	local result = dbPoll(qh, 0)
	local result_table = { }
	for _, rows in ipairs(result) do 
		table.insert(result_table, rows)
	end
	setElementData(resourceRoot, "elections:votes", result_table)
end


addEventHandler("onResourceStart", resourceRoot,
	function()
		dbQuery(reloadElection, exports.mysql:getConn("mta"), "SELECT * FROM `elections`")
		local ped = createPed(240, 1485.2607421875, 1251.177734375, 51.977203369141)
		setElementFrozen(ped, true)
		setElementRotation(ped, 0, 0, 180)
		setElementDimension(ped, 2060)
		setElementInterior(ped, 2)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.name", "Robert Philips")
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.gender", 0)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.nametag", true)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.behav", 0)

		--owl specifics
		exports.anticheat:changeProtectedElementDataEx(ped, "nametag", true)
		exports.anticheat:changeProtectedElementDataEx(ped, "name", "Robert Philips")
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.type", "electionsped")

		--setElementData(ped, "talk", 1, true)

		addEventHandler( 'onClientPedWasted', ped,
			function()
				setTimer(
					function()
						destroyElement(ped)
						createPed()
					end, 20000, 1)
			end, false)

		addEventHandler( 'onClientPedDamage', ped, cancelEvent, false )
	end)

function updateVotes(selection)
	local currentVotes = getElementData(resourceRoot, "elections:votes")

	local vote = nil
	for tableIndex, votingData in pairs(currentVotes) do
		if votingData["electionsname"] == selection then
			vote = tableIndex
		end
	end

	currentVotes[vote]["votes"] = tonumber(currentVotes[vote]["votes"]) + 1
	setElementData(resourceRoot, "elections:votes", currentVotes)

	dbExec(exports.mysql:getConn("mta"), "UPDATE elections SET votes = votes + 1 WHERE `electionsname` = ?", selection)
	dbExec(exports.mysql:getConn("mta"), "UPDATE account_details SET `electionsvoted`='1' WHERE `account_id` = ?", getElementData(client, "account:id"))
	setElementData(client, "electionsvoted", 1, true)
	outputChatBox("You have voted for: ".. selection, client)
end
addEvent("elections:refresh", true)
addEventHandler("elections:refresh", resourceRoot, updateVotes)

function displayVotes(thePlayer)
	if exports.integration:isPlayerHeadAdmin(thePlayer) then
		local voteTable = getElementData(resourceRoot, "elections:votes")
		outputChatBox("CURRENT VOTES:", thePlayer)
		for _, voteData in pairs(voteTable) do
			outputChatBox(voteData["electionsname"]..": "..voteData["votes"].." votes.", thePlayer)
		end
	end
end
addCommandHandler("electionvotes", displayVotes)

function resetElections()
	if not exports.integration:isPlayerHeadAdmin(client) then 
		return
	end

	dbExec(exports.mysql:getConn("mta"), "UPDATE account_details SET `electionsvoted`='0'")
	for _, player in ipairs(getElementsByType("player")) do 
		if getElementData(player, "electionsvoted") then 
			removeElementData(player, "electionsvoted")
		end
	end

	outputChatBox("Done.", client)
end
addEvent("elections:reset", true)
addEventHandler("elections:reset", resourceRoot, resetElections)

function addToElection(name)
	if not exports.integration:isPlayerHeadAdmin(client) then 
		return
	end

	dbExec(exports.mysql:getConn("mta"), "INSERT INTO elections (electionsname) VALUES (?)", name)
	dbQuery(reloadElection, exports.mysql:getConn("mta"), "SELECT * FROM `elections`")

	outputChatBox("Done.", client)
end
addEvent("elections:add", true)
addEventHandler("elections:add", resourceRoot, addToElection)

function removeFromElection(name)
	if not exports.integration:isPlayerHeadAdmin(client) then 
		return
	end

	dbExec(exports.mysql:getConn("mta"), "DELETE FROM `elections` WHERE electionsname = ?", name)
	dbQuery(reloadElection, exports.mysql:getConn("mta"), "SELECT * FROM `elections`")

	outputChatBox("Done.", client)
end
addEvent("elections:remove", true)
addEventHandler("elections:remove", resourceRoot, removeFromElection)