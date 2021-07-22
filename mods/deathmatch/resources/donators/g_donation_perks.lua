--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

donationPerks = {
			[1] = { "Toggle-able incoming private message", 																		50, 		7 },
			[2] = { "Toggle-able adverts", 																							50, 		14 },
			[3] = { "Toggle-able news alerts", 																						50, 		7 },
			[4] = { "+ $25 dollar payrise on payday", 																				50, 		7 },
			[5] = { "+ $75 dollar payrise on payday",																				100, 		7 },
			[6] = { "No phone bills", 																								50, 		0 },
			[7] = { "Free fuel", 																									50, 		0 },
			[8] = { "Discount card - 20% off in regular shops",																		50, 		0 },
			[9] = { "Dupont Membership (+1 extra manufacture slot)", 																50, 		1 },
			[10] = { "Toggle-able donator chat channel (/don)", 																	50, 		14 },
			[11] = { "Toggle-able golden nametag", 																					50, 		7 },
			[12] = { "Toggle-able hidden status from scoreboard", 																	150, 		14 },
			[13] = { "Game Coins Transfer", 																						35, 	1 },
			[14] = { "Increase interior slots", 																			    	100, 		1 },
			[15] = { "Increase vehicle slots", 																				    	100,		1},
			[16] = { "Username rename permit", 																						250, 		1 },
			[17] = { "A pair of keyless digital door locks for one interior",														400,		1 },
			[18] = { "Phone with custom number (6 digits min, must contains 2 different digits)",									500,		1},
			[19] = { "Phone with custom number (5 digits min, no different digits constraint)",										2500,		1},
			[20] = { "Assets transfer from a character to an alternative",															750,		1},
			[21] = { "Custom interior for your interior",																			500,		1},
			[22] = { "Instant driver's licenses & fishing permit",																	50,		0},
			[23] = { "Personalized vehicle licence plate",																			100,		1},
			[24] = { "Unique character selection screen (Grove St)",																750,		1},
			[25] = { "Unique character selection screen (Star Tower)",																1000,		1},
			[26] = { "Unique character selection screen (Mount Chiliad)",															1250,		1},
			[27] = { "Automatically open any road tolling from 40 meters away",														150,		7},
			[28] = { "New radio station that is aired globally on all cars radio & ghettoblasters",									500,		30},
			[29] = { "Customized country flags typing icon",																		150,		7},
			[30] = { "ATM Card - Premium, can be used to make transactions with a fair amount per day. (($50,000 per 5 hours))",	300,		0},
			[31] = { "ATM Card - Ultimate, can be used to make transactions with unlimited amount per day.",						1500,		0},
			[32] = { "Instant 15 hours played",																						250,		1},
			[33] = { "Cellphone private number",																					50,			-1},
			[34] = { "Instantly learn language",																					150,		0},
			[35] = { "Additional serial number in whitelist",																		150,		1},
			[36] = { "Interior inactivity protection",																				15,		7},
			[37] = { "Offline private message",																						3,		-1},
			[38] = { "Vehicle inactivity protection",																				15,		7},
			[39] = { "No vehicle taxes",																							300,	-1},
			[40] = { "No interior taxes",																							200,	-1},
			[41] = { "Free interior rentals",																						400,	0},
			[42] = { "Extra character slot",																						15,		1},
			[43] = { "Instant Dupont Manufacture",																					50,		0},

--					Title																											Points	Time
}

function getPerks(perkId)
	if not perkId or not tonumber(perkId) or not donationPerks[tonumber(perkId)] then
		return donationPerks
	else
		return donationPerks[tonumber(perkId)]
	end
end
