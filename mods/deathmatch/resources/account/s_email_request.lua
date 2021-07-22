local mysql = exports.mysql
function saveEmail(id,email)
	local updateEmail = mysql:query_free("UPDATE `accounts` SET `email` = '"..mysql:escape_string(email).."' WHERE `id` = '"..mysql:escape_string(id).."'")
end
addEvent("requestEmail:saveEmail", true)
addEventHandler("requestEmail:saveEmail", getRootElement(), saveEmail)
