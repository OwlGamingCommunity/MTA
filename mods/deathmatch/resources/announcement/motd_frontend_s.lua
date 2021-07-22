--MAXIME 2015.1.8
local mysql = exports.mysql
--local motdCache = nil
--local motdCacheRefreshRate = 60000*5 --5 minutes
function playerGetMotds()
	local motdCache = {}
	local mQuery1 = mysql:query("SELECT m.dismissable AS dismissable, m.id AS id, m.title AS title, m.content AS content, DATE_FORMAT(m.creation_date,'%b %d, %Y %h:%i %p') AS creation_date, (CASE WHEN (m.expiration_date IS NULL) THEN 'Never' ELSE DATE_FORMAT(m.expiration_date,'%b %d, %Y %h:%i %p') END) AS expiration_date, (CASE WHEN m.expiration_date IS NULL THEN 1 ELSE m.expiration_date > NOW() END) AS active, m.author AS author, m.audiences AS audiences, r.id AS rid FROM motds m LEFT JOIN motd_read r ON m.id=r.motdid AND r.userid="..getElementData(source, "account:id").." WHERE (m.expiration_date IS NULL OR m.expiration_date>NOW()=1) AND r.id IS NULL ORDER BY active DESC, m.creation_date DESC")
	while true do
		local row = mysql:fetch_assoc(mQuery1)
		if not row then break end
		row.author = exports.cache:getUsernameFromId(row.author)
		local staff = {}
		staff[1] = getElementData(source, "admin_level") or 0
		staff[2] = getElementData(source, "supporter_level") or 0
		staff[3] = getElementData(source, "vct_level") or 0
		staff[4] = getElementData(source, "scripter_level") or 0
		staff[5] = getElementData(source, "mapper_level") or 0
		staff[6] = getElementData(source, "fmt_level") or 0
		staff[0] = 0
		for i = 1, 5 do
			if staff[i] > 0 then
				staff[0] = nil
				break
			end
		end
		local audiences = fromJSON(row.audiences)
		for j, audience in pairs(audiences) do
			if staff[audience[1]] == audience[2] then
				table.insert(motdCache, row)
				break
			end
		end
	end
	mysql:free_result(mQuery1)
	setTimer(triggerClientEvent, 3000, 1, source, "playerReceiveMotds", source, motdCache)
end
addEvent("playerGetMotds", true)
addEventHandler("playerGetMotds", root, playerGetMotds)

--setTimer(function()
--	motdCache = nil
--end, motdCacheRefreshRate, 0)

function dismissMotd(id)
	mysql:query_free("INSERT INTO motd_read SET userid="..getElementData(source, "account:id")..", motdid="..id)
end
addEvent("dismissMotd", true)
addEventHandler("dismissMotd", root, dismissMotd)

function cleanUpMotdReadDatabase()
	mysql:query_free("DELETE FROM motd_read")
end