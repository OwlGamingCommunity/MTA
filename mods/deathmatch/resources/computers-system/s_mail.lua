mysql = exports.mysql

function leader_check (accountName, password, faction)
	local leader = exports.factions:isPlayerFactionLeader(faction)
		
	if not leader then -- If the player is not the leader
		triggerClientEvent("notLeader",client)
	else
		register_email(accountName, password)
	end
end
addEvent("leaderCheck",true)
addEventHandler("leaderCheck",getRootElement(),leader_check)

function register_email(accountName, password)
	local result = mysql:query("SELECT username FROM emailaccounts WHERE username='" .. mysql:escape_string(accountName) .."'")
	if (mysql:num_rows(result)>0) then
		mysql:free_result(result)
		triggerClientEvent("name_in_use", client) -- Error Message
	else
		mysql:free_result(result)
		triggerClientEvent("closeEmailLogin",client)
		local dbid = getElementData(client, "dbid")
		mysql:query_free("INSERT INTO emailaccounts SET username='" .. mysql:escape_string(accountName) .. "', password=MD5('" .. mysql:escape_string(password) .. "'), creator='"..mysql:escape_string(dbid).."'") -- Create the account.
		--[[mysql:query_free("INSERT INTO emails SET date= NOW(), sender='Customer Services', receiver='" .. mysql:escape_string(accountName) .. "', subject='Welcome', inbox='1',outbox='0', message='Welcome,\
\
Your email account has been registered.\
\
Now you are online you are ableto receive email on the move.\
\
Username: " ..mysql:escape_string(accountName).."\
Password: " ..mysql:escape_string(password).."\
\
Rest assured your private details are secure with us and our arbitarary third party advertisers.\
\
Thank you for registering.'")]]
		
		get_inbox(accountName)
		get_outbox(accountName)
	end
end
addEvent("registerEmail", true)
addEventHandler("registerEmail", getRootElement(),register_email)

function login_email(accountName, password)
	local result = mysql:query("SELECT * FROM emailaccounts WHERE username='" .. mysql:escape_string(accountName) .."' AND password=MD5('" .. mysql:escape_string(password) .. "')")
	if (mysql:num_rows(result)==0) then
		mysql:free_result(result)
		triggerClientEvent("loginError", client) -- Error Message
	else
		mysql:free_result(result)
		triggerClientEvent("closeEmailLogin",client)
		get_inbox(accountName)
		get_outbox(accountName)
	end
end
addEvent("loginEmail", true)
addEventHandler("loginEmail", getRootElement(),login_email)

function get_inbox(accountName)
	-- `date` - INTERVAL 1 hour as 'newtime'
	-- hour correction
	local result = mysql:query("SELECT id, `date` - INTERVAL 1 hour as 'newdate', sender, subject, message FROM emails WHERE receiver='".. mysql:escape_string(accountName) .."' AND inbox='1' ORDER BY date DESC")
	if (result) then
		inbox_table = { }
		local key = 1
		local continue = true
		while continue do
			local row = mysql:fetch_assoc(result)
			if not row then break end
			inbox_table[key] = { }
			inbox_table[key][1] = row["id"]
			inbox_table[key][2] = row["newdate"]
			inbox_table[key][3] = row["sender"]
			inbox_table[key][4] = row["subject"]
			inbox_table[key][5] = row["message"]
			key = key + 1
		end
		if(key==1)then
			inbox_table = {
				{ "","","","","Inbox is empty" },
			}
		end
		mysql:free_result(result)
		triggerClientEvent("showInbox",client,inbox_table, accountName)
	end
end
addEvent("s_getInbox",true)
addEventHandler("s_getInbox",getRootElement(),get_inbox)

function get_outbox(accountName)
	local result = mysql:query("SELECT id, `date` - INTERVAL 1 hour as 'newdate', receiver, subject, message FROM emails WHERE sender='".. mysql:escape_string(accountName) .."' AND outbox='1' ORDER BY date DESC")
	if (result) then
		outbox_table = { }
		local key = 1
		local continue = true
		while continue do
			local row = mysql:fetch_assoc(result)
			if not row then break end
			outbox_table[key] = { }
			outbox_table[key][1] = row["id"]
			outbox_table[key][2] = row["newdate"]
			outbox_table[key][3] = row["receiver"]
			outbox_table[key][4] = row["subject"]
			outbox_table[key][5] = row["message"]
			key = key + 1
		end
		if(key==1)then
			outbox_table = {
				{ "","","","","Outbox is empty" },
			}
		end
		mysql:free_result(result)
		triggerClientEvent("showOutbox",source,outbox_table, accountName)
	end
end
addEvent("s_getOutbox",true)
addEventHandler("s_getOutbox",getRootElement(),get_outbox)

function send_message(accountName,to,subject,message)
	local result = mysql:query("SELECT username FROM emailaccounts WHERE username='" .. mysql:escape_string(to) .."'")
	if (mysql:num_rows(result)==0) then
		mysql:free_result(result)
		triggerClientEvent("invalidAddress", client) -- Error Message
	else
		mysql:free_result(result)
		mysql:query_free("INSERT INTO emails SET date= NOW(), sender='".. mysql:escape_string(accountName) .."', receiver='" .. mysql:escape_string(to) .. "', subject='" .. mysql:escape_string(subject) .. "', message='" .. mysql:escape_string(message) .. "', inbox='1', outbox='1'")
		get_outbox(accountName)
		triggerClientEvent("c_sendMessage",client)
	end
end
addEvent("sendMessage",true)
addEventHandler("sendMessage", getRootElement(),send_message)

function delete_inbox_message(id,accountName)
	mysql:query_free("UPDATE emails SET inbox=0 WHERE id='" .. mysql:escape_string(id) .."'")
	mysql:query_free("DELETE FROM emails WHERE inbox='0' AND outbox='0'")
	get_inbox(accountName)
end
addEvent("deleteInboxMessage",true)
addEventHandler("deleteInboxMessage", getRootElement(),delete_inbox_message)

function delete_outbox_message(id, accountName)
	mysql:query_free("UPDATE emails SET outbox=0 WHERE id='" .. mysql:escape_string(id) .."'")
	mysql:query_free("DELETE FROM emails WHERE inbox='0' AND outbox='0'")
	get_outbox(accountName)
end
addEvent("deleteOutboxMessage",true)
addEventHandler("deleteOutboxMessage", getRootElement(),delete_outbox_message)