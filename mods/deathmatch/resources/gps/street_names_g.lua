street_name_info = nil
local names =
{
	-- highways etc.
	{ { 786912, 786456, 786503, 852353, 852333, 852169 }, { 852161, 852231, 852221, 786493, 786477, 786745, 786908 }, { 786817 }, { 786818 }, { 786821 }, { 786822 }, { 786823 }, { 852347 }, { 852349 }, { 852351 }, { 852362 }, { 852363 }, { 786819 }, { 852346 }, { 852364 }, name = "Interstate 425 West - Los Santos Expressway", map_name = "Interstate 425 West" },
	{ { 852176, 852170 }, { 852162, 852168 }, name = "Interstate 425 West - Liberty Tunnel", map_name = "Interstate 425 West" },
	{ { 327793, 327781, 393270, 327794, 327797, 327773, 327791 }, name = "Interstate 425 West" },
	{ { 1310734, 1310778 }, { 1310813, 1310784 }, name = "Los Santos Tunnel" },
	{ { 2031790, 2031803, 1507786, 983294, 983316, 1507826, 1507801, 2031780 }, { 983641, 983640 }, { 1507953, 1507952 }, name = "Interstate 425 East - Red County Turnpike", map_name = "Interstate 425 East" },
	{ { 983604, 983580, 917998, 1442214 }, { 917556, 918012, 983576, 983558 }, name = "Interstate 125" },
	{ { 983517, -983356 }, name = "Interstate 125/Kennedy Ave", map_name = "Interstate 125" },
	{ { -983356, 983539 }, name = "Kennedy Ave/Interstate 125", map_name = "Interstate 125" },
	{ { 1442239, 1442240 }, name = "Interstate 125/Pasadena Blvd", map_name = "Interstate 125" },
	{ { 918129, 917961 }, name = "Washington St/Interstate 125", map_name = "Interstate 125" },
	{ { 917953, 917954 }, name = "Interstate 125/Grove St", map_name = "Interstate 125" },
	{ { 983627, 983258, 983269, 393247, 393282, 393299, 327733 }, { 327732, 393303, 393289, 393509, 983281, 983262, 983244 }, { 983614 }, { 458885 }, { 458879 }, { 393505 }, { 393601 }, { 393600 }, { 458884 }, { 458880 }, { 983635 }, { 983623, 983628 }, name = "Interstate 425 South" },
	{ { 327848, 327815, 852079, 917771, 917555 }, { 1441801, 1442287 }, { 1966135, 1966148 }, { 1966146, 1966136 }, { 1442288, 1441800 }, { 917554, 917788, 327870 }, name = "Interstate 25" },
	
	{ { -917555, -917556 }, { -1441800, -917556 }, name = "Interstate 25/125 - Central Interchange", map_name = 'Central Interchange' },
	{ { -917555, -1441801 }, { -1441800, -917554 }, name = "Interstate 25 - Central Interchange", map_name = 'Central Interchange' },
	{ { -1442214, -1441801 }, name = "Interstate 125/25 North - Central Interchange", map_name = 'Central Interchange' },
	{ { -1442214, -917554 }, name = "Interstate 125/25 South - Central Interchange", map_name = 'Central Interchange' },
	
	{ { -1442287, 1442679, 1442690, -1966135 }, { 1442613, -1966135 }, { -1442287, 1441818 }, { -1966136, 1441809, 1441806, -1442288 }, { -1966136, 1442510 }, { 1441805, -1442288 }, name = "Interstate 25 - Mulholland Intersection", map_name = 'Mulholland Intersection' },
	{ { -1441818, 1442560, 1442509, 1376730 }, { -1442510, -1442509 }, name = "Interstate 25/West Broadway - Mulholland Intersection", map_name = 'Mulholland Intersection' },
	{ { -1442510, -1442589, -1441804 }, { -1441818, -1442526 }, name = "Interstate 25/East Broadway - Mulholland Intersection", map_name = 'Mulholland Intersection' },
	{ { -1441804, 1442602 }, { 1442604 }, name = "East Broadway - Mulholland Intersection", map_name = 'Mulholland Intersection' },
	{ { -1442602, -1442613 }, { -1442602, -1441805 }, name = "East Broadway/Interstate 25 - Mulholland Intersection", map_name = 'Mulholland Intersection' },
	{ { -1376731, 1442464 }, name = "West Broadway - Mulholland Intersection", map_name = 'Mulholland Intersection' },
	{ { -1442464, -1442613 }, { -1442464, -1441805 }, name = "West Broadway/Interstate 25 - Mulholland Intersection", map_name = 'Mulholland Intersection' },
	{ { 1442350, 1442460 }, { 1442340, 1442341 }, name = "Mulholland Intersection" },

	
	{ { 786718, 1310891, 1311498, 1376621, 1376626, 1376669, 1442496 }, { 1376721, 1376845, 1376650, 1376508, 1376733, 1376609, 1311156, 1310927, 786508 }, { 786828 }, { 1311510 }, { 1311512 }, { 1311513 }, { 1376935 }, { 1376936 }, { 1311511 }, { 1376945 }, { 1376946 }, { 1376947 }, { 1376948 }, { 1376943 }, { 1376939 }, { 1376938 }, { 1376940 }, { 1376941 }, name = "West Broadway" },
	{ { 1442495, 1442075, 1507670, 1507768 }, name = "East Broadway" },

	-- Santa Maria Beach
	{ { 786752, 786761, 786777, 786792 }, name = "Beach Rd" },
	{ { 786567, 786705 }, name = "Carnival Rd" },
	{ { 852419, 852405, 786945 }, name = "Verona Beach Blvd" },
	{ { 786944, 786935 }, { 786927, 786918 }, name = "Santa Maria Blvd" },
	
	-- Rodeo
	{ { 852365, -786659, -786824, -786640, 786589, 786524, 1310900, 1310947, -1311009, -1311514, -1311010, -1376395, 1376371, 1376293 }, name = "Rodeo Drive" },
	{ { 786533, -786539, -786826, -786540, -786652, -786825, -786664, 852019 }, name = "Olympic Blvd" },
	{ { 786591, -786561, -1310907, -1311518, -1310906, 1310916 }, name = "Royal St" },
	{ { 786623, -786620, 1310978, 1310977 }, name = "Soho Drive" },
	{ { 1310981, -1310940, 1310949 }, name = "York St" },
	{ { 1311142, 1311148, 786722 }, name = "Curve St" },
	{ { 1311011, -1311052, -1311053, 786680, 786649 }, { 786661, 786668, 786686, -1311055, -1311054, 1311470 }, { 1311514 }, { 786825 }, { 786824 }, name = "Western Ave" },
	{ { 786546, 786609, 1311067, 1376817, 1376814, 1376540, -1376520, -1376914, -1376521, 1376600, 1376601, 1376408, 1442251, -1442188, 1442226, 1442183 }, { 1376584, 1376585, 1376577, -1376519, -1376913, -1376518, 1376524, 1376835, 1311091, 1310960, 786599, 786542 }, { 786826 }, { 1311518 }, { 1311517 }, { 1376908 }, { 1376907 }, { 1376900 }, { 1376899 }, { 1376898 }, { 1376910 }, { 1376909 }, { 1376912 }, { 1376298 }, { 1376299 }, name = "Pasadena Blvd" },
	
	-- Richman/Mulholland
	{ { 786802, 1311212, 1311446, 1311429 }, name = "Providence St" },
	{ { 1310732, 1311388, 1311416, 1311454, 1376446, 1900740, 1376772 }, { 1376795, 1442262 }, { 1900928, 1900926 }, name = "Rich St" },
	{ { 1311181, 1311175, 1311166 }, name = "Owl St" },
	{ { 1311201, 1311200 }, name = "Owl/Providence St" },
	{ { 1311215, -1311386, 1311120 }, name = "Belmont Drive" },
	{ { 1311117, 1835548 }, name = "Square Rd" },
	{ { 1311500, 1310854, 1311267 }, name = "Tory St" },
	{ { 1311312, 1310860, 1376503 }, name = "McCain St" },
	{ { 1376755, 1376764 }, name = "VGB Circle Drive" },
	{ { 1376897, 1900911, 1900867, 1900925 }, name = "Palin St" },
	{ { 1376877, 1376875, 1376735 }, name = "State Rd" },
	
	-- Temple
	{ { 1376389, 1376379 }, { 1376384, 852011 }, { 852380, 852371 }, name = "Giggles St" },
	{ { 1376362, 1376269 }, name = "West Vinewood Blvd" },
	{ { 1376455, 1376458 }, { 1376316, 1376313 }, { 1376382, 1376381 }, { 1376291, 852008 }, { 852391, 852198 }, name = "Liberty Ave" },
	{ { 1376351, 1376352 }, { 1376358, 1376359 }, name = "Penn St" },
	{ { 1376450, 1376336, 1442328, 1441822 }, name = "Sunset Blvd" },
	{ { 1376326, 1376325 }, { 1376342, 1376341 }, name = "Mint St" },
	{ { 1376347, 1376348 }, { 1376346, 1376343 }, name = "Vice St" },
	{ { 1376302, 1376263 }, name = "Holy Cross St" },
	{ { 1376273, 1376272 }, name = "Pawn St" },
	{ { 1376307, 1376306 }, name = "Shine St" },
	
	-- Central Los Santos/Marina
	{ { 852032, 852057, 852195, 917514, 917527 }, name = "Metropolitan Ave" },
	{ { 917533, 917534 }, name = "Church St" },
	{ { 918146, 917641, -917632, 918039, 852036 }, { 851986, 852005, 852027, 852020 }, name = "Panopticon Ave" },
	{ { 851997, 851993 }, { 852002, 1376285 }, { 1376281, 1376983 }, name = "Beverly Ave" },
	{ { 1376677, 1376676 }, { 1376694, 1376928, 1376550, 1376573, 852307, 852312 }, { 1376931 }, { 1376932 }, { 852267, 852284, 1376564, 1376558, 1376702 }, { 1376686, 1376685 }, { 1376913 }, { 1376914 }, { 1376920, 1376919 }, { 1376926 }, { 1376927 }, name = "St. Lawrence Blvd" },
	{ { 1376531, 1376532 }, name = "Light St" },
	{ { 1376262, 1376259 }, name = "Saint St" },
	{ { 1376287, 1376286 }, name = "Hell St" },
	{ { 1376256, 852001 }, name = "Benedict XVI St" },
	{ { 851978, 851979 }, name = "Pius IX St" },
	{ { 852051, 852050 }, name = "Wells St" },
	{ { 852213, 852203 }, name = "Constitution Ave" },
	{ { 917598, 917599 }, name = "Pine St" },
	{ { 917506, 917809 }, { 918067, 918070, 918049, 918052 }, name = "Police Plaza" },
	{ { 851974, 851972 }, { 852062, 917605, 917607 }, { 917541, 917542 }, { 917832, 917684, 917939, 917630, 1441946 }, { 852065 }, { 917930 }, { 917936 }, name = "San Andreas Blvd" },
	{ { 852066, 852067 }, { 852190, 1376469 }, { 1376397, 1376421 }, name = "Central Ave" },
	{ { 1376415, 1376410 }, name = "Elm St" },
	{ { 1376425, 1376424 }, name = "Eye St" },
	{ { 917544, 917546 }, name = "White St" },
	{ { 918120, 1442695 }, { 1442698, 1442697 }, { 918123, 918124 }, name = "Apple St" },
	{ { 1442229, 1442717 }, name = "Peach St" },
	{ { 918030, 918031 }, name = "Sewers Rd" },
	
	-- South Los Santos
	{ { 852087, 852403 }, name = "Erp Rd" },
	{ { 983385, 458868, 393261, 458850, 458795, 458780, 458775, 458768, 983182, 917794, 917621 }, name = "Pacific Ave" },
	{ { 917893, -917797, 983403, 983409 }, name = "John Paul St" },
	{ { 917814, 983195 }, { 983201 }, name = "High St" },
	{ { 983424, 983416 }, { 983422 }, { 983415 }, { 983423 }, name = "Tar St" },
	{ { 983643, 983633 }, { 983061, 1507625 }, { 983552, 1507911 }, { 1507910 }, { 983458, 983468, 983482 }, { 983475 }, { 983467 }, name = "Atlantica Ave" },
	{ { 983549, 983073 }, name = "Yelp St" },
	{ { 917978, 917977 }, name = "Lombard St" },
	{ { 917696, -917698, 917706 }, { 917709 }, { 917705 }, { 917715 }, { 917713 }, { 917886 }, name = "Gates St" },
	{ { 917723, 917724 }, { 918163, 458886 }, { 918168, 393598 }, { 458759 }, { 458805, 458822, 458834 }, name = "Harbor Rd" },
	{ { 458793, 458792 }, name = "Mast Rd" },
	{ { 393216, 393222, 917926, -983117, 983142, -983125, 983192 }, name = "Industrial Blvd" },
	{ { 983166, 983435 }, name = "South St" },
	{ { 983434, 983448 }, { 983447 }, name = "St. Francis St" },
	{ { 983210, 983221 }, name = "Vernon Rd" },
	{ { 983488, 983490 }, { 983426, 983425 }, { 983429 }, name = "Sun St" }, -- last two routes = Owl St on the map
	{ { 983205, 983206 }, name = "Sand St" },
	{ { 917729, 917721, 917750 }, name = "Republican Ave" },
	{ { 917807, 917718 }, { 917869 }, name = "Reagen St" },
	{ { 917873, 917883 }, { 917881 }, { 917877 }, name = "Aces St" },
	{ { 918173, 917800 }, { 917803 }, { 917801 }, name = "Glendale St" },
	{ { 327681, 852141, 917853, 393398 }, name = "Hindenburg St North" },
	{ { 393399, 393418, 327698, 327710 }, name = "Hindenburg St South" },

	-- East Los Santos
	{ { 1376434, 1441954, 1442387, 1441992, 1442044, 1442254 }, name = "East Vinewood Blvd" },
	{ { 1441794, 1441799 }, { 1441798, 1441843 }, name = "Allerton St" },
	{ { 1376980, 1442709 }, { 1442319, 1442314 }, { 1441923, 1441902 }, name = "Park Ave" },
	{ { 1442031, 1442037, 1442024 }, name = "Park Ave North" },
	{ { 1442125, 1442193, 917651, 918083, 917908, 917818 }, { 917656, 917685 }, { 917658 }, { 917821 }, { 917914 }, { 917906 }, name = "Washington St" },
	{ { 1442013, -1442011, 1442006 }, name = "Green St" },
	{ { 1441966, 1442207 }, name = "Majestic St" },
	{ { 1442208, 1507719, 1507622, 1507614 }, name = "Carson St" },
	{ { 1441890, 1441884 }, { 1441886 }, { 1441882 }, name = "St. George St" },
	{ { 1442136, -1441866, -1442261, 1441892 }, name = "Rolland St" },
	{ { 1441868, 1507464 }, { 1441871 }, { 1441867 }, { 1441875 }, { 1441881 }, { 1507717, 1507718 }, name = "Belview Rd" },
	{ { 1441949, 1507475, 1441950 }, name = "Carson Quadrant" },
	{ { 1442056, 1441910 }, name = "Hill St" },
	{ { 1442101, 1442108, 1507357, 1507385, 1507750 }, { 1507343 }, { 1507338 }, { 1507350 }, { 1507351 }, { 1507335 }, { 1507329 }, { 1507345 }, { 1507332 }, name = "San Pedro Ave" },
	{ { 1507458, 1507942 }, { 1507715, 1507710 }, name = "Howard Blvd" },
	{ { 1507659, 1507658 }, name = "Peace Rd" },
	{ { 1507628, 1507638 }, name = "Fame St" },
	{ { 1507646, 1507571, -1507500, 1507517 }, name = "Caesar Rd" },
	{ { 1507553, 1507630 }, name = "Fremont St" },
	{ { 1507581, -1507566, 1507595 }, name = "St. Catherine St" },
	{ { 1507585, 1507586 }, name = "Freedom St" },
	{ { 1507575, -1507568, 1507904 }, name = "St. Joseph St" },
	{ { 1507903, 983091 }, name = "Pilon St" },
	{ { 1507649, 1507490, 983092, 983394 }, name = "Forum St" },
	{ { 2031889, 1507732, 1507523, 983084 }, name = "Santa Monica Blvd" },
	{ { 1507525, 1507921 }, name = "Bush St" },
	{ { 1507487, 1507855 }, name = "Sea St" },
	{ { 983085, 1507491 }, name = "Free Rd" },
	{ { 983609, 983106 }, name = "St. Anthony St" },
	{ { 983495, 1507843, 1507873, 1507870, 1507864 }, { 1507884, 1507542, 1507510, 983504 }, { 983634, 1507949 }, name = "Saints Blvd" },
	{ { 1507483, 983371, 983368 }, { 983329, 983330 }, name = "Kennedy Ave" },
	{ { 983053, 983044, 983048, 983346, 917614 }, { 917668, 918024, 918154 }, { 983351 }, name = "Grove St" },
	{ { 918155, 917647 }, { 917644 }, name = "Mason St" },
	{ { 917661, 917660 }, name = "Hawk St" },
	{ { 1441860, 1507448 }, name = "Forest Rd" },
	{ { 917693, 917678, 1442170 }, { 1442174, 1442173 }, name = "Guantanamo Ave" },
	{ { 1442725, 1442732 }, name = "County General Hospital" },
	{ { 1442722, 1441934 }, name = "Health St" },
	{ { 1441905, 1442410 }, name = "St. Mary St" },
	{ { 983229, -917615, 917616 }, { 917928 }, { 983629 }, { 983228 }, { 983223 }, name = "Liverpool Rd" },

-- SAN FIERRO
	{ { 2687039, 1639218 }, name = "Saint Francis Boulevard" },
	{ { 2163103, 2163102 }, name = "Wang" },
	{ { 2162874, 2162855 }, name = "Hayes Street" },
	{ { 2162867, 2162841 }, name = "Taft Street" },
	{ { 2162861, 2162860 }, name = "Leet" },
	{ { 2163256, 1639195 }, name = "Field" },
	{ { 1638845, 1573628 }, name = "Madison Avenue" },
	{ { 2162831, 2162829 }, name = "Scott Street" },
	{ { 1572970, 1572966 }, { 1573658, 2097555 }, { 2097338, 2097237 }, name = "Bohemian Avenue" },
	{ { 2097846, 2097675 }, { 2097839, 2097669 }, { 2163034, 2097405 }, { 2162695, 2162693 }, { 2162929 , 2162928 }, name = "Washington Avenue" },
	{ { 2097520, 2097206 }, { 2097201, 2097202 }, { 2162688, 2163289 }, { 2163295, 2163297 }, name = "Leviathan Avenue" },
	{ { 1573621, 1573616 }, { 1573730, 2097393 }, { 2097389, 2097385 }, { 2097382, 2097380 }, { 2097370, 2097369 }, name = "Constitution Avenue" },
	{ { 2621535, 2097193 }, { 2097956, 2097422 }, { 2097372, 1572990 }, { 1573667, 1573668 }, { 1572887, 1638472 },  name = "Lincoln Avenue" },
	--{ { 2622046, 1573136 }, { 2622073, 2622065 }, { 2686976, 2622065 }, name = "Pacific Avenue" },
	{ { 2163012, 2163013 }, { 2163004, 2162995 }, { 2686984, 2686983 }, { 2687005, 2687007 }, { 2687196, 2686990 }, name = "Panopticon Avenue" },
	{ { 1638869, 1638882 }, { 1638962, 1639035 }, name = "Elm Street" },
	{ { 2162758, 2163303 }, { 2162762, 2162754 }, { 2162732, 2162735 }, { 2162737, 2162736 }, { 2163176, 2162987 }, name = "Harrison Avenue" },
	{ { 2162922, 2162888 }, { 2162746, 2162747 }, { 2687025, 2687026 }, { 2687019, 2687020 }, { 2687107, 2687117 }, { 2687054, 2687276 }, name = "Imperial Avenue" },
	{ { 2687045 }, { 2687537, 2687536 }, name = "Saint Anne Street" },
	{ { 2621574, 2621909 }, name = "Saint Paul Street" },
	{ { 2621960, 2621945 }, { 2621978, 2621977 }, { 2622019, 2622025 }, { 2621544, 2621543 }, { 2687082, 2687081 }, { 2687508, 2687507 }, name = "Atwater Avenue" },
	{ { 2097200, 2621607 }, { 2687419, 2621563 }, name = "San Andreas Boulevard" },
	{ { 2097197, 2097196 }, name = "Saint Mary Street" },
	{ { 2163183, 1639092 }, name = "Dock Street" },
	{ { 1639112, 1639096 }, { 1638952, 1638920 }, name = "Gravel Street" },
	{ { 1639192, 1639183 }, name = "Industrial Street" },
	{ { 2163316, 2163308 }, name = "McCormack Street" },
	{ { 2621893, 2621866 }, name = "Pleasant Drive" },
	{ { 2621503, 2621921 }, name = "Tory Street" },
	{ { 2621529, 2621505 }, { 2621984, 2097189 }, { 2097184, 2097183 }, name = "Park Street" },
	{ { 2687069, 2687068 }, name = "4th Street" },
	{ { 2687518, 2687517 }, name = "3rd Street" },
	{ { 2621547, 2621996 }, name = "2nd Street" },
	{ { 2687073, 2687072 }, name = "1st Street" },
	{ { 2097434, 2621967}, { 2621533, 2621532 }, { 2621502, 2621497 }, name = "Giggles Avenue" },
	{ { 2097447, 2097163 }, name = "Norris Street" },
	{ { 2097539, 2621525 }, { 2621480, 2621462 }, name = "Whig Street West" },
	{ { 2097216, 2097176 }, name = "Hall Street" },
	{ { 1638620, 1638404 }, { 2162777, 1638622 }, { 2162823, 2162814 }, { 2162810, 2162809 }, { 2163359, 2163350 }, { 2687085, 2687077 }, { 2687070, 2687528 }, name = "Reagan Avenue East" },
	{ { 1638403, 1638865 }, { 1572980, 1572864 }, name = "Reagan Avenue South" },
	{ { 1572867, 1573676 }, { 1573682, 2097230 }, name = "Reagan Avenue West" },
	{ { 2687116, 2687047 }, { 2687064, 2687056 }, { 2621859, 2621476 }, name = "Whig Street North" },
	{ { 2163042, 2687402 }, { 2687410, 2687337 }, { 2687325, 2687377 }, name = "Union Drive North" },
	{ { 2687397, 2163037 }, { 2687329, 2687409 }, { 2687382, 2687303 }, name = "Union Drive South" },
	
	-- Highways, Freeways, etc.
	{ { 2687436, 2621651 }, { 2687445, 2621633 }, name = "Interstate 26" },
	{ { 1638445, 1245294 }, { 1638918, 1638899 }, { 2162976, 1639070 }, name = "Interstate 89" },

	--West Broadway, Dillimore
	{ { 1835546, 1835547 }, { 1835428, 1835427 }, name = "Dillimore Road" },
	{ { 1835490, 1835524 }, { 1835704, 1835703 }, name = "Main St." },
	{ { 1835496, 1835404 }, name = "The Tie" },
	{ { 1835408, 1835519 }, name = "Cress Street" },
	{ { 1835710, 1835698 }, { 1835699, 1835691 }, {1835690, 1835718}, name = "Salem Street" },
	{ { 1835719, 1835402 }, name = "Fullum Street" },
	{ { 1835708, 1900839 }, {1900839, 1900826}, {1900815, 1900711}, name = "Mayor Street" },
	{ { 1835541, 1835425 }, {1835421, 1835558}, {1835562, 1835037}, name = "Foothill Road" },


	--ROUTES
	{ { 1835499, 1835471 }, name = "Route 4 West" }, --Dillimore
	{ { 1900846, 1900860 }, name = "Route 4 East" }, --Dillimore
	{ { 2359586, 1311240 }, name = "Route 11" }, --From LS - Blueberry/Dillimore on to Memorial Road
	{ { 1835117, 1769679 }, {1769708, 1769707}, name = "Route 48 West" }, --Blueberry
	{ { 1835117, 1835126 }, {1900555, 1835205}, {1835383, 2490845}, name = "Route 48 East" }, --Blueberry


	--RIVERSIDES
	{ { 1900709, 1966091 }, name = "Palomino River" }, --Coastside of Montgomery http://prntscr.com/htweuu
	
	
	--Blueberry
	{ { 1835036, 1835317 }, {1835358, 1835348}, name = "Third Street" },
	{ { 1835328, 1835327 }, {1835361, 2359553}, name = "Main Street" },
	{ { 1835279, 1835374 }, {1835373, 1769719}, name = "First Street" },
	{ { 1835280, 1835274 }, {1835267, 1835300}, name = "St. James' Street" },
	{ { 1835301, 1835307 }, name = "Fourth Street" },
	{ { 1835288, 1835287 }, name = "Sec./First Street" },
	{ { 1835290, 1835342 }, name = "Second Street" },


	--MONTGOMERY
	{ { 1900544, 2424877 }, {2425275, 2425274}, {2424876, 2425241}, name = "Main Street" },
	{ { 2425153, 2424873 }, name = "Pie Street" },
	{ { 2425078, 2424870 }, {2425272, 2424871}, {2425273, 2490668}, name = "Cypress Rd." },
	{ { 2425093, 2425298 }, {2425285, 2425077}, {2425071, 2425037}, name = "Holmes Rd." },
	{ { 2425280, 2425279 }, name = "Kay Street" },
	{ { 2425304, 2425313 }, name = "Holmes' Grove" },
	
	--Palomino	
	{ { 2490842, 2555917 }, name = "Palomino Road" },
	{ { 2031699, 2555910 }, name = "Pine Street" },
	{ { 2555913, 2490372 }, {2490371, 2490368}, name = "Elm Street" },
	{ { 2490369, 2555914 }, {2556271, 2556270 }, {2556243, 2556248}, name = "Cornerbrook Street" },
	{ { 2031690, 2031680 }, {2031708, 2555998 }, name = "Main Street" },
	{ { 2031689, 1966120 }, {1966121, 1966128 }, name = "Bottom Street" },
	{ { 1966129, 2031705 }, {2031696, 2031677 }, name = "Reagan Street" },
	{ { 2031678, 2556225 }, {2556233, 2556218 }, name = "Crest Drive" },
	{ { 2556257, 2556214 }, {2556228, 2031664 }, name = "Clean Drive" },
	{ { 2031670, 2556249 }, name = "Maple Street" },
	{ { 2556236, 2556301 }, name = "Maple Crest" },

	--Angel Pine	
	{ { 65769, 65724 }, name = "Angel Pine Road" },
	{ { 142, 65543 }, name = "Angel Pine Road" },
	{ { 65720, 65576 }, name = "Main Street" },
	{ { 65594, 65885 }, name = "Main Street" },
	{ { 65788, 65803 }, name = "First Street" },	
	{ { 65818, 65811 }, name = "Second Street" },	
	{ { 65583, 65582 }, name = "Third Street" },
	{ { 65852, 65863 }, name = "Third Street" },	
	{ { 65588, 65680 }, name = "Fourth Street" },
	{ { 65859, 65848 }, name = "Winter Street" },
	{ { 65835, 524333 }, name = "Winter Street" },
	{ { 65802, 65589 }, name = "Spring Street" },
	{ { 65877, 65833 }, name = "Walsh Street" },
	{ { 65842, 65841 }, name = "Walsh Street" },
	{ { 65879, 128 }, name = "Trail Road" },
	{ { 65666, 65869 }, name = "Fall Street" },
	{ { 65870, 590179 }, name = "Fall Street" },
	{ { 590178, 65864 }, name = "Fall Street" },
	{ { 65727, 65736 }, name = "Felon Road" },
	{ { 65736, 65685 }, name = "Felon Road" },
	{ { 65685, 65915 }, name = "Felon Road" },
	{ { 65915, 590229 }, name = "Felon Road" },
--END OF ANGEL PINE @ PORTSIDE 2018


--SHADY CREEK
	{ { 590230, 590278 }, name = "Forgotten Path" },
	{ { 590279, 590242 }, name = "Forgotten Path" },
	{ { 590242, 590240 }, name = "Forgotten Path" },
	{ { 131190, 131190 }, name = "Corn Path" },
	{ { 131189, 65715 }, name = "Scenic Path" },
	{ { 65714, 65706 }, name = "Scenic Path" },
	{ { 65706, 65693 }, name = "Scenic Path" },
	{ { 131191, 131202 }, name = "Scenic Path" },
	{ { 131201, 131207 }, name = "Shady Bridge" },
	{ { 131208, 131216 }, name = "Scenic Path" },
	{ { 131217, 131224 }, name = "Scenic Path" },
	{ { 131215, 196635 }, name = "Scenic Path" },
	{ { 196635, 196646 }, name = "Scenic Path" },
	{ { 196646, 196654 }, name = "Scenic Path" },
	{ { 196654, 720959 }, name = "Scenic Path" },
--END OF SHADY CREEK @ Portside 2018


--ANGEL PINE Interstate
	{ { 524290, 4 }, name = "Interstate 27 Northbound" },	
	{ { 4, 65630 }, name = "Interstate 27 Westbound" },	
	{ { 65608, 65608 }, name = "Interstate 27 Westbound" },--bugfix	
	{ { 65631, 65645 }, name = "Interstate 27 Westbound" },	
	{ { 65643, 131114 }, name = "Interstate 27 Westbound" },
	{ { 65663, 65663 }, name = "Interstate 27 Westbound" },--bugfix
	{ { 131123, 131118 }, name = "Interstate 27 Westbound" },
	{ { 131144, 131134 }, name = "Interstate 27 Eastbound" },
	{ { 131134, 65566 }, name = "Interstate 27 Eastbound" },
	{ { 65663, 65655 }, name = "Interstate 27 Eastbound" },
	{ { 65656, 65622 }, name = "Interstate 27 Eastbound" },
	{ { 65622, 30 }, name = "Interstate 27 Eastbound" },
	{ { 31, 83 }, name = "Interstate 27 Southbound" },
	{ { 83, 524611 }, name = "Interstate 27 Southbound" },
	{ { 136, 66 }, name = "Mt. Chilliad Exit Southbound, Interstate 27 McKinley Entrance" },	
	{ { 524613, 61 }, name = "Interstate 27 McKinley, Mt. Chilliad Exit Soutbound" },	
	{ { 75, 109 }, name = "Mt. Chilliad Exit, Interstate 27 McKinley Entrance Southbound" },	
	{ { 103, 524625 }, name = "Mt. Chilliad Exit, Interstate 27 McKinley Entrance Northbound" },	
	{ { 65609, 65606 }, name = "Angel Pine Exit, Interstate 27 McKinley Entrance" },
	{ { 65635, 65634 }, name = "Interstate 27 McKinley, Angel Pine Exit" },
	{ { 65620, 65621 }, name = "Interstate 27 McKinley, Angel Pine Exit" },
	{ { 65599, 65762 }, name = "Route 10, Coast-view" },
	{ { 65762, 65548 }, name = "Route 10, Coast-view" },
	{ { 65548, 146 }, name = "Route 10, Coast-view" },
	{ { 146, 15 }, name = "Route 10, Coast-view" },
	{ { 15, 46 }, name = "Route 10, Coast-view" },
	{ { 46, 49 }, name = "Route 10, Coast-view" },
	{ { 49, 201 }, name = "Route 10, Coast-view" },
--END OF ANGEL PINE INTERSTATE @ Portside 2018
}

