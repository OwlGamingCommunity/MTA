addEvent("computers:on", true)
addEventHandler("computers:on", root,
	function()
		triggerEvent("sendAme",  client, "turns the computer on.")
	end
)
