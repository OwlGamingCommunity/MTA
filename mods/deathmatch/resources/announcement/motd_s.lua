--MAXIME 2015.1.8
local mysql = exports.mysql
function saveMotd(title, content, expire, dismissable, audiences,motdId)
	title = mysql:escape_string(title)
	content = mysql:escape_string(content)
	local time = "NULL"
	if expire == 1 then
		time = "NOW() + INTERVAL 1 DAY"
	elseif expire == 2 then
		time = "NOW() + INTERVAL 2 DAY"
	elseif expire == 3 then
		time = "NOW() + INTERVAL 3 DAY"
	elseif expire == 4 then
		time = "NOW() + INTERVAL 1 WEEK"
	elseif expire == 5 then
		time = "NOW() + INTERVAL 2 WEEK"
	elseif expire == 6 then
		time = "NOW() + INTERVAL 1 MONTH"
	elseif expire == 7 then
		time = "NOW() + INTERVAL 2 MONTH"
	elseif expire == 8 then
		time = "NOW() + INTERVAL 6 MONTH"
	elseif expire == 9 then
		time = "NOW() + INTERVAL 1 YEAR"
	end
	if motdId then
		mysql:query_free("UPDATE motds SET dismissable="..dismissable..", audiences='"..mysql:escape_string(toJSON(audiences)).."', title='"..title.."', content='"..content.."', author="..getElementData(source, "account:id")..", expiration_date="..time.." WHERE id="..motdId)
	else
		mysql:query_free("INSERT INTO motds SET dismissable="..dismissable..", audiences='"..mysql:escape_string(toJSON(audiences)).."', title='"..title.."', content='"..content.."', author="..getElementData(source, "account:id")..", expiration_date="..time)
	end
	--outputChatBox("INSERT INTO motds SET title='"..title.."', content='"..content.."', author="..getElementData(source, "account:id")..", expiration_date="..time)
	triggerEvent("getMotdList", source)
end
addEvent("saveMotd", true)
addEventHandler("saveMotd", root, saveMotd)

function getMotdList()
	local list = {}
	local mQuery1 = nil
	mQuery1 = mysql:query("SELECT m.dismissable AS dismissable, m.id AS id, m.title AS title, m.content AS content, DATE_FORMAT(m.creation_date,'%b %d, %Y %h:%i %p') AS creation_date, (CASE WHEN (m.expiration_date IS NULL) THEN 'Never' ELSE DATE_FORMAT(m.expiration_date,'%b %d, %Y %h:%i %p') END) AS expiration_date, (CASE WHEN m.expiration_date IS NULL THEN 1 ELSE m.expiration_date > NOW() END) AS active, m.author AS author, m.audiences AS audiences FROM motds m ORDER BY active DESC, m.creation_date DESC")
	while true do
		local row = mysql:fetch_assoc(mQuery1)
		if not row then break end
		table.insert(list, row )
	end
	mysql:free_result(mQuery1)
	triggerClientEvent(source, "openMotdManager", source, list)
end
addEvent("getMotdList", true)
addEventHandler("getMotdList", root, getMotdList)

function deleteMOTD(motdId)
	if mysql:query_free("DELETE FROM motds WHERE id="..motdId) then
		triggerEvent("getMotdList", source)
	end
end
addEvent("deleteMOTD", true)
addEventHandler("deleteMOTD", root, deleteMOTD)