local function setupStreetNode(value, node, currentStreetNodes, globalStreetNodes)
	table.insert(currentStreetNodes, {id = value.id, x = value.x, y = value.y})

	if triggerServerEvent and DEBUG then
		createBlip( value.x, value.y, value.z, 0, 1 )
	end

	if not value.streetname then
		value.streetname = node.name
		value.nodes = { globalStreetNodes }
	elseif value.streetname ~= node.name then
		value.streetname = value.streetname .. "/" .. node.name
		table.insert(value.nodes, globalStreetNodes)
	end
end

addEventHandler(triggerServerEvent and 'onClientResourceStart' or 'onResourceStart', resourceRoot, function ()
	local b = triggerServerEvent and DEBUG and createBlip or function() end
	local tempNameInfo = {}
	for k, node in ipairs( names ) do
		local globalStreetNodes = {}
		for _, route in ipairs( node ) do
			local currentStreetNodes = {}
			table.insert(globalStreetNodes, currentStreetNodes)

			if #route == 1 then
				local value = getNodeByID( vehicleNodes, route[1] )
				if value then
					setupStreetNode(value, node, currentStreetNodes, globalStreetNodes)
				end
			else
				for i = 1, #route - 1 do
					local path = calculatePathByNodeIDs( math.abs(route[i]), math.abs(route[i+1]) )
					for key, value in ipairs(path) do
						if value.id == -route[i] or value.id == -route[i+1] then
						else
							setupStreetNode(value, node, currentStreetNodes, globalStreetNodes)
						end
					end
				end
			end
		end

		-- generate data for the f11 map
		if triggerServerEvent then
			local name = node.map_name or node.name
			if not tempNameInfo[name] then
				tempNameInfo[name] = {globalStreetNodes }
			else
				table.insert(tempNameInfo[name], globalStreetNodes)
			end
		end
	end

	if triggerServerEvent then
		street_name_info = {}
		for name, nodes in pairs(tempNameInfo) do
			table.insert(street_name_info, { name = name, nodes = nodes })
		end
		table.sort(street_name_info, function(a, b) return b.name > a.name end)
		for k, v in ipairs(street_name_info) do
			v.num = k
		end
	end
end)
