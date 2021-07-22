function VehicleFixes()
	setModelHandling(400, "mass", 2500)
	setModelHandling(400, "turnMass", 5700)
	setModelHandling(400, "dragCoeff", 2.5)
	setModelHandling(400, "centerOfMass", {0.0, 0.0, -0.3} )
	setModelHandling(400, "percentSubmerged", 80)
	setModelHandling(400, "tractionMultiplier", 0.65)
	setModelHandling(400, "tractionLoss", 0.89)
	setModelHandling(400, "tractionBias", 0.5)
	setModelHandling(400, "numberOfGears", 5)
	setModelHandling(400, "maxVelocity", 160)
	setModelHandling(400, "engineAcceleration", 10)
	setModelHandling(400, "engineInertia", 25)
	setModelHandling(400, "driveType", "awd")
	setModelHandling(400, "engineType", "petrol")
	setModelHandling(400, "brakeDeceleration", 7)
	setModelHandling(400, "brakeBias", 0.45)
	setModelHandling(400, "ABS", false)
	setModelHandling(400, "steeringLock", 35)
	setModelHandling(400, "suspensionForceLevel", 1)
	setModelHandling(400, "suspensionDamping", 0.05)
	setModelHandling(400, "suspensionHighSpeedDamping", 0.0)
	setModelHandling(400, "suspensionUpperLimit", 0.40)
	setModelHandling(400, "suspensionLowerLimit", -0.2)
	setModelHandling(400, "suspensionFrontRearBias", 0.5)
	setModelHandling(400, "suspensionAntiDiveMultiplier", 0.3)
	setModelHandling(400, "seatOffsetDistance", 0.44)
	setModelHandling(400, "collisionDamageMultiplier", 0.35)
	setModelHandling(400, "modelFlags", 0x20)
	setModelHandling(400, "handlingFlags", 0x304407)
	setModelHandling(400, "headLight", 1)
	setModelHandling(400, "tailLight", 1)
	setModelHandling(400, "animGroup", 0)

	setModelHandling(546, "mass", 1600)
	setModelHandling(546, "turnMass", 4500)
	setModelHandling(546, "dragCoeff", 2)
	setModelHandling(546, "centerOfMass", {0.0, 0.3, -0.1} )
	setModelHandling(546, "percentSubmerged", 75)
	setModelHandling(546, "tractionMultiplier", 0.75)
	setModelHandling(546, "tractionLoss", 0.85)
	setModelHandling(546, "tractionBias", 0.52)
	setModelHandling(546, "numberOfGears", 5)
	setModelHandling(546, "maxVelocity", 200)
	setModelHandling(546, "engineAcceleration", 10)
	setModelHandling(546, "engineInertia", 10)
	setModelHandling(546, "driveType", "rwd")
	setModelHandling(546, "engineType", "petrol")
	setModelHandling(546, "brakeDeceleration", 10)
	setModelHandling(546, "brakeBias", 0.53)
	setModelHandling(546, "ABS", false)
	setModelHandling(546, "steeringLock", 35)
	setModelHandling(546, "suspensionForceLevel", 0.9)
	setModelHandling(546, "suspensionDamping", 0.08)
	setModelHandling(546, "suspensionHighSpeedDamping", 0.0)
	setModelHandling(546, "suspensionUpperLimit", 0.28)
	setModelHandling(546, "suspensionLowerLimit", -0.17)
	setModelHandling(546, "suspensionFrontRearBias", 0.55)
	setModelHandling(546, "suspensionAntiDiveMultiplier", 0.0)
	setModelHandling(546, "seatOffsetDistance", 0.2)
	setModelHandling(546, "collisionDamageMultiplier", 0.24)
	setModelHandling(546, "modelFlags", 0x40000000)
	setModelHandling(546, "handlingFlags", 0x10200008)
	setModelHandling(546, "headLight", 1)
	setModelHandling(546, "tailLight", 3)
	setModelHandling(546, "animGroup", 0)

	-- Maxime 30/3/2013 :Change Yosemite handling.
	local handlingDescription = {"mass", "turnMass", "dragCoeff", "centerOfMass", "percentSubmerged", "tractionMultiplier", "tractionLoss", "tractionBias", "engineAcceleration", "driveType", "engineType", "brakeBias", "ABS", "steeringLock", "suspensionForceLevel", "suspensionDamping", "suspensionHighSpeedDamping", "suspensionUpperLimit", "suspensionLowerLimit", "suspensionFrontRearBias", "suspensionAntiDiveMultiplier"}
    for i,v in ipairs(handlingDescription) do
		local handlingVehicle = getOriginalHandling(getVehicleModelFromName("FBI Rancher"))
		setModelHandling(554, v, handlingVehicle[v])
    end
    setModelHandling(554, "maxVelocity", 140)
    setModelHandling(554, "engineAcceleration", 10)
end
--addEventHandler("onResourceStart", resourceRoot, VehicleFixes) --Disabled by MAXIME

--[[
	This makes it so when the vehicle touches the water the interior is not fully submerged right away, that way if you are in a vehicle interior
	you can still have a chance to sorta escape instead of it being instantly full and allowing you to just swim out.
]]
local percentSubmerged = 38

local unAffectedVehicleCategories = {
	["Boat"] = true;
	["Bike"] = true
}

local vehicleIDS = { 602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585,
405, 587, 409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 592, 553, 577, 488, 511, 497, 548, 563, 512, 476, 593, 447, 425, 519, 520, 460,
417, 469, 487, 513, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 472, 473, 493, 595, 484, 430, 453, 452, 446, 454, 485, 552, 431,
438, 437, 574, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 432, 528, 601, 407, 428, 544, 523, 470, 598, 499, 588, 609, 403, 498, 514, 524,
423, 532, 414, 578, 443, 486, 515, 406, 531, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534,
567, 535, 576, 412, 402, 542, 603, 475, 449, 537, 538, 570, 441, 464, 501, 465, 564, 568, 557, 424, 471, 504, 495, 457, 539, 483, 508, 571, 500,
444, 556, 429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458,
606, 607, 610, 590, 569, 611, 584, 608, 435, 450, 591, 594 }

for i,id in ipairs (vehicleIDS) do
	if not unAffectedVehicleCategories[getVehicleType(id)] then
		setModelHandling (id, "percentSubmerged", percentSubmerged)
	end
end
