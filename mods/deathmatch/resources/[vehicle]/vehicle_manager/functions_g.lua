--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function canAccessVehicleManager( player )
	return exports.integration:isPlayerTrialAdmin( player ) or exports.integration:isPlayerVCTMember( player ) or exports.integration:isPlayerScripter( player )
end