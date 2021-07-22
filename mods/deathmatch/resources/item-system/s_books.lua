function startBook(id, slot)
	if not tonumber(id) then
		outputChatBox("Error, BK#01. Report on bugs.owlgaming.net", client, 255, 0, 0)
		return
	end

	local query = mysql:query("SELECT title, author, book, readOnly FROM books WHERE id=".. mysql:escape_string(id))
	if query then
		local row = mysql:fetch_assoc(query)
		if row then
			triggerClientEvent(client, "PlayerBook", client, row.title, row.author, row.book, row.readOnly, slot, id)
		else
			triggerClientEvent(client, "PlayerBook", client, false, false, "Error, BK#02: Issue fetching book data! Report @ bugs.owlgaming.net")
		end
	else
		triggerClientEvent(client, "PlayerBook", client, false, false,"Error, BK#03: Issue Running SQL Query! Report @ bugs.owlgaming.net")
	end
	mysql:free_result(query)
end
addEvent("books:beginBook", true)
addEventHandler("books:beginBook", getRootElement(), startBook)

function setData(id, title, author, book, readOnly, slot)
	local itemValue = title..":"..author..":"..id

	updateItemValue(client, slot, itemValue)

	if not tonumber(id) then
		return
	end

	if readOnly then
		readOnly = 1
	else
		readOnly = 0
	end
	if readOnly == 1 then
		triggerEvent("sendAme", client, "closes ".. title .. " and clicks their pen.")
	end
	local query = mysql:query_free("UPDATE books SET title='".. mysql:escape_string(title) .."', author='".. mysql:escape_string(author) .."', book='".. mysql:escape_string(book) .."', readOnly=".. readOnly .. " WHERE id=".. id)
end
addEvent("books:setData", true)
addEventHandler("books:setData", getRootElement(), setData)
