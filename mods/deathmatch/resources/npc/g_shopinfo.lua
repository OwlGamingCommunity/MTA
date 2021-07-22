--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

--- clothe shop skins
blackMales = {293, 300, 284, 278, 274, 265, 19, 310, 311, 301, 302, 296, 297, 269, 270, 271, 7, 14, 15, 16, 17, 18, 20, 21, 22, 24, 25, 28, 35, 36, 51, 66, 67, 79,
80, 83, 84, 102, 103, 104, 105, 106, 107, 134, 136, 142, 143, 144, 156, 163, 166, 168, 176, 180, 182, 183, 185, 220, 221, 222, 249, 253, 260, 262 }
whiteMales = {126, 268, 288, 287, 286, 285, 283, 282, 281, 280, 279, 277, 276, 275, 267, 266, 239, 167, 71, 305, 306, 307, 308, 309, 312, 303, 299, 291, 292, 294, 295, 1, 2, 23, 26,
27, 29, 30, 32, 33, 34, 35, 36, 37, 38, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 58, 59, 60, 61, 62, 68, 70, 72, 73, 78, 81, 82, 94, 95, 96, 97, 98, 99, 100, 101, 108, 109, 110,
111, 112, 113, 114, 115, 116, 120, 121, 124, 125, 127, 128, 132, 133, 135, 137, 146, 147, 153, 154, 155, 158, 159, 160, 161, 162, 164, 165, 170, 171, 173, 174, 175, 177,
179, 181, 184, 186, 187, 188, 189, 200, 202, 204, 206, 209, 212, 213, 217, 223, 230, 234, 235, 236, 240, 241, 242, 247, 248, 250, 252, 254, 255, 258, 259, 261, 264, 272 }
asianMales = {290, 49, 57, 58, 59, 60, 117, 118, 120, 121, 122, 123, 170, 186, 187, 203, 210, 227, 228, 229, 294}
blackFemales = {--[[245, ]]9, 304, 298, 10, 11, 12, 13, 40, 41, 63, 64, 69, 76, 139, 148, 190, 195, 207, 215, 218, 219, 238, 243, 244, 256, 304 } -- 245 = Santa, so disabled.
whiteFemales = {91, 191, 12, 31, 38, 39, 40, 41, 53, 54, 55, 56, 64, 75, 77, 85, 87, 88, 89, 90, 92, 93, 129, 130, 131, 138, 140, 145, 150, 151, 152, 157, 172, 178, 192, 193, 194,
196, 197, 198, 199, 201, 205, 211, 214, 216, 224, 225, 226, 231, 232, 233, 237, 243, 246, 251, 257, 263, 298 }
asianFemales = {38, 53, 54, 55, 56, 88, 141, 169, 178, 224, 225, 226, 263}
local fittingskins = {[0] = {[0] = blackMales, [1] = whiteMales, [2] = asianMales}, [1] = {[0] = blackFemales, [1] = whiteFemales, [2] = asianFemales}}
-- Removed 9 as a black female
-- these are all the skins
disabledUpgrades = {
	[1142] = true,
	[1109] = true,
	[1008] = true,
	[1009] = true,
	[1010] = true,
	[1158] = true,
}

local restricted_skins = {
	[71] = true,
	[265] = true,
	[266] = true,
	[267] = true,
	[274] = true,
	[275] = true,
	[276] = true,
	[277] = true,
	[278] = true,
	[279] = true,
	[275] = true,
	[280] = true,
	[281] = true,
	[282] = true,
	[283] = true,
	[284] = true,
	[285] = true,
	[286] = true,
	[287] = true,
	[288] = true,
	[300] = true,
 }
 
bandanas = { [122] = true, [123] = true, [124] = true, [136] = true, [168] = true, [125] = true, [158] = true, [135] = true, [237] = true, [238] = true, [239] = true }

function getRestrictedSkins()
	return restricted_skins
end

function getDisabledUpgrades()
	return disabledUpgrades
end
skins = { 1, 2, 268, 269, 270, 271, 272, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 7, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68, 69, 72, 73, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 178, 179, 180, 181, 182, 183, 184, 185, 186, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 263, 264 }
local wheelPrice = 2500
local priceReduce = 1

-- g_shops[1][1][1]['name'] == "Flowers"

