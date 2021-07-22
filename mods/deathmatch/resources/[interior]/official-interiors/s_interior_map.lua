MTAoutputChatBox = outputChatBox
function outputChatBox( text, visibleTo, r, g, b, colorCoded )
	if string.len(text) > 128 then -- MTA Chatbox size limit
		MTAoutputChatBox( string.sub(text, 1, 127), visibleTo, r, g, b, colorCoded  )
		outputChatBox( string.sub(text, 128), visibleTo, r, g, b, colorCoded  )
	else
		MTAoutputChatBox( text, visibleTo, r, g, b, colorCoded  )
	end
end


interiors = {
	[1] = {  3,   975.26,    -8.64, 1001.14, 90 , "Business_StripClub1"},
	[2] = { 11,   501.84,   -67.84,  998.75, 180 , "Ten_Green-Bottles"},
	[3] = {  5,   772.43,    -5.19, 1000.72, 0 , "LS_Ganton_GYM" },
	[4] = {  2,   2517.2119140625, -1296.705078125, 1076.9359130859, 270, "Luxurious Lobby (Maxime)" },
	[5] = {  3,   965.16015625, -53.212890625, 1001.1245727539, 90, "StripclubVIPArea (Maxime)" },
	[6] = {  3,   834.61,     7.54, 1004.18, 90 , "BettingShop" },
	[7] = {  5,   1254.48046875, -938.01171875, 1096.6500244141, 180 ,"Luxurious Hallway (Maxime)" },
	[8] = {  3,  1212.18,   -25.93, 1000.95, 180, "SmallStripClub" },
	[9] = { 18,  1306.86,     6.83, 1001.02, 90, "FullWarehouse" },
	[10] = {  1,  1412.14,    -2.28, 1000.92, 115, "UnfWarehouse" },
	[11] = {  3,   418.75,   -84.31, 1001.80, 0 , "GantonBarbers"  }, -- 11
	[12] = {  3,   390.44,   173.91, 1008.38, 90 , "CityHall"  }, -- 12
	[13] = {  3,   207.01,  -139.91, 1003.50, 0 , "Prolapstore"  }, -- 13
	[14] = {  3,  -100.40,   -24.96, 1000.71, 0 , "LrgSexShop"  }, -- 14
	[15] = {  3,  -204.31,   -44.08, 1002.27, 0 , "TatooParlour"  }, -- 15
	[16] = { 17,  -204.23,    -8.88, 1002.27, 0 , "TatooParlour2"  }, -- 16
	[17] = { 17,   -25.91,  -188.05, 1003.54, 0 , "Business_24/7 "  }, -- 17
	[18] = {  5,   372.18,  -133.28, 1001.49, 0 , "Business_Pizza "  }, -- 18
	[19] = { 17,   377.16,  -192.91, 1000.64, 0 , "Business_Donut"  }, -- 19
	[20] = {  7,   315.79,  -143.27,  999.60, 0 , "ammunation"  }, -- 20
	[21] = {  5,   227.08,    -8.14, 1002.21, 90 , "victim "  }, -- 21
	[22] = { 10,     6.05,   -31.27, 1003.54, 0 , "24/7 "  }, -- 22
	[23] = {  7,   773.93,   -78.49, 1000.66, 0 , "GYM "  }, -- 23
	[24] = {  1,   613.52,     3.31, 1000.92, 180 , "GARAGE"  }, -- 24
	[25] = {  1,   285.39,   -41.44, 1001.51, 0 , "AMMU "  }, -- 25
	[26] = {  1,   203.79,   -50.34, 1001.80, 0 , "SUBURB "  }, -- 26
	[27] = {  7, -1409.35,  -255.91, 1043.66, 250 , "LSFORUM "  }, -- 27
	[28] = {  2,  1204.81,   -13.60, 1000.92, 0 , "STRIP "  }, -- 28
	[29] = { 10,  2019.02,  1017.93,  996.87, 90 , "4DRAGON "  }, -- 29
	[30] = { 10, -1128.64,  1066.33, 1345.74, 270 , "ZEROS RC BATTLEFIELD"  }, -- 30
	[31] = { 10,   362.88,   -75.11, 1001.50, 315 , "BurgerShot"  }, -- 31
	[32] = {  1,  2233.92,  1714.58, 1012.38, 180 , "Caligula"  }, -- 32
	[33] = {  2,   411.63,   -23.06, 1001.80, 0 , "Haircut"  }, -- 33
	[34] = { 18,   -31.02,   -91.92, 1003.54, 0 , "24/7 "  }, -- 34
	[35] = { 18,   161.46,   -96.72, 1001.80, 0 , "Zip"  }, -- 35
	[36] = {  3, -2636.77,  1402.60,  906.46, 0 , "Jizzy"  }, -- 36
	[37] = {  2,  2541.72, -1303.89, 1025.07, 265 , "Bigsmoke Crackhouse"  }, -- 37
	[38] = {  1, -2158.81,   643.14, 1052.37, 180 , "Horsebetting"  }, -- 38 BUSINESS Horsebetting
	[39] = { 14,   204.44,  -168.58, 1000.52, 0 , "DidierSach"  }, -- 39 BUSINESS DidierSach
	[40] = { 12,  1133.25,   -15.26, 1000.67, 0 , "Casino"  }, -- 40 Casino
	[41] = { 14, -1464.86,  1556.02, 1052.53, 0 , "Motorcross"  }, -- 41 Motorcross
	[42] = { 17,   493.34,   -24.48, 1000.67, 0 , "Alhambra"  }, -- 42 Alhambra
	[43] = { 18,  1726.86, -1638.05,   20.22, 180 , "Atrium"  }, -- 43 Atrium
	[44] = { 16,  -204.41,   -27.22, 1002.27, 0 , "Tattooparlor"  }, -- 44 Tattooparlor
	[45] = { 16,   -25.68,  -140.99, 1003.54, 0 , "24/7"  }, -- 45
	[46] = { 15,  2214.62, -1150.38, 1025.79, 270 , "Jefferson Motel"  }, -- 46
	[47] = {  1,  681.5419921875, -451.20703125, -25.6171875, 180 , "Welcome Pump (Maxime)"  }, -- 47
	[48] = { 15,   207.58,  -111.00, 1005.13, 0 , "Binco's"  }, -- 48
	[49] = { 15, -1424.42,   928.36, 1036.39, 350 , "Arena"  }, -- 49 Arena
	[50] = {  0,  2304.87,   -16.07,  -16.07, 270 , "Old Bank in Palomino Creek"  }, -- 50 , no actual interior, tp coords are wrong too
	[51] = { 18,  -229.17,  1401.14,   27.76, 270 , "Lil' Probe Inn"  }, -- 51
	[52] = {  4,   285.71,   -86.37, 1001.52, 0 , "Ammunation"  }, -- 52 Ammunation
	[53] = {  4,   460.18,   -88.41,  999.55, 90 , "Restaurant"  }, -- 53 Restaurant
	[54] = {  4,   -27.30,   -31.41, 1003.55, 0 , "24/7"  }, -- 54 24/7
	[55] = {  1,   964.94,  2159.97, 1011.03, 90 , "Sindacco Meat Factory"  }, -- 55
	[56] = { 12,   411.86,   -54.20, 1001.89, 0 , "Barber"  }, -- 56 Barber
	[57] = {  6,   774.20,   -50.20, 1000.58, 0 , "San Fierro Gym"  }, -- 57 San Fierro Gym
	[58] = {  3,  1494.28,  1303.91, 1093.28, 0 , "Office"  }, -- 58 Office
	[59] = {  6, -2240.69,   128.43, 1035.41, 270 , "Zero's RC Shop"  }, -- 59
	[60] = {  6,   297.05,  -111.79, 1001.51, 0 , "Small Ammunation"  }, -- 60
	[61] = {  6,   316.37,  -170.02,  999.59, 0 , "Small Ammunation"  }, -- 61
	[62] = {  6,   -27.15,   -57.87, 1003.54, 0 , "24/7"  }, -- 62
	[63] = {  9,   364.95,   -11.60, 1001.85, 0 , "Cluckin' Bell"  }, -- 63
	[64] = {  1,  2266.32,  1647.59, 1084.23, 270 , "Hotel Huge"  }, -- 64
	[65] = {  3, -2029.61,  -119.36, 1035.17, 0 , "DMV"  }, -- 65
	[66] = {  8,  2365.14, -1135.35, 1050.87, 0 , "House_Luxury Medium"  }, -- 66
	[67] = {  8,   -42.65,  1405.46, 1084.42, 0 , "HOUSE_SmallMedium"  }, -- 67 HOUSE_SmallMedium
	[68] = {  9,    83.00,  1322.48, 1083.86, 0 , "HOUSE_Luxury"  }, -- 68 HOUSE_Luxury
	[69] = {  9,   260.67,  1237.32, 1084.25, 0 , "HOUSE_Medium"  }, -- 69 HOUSE_Medium
	[70] = {  3,   620.01,  -119.85,  998.84, 180 , "Garage (Maxime)"  }, -- 70
	[71] = {  5,  2233.57, -1115.08, 1050.88, 0 , "HOUSE_BEDROOM"  }, -- 71
	[72] = {  2,   446.97,  1397.22, 1084.30, 0 , "HOUSE_Medium"  }, -- 72 HOUSE_Medium
	[73] = {  4,   261.14,  1284.56, 1080.25, 0 , "HOUSE_Medium"  }, -- 73 HOUSE_Medium
	[74] = { 15,   295.05,  1472.36, 1080.25, 0 , "HOUSE_Medium"  }, -- 74 HOUSE_Medium
	[75] = {  3,   235.44,  1186.83, 1080.25, 0 , "HOUSE_big"  }, -- 75 HOUSE_big
	[76] = {  2,   226.48,  1239.87, 1082.14, 90 , "HOUSE_Medium"  }, -- 76 HOUSE_medium
	[77] = {  1,   223.22,  1287.17, 1082.14, 0 , "HOUSE_Medium"  }, -- 77 HOUSE_medium
	[78] = {  5,   226.56,  1114.19, 1080.99, 270 , "HOUSE_Luxury"  }, -- 78 HOUSE_Luxury
	[79] = {  5,  2233.53, -1115.26, 1050.88, 0 , "HOUSE_Hotelroom"  }, -- 79 HOUSE_Hotelroom
	[80] = {  9,  2317.81, -1026.55, 1050.21, 0 , "HOUSE_Luxury"  }, -- 80 HOUSE_Luxury
	[81] = { 10,  2259.68, -1136.09, 1050.63, 270 , "HOUSE_crap"  }, -- 81 HOUSE_crap
	[82] = { 10,   422.26,  2536.37,   10.00, 90 , "HOUSE_desertaitport"  }, -- 82 HOUSE_desertaitport
	[83] = { 14,   254.46,   -41.60, 1002.02, 270 , "HOUSE_wardrobe"  }, -- 83 HOUSE_wardrobe
	[84] = {  5,  1260.84,  -785.42, 1091.90, 270 , "HOUSE_Maggod"  }, -- 84 HOUSE_Maggod
	[85] = {  2,   266.56,   305.02,  999.14, 270 , "HOUSE_BEDROOM"  }, -- 85 HOUSE_BEDROOM
	[86] = {  3,  2496.03, -1692.17, 1014.74, 180 , "HOUSE_CJ"  }, -- 86 HOUSE_CJ
	[87] = {  2,  2468.77, -1698.25, 1013.50, 90 , "HOUSE_RYDER"  }, -- 87 HOUSE_RYDER
	[88] = {  2,  2237.52, -1081.64, 1049.02, 0 , "HOUSE_Medium"  }, -- 88 HOUSE_Medium
	[89] = {  1,  2218.24, -1076.27, 1050.48, 90 , "HOUSE_Hotelroom"  }, -- 89 HOUSE_Hotelroom
	[90] = {  6,   744.46,  1436.68, 1102.70, 0 , "HOUSE_WHORE"  }, -- 90 HOUSE_WHORE
	[91] = {  8,  2807.66, -1174.54, 1025.57, 0 , "HOUSE_Medium"  }, -- 91 HOUSE_Medium
	[92] = {  6,   234.20,  1063.85, 1084.21, 0 , "HOUSE_MansionLuxury"  }, -- 92 HOUSE_MansionLuxury
	[93] = {  4,  -260.78,  1456.73, 1084.36, 90 , "HOUSE_Luxury"  }, -- 93 HOUSE_Luxury
	[94] = {  5,    22.98,  1403.60, 1084.42, 0 , "HOUSE_LowLuxury"  }, -- 94 HOUSE_LowLuxury
	[95] = {  5,   140.39,  1366.36, 1083.85, 0 , "HOUSE_UltraLuxury"  }, -- 95 HOUSE_UltraLuxury
	[96] = { 12,  2324.42, -1149.20, 1050.71, 0 , "HOUSE_Luxory"  }, -- 96 HOUSE_Luxory
	[97] = { 10,    24.00,  1340.33, 1084.37, 0 , "HOUSE_Medium"  }, -- 97 HOUSE_Medium
	[98] = {  4,   221.77,  1140.43, 1082.60, 0 , "HOUSE_Medium"  }, -- 98 HOUSE_MEDIUM
	[99] = {  6,   343.98,   305.14,  999.14, 270 , "HOUSE_Kinkyroom"  }, -- 99 HOUSE_Kinkyroom
	[100] = {  6,   -68.83,  1351.46, 1080.21, 0 , "HOUSE_Medium"  }, -- 100 HOUSE_Medium
	[101] = { 10,   246.37,   107.51, 1003.21, 0 , "BUSINESS_PD_BANK"  }, -- 101 BUSINESS_PD_BANK
	[102] = {  3,   289.77,   171.74, 1007.17, 0 , "PDBUSINESS"  }, -- 102 PDBUSINESS
	[103] = {  5,   322.24,   302.45,  999.14, 0 , "PD_FortCarson"  }, -- 103 PD_FortCarson
	[104] = {  6,   246.85,    62.49, 1003.64, 0 , "PD_LS"  }, -- 104 PD_LS
	[105] = {  1,  -794.98,   489.78, 1376.20, 0 , "MARCO'S_BISTRO (Maxime)"  }, -- 105
	[106] = {  6,  2196.85, -1204.40, 1049.00, 0 , "SAFEHOUSE 13 - HIGH"  }, -- 106 SAFEHOUSE 13 - HIGH
	[107] = { 10,  2270.41, -1210.46, 1047.56, 0 , "SAFEHOUSE 14 - MEDIUM-HIGH"  }, -- 107 SAFEHOUSE 14 - MEDIUM-HIGH
	[108] = {  6,  2308.80, -1212.94, 1049.02, 0 , "SAFEHOUSE 15 - LOW"  }, -- 108 SAFEHOUSE 15 - LOW
	[109] = {  6,  2333.00, -1077.00, 1049.00, 0 , "SAFEHOUSE 8 - LOW"  }, -- 109 SAFEHOUSE 8 - LOW
	[110] = {  5,   318.55,  1114.47, 1083.88, 0 , "BALLAS CRACK DEN"  }, -- 110 BALLAS CRACK DEN
	[111] = {  2,   620.18,   -70.89,  997.99, 0 , "Small Garage (Maxime)"  }, -- 111 Small Garage (Maxime)
	[112] = {  2,     1.90,    -3.20,  999.40, 0 , "Trailer (custom)"  }, -- 112 Trailer (custom)
	[113] = {  6,  2438.35, -2537.32, 1095.43, 0 , "Warehouse (custom)"  }, -- 113 Warehouse (custom)
	[114] = {  7,   225.71,  1021.44, 1084.01, 0 , "HOUSE HIGH"  }, -- 114 HOUSE HIGH
	[115] = {  8,  2480.60, -1687.23, 2031.49, 0 , "RESTROOM/TOILET (custom)"  }, -- 115
	[116] = { 11,  2282.98, -1140.15, 1050.90, 0 , "small hotel room"  }, -- 116 small hotel room
	[117] = { 20,  2535.96, -1339.61, 1030.93, 0 , "Flat Interior (Maxime)"  }, -- 117 c
	[118] = { 20,  1412.26,  1525.49, 1542.80, 0 , "Church (monstama77)"  }, -- 118 Church (monstama77)
	[119] = { 21, -2031.88,  -118.21, 1039.30, 0 , "Neat Small Garage (Antman)"  }, -- 119 Neat Small Garage (Antman)
	[120] = { 22,  1910.78, -2395.60,   13.56, 0 , "Library (Callum)"  }, -- 120 Library (Callum)
	[121] = { 23,  1806.75, -2454.64,   13.56, 0 , "Beach Huts (Callum)"  }, -- 121 Beach Huts (Callum)
	[122] = { 24,    25.08,    -6.73,   40.43, 0 , "Office (Joosty)"  }, -- 122 Office (Joosty)
	[123] = { 25,  1920.57, -2327.92,   13.75, 0 , "Mid-sized Warehouse (Marser)"  }, -- 123 Mid-sized Warehouse (Marser)
	[124] = { 26,  1974.03, -2488.14,   13.62, 0 , "Medium-Class House (Marser)"  }, -- 124 Medium-Class House (Marser)
	[125] = { 27,  1877.89, -2466.96,   13.58, 0 , "Pawnshop (Marser)"  }, -- 125 Pawnshop (Marser)
	[126] = { 28,   962.51,  2054.07,   10.86, 0 , "Big Warehouse (Marser)"  }, -- 126 Big Warehouse (Marser)
	[127] = { 29,  2532.83, -1667.51,  246.67, 0 , "British Pub (LauraV)"  }, -- 127 British Pub (LauraV)
	[128] = { 30,  -199.28,  1119.81,  225.94, 0 , "Wooden Bar (LauraV)"  }, -- 128 Wooden Bar (LauraV)
	[129] = { 31,   269.71,   -28.78,  988.79, 0 , "ProLaps Gym (LauraV)"  }, -- 129 ProLaps Gym (LauraV)
	[130] = { 32,  2079.89,   477.98,   41.85, 0 , "Workout Complex (LauraV)"  }, -- 130 Workout Complex (LauraV)
	[131] = { 33,  2322.57, -1393.40,  395.09, 0 , "Realistic House (LauraV)"  }, -- 131 Realistic House (LauraV)
	[132] = { 15,   377.15,  1417.42, 1081.30, 90 , "Random house, Two bedrooms, kitchen."  }, -- 132 Random house, Two bedrooms, kitchen.
	[133] = { 15,   387.22,  1471.76, 1080.18, 90 , "Random house, One bedroom, kitchen."  }, -- 133 Random house, One bedroom, kitchen.
	[134] = { 15,   327.96,  1477.72, 1084.43, 0 , "Random house, Two bedrooms, kitchen, bathroom, bright kitchen."  },
	[135] = { 1, 2300.720703125, 1685.6923828125, 1101.9095458984, 180 , "Staircase (Socialz)"  }, -- 135 Staircase (Socialz)
	[136] = { 15, 328.0419921875, 1477.7236328125, 1084.4375, 0 , "Small cool house interior given by ablindman"  },
	[137] = { 22, 1433.6201171875, 1363.212890625, 10.830528259277, 0 , "Garage by 360"  }, -- 137 Garage by 360
	[138] = { 10, 227.60000610,116.80000305,999.20001221,0 , "LSPD Interior by Alberto"  }, -- 138 LSPD Interior by Alberto
	[139] = { 1, 243.7177734375, 304.9326171875, 999.1484375, 270 , "Bedroom by ablindman"  }, -- 139 Bedroom by ablindman
	[140] = { 4, 299.78125, 311.099609375, 1003.3046875, 270 , "Crackhouse by ablindman"  }, -- 140 Crackhouse by ablindman
	[141] = { 77, 1150.19140625, -808.0947265625, 2099.0656738281, 180 , "Studio (Socialz)"  }, -- 141 Studio (Socialz)
	[142] = { 38, 1422.083984375, -2451.73828125, 13.5546875, 0 , "Garage by Mamiee (Maxime)"  }, -- 142 Garage by Mamiee (Maxime)
	[143] = { 5, 1104.16919, -778.24506, 976.25159, 0 , "Medium Sized Offices + Hallway by Diuvel, Sketchead, McNitro and rjm (Maxime)"  },
	[144] = { 4, -1435.8690, -662.2505, 1052.4650, 270 , "Dirt Bike Track"  }, -- 144 Dirt Bike Track
	[145] = { 67, 1416.5126953125, 1382.8359375, 11.280016899109, 0 , "Small Bar With Office + Basement by Lyricist (Maxime)"  },
	[146] = { 10, 563.11963, 2641.35791, 9.29688, 90 , "Small Medium Class Apartment by Diuvel, Sketchead, McNitro and rjm (Maxime)"  },
	[147] = { 1, 1105.9000244141,-1312.8000488281,79.0625, 0 , "Underground Parking Garage by Anthony"  }, -- 147
	[148] = { 7, 403.23315, -304.4404, 1007.26221, 0, "Bakkery by Diuvel, Sketchead, McNitro and rjm (Maxime)"  },  -- 148
	[149] = { 24, 529.505859375, 63.921875, 1044.458984375, 0 , "Forrests Garage"  }, -- 149
	[150] = { 33, 1429.0107421875, 1463.2529296875, 10.888198852539, 0 , "Soho Shamal"  }, -- 150
	[151] = { 2, 2111.5615234375, -1442.1728515625, 291.42590332031, 270 , "Conference Room (Maxime)"  }, -- 151
	[152] = { 2, 2153.1865234375, -1417.4912109375, 293.73016357422, 90 , "High Command Offices (Maxime)"  }, -- 152
	[153] = { 2,  2170.9775390625, -1432.7744140625, 281.59719848633, 270 , "Staircase (Maxime)"  }, -- 153
	[154] = { 2,  2124.546875, -1437.1748046875, 300.67114257813, 180 , "Hallway (Maxime)"  }, -- 154
	[155] = { 56,  2132.8671875, -1638.8876953125, 389.73281860352, 0 , "Open Offices (Maxime)"  }, -- 155
	[156] = { 56,  1956.857421875, -2307.275390625, 14.09362411499, 0 , "Huge Underground Parking Lot (Maxime)"  }, -- 156
	[157] = { 56,  1914.861328125, -2386.41796875, 13.56685256958, 270 , "Medium Sized Underground Parking Lot (Maxime)"  }, -- 157
	[158] = { 0, 1527.72265625, 1616.08203125, 15.43788433075 , 180 , "RS Haul Warehouse (Mamiee)"  }, -- 158
	[159] = { 3, 995.31976, -227.2952, 972.39697 , 90 , "Auto Showroom by Diuvel, Sketchead, McNitro and rjm (Maxime)"  },
	[160] = { 10, 322.75504, -96.3672, 997.93127, 0 , "Small Casino + Backroom by Diuvel, Sketchead, McNitro and rjm (Maxime)"  },
	[161] = { 3, 794.966796875, 64.173828125, 965.2890625, 180 , "Small Tuning Garage by Diuvel, Sketchead, McNitro and rjm (Maxime)"  },
	[162] = { 34, 2027.2197265625, -2037.1748046875, 35.029685974121, 0 , "Low class House + Garage by Jimmykojootti (Maxime)"  },
	[163] = { 40, 315.45667, -112.94063, 1011.00781, 0 , "Small Garage Fits 2 Cars by Gundi92 (Maxime)"  },
	[164] = { 41, 855.017578125, 154.5146484375, 1009.151550293, 0 , "Illegal Casino by Gundi92 (Maxime)"  },
	[165] = { 42, -2145.615234375, 646.9287109375, 1206.4937744141, 270 , "Asian Styled Office by Gundi92 (Maxime)"  },
	[166] = { 43, 522.4501953125, 2379.2119140625, 435.39999389648, 0 , "General Store by Gundi92 (Maxime)"  },
	[167] = { 44, -1196.7939453125, -263.5166015625, 14.354687690735, 180 , "Mamiee Casino (Maxime)"  },
	[168] = { 45, 1384.8291015625, 1464.4951171875, 10.864421844482, 0 , "Enforcer"  },
	[169] = { 46, 1471.8935546875, 1752.9169921875, 14.760937690735 , 0 , "Low Class Apartment Lobby(Mamiee)"  },
	[170] = { 18, -18.2, -139.89999, 1043.90002 , 180 , "Small backroom with office"  },
	[171] = { 1, -1800.7724609375, 651.150390625, 960.38592529297, 80 , "LSFD"  },
	[172] = { 47, 1573.4541015625, -2413.10546875, 13.60781288147, 270 , "Fitness Gym by Yest"  },
	[173] = { 4, 1597, 1622, 13.60781288147, 10.8, "Jetbridge by Exciter"  },
	[174] = { 4, 1345.7598, 1485.4551, 19.312, 0, "Outdoor Tent" }
}


function getInteriorsList()
	return interiors
end

function printInteriorsList(thePlayer, commandName,  from, to )
	from = tonumber(from)
	to = tonumber(to)
	if not from or not to or from > to then
		outputChatBox("SYNTAX: /" .. commandName .. " [From ID] [To ID]", thePlayer, 255, 194, 15)
		return false
	end
	local count = 0
	local linkForum = "https://owlgaming.net/library/interiors/"
	for _,interior in pairs(interiors) do
		count = count + 1
	end

	outputChatBox("List of "..count.." official interiors from "..from.." to "..to..":", thePlayer, 170,170,170)

	for i = from , to do
		if not interiors[i] then
			break
		end
		outputChatBox("Interior ID#"..i.." - "..(interiors[i][6] or "Unnamed"), thePlayer, 0, 255,0)
	end


	outputChatBox("For a full list of "..count.." official interiors with Pictures. Please visit:", thePlayer, 170,170,170)
	outputChatBox(linkForum.." - Copied to clipboard.", thePlayer,170,170,170)
	triggerClientEvent(thePlayer, "official-interiors:copytoclipboard",thePlayer, linkForum)
	return true
end
addCommandHandler("listints", printInteriorsList)
addCommandHandler("listinteriors", printInteriorsList)
