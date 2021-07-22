-- server side
-- anumaz, owlgaming, 2014-12-14

--[[

CREATE TABLE `owl_mta`.`sfia_pilots` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `charactername` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`));

--]]
local mysql = exports.mysql

addEventHandler("onResourceStart", resourceRoot,
	function()
		local result = exports.mysql:query( "SELECT `id`, `charactername` FROM `sfia_pilots`" )
		local result_table = { }
		while true do
			local row = exports.mysql:fetch_assoc( result )
			if not row then
				break
			end
			table.insert(result_table, row)
		end
		exports.mysql:free_result( result )
		setElementData(resourceRoot, "sfia_pilots:table", result_table)

		local ped = createPed(98, 1489.0400390625, 1305.4501953125, 1093.2963867188)
		setElementFrozen(ped, true)
		setElementRotation(ped, 0, 0, 270)
		setElementDimension(ped, 3091)
		setElementInterior(ped, 3)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.name", "John Belshire")
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.gender", 0)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.nametag", true)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.behav", 0)

		--owl specifics
		exports.anticheat:changeProtectedElementDataEx(ped, "nametag", true)
		exports.anticheat:changeProtectedElementDataEx(ped, "name", "John Belshire")
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.type", "pilotmission")

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


function doQuery(thetype, info, client, amount)
	if thetype == 1 then
		exports.mysql:query_free("INSERT INTO `sfia_pilots` SET `charactername`='"..exports.mysql:escape_string(info).."'")
	elseif thetype == 2 then
		exports.mysql:query_free("DELETE FROM `sfia_pilots` WHERE `charactername`='"..exports.mysql:escape_string(info).."'")
	elseif thetype == 3 then
		local theTeam = getTeamFromName("Federal Aviation Administration")
		exports.global:giveMoney(theTeam, amount)
		exports.global:giveMoney(client, amount)
		exports.mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. mysql:escape_string(getElementData(client, "dbid")) .. ", " .. mysql:escape_string(-getElementData(theTeam, "id")) .. ", " .. mysql:escape_string(amount) .. ", '', 5)" )
	end
end
addEvent("sfia_pilots:doquery", true)
addEventHandler("sfia_pilots:doquery", resourceRoot, doQuery)
