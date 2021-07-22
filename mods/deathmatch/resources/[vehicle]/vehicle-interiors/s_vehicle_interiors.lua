--MODIFIED! by Exciter

local vehicles = { }
local vehicleInteriorGates = { }

local customVehInteriors = {
	--model,x,y,z,rx,ry,rz,interior, (optional - scale), (optional - collisionsenabled)

	--1: Andromada
	[1] = {
		{14548,-445.39999,87.3,1226.80005,13,0,0,1},
		{3069,-445.39999,111.2,1224.69995,0,0,0,1}
	},
	--2: Shamal
	[2] = {
		{2924,2.4000000953674,34.400001525879,1202.0999755859,0,0,0,1}
	},
	--3: AT-400
	[3] = {
		{14548,-388.89999, 86.6, 1226.80005,13,0,0,1},
		{7191,-391.10001, 110.2, 1226.69995,0,0,270,1},
		{7191,-391.10001, 110.2, 1230.19995,0,0,270,1},
		{7191,-411.79999,62.6,1226.69995,0,0,270,1},
		{7191,-365.89999,62.6,1226.69995,0,0,90,1},
		{7191,-373.89999,62.6,1229.40002,0,0,90,1},
	},

	--4: Ambulance
	[4] = {
		{ 1698, 2002.0, 2285.0, 1010.0,0,0,0,30 },
		{ 1698, 2003.36, 2285.0, 1010.0,0,0,0,30 },
		{ 1698, 2004.72, 2285.0, 1010.0,0,0,0,30 },
		{ 1698, 2002.0, 2288.3, 1010.0,0,0,0,30 },
		{ 1698, 2003.36, 2288.3, 1010.0,0,0,0,30 },
		{ 1698, 2004.72, 2288.3, 1010.0,0,0,0,30 },
		{ 3386, 2001.58, 2285.75, 1010.1, 0.0, 0.0, 180.0, 30 },
		{ 3388, 2001.58, 2284.8, 1010.1, 0.0, 0.0, 180.0, 30 },
		{ 2146, 2003.3, 2286.4, 1010.6,0,0,0,30 },
		{ 16000, 2001.3, 2281.0, 1007.5, 0.0, 0.0, 270.0, 30 },
		{ 16000, 2005.4, 2281.0, 1007.5, 0.0, 0.0, 90.0, 30},
		{ 18049, 2006.0, 2279.5, 1013.05, 0.0, 0.0, 90.0, 30 },
		{ 2639, 2005.0, 2285.55, 1010.7, 0.0, 0.0, 90.0, 30 },
		{ 3791, 2005.3, 2288.25, 1012.4, 270.0, 0.0, 90.0, 30 },
		{ 2174, 2001.7, 2286.74, 1010.1, 0.0, 0.0, 90.0, 30 },
		{ 2690, 2001.41, 2287.0, 1011.25, 0.0, 0.0, 90.0, 30 },
		{ 2163, 2001.3, 2286.84, 1011.9, 0.0, 0.0, 90.0, 30 },
		{ 1789, 2005.1, 2284.1, 1010.7, 0.0, 0.0, 270.0, 30 },
		{ 1369, 2001.85, 2283.85, 1010.7, 0.0, 0.0, 90.0, 30 },
		{ 3384, 2001.9, 2288.85, 1011.1, 0.0, 0.0, 180.0, 30 },
		{ 3395, 2005.3, 2288.32, 1010.05,0,0,0,30 },
		{ 11469, 2008.6, 2294.5, 1010.1, 0.0, 0.0, 90.0, 30 },
		{ 2154, 2001.55, 2289.75, 1010.0, 0.0, 0.0, 90.0, 30 },
		{ 2741, 2001.4, 2289.65, 1012.0, 0.0, 0.0, 90.0, 30 },
		{ 2685, 2001.35, 2289.65, 1011.5, 0.0, 0.0, 90.0, 30 },
		{ 18056, 2005.4, 2290.4, 1011.9, 0.0, 0.0, 180.0, 30 },
		{ 2688, 2001.4, 2283.85, 1012.0, 0.0, 0.0, 90.0, 30 },
		{ 2687, 2005.35, 2286.0, 1012.0, 0.0, 0.0, 270.0, 30 },
		{ 16000, 2006.5, 2290.0, 1020.0, 0.0, 180.0, 180.0, 30 },
		{ 16000, 1991.0, 2283.4, 1016.0, 0.0, 90.0, 0.0, 30 },
		{ 16000, 2015.7, 2283.4, 1016.0, 0.0, 270.0, 0.0, 30 },
		{ 1719, 2005.0, 2284.1, 1010.6, 0.0, 0.0, 270.0, 30 },
		{ 1718, 2005.1, 2284.1, 1010.73, 0.0, 0.0, 270.0, 30 },
		{ 1785, 2005.1, 2284.1, 1010.95, 0.0, 0.0, 270.0, 30 },
		{ 1783, 2005.05, 2284.1, 1010.4, 0.0, 0.0, 270.0, 30 },
	},
	--5: Swat Van (Enforcer)
	[5] = {
		{ 3055, 1385.01465, 1468.0957, 9.85458, 90, 179.995, 90, 31 },
		{ 3055, 1382.08594, 1468.05762, 10.29892, 0, 0, 90, 31 },
		{ 3055, 1384.2841, 1479.1, 10.29892, 0, 0, 0, 31 },
		{ 3055, 1387, 1468.06836, 10.29892, 0, 0, 270, 31 },
		{ 14851, 1375.6611, 1460.15, 8.13512, 0, 0, 270.005, 31 },
		{ 11631, 1386.30005, 1467.69922, 11.1, 0, 0, 270.011, 31 },
		{ 1958, 1382.60742, 1468.5813, 10.61344, 0, 0, 268.727, 31 },
		{ 2606, 1382.19995, 1468.80005, 11.9, 0, 0, 90, 31 },
		{ 2372, 1381.69678, 1465.41614, 10.69246, 89.616, 246.464, 203.536, 31 },
		{ 2008, 1382.7217, 1468.5098, 9.84762, 0, 0, 90, 31 },
		{ 3055, 1389.25, 1466.50684, 10.29892, 0, 0, 0, 31 },
		{ 3055, 1379.95996, 1466.51758, 10.29892, 0, 0, 0, 31 },
		{ 2606, 1382.19995, 1468.80005, 11.4, 0, 0, 90, 31 },
		{ 2227, 1381.81018, 1468.55676, 10.05617, 0, 0, 90, 31 },
		{ 2007, 1382.6, 1467.49, 9.37511, 0, 0, 90.126, 31 },
		{ 3055, 1382.57715, 1468.05005, 13.12, 90, 179.995, 270, 31 },
		{ 3055, 1387.60449, 1468.04883, 13.10289, 90, 179.995, 269.995, 31 },
		{ 3793, 1382.41406, 1465.85791, 11.38892, 0.033, 270.033, 229.963, 31 },
		{ 3793, 1382.41943, 1464.76172, 11.38892, 0.027, 270.033, 229.96, 31 },
		{ 2372, 1381.71094, 1466.51123, 10.69246, 89.615, 246.462, 203.533, 31 },
		{ 3055, 1389.56055, 1464.15857, 10.29892, 0, 0, 0, 31 },
		{ 3055, 1379.94934, 1464.15662, 10.29892, 0, 0, 0, 31 },
		{ 3055, 1383.59509, 1464.13318, 12.09403, 0, 0, 0, 31 },
		{ 3055, 1383.54785, 1466.52832, 14.6, 0, 0, 0, 31 },
		{ 7707, 1383.73743, 1464.10437, 10.9326, 0, 0, 90, 31 },
		{ 2372, 1383.83582, 1463.23877, 10.58514, 89.615, 246.462, 291.867, 31 },
		{ 14792, 1376.2998, 1485.55, 11.3, 0, 0, 90, 31 },
		{ 1808, 1382.5, 1470.30005, 9.8, 0, 0, 90, 31 },
		{ 2133, 1382.80005, 1471.09998, 9.9, 0, 0, 90, 31 },
		{ 2149, 1382.59998, 1471.19995, 11.1, 0, 0, 90, 31 },
		{ 3055, 1382.08594, 1475.89001, 10.29892, 0, 0, 90, 31 },
		{ 3055, 1386.8994, 1475.7998, 10.29892, 0, 0, 90, 31 },
		{ 3055, 1382.57715, 1475.88, 13.10289, 90, 179.995, 270, 31 },
		{ 3055, 1387.60449, 1475.88, 13.10289, 90, 179.995, 269.995, 31 },
		{ 1703, 1382.80005, 1472, 9.8, 0, 0, 90, 31 },
		{ 1719, 1386.59998, 1478.09998, 11.9, 0, 0, 90, 31 },
		{ 3055, 1385.01465, 1475, 9.85458, 90, 179.995, 90, 31 },
		{ 2133, 1386.2998, 1475.2, 9.9, 0, 0, 270, 31 },
		{ 2133, 1386.2998, 1474.2, 9.9, 0, 0, 270, 31 },
		{ 2133, 1386.2998, 1473.2, 9.9, 0, 0, 270, 31 },
		{ 2133, 1386.2998, 1472.2, 9.9, 0, 0, 270, 31 },
		{ 2133, 1386.2998, 1471.2, 9.9, 0, 0, 270, 31 },
		{ 2133, 1386.2998, 1470.2, 9.9, 0, 0, 270, 31 },
		{ 2737, 1382.2305, 1476, 12, 0, 0, 90, 31 },
		{ 2267, 1386.85, 1473, 11.9, 0, 0, 270, 31 },
		{ 1714, 1385.4, 1467.3, 9.9, 0, 0, 90, 31 },
		{ 1714, 1383.6, 1469.4, 9.9, 0, 0, 270, 31 },
		{ 2167, 1382.2, 1474.9, 9.85, 0, 0, 90, 31 },
		{ 2167, 1382.2, 1475.8, 9.85, 0, 0, 90, 31 },
		{ 2167, 1382.2, 1476.7, 9.85, 0, 0, 90, 31 },
		{ 2167, 1382.2, 1477.6, 9.85, 0, 0, 90, 31 },
		{ 2167, 1382.2, 1478.5, 9.85, 0, 0, 90, 31 },
		{ 2257, 1382.2, 1473.4, 12.4, 0, 0, 90, 31 },
		{ 2258, 1386.88, 1468, 12, 0, 0, 270, 31 },
	},
	--6: Cargobob
	[6] = {
		{ 14548, 1475.28857, 1766.46973, -67.60286, 140.00000, 0.00000, 178.92003, 32 },
		{ 14548, 1472.17249, 1799.81543, -44.23270, 13.00000, 0.00000, 0.00000, 32 },
		{ 14548, 1469.28552, 1766.57971, -67.60290, 140.00000, 0.04000, 178.92000, 32 },
		{ 7020, 1473.52942, 1781.22742, -48.43428, 63.24001, -5.15999, 4.68000, 32 },
		{ 2949, 1472.90759, 1766.03235, -46.27661, 0.00000, 0.00000, -89.69994, 32 },
		{ 2808, 1474.38000, 1777.63843, -45.63150, 0.00000, 0.00000, 90.30000, 32 },
		{ 2808, 1474.38000, 1775.36047, -45.63150, 0.00000, 0.00000, 90.30000, 32 },
		{ 2808, 1474.38000, 1773.12097, -45.63150, 0.00000, 0.00000, 90.30000, 32 },
		{ 2808, 1469.88000, 1777.81628, -45.63150, 0.00000, 0.00000, 270.41989, 32 },
		{ 2808, 1469.88000, 1775.54407, -45.63150, 0.00000, 0.00000, 270.41989, 32 },
		{ 2808, 1469.88000, 1773.24915, -45.63150, 0.00000, 0.00000, 270.41989, 32 },
		{ 2808, 1469.88000, 1770.97107, -45.63150, 0.00000, 0.00000, 270.41989, 32 },
		{ 2808, 1474.38000, 1770.90930, -45.63150, 0.00000, 0.00000, 90.30000, 32 },
		{ 2886, 1471.18958, 1766.02930, -44.77806, 0.00000, 0.00000, -180.66005, 32 },
		{ 14548, 1469.74316, 1787.14697, -44.21432, 13.00000, 0.00000, 0.00000, 32 },
		{ 14548, 1474.48499, 1787.15466, -44.21596, 13.00000, 0.00000, 0.00000, 32 },
		{ 14548, 1472.17249, 1787.15466, -44.89402, 13.00000, 0.00000, 0.00000, 32 },
	},
	--model,x,y,z,rx,ry,rz,interior
	[7] = { -- Yankee
		{2932, 2126.3999, -1087.7, 104.1, 0, 0, 0, 5},
		{2932, 2129.3999, -1087.7, 106.8, 0, 0, 0, 5},
		{2932, 2123.3999, -1087.7, 106.8, 0, 0, 0, 5},
		{2932, 2126.3999, -1087.7, 109.6, 0, 0, 0, 5},
		{2932, 2126.5, -1080.6, 106.8, 0, 0, 0, 5},
		{2885, 2126.4001, -1091.3, 108.7, 0, 0, 180, 5},
	},
	[8] = { -- Tropic
		{1659,1591.1318000,606.1796900,4.5516000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(htl_fan_static_dy) (1)
		{2136,1590.4361600,607.0333900,2.0404000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(cj_k3_sink) (1)
		{2305,1592.4260000,607.0263100,2.0404000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(cj_k3_c_unit) (1)
		{2137,1591.4680000,607.0269800,6.4308000,0.0000000,180.0000000,0.0000000,1,1,true}, --object(cj_k3_low_unit3) (1)
		{2137,1590.4805000,607.0273400,6.4308000,0.0000000,180.0000000,0.0000000,1,1,true}, --object(cj_k3_low_unit3) (2)
		{2137,1592.4290000,606.0676900,2.0404000,0.0000000,0.0000000,270.0000000,1,1,true}, --object(cj_k3_low_unit3) (3)
		{14747,1593.5699000,601.3126800,3.3812000,0.0000000,0.0000000,270.0000000,1,0.75,false}, --object(curses04) (1)
		{1560,1590.1027000,607.5731800,1.2122000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(gen_doorext7_11l) (1)
		{1560,1591.6729000,607.5748900,0.6258000,0.0000000,0.0000000,180.0000000,1,1,true}, --object(gen_doorext7_11l) (2)
		{11292,1585.9111000,607.5166000,3.2500000,0.0000000,0.0000000,89.9950000,1,1,true}, --object(gasstatiohut) (4)
		{2027,1588.7285000,607.6118200,2.5928000,0.0000000,0.0000000,0.0000000,1,1,false}, --object(dinerseat_4) (1)
		{11292,1588.6631000,606.0236200,3.2536000,0.0000000,0.0000000,180.0000000,1,1,true}, --object(gasstatiohut) (1)
		{2208,1587.9248000,603.8896500,2.0476000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(med_office7_unit_1) (1)
		{2299,1584.7384000,604.0413200,1.7740000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(swank_bed_6) (1)
		{2269,1588.1504000,606.9777800,3.2285000,0.0000000,0.0000000,90.0000000,1,1.25,false}, --object(frame_wood_4) (1)
		{2269,1588.0964000,606.9774800,3.2285000,0.0000000,0.0000000,90.0000000,1,1.25,false}, --object(frame_wood_4) (2)
		{2267,1588.7676000,607.4599600,3.6375000,0.0000000,0.0000000,0.0000000,1,1.2,false}, --object(frame_wood_3) (1)
		{2267,1588.7676000,607.5158100,3.6375000,0.0000000,0.0000000,0.0000000,1,1.2,false}, --object(frame_wood_3) (2)
		{2263,1586.6135000,607.0141000,3.1855000,0.0000000,0.0000000,270.0000000,1,1.55,true}, --object(frame_slim_4) (1)
		{2263,1586.6602000,607.0136700,3.1855000,0.0000000,0.0000000,270.0000000,1,1.55,true}, --object(frame_slim_4) (2)
		{2261,1586.1176000,606.9027700,3.1901000,0.0000000,0.0000000,0.0000000,1,1.2,false}, --object(frame_slim_2) (1)
		{2261,1586.1172000,606.9365200,3.1901000,0.0000000,0.0000000,0.0000000,1,1.2,false}, --object(frame_slim_2) (2)
		{1808,1587.6617000,606.0899000,2.0332000,0.0000000,0.0000000,90.0000000,1,1,true}, --object(cj_watercooler2) (1)
		{2089,1585.6693000,604.1555800,2.0062000,0.0000000,0.0000000,180.0000000,1,1,true}, --object(swank_cabinet_2) (1)
		{2167,1586.7450000,603.9329800,2.0476000,0.0000000,0.0000000,180.0000000,1,1.325,true}, --object(med_office_unit_7) (1)
		{2080,1588.6846000,603.9102200,2.6135000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(swank_dinning_2) (1)
		{2311,1588.8047000,603.6610700,3.1456000,270.0000000,0.0000000,0.0000000,1,0.5,false}, --object(cj_tv_table2) (2)
		{3859,1589.2002000,604.2041000,2.9530000,0.0000000,0.0000000,107.0000000,1,0.15,false}, --object(ottosmash04) (1)
		{1664,1589.5627000,604.0329000,3.0796000,0.0000000,0.0000000,90.0000000,1,1,true}, --object(propwinebotl2) (1)
		{1668,1589.4395000,604.0219100,3.0796000,0.0000000,0.0000000,170.0000000,1,1,true}, --object(propvodkabotl1) (1)
		{1669,1589.3032000,604.0347300,3.0796000,0.0000000,0.0000000,207.2500000,1,1,true}, --object(propwinebotl1) (1)
		{1562,1591.3907000,604.2948000,2.7028000,0.0000000,0.0000000,190.0000000,1,1,true}, --object(ab_jetseat) (1)
		{1563,1591.4543000,603.9420200,3.2200000,0.0000000,0.0000000,190.0000000,1,1,false}, --object(ab_jetseat_hrest) (1)
		{1512,1588.8173000,604.0496800,3.1067000,0.0000000,0.0000000,300.0000000,1,1,true}, --object(dyn_wine_03) (1)
		{1510,1588.4399000,604.0045800,2.9201000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(dyn_ashtry) (1)
		{1667,1589.0178000,603.9912700,2.9992000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(propwineglass1) (1)
		{1667,1589.1094000,604.0560300,2.9992000,0.0000000,0.0000000,280.0000000,1,1,true}, --object(propwineglass1) (2)
		{3467,1588.7465000,607.5374100,2.7900000,90.0000000,0.0000000,0.0000000,1,0,true}, --object(vegstreetsign1) (1)
		{1659,1588.7162000,606.9296900,4.5516000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(htl_fan_static_dy) (2)
		{1659,1585.7769000,605.7301000,4.5516000,0.0000000,0.0000000,0.0000000,1,1,true}, --object(htl_fan_static_dy) (3)
		{2238,1587.6741000,604.0288100,3.2164000,0.0000000,0.0000000,0.0000000,1,0.75,true}, --object(cj_lava_lamp) (1)
		{2878,1592.9579000,605.4478100,3.2091000,0.0000000,0.0000000,270.0000000,1,1,true}, --object(cj_victim_door) (1)
		{1478,1589.1930000,604.1353800,3.0830000,0.0000000,180.0000000,0.0000000,1,0.5,false}, --object(dyn_post_box) (1)
		{1537,1592.9438000,605.4534900,1.9558000,0.0000000,0.0000000,90.0000000,1,0.95,false}, --object(gen_doorext16) (2)
		{18001,1592.9031000,604.7188100,0.1591000,0.0000000,90.0000000,270.0000000,1,1,true}, --object(int_barbera07) (1)
		{18001,1592.8943000,604.7188100,0.1591000,0.0000000,90.0000000,270.0000000,1,1,true}, --object(int_barbera07) (2)
		{18001,1592.8855000,604.7188100,0.1591000,0.0000000,90.0000000,270.0000000,1,1,true}, --object(int_barbera07) (3)
	},
	[9] = { -- Trailer
		{3055,1532.0000000,1420.1000000,10.0000000,90.0000000,180.0000000,270.0000000,0}, -- 0
		{3055,1532.0000000,1427.9004000,10.0000000,90.0000000,179.9950000,270.0000000,0}, -- 1
		{3055,1532.0000000,1435.7000000,10.0000000,90.0000000,179.9950000,270.0000000,0}, -- 2
		{7627,1540.2000000,1447.8000000,8.6000000,0.0000000,0.0000000,90.0000000,0}, -- 3
		{7627,1524.4000000,1410.5000000,8.6000000,0.0000000,0.0000000,270.0000000,0}, -- 4
		{7627,1541.3000000,1411.0000000,8.6000000,0.0000000,0.0000000,0.0000000,0}, -- 5
		{7627,1527.4000000,1439.3000000,8.6000000,0.0000000,0.0000000,180.0000000,0}, -- 6
		{5856,1532.2990000,1416.4521000,12.0000000,0.0000000,0.0000000,270.0000000,0}, -- 7
		{2669,1531.5000000,1435.2000000,11.2000000,270.0000000,0.0000000,180.0000000,0}, -- 8
		{2669,1534.9000000,1435.2000000,11.2000000,270.0000000,0.0000000,179.9950000,0}, -- 9
		{3055,1532.0000000,1430.8000000,14.0000000,270.0000000,180.0000000,90.0000000,0}, -- 10
		{3055,1532.0000000,1423.0000000,14.0000000,270.0000000,179.9950000,90.0000000,0}, -- 11
		{3055,1532.0000000,1415.2002000,14.0000000,270.0000000,179.9950000,90.0000000,0}, -- 12
		{3095,1531.7162000,1420.2119000,9.9500000,0.0000000,180.0000000,270.0000000,0}, -- 13
		{3095,1531.6801000,1427.1868000,9.9500000,0.0000000,179.9950000,270.0000000,0}, -- 14
		{3095,1531.3132000,1431.2701000,10.0000000,0.0000000,179.9950000,270.0000000,0}, -- 15
		{1383,1535.9000000,1433.7000000,15.2000000,0.0000000,270.0000000,90.0000000,0}, -- 16
		{1383,1535.9000000,1435.0000000,15.2000000,0.0000000,270.0000000,180.0000000,0}, -- 17
		{1383,1528.7000000,1433.0000000,15.2000000,0.0000000,270.0000000,270.0000000,0}, -- 18
		{1383,1528.8000000,1415.3000000,15.2000000,0.0000000,270.0000000,0.0000000,0}, -- 19
		{1383,1528.7000000,1433.0000000,8.8000000,90.0000000,0.0000000,180.0000000,0}, -- 20
		{1383,1529.8000000,1435.0000000,8.8000000,90.0000000,0.0000000,90.0000000,0}, -- 21
		{1383,1535.9000000,1434.1000000,8.8000000,90.0000000,0.0000000,0.0000000,0}, -- 22
	},
	
	[10] = { -- FBI Truck
		{ 2957, 1387.1, 1236.5, 11.4, 0, 0, 0, 36, 1 },
		{ 2957, 1382.6, 1238.7, 11.4, 0, 0, 90, 36, 1 },
		{ 2957, 1386, 1238.6, 11.4, 0, 0, 90, 36, 1 },
		{ 14401, 1383.1, 1239, 10.1, 0, 0, 0, 36, 1 },
		{ 14401, 1386.8, 1239, 10.1, 0, 0, 0, 36, 1 },
		{ 2957, 1381.6, 1241, 11.4, 0, 0, 180, 36, 1 },
		{ 2957, 1387.2, 1241, 11.4, 0, 0, 180, 36, 1 },
		{ 2949, 1383.6, 1241, 9.8, 0, 0, 90, 36, 1 },
		{ 2957, 1384.7, 1241, 13.9, 0, 0, 180, 36, 1 },
		{ 2957, 1384.3, 1238.8, 9.8, 90, 0, 270, 36, 1 },
		{ 2957, 1384.3, 1238.8, 12.3, 90, 0, 270, 36, 1 },
		{ 2957, 1381.5, 1236.5, 10, 0, 0, 0, 36, 1 },
		{ 1649, 1384.2, 1236.5, 11.4, 0, 0, 0, 36, 1 },
		{ 2957, 1382.6, 1236.5, 13.2, 0, 0, 0, 36, 1 },
		{ 2957, 1382.6, 1236.5, 11.3, 0, 0, 0, 36, 0 },	
	},

	[11] = { -- Benson
        --model,x,y,z,rx,ry,rz,interior
        {2679, 2475.55, -1660.65, 13.57, 0, 0, 0, 40},
        {2678, 2474.04, -1660.65, 13.57, 0, 0, 0, 40},
        {2669, 2474.8, -1658, 13.7, 0, 0, 0, 40},

    },
}

-- check all existing vehicles for interiors
addEventHandler( "onResourceStart", getResourceRootElement( ),
	function( )
		for key, value in ipairs( getElementsByType( "vehicle" ) ) do
			add( value )
		end
	end
)

-- cleanup code
addEventHandler( "onElementDestroy", getRootElement( ),
	function( )
		if vehicles[ source ] then
			destroyElement( vehicles[ source ] )
			vehicles[ source ] = nil
		end
	end
)

addEventHandler( "onResourceStop", getResourceRootElement( ),
	function( )
		for key, value in ipairs( getElementsByType( "vehicle" ) ) do
			if getElementData( value, "entrance" ) then
				exports.anticheat:changeProtectedElementDataEx( value, "entrance" )
			end
		end
		for key, value in ipairs(vehicleInteriorGates) do
			exports["gate-manager"]:removeGate(value)
		end
	end
)

-- code to create the pickup and set properties
local function addInterior( vehicle, targetx, targety, targetz, targetinterior )
	local intpickup = createPickup( targetx, targety, targetz, 3, 1318 )
	setElementDimension( intpickup, getElementData( vehicle, "dbid" ) + 20000 )
	setElementInterior( intpickup, targetinterior )

	vehicles[ vehicle ] = intpickup
	exports.anticheat:changeProtectedElementDataEx( vehicle, "entrance", true )
end

-- exported, called when a vehicle is created
function add( vehicle )
	--[[
	if getElementData(vehicle, "dbid") == 8726 then -- vehicle is shamal and vehid is 8726
		addInterior( vehicle, 1429, 1463, 11, 33) -- add the interior
		return true, 33 -- this is teh interior the shit was createObject'd in.
	--]]
	if getElementModel( vehicle ) == 519 then -- Shamal
		local dbid = tonumber(getElementData(vehicle, "dbid"))
		local dim = dbid+20000

		--create custom objects
		for k,v in ipairs(customVehInteriors[2]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
		end

		--add cockpit door
		local gate = exports["gate-manager"]:createGate(2924,1,34.5,1199.8000488281,0,0,180,-0.30000001192093,34.5,1199.8000488281,0,0,180,1,dim,0,30,9,tostring(dbid),2)
		table.insert(vehicleInteriorGates, gate)

		addInterior( vehicle,  2.609375, 33.212890625, 1199.6, 1 )
		--addInterior( vehicle, 3.8, 23.1, 1199.6, 1 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 2)
		attachElements(marker, vehicle, -2, 3.5, -2)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)

		local shape = createColSphere(1.7294921875, 35.7333984375, 1200.3044433594, 1.5)
		setElementInterior(shape, 1)
		setElementDimension(shape, dim)
		addEventHandler("onColShapeHit", shape, hitCockpitShape)
		addEventHandler("onColShapeLeave", shape, leaveCockpitShape)

		return true, 1 -- interior id
	elseif getElementModel( vehicle ) == 577 then -- AT-400
		local dbid = tonumber(getElementData(vehicle, "dbid"))
		local dim = dbid+20000

		--create custom objects
		local addY = 0
		for i = 1,14 do
			table.insert(customVehInteriors[3], {1562, -384.60001, 65.1+addY, 1225.5, 0, 0, 0,1})
			table.insert(customVehInteriors[3], {1562, -385.39999, 65.1+addY, 1225.5, 0, 0, 0,1})
			table.insert(customVehInteriors[3], {1562, -386.20001, 65.1+addY, 1225.5, 0, 0, 0,1})
			table.insert(customVehInteriors[3], {1562, -393.29999, 65.1+addY, 1225.5, 0, 0, 0,1})
			table.insert(customVehInteriors[3], {1562, -392.5, 65.1+addY, 1225.5, 0, 0, 0,1})
			table.insert(customVehInteriors[3], {1562, -391.70001, 65.1+addY, 1225.5, 0, 0, 0,1})
			table.insert(customVehInteriors[3], {1562, -389.79999, 65.1+addY, 1225.5, 0, 0, 0,1})
			table.insert(customVehInteriors[3], {1562, -389, 65.1+addY, 1225.5, 0, 0, 0,1})
			table.insert(customVehInteriors[3], {1562, -388.20001, 65.1+addY, 1225.5, 0, 0, 0,1})
			addY = addY + 2.8
		end

		for k,v in ipairs(customVehInteriors[3]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
			if(v[1] == 1562) then --add pillows to jet seats
				local object2 = createObject(1563,v[2],v[3],v[4],v[5],v[6],v[7])
				setElementInterior(object2, v[8])
				setElementDimension(object2, dim)
				attachElements(object2, object, 0, 0.35, 0.54)
			end
		end

		addInterior( vehicle, -391.79999, 58, 1225.80005, 1 )

		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 2)
		attachElements(marker, vehicle, -4.5, 19, 2.7)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)

		local shape = createColSphere(-388.79999, 53.9, 1225.80005, 1.5)
		setElementInterior(shape, 1)
		setElementDimension(shape, dim)
		addEventHandler("onColShapeHit", shape, hitCockpitShape)
		addEventHandler("onColShapeLeave", shape, leaveCockpitShape)

		return true, 1
	elseif getElementModel(vehicle) == 592 then --Andromada
		--create the andromada interior
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[1]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
		end
		addInterior(vehicle,  -445.29999, 113.1, 1226.19995, 1)

		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 5)
		attachElements(marker, vehicle, 0, -23, -2.2)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)

		return true, 1

	elseif getElementModel( vehicle ) == 508 then --Journey
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 2, 0, 0)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		addInterior( vehicle, 1.9, -3.2, 999.4, 2 )
		return true, 2
	elseif getElementModel( vehicle ) == 484 then -- Marquis (sailboat)
		addInterior( vehicle, 1.9, -3.2, 999.4, 2 )
		return true, 2
	elseif getElementModel( vehicle ) == 416 then -- Ambulance
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[4]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
		end
		addInterior( vehicle, 2003.3, 2284.2, 1011.1, 30 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 0, -4, 0)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		return true, 30
	elseif getElementModel( vehicle ) == 427 then -- Enforcer
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[5]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
		end
		addInterior( vehicle, 1384.8, 1464.7, 11, 31 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 0, -4, 0)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		return true, 31
	elseif getElementModel( vehicle ) == 548 then -- Cargobob
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[6]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
		end
		addInterior( vehicle, 1472.1632080078, 1778.9901123047, -45.214691162109, 32 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 0, -4.5, -1.5)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		return true, 32
	elseif getElementModel( vehicle ) == 456 then -- Yankee
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[7]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
		end
		addInterior( vehicle,  2126.3256835938, -1090.3688964844, 106.55341339111, 5 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 0, -4, 0)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		return true, 30
	elseif getElementModel( vehicle ) == 454 then -- Tropic
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[8]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)

			if v[9] then
				setObjectScale(object, v[9])
			end

			if v[10] then
				setElementCollisionsEnabled(object, v[10])
			end
		end
		addInterior( vehicle,  1592.3962, 604.81598, 3.0476, 1 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 0, -4, 0)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		return true, 1
	elseif getElementModel( vehicle ) == 435 then -- Trailer
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[9]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
		end
		-- <marker id="marker (cylinder) (1)" type="cylinder" color="#0000ffff" size="1" interior="0" dimension="0" alpha="255" posX="1532.3928" posY="1421.2961" posZ="11.00984" rotX="0" rotY="0" rotZ="0"></marker>
		addInterior( vehicle,  1532.392, 1421.2961, 11.00984, 0 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 0, -4, 0)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		return true, 1
	elseif getElementModel( vehicle ) == 528 then -- FBI truck
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[10]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
			setObjectScale(object, v[9])
		end
		addInterior( vehicle, 1384.37, 1240.6, 10.88, 36 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 0, -4, 0)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		return true, 36
	elseif getElementModel( vehicle ) == 499 then -- Benson
		local dim = tonumber(getElementData(vehicle, "dbid")) + 20000
		for k,v in ipairs(customVehInteriors[11]) do
			local object = createObject(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			setElementInterior(object, v[8])
			setElementDimension(object, dim)
		end
		addInterior( vehicle, 2474.8, -1660.2, 13.5, 40 )
		local x,y,z = getElementPosition(vehicle)
		local marker = createColSphere(x, y, z, 1)
		attachElements(marker, vehicle, 0, -4, 0)
		addEventHandler("onColShapeHit", marker, hitVehicleEntrance)
		addEventHandler("onColShapeLeave", marker, leaveVehicleEntrance)
		return true, 40
	else
		return false
	end
end

function hitCockpitShape(hitElement, matchingDimension)
	--outputDebugString("hitCockpitShape()")
	if matchingDimension and getElementType(hitElement) == "player" then
		bindKey(hitElement, "enter_exit", "down", enterCockpitByKey)
		bindKey(hitElement, "g", "down", enterCockpitByKey) --enter_passenger
	end
end
function leaveCockpitShape(hitElement, matchingDimension)
	--outputDebugString("leaveCockpitShape()")
	if matchingDimension and getElementType(hitElement) == "player" then
		unbindKey(hitElement, "enter_exit", "down", enterCockpitByKey)
		unbindKey(hitElement, "g", "down", enterCockpitByKey) --enter_passenger
	end
end
function enterCockpitByKey(thePlayer, key, keyState)
	unbindKey(thePlayer, "enter_exit", "down", enterCockpitByKey)
	unbindKey(thePlayer, "g", "down", enterCockpitByKey) --enter_passenger
	fadeCamera(thePlayer, false)
	local dbid = getElementDimension(thePlayer) - 20000
	local vehicle
	for value in pairs( vehicles ) do
		if getElementData( value, "dbid" ) == dbid then
			vehicle = value
			break
		end
	end
	if vehicle then
		if isVehicleLocked(vehicle) then
			outputChatBox("The cockpit door is locked.", thePlayer, 255, 0, 0, false)
			fadeCamera(thePlayer, true)
			return
		else
			local allowed = false
			local model = getElementModel(vehicle)
			if(model == 577 or model == 519) then --AT-400 & Shamal
				if(getElementData(thePlayer, "duty_admin") == 1 or exports.global:hasItem(thePlayer, 3, tonumber(dbid)) or (exports.factions:isPlayerInFaction(thePlayer, getElementData(vehicle, "faction")))) then
					allowed = true
				end
			end
			if allowed then
				local seat
				if(key == "enter_exit") then
					seat = 0
				elseif(key == "g") then --enter_passenger
					seat = 1
				end
				local numSeats = getVehicleMaxPassengers(vehicle)
				if(numSeats == 1) then
					seat = 0
				end
				if seat then
					if getVehicleOccupant(vehicle, seat) then
						if numSeats > 1 then
							if seat == 0 then
								if getVehicleOccupant(vehicle, 1) then
									--outputChatBox("That seat is already occupied.", thePlayer, 255, 0, 0, false)
									exports.hud:sendBottomNotification(thePlayer, "Occupied", "That seat is already occupied.")
									fadeCamera(thePlayer, true)
									return
								else
									seat = 1
								end
							else
								if getVehicleOccupant(vehicle, 0) then
									--outputChatBox("That seat is already occupied.", thePlayer, 255, 0, 0, false)
									exports.hud:sendBottomNotification(thePlayer, "Occupied", "That seat is already occupied.")
									fadeCamera(thePlayer, true)
									return
								else
									seat = 0
								end
							end
						else
							outputChatBox("That seat is already occupied.", thePlayer, 255, 0, 0, false)
							exports.hud:sendBottomNotification(thePlayer, "Occupied", "That seat is already occupied.")
							fadeCamera(thePlayer, true)
							return
						end
					end
					local result = warpPedIntoVehicle(thePlayer, vehicle, seat)
					if result then
						setElementInterior(thePlayer, getElementInterior(vehicle))
						setElementDimension(thePlayer, getElementDimension(vehicle))
						triggerEvent("texture-system:loadCustomTextures", thePlayer)
						fadeCamera(thePlayer, true)
						return
					end
				else
					--outputDebugString("no seat")
				end
			end
		end
	end
	fadeCamera(thePlayer, true)
end

function hitVehicleEntrance(hitElement, matchingDimension)
	--outputDebugString("hitVehicleEntrance()")
	if matchingDimension and getElementType(hitElement) == "player" then
		--outputDebugString("matching")
		local vehicle = getElementAttachedTo(source)
		if vehicles[ vehicle ] then
			--outputDebugString("found veh")
			if not isVehicleLocked( vehicle ) then
				--outputDebugString("not locked")
				--[[
				local owner = getElementData(vehicle, "owner")
				local faction = getElementData(vehicle, "faction")
				local ownerName = "None."
				if owner < 0 and faction == -1 then
					--ownerName = "None."
				elseif (faction==-1) and (owner>0) then
					ownerName = exports['cache']:getCharacterName(owner)
				elseif(faction > 0) then
					local factionName
					for key, value in ipairs(exports.pool:getPoolElementsByType("team")) do
						local id = tonumber(getElementData(value, "id"))
						if (id==faction) then
							factionName = getTeamName(value)
							break
						end
					end
					if factionName then
						ownerName = factionName
					end
				end
				--]]
				triggerClientEvent(hitElement, "vehicle-interiors:showInteriorGUI", vehicle)
			end
		end
	end
end
function leaveVehicleEntrance(hitElement, matchingDimension)
	--outputDebugString("leaveVehicleEntrance()")
	if matchingDimension and getElementType(hitElement) == "player" then
		triggerClientEvent(hitElement, "vehicle-interiors:hideInteriorGUI", hitElement)
	end
end

-- enter over right click menu
function teleportTo( player, x, y, z, dimension, interior, freeze )
	fadeCamera( player, false, 1 )

	setTimer(
		function( player )
			setElementDimension( player, dimension )
			setElementInterior( player, interior )
			setCameraInterior( player, interior )
			setElementPosition( player, x, y, z )

			setTimer( fadeCamera, 1000, 1, player, true, 2 )

			if freeze then
				triggerClientEvent( player, "usedElevator", player ) -- DISABLED because the event was buggged for an unknown reason on client side / MAXIME
				setElementFrozen( player, true )
				setPedGravity( player, 0 )
			end
		end, 1000, 1, player
	)
end

addEvent( "enterVehicleInterior", true )
addEventHandler( "enterVehicleInterior", getRootElement( ),
	function( vehicle )
		--outputDebugString("enterVehicleInterior")
		if vehicles[ vehicle ] then
			if isVehicleLocked( vehicle ) then
				outputChatBox( "You try the door handle, but it seems to be locked.", source, 255, 0, 0 )
			else
				local model = getElementModel(vehicle)
				if(model == 577 or model == 592) then --texture change
					triggerClientEvent(source, "vehicle-interiors:changeTextures", vehicle, model)
				end

				if (model == 592) or (model == 435) then -- Entering with another vehicle?
					if(isPedInVehicle(source)) then
						if(getPedOccupiedVehicleSeat(source) == 0) then
							local pedVehicle = getPedOccupiedVehicle(source)
							exports.anticheat:changeProtectedElementDataEx(pedVehicle, "health", getElementHealth(pedVehicle), false)
							for i = 0, getVehicleMaxPassengers( pedVehicle ) do
								local p = getVehicleOccupant( pedVehicle, i )
								if p then
									triggerClientEvent( p, "CantFallOffBike", p )
								end
							end
							local exit = vehicles[ vehicle ]
							local x, y, z = getElementPosition(exit)
							setTimer(warpVehicleIntoInteriorfunction, 500, 1, pedVehicle, getElementInterior(exit), getElementDimension(exit), x, y, z)
						end
						return
					end
				end

				local exit = vehicles[ vehicle ]
				local x, y, z = getElementPosition(exit)
				local targetInt, targetDim = getElementInterior(exit), getElementDimension(exit)
				local teleportArr = { x = x, y = y, z = z, int = targetInt, dim = targetDim, rot = 0 }
				exports.interior_system:setPlayerInsideInterior3(false, source, teleportArr)
			end
		end
	end
)

function warpVehicleIntoInteriorfunction(vehicle, interior, dimension, x, y, z, rz)
	if isElement(vehicle) then
		local offset = getElementData(vehicle, "groundoffset") or 2

		setElementPosition(vehicle, x, y, z  - 1 + offset)
		setElementInterior(vehicle, interior)
		setElementDimension(vehicle, dimension)
		setElementVelocity(vehicle, 0, 0, 0)
		setElementAngularVelocity(vehicle, 0, 0, 0)
		setVehicleRotation(vehicle, 0, 0, 0)
		--setElementRotation(vehicle, rz or 0, 0, 0, "ZYX")
		setTimer(setElementAngularVelocity, 50, 2, vehicle, 0, 0, 0)
		setElementHealth(vehicle, getElementData(vehicle, "health") or 1000)
		exports.anticheat:changeProtectedElementDataEx(vehicle, "health")
		setElementFrozen(vehicle, true)

		setTimer(setElementFrozen, 1000, 1, vehicle, false)

		for i = 0, getVehicleMaxPassengers( vehicle ) do
			local player = getVehicleOccupant( vehicle, i )
			if player then
				setElementInterior(player, interior)
				setCameraInterior(player, interior)
				setElementDimension(player, dimension)
				setCameraTarget(player)

				exports.anticheat:changeProtectedElementDataEx(player, "realinvehicle", 1, false)
			end
		end
	end
end


function enterVehicleInteriorByMarker(hitElement, matchingDimension)
	if(matchingDimension and getElementType(hitElement) == "player") then
		if not isPedInVehicle(hitElement) then
			local exiting = getElementData(hitElement, "vehint.exiting")
			if not exiting then
				local vehicle = getElementAttachedTo(source)
				if vehicles[ vehicle ] then
					if not isVehicleLocked( vehicle ) then
						local model = getElementModel(vehicle)
						if(model == 577 or model == 592) then --texture change
							triggerClientEvent(hitElement, "vehicle-interiors:changeTextures", vehicle, model)
						end
						local exit = vehicles[ vehicle ]
						local x, y, z = getElementPosition(exit)
						local teleportArr = { x = x, y = y, z = z, int = getElementInterior(exit), dim = getElementDimension(exit), rot = 0 }
						exports.interior_system:setPlayerInsideInterior3(false, hitElement, teleportArr)
					end
				end
			else
				--outputDebugString("exiting")
			end
		end
	end
end

function leaveVehIntMarker(hitElement, matchingDimension)
	if(getElementType(hitElement) == "player") then
		setElementData(hitElement, "vehint.exiting", false, false)
	end
end

function leaveInterior( player )
	local dim = getElementDimension( player ) - 20000
	for value in pairs( vehicles ) do
		if getElementData( value, "dbid" ) == dim then
			if isVehicleLocked( value ) then
				outputChatBox( "You try the door handle, but it seems to be locked.", player, 255, 0, 0 )
			else
				if(getElementData(value, "airport.gate.connected")) then
					local gateID = tonumber(getElementData(value, "airport.gate.connected"))
					local teleportArr = exports["sfia"]:getDataForExitingConnectedPlane(gateID, value)
					if teleportArr then
						exports.interior_system:setPlayerInsideInterior3(false, player, teleportArr)
						return
					end
				end

				local x, y, z = getElementPosition( value )
				local xadd, yadd, zadd = 0, 0, 2

				if (getElementModel(value) == 508) then -- Journey
					local attached = getAttachedElements(value)
					for k,v in ipairs(attached) do
						if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 0,0,0.5
							break
						end
					end
				elseif (getElementModel(value) == 519) then -- Shamal
					local attached = getAttachedElements(value)
					for k,v in ipairs(attached) do
						if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 0,0,1.5
							break
						end
					end
				elseif (getElementModel(value) == 577) then -- AT-400
					local attached = getAttachedElements(value)
					for k,v in ipairs(attached) do
						if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 0,0,1.5
							break
						end
					end
				elseif (getElementModel(value) == 592) then -- Andromada
					local attached = getAttachedElements(value)
					for k,v in ipairs(attached) do
						if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 0,0,2
							break
						end
					end
					if(isPedInVehicle(player)) then
						if(getPedOccupiedVehicleSeat(player) == 0) then
							local pedVehicle = getPedOccupiedVehicle(player)
							exports.anticheat:changeProtectedElementDataEx(pedVehicle, "health", getElementHealth(pedVehicle), false)
							for i = 0, getVehicleMaxPassengers( pedVehicle ) do
								local p = getVehicleOccupant( pedVehicle, i )
								if p then
									triggerClientEvent( p, "CantFallOffBike", p )
								end
							end
							local rz,ry,rx = getElementRotation(value, "ZYX")
							local rot = 0
							if(rz >= 180) then
								rot = rz - 180
							else
								rot = rz + 180
							end

							setTimer(warpVehicleIntoInteriorfunction, 500, 1, pedVehicle, getElementInterior(value), getElementDimension(value), x+xadd, y+yadd, z+zadd, rot)
						end
						return
					end
				elseif (getElementModel(value) == 416) then -- Ambulance
					local attached = getAttachedElements(value)
					for k,v in ipairs(attached) do
						if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 0,0,0.5
							break
						end
					end
				elseif (getElementModel(value) == 427) then -- Enforcer
					local attached = getAttachedElements(value)
					for k,v in ipairs(attached) do
						if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 0,0,0.5
							break
						end
					end
				elseif (getElementModel(value) == 548) then -- Cargobob
					local attached = getAttachedElements(value)
					for k,v in ipairs(attached) do
						if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 0,0,0.1
							break
						end
					end
				elseif (getElementModel(value) == 456) then --Yankee
				    local attached = getAttachedElements(value)
				    for k,v in ipairs(attached) do
				        if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 1.4, 1.4, 0
				            break
				        end
					end
				elseif (getElementModel(value) == 499) then -- Benson
				    local attached = getAttachedElements(value)
				    for k,v in ipairs(attached) do
				        if(getElementType(v) == "colshape") then
				            x,y,z = getElementPosition(v)
				            xadd,yadd,zadd = 0, 0, 0.5
				            break
				        end
				    end
				elseif (getElementModel(value) == 454) then --Tropic
				    local attached = getAttachedElements(value)
				    for k,v in ipairs(attached) do
				        if(getElementType(v) == "colshape") then
				            x,y,z = getElementPosition(v)
				            xadd,yadd,zadd = 0, 0, 1
				            break
				        end
				    end
				elseif (getElementModel(value) == 435) then --Trailer
				    local attached = getAttachedElements(value)
				    for k,v in ipairs(attached) do
				        if(getElementType(v) == "colshape") then
				            x,y,z = getElementPosition(v)
				            xadd,yadd,zadd = 0, 2, 0
				            break
				        end
					end
					if(isPedInVehicle(player)) then
						if(getPedOccupiedVehicleSeat(player) == 0) then
							local pedVehicle = getPedOccupiedVehicle(player)
							exports.anticheat:changeProtectedElementDataEx(pedVehicle, "health", getElementHealth(pedVehicle), false)
							for i = 0, getVehicleMaxPassengers( pedVehicle ) do
								local p = getVehicleOccupant( pedVehicle, i )
								if p then
									triggerClientEvent( p, "CantFallOffBike", p )
								end
							end

							local rz,ry,rx = getElementRotation(value, "ZYX")
							local offset = 3
							xadd,yadd,zadd = 0, 0, 0
							if rx > 315 or (rx > 0 and rx <= 45) then
								yadd = -offset
							elseif rx > 45 and rx <= 135 then
								xadd = offset
							elseif rx > 135 and rx <= 225 then
								yadd = offset
							else
								xadd = -offset
							end

							local rot = 0
							if(rz >= 180) then
								rot = rz - 180
							else
								rot = rz + 180
							end

							setTimer(warpVehicleIntoInteriorfunction, 500, 1, pedVehicle, getElementInterior(value), getElementDimension(value), x+xadd, y+yadd, z+zadd, rot)
						end
						return
					end
				elseif (getElementModel(value) == 528) then -- FBI Truck
					local attached = getAttachedElements(value)
					for k,v in ipairs(attached) do
						if(getElementType(v) == "colshape") then
							x,y,z = getElementPosition(v)
							xadd,yadd,zadd = 0,0,0.5
							break
						end
					end	
					if(isPedInVehicle(player)) then
						if(getPedOccupiedVehicleSeat(player) == 0) then
							local pedVehicle = getPedOccupiedVehicle(player)
							exports.anticheat:changeProtectedElementDataEx(pedVehicle, "health", getElementHealth(pedVehicle), false)
							for i = 0, getVehicleMaxPassengers( pedVehicle ) do
								local p = getVehicleOccupant( pedVehicle, i )
								if p then
									triggerClientEvent( p, "CantFallOffBike", p )
								end
							end

							local rz,ry,rx = getElementRotation(value, "ZYX")
							local offset = 3
							xadd,yadd,zadd = 0, 0, 0
							if rx > 315 or (rx > 0 and rx <= 45) then
								yadd = -offset
							elseif rx > 45 and rx <= 135 then
								xadd = offset
							elseif rx > 135 and rx <= 225 then
								yadd = offset
							else
								xadd = -offset
							end

							local rot = 0
							if(rz >= 180) then
								rot = rz - 180
							else
								rot = rz + 180
							end

							setTimer(warpVehicleIntoInteriorfunction, 500, 1, pedVehicle, getElementInterior(value), getElementDimension(value), x+xadd, y+yadd, z+zadd, rot)
						end
						return
					end
				end
				local teleportArr = { x = x + xadd, y = y + yadd, z = z + zadd, int = getElementInterior(value), dim = getElementDimension(value) }
				exports.interior_system:setPlayerInsideInterior3(false, player, teleportArr)
				return
			end
		end
	end
end

-- cancel picking up our pickups
function isInPickup( thePlayer, thePickup, distance )
	if not isElement(thePickup) then return false end

	local ax, ay, az = getElementPosition(thePlayer)
	local bx, by, bz = getElementPosition(thePickup)

	return getDistanceBetweenPoints3D(ax, ay, az, bx, by, bz) < ( distance or 2 ) and getElementInterior(thePlayer) == getElementInterior(thePickup) and getElementDimension(thePlayer) == getElementDimension(thePickup)
end

function isNearExit( thePlayer, theVehicle )
	return isInPickup( thePlayer, vehicles[ theVehicle ] )
end

function checkLeavePickup( player, pickup )
	if isElement( player ) then
		if isInPickup( player, pickup ) then
			setTimer( checkLeavePickup, 500, 1, player, pickup )
		else
			unbindKey( player, "f", "down", leaveInterior )
		end
	end
end

addEventHandler( "onPickupHit", getResourceRootElement( ),
	function( player )
		bindKey( player, "f", "down", leaveInterior )

		setTimer( checkLeavePickup, 500, 1, player, source )

		cancelEvent( )
	end
)

-- make sure we blow
addEventHandler( "onVehicleRespawn", getRootElement( ),
	function( blown )
		if blown and vehicles[ source ] then
			local dim = getElementData(source, "dbid") + 20000
			for k, v in ipairs( getElementsByType( "player" ) ) do
				if getElementDimension( v ) == dim then
					killPed( v, 0 )
				end
			end
		end
	end
)

function vehicleKnock(veh)
	local player = source
	if (player) then
		local tpd = getElementDimension(player)
		if (tpd > 20000) then
			local vid = tpd - 20000
			for key, value in ipairs( getElementsByType( "vehicle" ) ) do
				if getElementData( value, "dbid" ) == vid then
					exports.global:sendLocalText(player, " *" .. getPlayerName(player):gsub("_"," ") .. " begins to knock on the vehicle.", 255, 51, 102)
					exports.global:sendLocalText(value, " * Knocks can be heard coming from inside the vehicle. * ", 255, 51, 102) --     ((" .. getPlayerName(player):gsub("_"," ") .. "))
				end
			end
		else
			if vehicles[veh] then
				local exit = vehicles[veh]

				if (exit) then
					exports.global:sendLocalText(player, " *" .. getPlayerName(player):gsub("_"," ") .. " begins to knock on the vehicle.", 255, 51, 102)
					exports.global:sendLocalText(exit, " * Knocks can be heard coming from the outside. * ", 255, 51, 102) --     ((" .. getPlayerName(player):gsub("_"," ") .. "))
				end
			end
		end
	end
end
addEvent("onVehicleKnocking", true)
addEventHandler("onVehicleKnocking", getRootElement(), vehicleKnock)

function enterVehicle(thePlayer, seat, jacked)
	local model = getElementModel(source)
	if(model == 519 or model == 577) then --Shamal & AT-400
		if vehicles[source] then
			--[[local x,y,z = getElementPosition(source)
			local px,py,pz = getElementPosition(thePlayer)
			if(getDistanceBetweenPoints3D(x,y,z,px,py,pz) < 3) then
				if not isVehicleLocked(source) then
					--outputDebugString("not locked")
					local exit = vehicles[source]
					local x, y, z = getElementPosition(exit)
					local teleportArr = { x, y, z, getElementInterior(exit), getElementDimension(exit), 0, 0 }
					triggerClientEvent(thePlayer, "setPlayerInsideInterior2", source, teleportArr, 0)
				end
			else
				outputDebugString("too far away: "..tostring(getDistanceBetweenPoints3D(x,y,z,px,py,pz)))
			end--]]
			cancelEvent()
		end
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), enterVehicle)
function exitVehicle(thePlayer, seat, jacked, door)
	if(getElementModel(source) == 519) then --Shamal
		if vehicles[source] then
			if not isVehicleLocked(source) then
				removePedFromVehicle(thePlayer)
				local teleportArr = { x = 1.7294921875, y = 35.7333984375, z = 1200.3044433594, int = 1, dim = tonumber(getElementData(source, "dbid"))+20000, rot = 0 }
				exports.interior_system:setPlayerInsideInterior3(false, thePlayer, teleportArr)
			else
				--outputChatBox("The cockpit door is locked.", thePlayer, 255, 0, 0, false)
				exports.hud:sendBottomNotification(thePlayer, "Locked", "The cockpit door is locked.")
			end
			cancelEvent()
		end
	elseif(getElementModel(source) == 577) then --AT-400
		if vehicles[source] then
			if not isVehicleLocked(source) then
				removePedFromVehicle(thePlayer)
				local teleportArr = { x = -388.79999, y = 53.9, z = 1225.80005, int = 1, dim = tonumber(getElementData(source, "dbid"))+20000, rot = 0}
				exports.interior_system:setPlayerInsideInterior3(false, thePlayer, teleportArr)
			else
				--outputChatBox("The cockpit door is locked.", thePlayer, 255, 0, 0, false)
				exports.hud:sendBottomNotification(thePlayer, "Locked", "The cockpit door is locked.")
			end
			cancelEvent()
		end
	end
end
addEventHandler("onVehicleStartExit", getRootElement(), exitVehicle)

function seeThroughWindows(thePlayer, nx, ny, nz) -- This is for /windows
	local dim = getElementDimension(thePlayer)
	if (getElementData(thePlayer, "isInWindow") == false or not getElementData(thePlayer, "isInWindow")) and dim > 20000 then
		outputChatBox("Viewing through windows", thePlayer)

		local id = dim - 20000
		local vehicle = exports.pool:getElement("vehicle", tonumber(id))
		local x, y, z = getElementPosition(vehicle)
		local vehdim = getElementDimension(vehicle)
		local vehint = getElementInterior(vehicle)
		local dim = getElementDimension(thePlayer)
		local int = getElementInterior(thePlayer)
		local px, py, pz = getElementPosition(thePlayer)
		setElementData(thePlayer, "isInWindow", true) -- Got to set a bunch of element data so he can return safely into normal mode
		setElementData(thePlayer, "isInWindow:vehID", id)
		setElementData(thePlayer, "isInWindow:dim", dim)
		setElementData(thePlayer, "isInWindow:int", int)
		setElementData(thePlayer, "isInWindow:x", px)
		setElementData(thePlayer, "isInWindow:y", py)
		setElementData(thePlayer, "isInWindow:z", pz)
		setElementData(thePlayer, "isInWindow:initialdim", vehdim)
		setElementData(thePlayer, "isInWindow:initialint", vehint)

		setElementInterior(thePlayer, vehint)
		setElementDimension(thePlayer, vehdim)

		setElementPosition(thePlayer, x, y, z+1)
		setElementAlpha(thePlayer, 0)
		local zoffset = 3 -- Basic offset, exceptions below
		if getVehicleModelFromName( getVehicleName( vehicle ) ) == 577 then zoffset = 8 end -- AT-400 is big!
		attachElements(thePlayer, vehicle, 0, 0, zoffset)
	elseif getElementData(thePlayer, "isInWindow") == true then -- This is if he's already in window mode
		outputChatBox("Viewing back into interior", thePlayer)
		detachElements(thePlayer)
		setElementData(thePlayer, "isInWindow", false)
		local returndim = getElementData(thePlayer, "isInWindow:dim")
		local returnint = getElementData(thePlayer, "isInWindow:int")
		local px = getElementData(thePlayer, "isInWindow:x")
		local py = getElementData(thePlayer, "isInWindow:y")
		local pz = getElementData(thePlayer, "isInWindow:z")
		setElementPosition(thePlayer, px, py, pz)
		setElementInterior(thePlayer, returnint)
		setElementDimension(thePlayer, returndim)
		setElementAlpha(thePlayer, 255)
	end
end
addEvent("seeThroughWindows", true)
addEventHandler("seeThroughWindows", getRootElement(), seeThroughWindows)

function updateView(thePlayer) -- This checks if the vehicle changed dim/int. If it did, it returns the player back into normal position so his int/dim is not fucked up. He will need to type /windows again.
	if getElementData(thePlayer, "isInWindow") == true then
		local id = getElementData(thePlayer, "isInWindow:vehID")
		local vehicle = exports.pool:getElement("vehicle", tonumber(id))
		local x, y, z = getElementPosition(vehicle)
		local dim = getElementDimension(vehicle)
		local int = getElementInterior(vehicle)

		if int ~= getElementData(thePlayer, "isInWindow:initialint") and dim ~= getElementData(thePlayer, "isInWindow:initialdim") then
			triggerEvent("seeThroughWindows", getRootElement(), thePlayer)
		end
	end
end
addEvent("updateWindowsView", true)
addEventHandler("updateWindowsView", getRootElement(), updateView)