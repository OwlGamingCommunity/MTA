--MAXIME / 2015.1.8

function canPlayerAccessStaffManager(player)
	return exports.integration:isPlayerTrialAdmin(player) or exports.integration:isPlayerSupporter(player) or exports.integration:isPlayerVCTMember(player) or exports.integration:isPlayerLeadScripter(player) or exports.integration:isPlayerMappingTeamLeader(player)
end
	