local migrations = {
	"ALTER TABLE `shop_products` ADD `pMetadata` TEXT NULL DEFAULT NULL AFTER `pItemValue` ;",
}
addEventHandler('onResourceStart', resourceRoot,
	function ()
		exports.mysql:createMigrations(getResourceName(getThisResource()), migrations)
	end
)


function convertGenerics()
	-- define the variables based on which items we're converting, either world or inventory
	local idRow = "pID"
	local valueRow = "pItemValue"
	local metadataRow = "pMetadata"
	local queryStr = "SELECT `"..idRow.."`, `"..valueRow.."`, `"..metadataRow.."` FROM shop_products WHERE pItemID = 80 AND pItemValue != 1"
	local updateStr = "UPDATE shop_products SET "..valueRow.." = 1, "..metadataRow.." = ? WHERE "..idRow.." = ?"
	
	outputDebugString("[NPC] Converting all generic items in the NPC system ...")
	
	local counter = 0
	dbQuery(function(qh)
		local res, rows, err = dbPoll(qh,0)
		if rows > 0 then
			for _, row in pairs(res) do
				if row then
					local metadata
					if row[metadataRow] and row[metadataRow] ~= mysql_null() then
						metadata = fromJSON(row[metadataRow]) or {}
					else
						metadata = {}
					end
					local itemValue = exports.global:explode(":", row[valueRow])
					if itemValue[1] then
						metadata['item_name'] = itemValue[1]
						counter = counter + 1
					end
					if itemValue[2] then
						metadata['model'] = itemValue[2]
					end
					if itemValue[3] then
						metadata['scale'] = itemValue[3]
					end
					if itemValue[4] and itemValue[5] then
						metadata['url'] = "http://" .. itemValue[4]
						metadata['texture'] = itemValue[5]
					end
					dbExec(mysql:getConn('mta'), updateStr, toJSON(metadata), row[idRow])
				end
			end
			
			outputDebugString("[NPC] " .. counter .. " items have been converted, restarting NPC system.")
			setTimer(restartResource, 30000, 1, getResourceFromName("npc"))
		end
	end, mysql:getConn('mta'), queryStr)
end

function commandConvertGenerics(player, cmd)
	if exports.integration:isPlayerScripter(player) then
		local seconds = 30
		outputChatBox(" WARNING: Large script execution will take place in " .. seconds .. " seconds, it will cause major delays for a few minutes.", root, 255, 0, 0)
		setElementData(getResourceRootElement(getThisResource()), "debug_enabled", true, true)
		setTimer(convertGenerics, seconds*1000, 1)
	end
end
addCommandHandler("convertshopgenerics", commandConvertGenerics)