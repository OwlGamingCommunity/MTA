--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function canPlayerAccessMotdManager(player)
	return exports.integration:isPlayerTrialAdmin(player) or exports.integration:isPlayerSupporter(player) or exports.integration:isPlayerScripter(player) or exports.integration:isPlayerVehicleConsultant(player)
end

staffTitles = exports.integration:getStaffTitles()