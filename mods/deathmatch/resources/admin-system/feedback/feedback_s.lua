--MAXIME / 2015.1.29
--[[
-- Dumping structure for table mta.feedbacks
CREATE TABLE IF NOT EXISTS `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `from_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL DEFAULT '3',
  `comment` varchar(500) DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=117903 DEFAULT CHARSET=latin1;
]]

local mysql = exports.mysql
function formSubmit(staffId, rating, comment)
	if not staffId or not tonumber(staffId) then
		outputChatBox("Feedback has failed to submit. Thank you for taking the time to give us your feedback anyway.", source, 255,0,0)
		return false
	end
	local tail = ""
	if comment then
		tail = " , comment='"..mysql:escape_string(comment).."'"
	end
	if mysql:query_free("INSERT INTO feedbacks SET staff_id="..staffId..", rating="..rating..", from_id="..getElementData(source, "account:id")..tail) then
		outputChatBox("Feedback has successfully submitted. Thank you for taking the time to give us your feedback.", source, 0,255,0)
		return true
	else
		outputChatBox("Feedback has failed to submit. Thank you for taking the time to give us your feedback anyway.", source, 255,0,0)
		return false
	end
end
addEvent("feedback:formSubmit", true)
addEventHandler("feedback:formSubmit", root, formSubmit)

function openFeedBackDetails(staff)
	if staff then
		local sql = "SELECT id, username FROM accounts WHERE username='"..mysql:escape_string(staff).."'"
		if tonumber(staff) then
			sql = "SELECT id, username FROM accounts WHERE id="..staff
		end
		local target = mysql:query_fetch_assoc(sql)
		if target and target.id and tonumber(target.id) then
			target.id = tonumber(target.id)
			if target.id ~= getElementData(source, "account:id") and not exports.integration:isPlayerLeadAdmin(source) then
				return outputChatBox("You don't have sufficient permissions to view feedbacks of this staff member.", source, 255,0,0)
			end
			local feedbacks = {}
			local q = mysql:query("SELECT username, rating, comment, DATE_FORMAT(date,'%b %d, %Y %h:%i %p') AS date FROM feedbacks f LEFT JOIN accounts a ON f.from_id=a.id WHERE f.staff_id="..(target.id).." ORDER BY f.id DESC")
			while q do
				local row = mysql:fetch_assoc(q)
				if not row then break end
				table.insert(feedbacks, row)
			end
			triggerClientEvent(source, "feedback:openFeedBackDetails", source, {feedbacks, target.username})
		end
	end
end
addEvent("feedback:openFeedBackDetails", true)
addEventHandler("feedback:openFeedBackDetails", root, openFeedBackDetails)

function showFeedbacks(player, cmd, ...)
	if (...) then
		if not exports.integration:isPlayerLeadAdmin(player) then
			return outputChatBox("You don't have sufficient permissions to view other staff's feedbacks.", player, 255,0,0)
		end
		triggerEvent("feedback:openFeedBackDetails", player, table.concat({...}," "))
	else
		triggerEvent("feedback:openFeedBackDetails", player, getElementData(player, "account:id"))
	end
end
--addCommandHandler("showfeedbacks", showFeedbacks)
