script_serverside = true
data_sent = {}

function sendAttachmentData()
	if data_sent[client] then return end
	triggerClientEvent(client,"boneAttach_sendAttachmentData",root,
		attached_ped,
		attached_bone,
		attached_x,
		attached_y,
		attached_z,
		attached_rx,
		attached_ry,
		attached_rz
	)
	data_sent[client] = true
end
addEvent("boneAttach_requestAttachmentData",true)
addEventHandler("boneAttach_requestAttachmentData",root,sendAttachmentData)

function removeDataSentFlag()
	data_sent[source] = nil
end
addEventHandler("onPlayerQuit",root,removeDataSentFlag)