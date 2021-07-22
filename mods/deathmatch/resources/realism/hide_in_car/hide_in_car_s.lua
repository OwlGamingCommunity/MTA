--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function hideInCar(p, c)
	outputChatBox('hiding')
	exports.global:applyAnimation(p, 'BF_injection', 'BF_getin_LHS', -1, false, true, false, false, true)
end
addCommandHandler( 'hide', hideInCar, false, false )