--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function isActiveBusiness(int)
	local status = int and getElementData(int, 'status')
	local int_type = status and status.type or nil
	return int_type == 1 and (status.faction>0 or status.owner>0) , status
end