g_shops = {
	{ -- 1
		name = "General Store",
		description = "This shop sells all kind of general purpose items.",
		image = "general.png",

		{
			name = "General Items",
			--{ name = "Lottery Ticket", description = "A ticket that can make you or break you.", price = 75, itemID = 68, itemValue = nil, minimum_age = 18 },
			{ name = "Flowers", description = "A bouquet of lovely flowers.", price = 5, itemID = 115, itemValue = 14 },
			{ name = "Phonebook", description = "A large phonebook of everyones phone numbers.", price = 30, itemID = 7 },
			{ name = "Dice", description = "A six-sided white dice with black dots, perfect for gambling.", price = 2, itemID = 10, itemValue = 1 },
			{ name = "20-sided Dice", description = "A twenty-sided white dice with black dots, for that Dungeons & Dragons feel.", price = 5, itemID = 10, itemValue = 20 },
			{ name = "Golf Club", description = "Perfect golf club for hitting that hole-in-one.", price = 60, itemID = 115, itemValue = 2 },
			{ name = "Baseball Bat", description = "Hit a home run with this.", price = 60, itemID = 115, itemValue = 5 },
			{ name = "Shovel", description = "Perfect tool to dig a hole.", price = 40, itemID = 115, itemValue = 6 },
			{ name = "Pool Cue", description = "For that game of pub pool.", price = 35, itemID = 115, itemValue = 7 },
			{ name = "Cane", description = "A stick has never been so classy.", price = 65, itemID = 115, itemValue = 15 },
			{ name = "Fire Extinguisher", description = "There is never one of these around when there is a fire", price = 50, itemID = 115, itemValue = 42 },
			{ name = "Spray Can", description = "Hey, you better not tag with this punk!", price = 50, itemID = 115, itemValue = 41 },
			{ name = "Parachute", description = "If you don't want to splat on the ground, you better buy one", price = 400, itemID = 115, itemValue = 46 },
			{ name = "City Guide", description = "A small city guide booklet.", price = 15, itemID = 18 },
			{ name = "Backpack", description = "A reasonably sized backpack.", price = 30, itemID = 48 },
			{ name = "Fishing Rod", description = "A 7 foot carbon steel fishing rod.", price = 300, itemID = 49 },
			{ name = "Mask", description = "A ski mask.", price = 20, itemID = 56 },
			{ name = "Fuel Can", description = "A small metal fuel canister.", price = 35, itemID = 57, itemValue = 0 },
			{ name = "First Aid Kit", description = "A small First Aid Kit", price = 15, itemID = 70, itemValue = 3 },
			{ name = "Rolling Papers", description = "Papers to roll your cigarettes.", price = 10, itemID = 181, itemValue = 20 },
			--[[
			{ name = "Mini Notebook", description = "An empty Notebook, enough to write 5 notes.", price = 10, itemID = 71, itemValue = 5 },
			{ name = "Notebook", description = "An empty Notebook, enough to write 50 notes.", price = 15, itemID = 71, itemValue = 50 },
			{ name = "XXL Notebook", description = "An empty Notebook, enough to write 125 notes.", price = 20, itemID = 71, itemValue = 125 },
			]]
			{ name = "Helmet", description = "A helmet commonly used by people riding bikes.", price = 100, itemID = 90 },
			{ name = "Biker Helmet", description = "A helmet commonly used by people riding bikes.", price = 100, itemID = 171},
			{ name = "Full Face Helmet", description = "A helmet commonly used by people riding bikes.", price = 100, itemID = 172},
			{ name = "Pack of cigarettes", description = "Things you can smoke...", price = 10, itemID = 105, itemValue = 20, minimum_age = 18 },
			{ name = "Lighters", description = "To light up your addiction, a geuine Zippo!", price = 45, itemID = 107 },
			{ name = "Knife", description = "To help ya out in the kitchen.", price = 15, itemID = 115, itemValue = 4 },
			{ name = "Card Deck", description = "Want to play a game?", price = 10, itemID = 77 },
			{ name = "Picture Frame", description = "You can use these to decorate your interior!", price = 350, itemID = 147, itemValue = 1 },
			{ name = "Briefcase", description = "A brown leather briefcase.", price = 75, itemID = 160},
			{ name = "Duffle Bag", description = "A large cylindrical bag made of cloth with a drawstring closure at the top.", price = 60, itemID = 163},
			{ name = "Blank Book", description = "A hardcover book with nothing written in it.", price = 40, itemID = 178, itemValue = "New Book"},
			{ name = "Bicycle Lock", description = "A metal lock that allows you to lock your bicycle", price = 250, itemID = 275, itemValue = 1},
		},
		{
			name = "Consumable",
			{ name = "Sandwich", description = "A yummy sandwich with cheese.", price = 6, itemID = 8 },
			{ name = "Softdrink", description = "A can of Sprunk.", price = 3, itemID = 9 },
		},
	},
	{ -- 2
		name = "Gun and Ammo Store",
		description = "All your gun needs since 1914.",
		image = "gun.png",

		{
			name = "Guns and Ammo",
			{ name = "Colt-45 Pistol", description = "A silver Colt-45.", price = 850, itemID = 115, itemValue = 22, license = true },
			{ name = "Desert Eagle Pistol", description = "A shiny Desert Eagle.", price = 1200, itemID = 115, itemValue = 24, license = true },
			{ name = "Shotgun", description = "A silver shotgun.", price = 1049, itemID = 115, itemValue = 25, license = true },
			{ name = "Country Rifle", description = "A country rifle.", price = 1599, itemID = 115, itemValue = 33, license = true },
			{ name = "9mm Ammopack", description = "Cartridge: 9mm, Compactible with Colt 45, Silenced, Uzi, MP5, Tec-9. Bullet Style: Flex Tip Expanding (FTX), Bullet Weight: 7.45 grams, Application: Self Defense.", price = 100, itemID = 116, itemValue = 1, ammo = 25, license = true },
			{ name = ".45 ACP Ammopack", description = "Cartridge: .45 ACP, Compactible with Deagle. Bullet Style: Full Metal Jacket (FMJ), Metal Case (MC), Bullet Weight: 11.99 grams, Application: Target, Competition, Training.", price = 110, itemID = 116, itemValue = 4, ammo = 20, license = true },
			{ name = "12 Gauge Ammopack", description = "Cartridge: 12 Gauge, Compactible with Shotgun, Sawed-off, Combat Shotgun. Bullet Style: Factory-style, Bullet Weight: 31.89 grams, Application: Target, Hunting.", price = 90, itemID = 116, itemValue = 5, ammo = 20, license = true },
			{ name = "7.62mm Ammopack", description = "Cartridge: 7.62mm, Compactible with AK-47, Rifle, Sniper, Minigun. Bullet Style: Full Metal Jacket (FMJ), Bullet Weight: 9.66 grams, Application: Practice, Target, Training.", price = 150, itemID = 116, itemValue = 2, ammo = 30, license = true },
			{ name = "5.56mm Ammopack", description = "Cartridge: 5.56mm, Compactible with M4. Bullet Style: Full Metal Jacket (FMJ), Bullet Weight: 4.02 grams, Application: Law Enforcement, Plinking.", price = 150, itemID = 116, itemValue = 3, ammo = 30, license = true },
		}
	},
	{ -- 3
		name = "Food Store",
		description = "The least poisoned food and drinks on the planet.",
		image = "food.png",

		{
			name = "Food",
			{ name = "Sandwich", description = "A yummy sandwich with cheese", price = 5, itemID = 8 },
			{ name = "Taco", description = "A greasy mexican taco", price = 7, itemID = 11 },
			{ name = "Burger", description = "A double cheeseburger with bacon", price = 6, itemID = 12 },
			{ name = "Donut", description = "Hot sticky sugar covered donut", price = 3, itemID = 13 },
			{ name = "Cookie", description = "A luxury chocolate chip cookie", price = 3, itemID = 14 },
			{ name = "Hotdog", description = "Nice, tasty hotdog!", price = 5, itemID = 1 },
			{ name = "Pancake", description = "Yummy, a pancake!!", price = 2, itemID = 108 },
		},
		{
			name = "Drink",
			{ name = "Softdrink", description = "A cold can of Sprunk.", price = 5, itemID = 9 },
			{ name = "Water", description = "A bottle of mineral water.", price = 3, itemID = 15 },
		}
	},
	{ -- 4
		name = "Sex Shop",
		description = "All of the items you'll need for the perfect night in.",
		image = "sex.png",

		{
			name = "Sexy",
			{ name = "Long Purple Dildo", description = "A very large purple dildo", price = 20, itemID = 115, itemValue = 10 },
			{ name = "Short Tan Dildo", description = "A small tan dildo.", price = 15, itemID = 115, itemValue = 11 },
			{ name = "Vibrator", description = "A vibrator, what more needs to be said?", price = 25, itemID = 115, itemValue = 12 },
			{ name = "Flowers", description = "A bouquet of lovely flowers.", price = 5, itemID = 115, itemValue = 14 },
			{ name = "Handcuffs", description = "A metal pair of handcuffs.", price = 90, itemID = 45 },
			{ name = "Rope", description = "A long rope.", price = 15, itemID = 46 },
			{ name = "Blindfold", description = "A black blindfold.", price = 15, itemID = 66 },
		},
		{
			name = "Clothes",
			{ name = "Clothes 87", description = "Sexy clothes for sexy people.", price = 55, itemID = 16, itemValue = 87 },
			{ name = "Clothes 178", description = "Sexy clothes for sexy people.", price = 55, itemID = 16, itemValue = 178 },
			{ name = "Clothes 244", description = "Sexy clothes for sexy people.", price = 55, itemID = 16, itemValue = 244 },
			{ name = "Clothes 246", description = "Sexy clothes for sexy people.", price = 55, itemID = 16, itemValue = 246 },
			{ name = "Clothes 257", description = "Sexy clothes for sexy people.", price = 55, itemID = 16, itemValue = 257 },
		}
	},
	{ -- 5
		name = "Clothes Shop",
		description = "You don't look fat in those!",
		image = "clothes.png",
		-- Items to be generated elsewhere.
		{
			name = "Clothes fitting you"
		},
		{
			name = "Others"
		},
	},
	{ -- 6
		name = "Gym",
		description = "The best place to learn about hand-to-hand combat.",
		image = "general.png",

		{
			name = "Fighting Styles",
			{ name = "Standard Combat for Dummies", description = "Standard everyday fighting.", price = 10, itemID = 20 },
			{ name = "Boxing for Dummies", description = "Mike Tyson, on drugs.", price = 50, itemID = 21 },
			{ name = "Kung Fu for Dummies", description = "I know kung-fu, so can you.", price = 50, itemID = 22 },
			-- item ID 23 is just a greek book, anyhow :o
			{ name = "Grab & Kick for Dummies", description = "Kick his 'ead in!", price = 50, itemID = 24 },
			{ name = "Elbows for Dummies", description = "You may look retarded, but you will kick his ass!", price = 50, itemID = 25 },
		}
	},
	{ -- 7
		name = "Rapid Auto Parts - Viozy",
		description = "If it isn't by Viozy, it's fraud. All sales posted reduced by 50% for exclusive members.",
		image = "viozy-auto.png",
		{
			name = "Tint Application",
			{ name = "HP Charcoal Window Film", description = "Viozy Window Films ((50 /chance))", price = 305 / priceReduce, itemID = 184, itemValue = "Viozy HP Charcoal Window Tint Film ((50 /chance))" },
			{ name = "CXP70 Window Film", description = "Viozy CXP70 Window Film ((95 /chance))", price = 490 / priceReduce, itemID = 185, itemValue = "Viozy CXP70 Window Film ((95 /chance))" },
			{ name = "Border Edge Cutter (Red Anodized)", description = "Border Edge Cutter for Tinting", price = 180 / priceReduce, itemID = 186, itemValue = "Viozy Border Edge Cutter (Red Anodized)" },
			{ name = "Solar Spectrum Tranmission Meter", description = "Spectrum Meter for testing film before use", price = 1000 / priceReduce, itemID = 187, itemValue = "Viozy Solar Spectrum Tranmission Meter" },
			{ name = "Tint Chek 2800", description = "Measures the Visible Light Transmission on any film/glass", price = 280 / priceReduce, itemID = 188, itemValue = "Viozy Tint Chek 2800" },
			{ name = "Equalizer Heatwave Heat Gun", description = "Easy to use heat gun perfect for shrinking back windows", price = 530 / priceReduce, itemID = 189, itemValue = "Viozy Equalizer Heatwave Heat Gun" },
			{ name = "36 Multi-Purpose Cutter Bucket", description = "Ideal for light cutting jobs while applying tint", price = 120 / priceReduce, itemID = 190, itemValue = "Viozy 36 Multi-Purpose Cutter Bucket" },
			{ name = "Tint Demonstration Lamp", description = "Effectve presentation of tinted application", price = 150 / priceReduce, itemID = 191, itemValue = "Viozy Tint Demonstration Lamp" },
			{ name = "Triumph Angled Scraper", description = "6-inch Angled Scraper for applying tint", price = 100 / priceReduce, itemID = 192, itemValue = "Viozy Triumph Angled Scraper" },
			{ name = "Performax 48oz Hand Sprayer", description = "Performax Hand Sprayer for tint application", price = 200 / priceReduce, itemID = 193, itemValue = "Viozy Performax 48oz Hand Sprayer" },
			{ name = "Ammonia Bottle", description = "A bottle of ammonia solution", price = 50 / priceReduce, itemID = 260, itemValue = "Ammonia Bottle" },
		},

		{
			name = "Mechanics",
			{ name = "Vehicle Ignition - 2010 ((20 /chance))", description = "Vehicle Ignition made by Viozy for 2010", price = 196 / priceReduce, itemID = 194, itemValue = "Viozy Vehicle Ignition - 2010 ((20 /chance))" },
			{ name = "Vehicle Ignition - 2011 ((30 /chance))", description = "Vehicle Ignition made by Viozy for 2011", price = 254 / priceReduce, itemID = 195, itemValue = "Viozy Vehicle Ignition - 2011 ((30 /chance))" },
			{ name = "Vehicle Ignition - 2012 ((40 /chance))", description = "Vehicle Ignition made by Viozy for 2012", price = 364 / priceReduce, itemID = 196, itemValue = "Viozy Vehicle Ignition - 2012 ((40 /chance))" },
			{ name = "Vehicle Ignition - 2013 ((50 /chance))", description = "Vehicle Ignition made by Viozy for 2013", price = 546 / priceReduce, itemID = 197, itemValue = "Viozy Vehicle Ignition - 2013 ((50 /chance))" },
			{ name = "Vehicle Ignition - 2014 ((70 /chance))", description = "Vehicle Ignition made by Viozy for 2014", price = 929 / priceReduce, itemID = 198, itemValue = "Viozy Vehicle Ignition - 2014 ((70 /chance))" },
			{ name = "Vehicle Ignition - 2015 ((90 /chance))", description = "Vehicle Ignition made by Viozy for 2015", price = 1765 / priceReduce, itemID = 199, itemValue = "Viozy Vehicle Ignition - 2015 ((90 /chance))" },
			{ name = "HVT 358 Portable Spark Nano 4.0 ((50 /chance))", description = "GPS HVT 358 Spark Nano 4.0 Portable ((50 /chance to be found)), by Viozy", price = 345 / priceReduce, itemID = 205, itemValue = "Viozy HVT 358 Portable Spark Nano 4.0 ((50 /chance))" },
			{ name = "Hidden Vehicle Tracker 272 Micro ((30 /chance))", description = "GPS HVT 272 Micro, easy installation ((30 /chance to be found)), by Viozy", price = 840 / priceReduce, itemID = 204, itemValue = "Viozy Hidden Vehicle Tracker 272 Micro ((30 /chance))" },
			{ name = "Hidden Vehicle Tracker 315 Pro ((Undetectable))", description = "GPS HVT 315 Pro, easy installation ((and undetectable)), by Viozy", price = 2229 / priceReduce, itemID = 203, itemValue = "Viozy Hidden Vehicle Tracker 315 Pro ((Undetectable))" },
		},
		{
			name = "Discount Tires",
			{ name = "Access", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1098 },
			{ name = "Virtual", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1097 },
			{ name = "Ahab", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1096 },
			{ name = "Atomic", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1085 },
			{ name = "Trance", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1084 },
			{ name = "Dollar", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1083 },
			{ name = "Import", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1082 },
			{ name = "Grove", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1081 },
			{ name = "Switch", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1080 },
			{ name = "Cutter", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1079 },
			{ name = "Twist", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1078 },
			{ name = "Classic", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1077 },
			{ name = "Wires", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1076 },
			{ name = "Rimshine", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1075 },
			{ name = "Mega", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1074 },
			{ name = "Shadow", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1073 },
			{ name = "Offroad", description = "Used Tires", price = wheelPrice / priceReduce, itemID = 114, itemValue = 1025 },

		}

	},
	{ -- 8
		name = "Electronics Store",
		description = "The latest technology, extremely overpriced just for you.",
		image = "general.png",

		{
			name = "Electronics",
			{ name = "Cellphone", description = "A stylish, slim cell phone.", price = 800, itemID = 2 },
			{ name = "Flashlight", description = "Lights up the environment.", price = 25, itemID = 145, itemValue = 100 },
			{ name = "Ghettoblaster", description = "A black ghettoblaster.", price = 250, itemID = 54 },
			{ name = "Camera", description = "A small black analogue camera.", price = 75, itemID = 115, itemValue = 43 },
			{ name = "Radio", description = "A black radio.", price = 50, itemID = 6 },
			{ name = "Earpiece", description = "An earpiece that can be used with an radio.", price = 25, itemID = 88 },
			{ name = "Watch", description = "Telling the time was never so sexy!", price = 25, itemID = 17 },
			{ name = "MP3 Player", description = "A white, sleek looking MP3 Player. The brand reads EyePod.", price = 120, itemID = 19 },
			{ name = "Chemistry Set", description = "A small chemistry set.", price = 2000, itemID = 44 },
			{ name = "Safe", description = "A Safe to store your items in.", price = 500, itemID = 223, itemValue = "Safe:2332:50" }, -- Model ID is the old safe and cap is 50kg
			--{ name = "GPS", description = "A GPS Satnav for a car.", price = 300, itemID = 67 },
			{ name = "Portable GPS", description = "Personal global positioning device, with recent maps.", price = 200, itemID = 111 },
			{ name = "Macbook pro A1286 Core i7", description = "A top of the range Macbook to view e-mails and browse the internet.", price = 2200, itemID = 96 },
			{ name = "Portable TV", description = "A portable TV to watch the TV.", price = 750, itemID = 104 },
			{ name = "Toll Pass", description = "For your car: Automatically charges you when driving through a toll gate.", price = 400, itemID = 118 },
			{ name = "Vehicle Alarm System", description = "Protect your vehicle with an alarm.", price = 1000, itemID = 130 },
			{ name = "Car Battery Charger", description = "Can quickly charge almost every battery type, and it's a great choice for home mechanics and small shops.", price = 150, itemID = 232, itemValue = 1},
			{ name = "Night Vision Goggles", description = "A robust, dependable, high-performance night vision system.", price = 4499, itemID = 115, itemValue = 44 },
			{ name = "Infrared Goggles", description = "Lightweight, rugged and a top notch performer and an exceptional choice for hands-free usage.", price = 7499, itemID = 115, itemValue = 45 },
		}
	},
	{ -- 9
		name = "Alcohol Store",
		description = "Everything from Vodka to Beer and the other way round.",
		image = "general.png",

		{
			name = "Drinks",
			{ name = "Ziebrand Beer", description = "The finest beer, imported from Holland.", price = 10, itemID = 58, minimum_age = 21 },
			{ name = "Bastradov Vodka", description = "For your best friends - Bastradov Vodka.", price = 25, itemID = 62, minimum_age = 21 },
			{ name = "Scottish Whiskey", description = "The Best Scottish Whiskey, now exclusively made from Haggis.", price = 15, itemID = 63, minimum_age = 21 },
			{ name = "Softdrink", description = "A cold can of Sprunk.", price = 3, itemID = 9 },
		}
	},
	{ -- 10
		name = "Book Store",
		description = "New things to learn? Sound like... fun?!",
		image = "general.png",

		{
			name = "Books",
			{ name = "City Guide", description = "A small city guide booklet.", price = 15, itemID = 18 },
			{ name = "Los Santos Highway Code", description = "A paperback book.", price = 10, itemID = 50 },
			{ name = "Chemistry 101", description = "A hardback academic book.", price = 20, itemID = 51 },
			{ name = "Blank Book", description = "A hardcover book with nothing written in it.", price = 40, itemID = 178, itemValue = "New Book"},
		}
	},
	{ -- 11
		name = "Cafe",
		description = "You want some chocolate on your rim?",
		image = "food.png",

		{
			name = "Food",
			{ name = "Donut", description = "Hot sticky sugar covered donut", price = 3, itemID = 13 },
			{ name = "Cookie", description = "A luxuty chocolate chip cookie", price = 3, itemID = 14 },
		},
		{
			name = "Drinks",
			{ name = "Coffee", description = "A small cup of coffee.", price = 1, itemID = 83, itemValue = 2 },
			{ name = "Softdrink", description = "A cold can of Sprunk.", price = 3, itemID = 9, itemValue = 3 },
			{ name = "Water", description = "A bottle of mineral water.", price = 1, itemID = 15, itemValue = 2 },
		}
	},
	{ -- 12
		name = "Santa's Grotto",
		description = "Ho-ho-ho, Merry Christmas.",
		image = "general.png",

		{
			name = "Christmas Items",
			{ name = "Christmas Present", description = "What could be inside?", price = 0, itemID = 94 },
			{ name = "Eggnog", description = "Yum Yum!", price = 0, itemID = 91 },
			{ name = "Turkey", description = "Yum Yum!", price = 0, itemID = 92 },
			{ name = "Christmas Pudding", description = "Yum Yum!", price = 0, itemID = 93 },
		}
	},
	{ -- 13
		name = "Prison Worker",
		description = "Now that looks... vaguely tasty.",
		image = "general.png",

		{
			name  = "Disgusting Stuff",
			{ name = "Mixed Dinner Tray", description = "Lets play the guessing game.", price = 0, itemID = 99 },
			{ name = "Small Milk Carton", description = "Lumps included!", price = 0, itemID = 100 },
			{ name = "Small Juice Carton", description = "Thirsty?", price = 0, itemID = 101 },
		}
	},
	{ -- 14
		name = "One Stop Mod Shop",
		description = "Any parts you'll ever need!",
		image = "general.png",

		-- items to be filled in later
		{
			name = "Vehicle Parts"
		}
	},
	{ -- 15
		name = "NPC",
		description = "(( This is just an NPC, not meant to hold any items. ))",
		image = "general.png",

		{
			name = "No items"
		}
	},
	{ -- 16
		name = "Hardware Store",
		description = "Need some tools?!",
		image = "general.png",

		{
			name = "Power Tools",
			{ name = "Power Drill", description = "An electric battery operated drill.", price = 50, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Power Drill"} },
			{ name = "Power Saw", description = "An electric plug-in saw.", price = 65, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Power Saw"} },
			{ name = "Pneumatic Nail Gun", description = "A pneumatic-operated nail gun.", price = 80, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Pneumatic Nail Gun"} },
			{ name = "Pneumatic Paint Gun", description = "A pneumatic-operated nail gun.", price = 90, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Pneumatic Paint Gun"} },
			{ name = "Air Wrench", description = "A pneumatic-operated wrench.", price = 80, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Air Wrench"} },
			{ name = "Torch", description = "A mobile natural-gas operated torch set.", price = 80, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Mobile Torch Set"} },
			{ name = "Electric Welder", description = "A mobile plug-in electricity operated electric welder.", price = 80, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Mobile Electric Welder"} },
		},
		{
			name = "Hand Tools",
			{ name = "Hammer", description = "An iron hammer.", price = 25, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Iron Hammer"} },
			{ name = "Phillips Screwdriver", description = "A phillips screwdriver.", price = 5, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Phillips Screwdriver"} },
			{ name = "Flathead Screwdriver", description = "A flathead screwdriver.", price = 5, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Flathead Screwdriver"} },
			{ name = "Robinson Screwdriver", description = "A robinson screwdriver.", price = 6, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Robinson Screwdriver"} },
			{ name = "Torx Screwdriver", description = "A torx screwdriver.", price = 8, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Torx Screwdriver"} },
			{ name = "Needlenose Pliers", description = "Pliers.", price = 25, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Needlenose Pliers"} },
			{ name = "Crowbar", description = "A large iron crowbar.", price = 30, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Iron Crowbar"} },
			{ name = "Tire Iron", description = "A tire iron.", price = 25, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Tire Iron"} },
			{ name = "Wrench", description = "An adjustable wrench.", price = 7, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Wrench"} },
			{ name = "Monkey Wrench", description = "A large monkey wrench.", price = 12, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Monkey Wrench"} },
			{ name = "Socket Wrench", description = "A socket wrench.", price = 8, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Socket Wrench"} },
			{ name = "Torque Wrench", description = "A large torque wrench.", price = 35, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Torque Wrench"} },
			{ name = "Vise Grip", decsription = "A vise grip.", price = 12, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Vise Grip"} },
			{ name = "Wirecutters", decsription = "Used to cut wires.", price = 6, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Wirecutters"} },
			{ name = "Hack Saw", description = "A hack saw.", price = 40, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Hack Saw"} },
		},
		{
			name = "Screws & Nails",
			{ name = "Phillips Screws", description = "A box of phillips screws.", price = 3, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Phillips Screws (100)"} },
			{ name = "Flathead Screws", description = "A box of flathead screws.", price = 3, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Flathead Screws (100)"} },
			{ name = "Robinson Screws", description = "A box of robinson screws.", price = 3, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Robinson Screws (100)"} },
			{ name = "Torx Screws", description = "A box of torx screws.", price = 3, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Torx Screws (100)"} },
			{ name = "Iron Nails", description = "A box of iron nails.", price = 2, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Iron Nails (100)"} },
		},
		{
			name = "Misc.",
			{ name = "Bosch 6 Gallon Air Compressor", description = "A 6 gallon Bosch air compressor.", price = 300, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Bosch 6 Gallon Air Compressor"} },
			{ name = "Gloves", description = "A pair of wearable gloves.", price = 2, itemID = 270, itemValue = 1 },
			{ name = "Chlorex Bleach", description = "A bottle of Chlorex bleach.", price = 13, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Chlorex Bleach"} },
			{ name = "Paint Can", description = "A can of paint in your colour of choice.", price = 10, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Paint Can"} },
			{ name = "Toolbox", description = "A red metal toolbox.", price = 20, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Red Metal Toolbox"} },
			{ name = "Rubbermaid Plastic Trashcan", description = "A Rubbermaid plastic trashcan.", price = 25, itemID = 80, itemValue = 1, metadata = {['item_name'] = "Rubbermaid Plastic Trashcan"} },
		}
	},
	{ -- 17
		name = "Custom Store",
		description = " ",
		image = "general.png",
	},
	{ -- 18
		name = "Faction Drop NPC - General Items",
		description = " ",
		image = "general.png",
	},
	{ -- 19
		name = "Faction Drop NPC - Weapons",
		description = " ",
		image = "general.png",
	},
}

-- some initial updating once you start the resource
function loadLanguages( )
	local shop = g_shops[ 10 ]
	for i = 1, exports['language-system']:getLanguageCount() do
		local ln = exports['language-system']:getLanguageName(i)
		if ln then
			table.insert( shop[1], { name = ln .. " Dictionary", description = "A Dictionary, useful for learning " .. ln .. ".", price = 25, itemID = 69, itemValue = i } )
		end
	end
end

addEventHandler( "onResourceStart", resourceRoot, loadLanguages )
addEventHandler( "onClientResourceStart", resourceRoot, loadLanguages )

-- util

function getMetaItemName(item)
	local metaName = type(item.metadata) == 'table' and item.metadata.item_name or nil

	return metaName ~= nil and metaName or ''
end

function checkItemSupplies(shop_type, supplies, itemID, itemValue, itemMetaName)
	if supplies then
		-- regular items
		if (supplies[itemID .. ":" .. (itemValue or 1)] and supplies[itemID .. ":" .. (itemValue or 1)] > 0) then
			return true
		-- generics with meta name
		elseif (supplies[itemID .. ":" .. (itemValue or 1) .. ":" .. itemMetaName] and supplies[itemID .. ":" .. (itemValue or 1) .. ":" .. itemMetaName] > 0) then
			return true
		-- clothes
		elseif (itemID == 16 and supplies[tostring(itemID)] and supplies[tostring(itemID)] > 0) then
			return true
		-- bandanas
		elseif (bandanas[itemID] and supplies["122"] and supplies["122"] > 0) then
			return true
		-- car mods
		elseif (itemID == 114 and vehicle_upgrades[tonumber(itemValue)-999] and vehicle_upgrades[tonumber(itemValue)-999][3] and supplies["114:" .. vehicle_upgrades[tonumber(itemValue)-999][3]] and supplies["114:" .. vehicle_upgrades[tonumber(itemValue)-999][3]] > 0) then
			return true
		end
	end
	return false
end

function getItemFromIndex( shop_type, index, usingStocks, interior )
	local shop = g_shops[ shop_type ]
	if shop then
		if usingStocks and interior then
			local status = getElementData(interior, "status")
			local supplies = fromJSON(status.supplies)
			local govOwned = status.type == 2
			local counter = 1
			for _, category in ipairs(shop) do
				for _, item in ipairs(category) do
					if checkItemSupplies(shop_type, supplies, item.itemID, item.itemValue, getMetaItemName(item)) or govOwned then
						if counter == index then
							return item
						end
						counter = counter + 1
					end
				end
			end
		else
			for _, category in ipairs(shop) do
				if index <= #category then
					return category[index]
				else
					index = index - #category
				end
			end
		end
	end
end

--
--local simplesmallcache = {}
function updateItems( shop_type, race, gender )
	if shop_type == 5 then -- clothes shop
		-- load the shop
		local shop = g_shops[shop_type]

		-- clear all items
		for _, category in ipairs(shop) do
			while #category > 0 do
				table.remove( category, i )
			end
		end

		-- uber complex logic to add skins
		local nat = {}
		local availableskins = fittingskins[gender][race]
		table.sort(availableskins)
		for k, v in ipairs(availableskins) do
			if not restricted_skins[v] then
				table.insert( shop[1], { name = "Collection #" .. v, description = "Click to expand", price = 50, itemID = 16, itemValue = v, fitting = true } )
				nat[v] = true
			end
		end

		local otherSkins = {}
		for gendr = 0, 1 do
			for rac = 0, 2 do
				if gendr ~= gender or rac ~= race then
					for k, v in pairs(fittingskins[gendr][rac]) do
						if not nat[v] and not restricted_skins[v] then
							table.insert(otherSkins, v)
						end
					end
				end
			end
		end
		table.sort(otherSkins)

		for k, v in ipairs(otherSkins) do
			table.insert( shop[2], { name = "Collection #" .. v, description = "These don't seem to fit you well", price = 50, itemID = 16, itemValue = v } )
		end

		shop[3] = {
			name = 'Bandanas',
			{ name = "Light Blue Bandana", description = "A light blue rag.", price = 5, itemID = 122 },
			{ name = "Red Bandana", description = "A red rag.", price = 5, itemID = 123 },
			{ name = "Yellow Bandana", description = "A yellow rag.", price = 5, itemID = 124 },
			{ name = "Purple Bandana", description = "A purple rag.", price = 5, itemID = 125 },
			{ name = "Blue Bandana", description = "A blue rag.", price = 5, itemID = 135 },
			{ name = "Brown Bandana", description = "A brown rag.", price = 5, itemID = 136 },
			{ name = "Green Bandana", description = "A green rag.", price = 5, itemID = 158 },
			{ name = "Orange Bandana", description = "A orange rag.", price = 5, itemID = 168 },
			{ name = "Black Bandana", description = "A black rag.", price = 5, itemID = 237 },
			{ name = "Grey Bandana", description = "A grey rag.", price = 5, itemID = 238 },
			{ name = "White Bandana", description = "A white rag.", price = 5, itemID = 239 },
		}

		-- simplesmallcache[tostring(race) .. "|" .. tostring(gender)] = shop
	elseif shop_type == 14 then
		-- param (race)= vehicle model
		--[[local c = simplesmallcache["vm"]
		if c then
			return
		end]]

		-- remove old data
		for _, category in ipairs(shop) do
			while #category > 0 do
				table.remove( category, i )
			end
		end

		for v = 1000, 1193 do
			if vehicle_upgrades[v-999] then
				local str = exports['item-system']:getItemDescription( 114, v )

				local p = str:find("%(")
				local vehicleName = ""
				if p then
					vehicleName = str:sub(p+1, #str-1) .. " - "
					str = str:sub(1, p-2)
				end
				if not disabledUpgrades[v] then
					table.insert( shop[1], { name = vehicleName .. ( getVehicleUpgradeSlotName(v) or "Lights" ), description = str, price = vehicle_upgrades[v-999][2], itemID = 114, itemValue = v})
				end
			end
		end
		-- bar battery
		table.insert( shop[1], { name = exports['item-system']:getItemName( 232 ), description = exports['item-system']:getItemDescription( 232, 1 ), price = 130*2, itemID = 232, itemValue = 1} )
	end
end

function getFittingSkins()
	return fittingskins
end


function getDiscount( player, shoptype )
	local discount = 1
	if shoptype == 7 then
		discount = discount * 0.5
	elseif shoptype == 14 then
		discount = discount * 0.5
	end

	if exports.donators:hasPlayerPerk( player, 8 ) then
		discount = discount * 0.8
	end
	return discount
end
