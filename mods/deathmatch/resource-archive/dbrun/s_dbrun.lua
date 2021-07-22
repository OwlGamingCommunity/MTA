local queries = {
"UPDATE `characters` SET `skin` = 244 WHERE `skin` = 245",
}

function doQueries(thePlayer, cmd, num)
	if exports.integration:isPlayerScripter(thePlayer) then
		num = tonumber(num)
		if not num then
			outputChatBox("SYNTAX: /"..tostring(cmd).." [id] (use 0 to run all)",thePlayer)
			return
		end
		local mysql = exports.mysql
		if num > 0 then
			if queries[num] then
				local q = queries[num]
				outputChatBox("Doing query "..tostring(num).."...", thePlayer)
				outputConsole(q,thePlayer)
				mysql:query_free(q)
				outputChatBox("Done.", thePlayer)
			else
				outputChatBox("Query "..tostring(num).." does not exist.")
			end
		elseif num == 0 then
			outputChatBox("Doing queries", thePlayer)
			for k,v in ipairs(queries) do
				outputConsole(v,thePlayer)
				mysql:query_free(v)
			end
			outputChatBox("Done.", thePlayer)
		end
	end
end
addCommandHandler("dbrun", doQueries)
