--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

carFuel = {
	-- [MODEL ID] = Tank Size{Litres},,  Kilometers/Litre
	[400] = {85},	--Landstalker  12l/100km
	[401] = {45},	--Bravura  6l/100km
	[402] = {45},	--Buffalo  8l/100km
	[403] = {60},	--Linerunner {truck},  39l/100km
	[404] = {55},	--Perenail  9l/100km
	[405] = {70},	--Sentinel  6l/100km
	[406] = {500},	--Dumper  49l/100km
	[407] = {500},	--Firetruck  25l/100km
	[408] = {400},	--Trashmaster  30l/100km
	[409] = {75},	--Stretch  15l/100km
	[410] = {45},	--Manana  6l/100km
	[411] = {45},	--Infernus  10l/100km
	[412] = {45},	--Voodoo  6l/100km
	[413] = {200},	--Pony  20l/100km
	[414] = {200},	--Mule  20l/100km
	[415] = {45},	--Cheetah  10l/100km
	[416] = {200},	--Ambulance  20l/100km
	[417] = {1000}, -- leviathan
	[418] = {75},	--Moonbeam  15l/100km
	[419] = {55},	--Esperanto  8l/100km
	[420] = {55},	--Taxi  6l/100km
	[421] = {55},	--Washington  8l/100km
	[422] = {75},	--Bobcat  12l/100km
	[423] = {200},	--Mr Whoopee  20l/100km
	[424] = {45},		--BF Injection  20l/100km
	[425] = {3000}, --Hunter
	[426] = {55},	--Premier  6l/100km
	[427] = {200},	--Enforcer  30l/100km
	[428] = {150},	--Securicar  30l/100km
	[429] = {45},	--Banshee  10l/100km
	-- 430 is a boat
	[431] = {800},	--Bus  30l/100km
	[432] = {450},	--Rhino {tank},  60l/100km
	[433] = {45},		--Hotkinfe  20l/100km
	-- 435 is a truck trailer
	[436] = {45},	--Previon  6l/100km
	[437] = {900},	--Coach 25l/100km
	[438] = {55},	--Cabbie  10l/100km
	[439] = {45},	--Stallion  9l/100km
	[440] = {100},	--Rumpo  20l/100km
	-- 441 is remore controlled car
	[442] = {75},	--Romero  15l/100km
	[443] = {500},	--Packer  25l/100km
	[444] = {75},	--Monster  25l/100km
	[445] = {55},	--Admiral  10l/100km
	-- 446 is boat
	[447] = {150}, -- Seasparrow
	[448] = {5},		--Pizza boy 2l/100km
	-- 449 is tram
	-- 450 is truck trailer
	[451] = {45},	--Turismo  10l/100km
	-- 452 is boat
	-- 453 is boat
	-- 454 is boat
	[455] = {500},	--Flatbed  25l/100km
	[456] = {200},	--Yankee  20l/100km
	-- 457 is golfcart which runs on electric engine
	[458] = {55},	--Solair  7l/100km
	[459] = {100},	--Top Fun  20l/100km
	[460] = {150}, --Skimmer
	[461] = {10},	--PCJ-600 5l/100km
	[462] = {50},	--Faggio 2l/100km
	[463] = {50},	--Freeway 3l/100km
	-- 464 is remote controlled vehicle
	-- 465 is remote controlled vehicle
	[466] = {55},	--Glendale  8l/100km
	[467] = {55},	--Oceanic  8l/100km
	[468] = {15},	--Sanchez 4l/100km
	[469] = {150}, -- Sparrow
	[470] = {75},	--Patriot  16l/100km
	[471] = {15},	--Quad 4l/100km
	-- 473 is boat
	[474] = {75},	--Hermes 8l/100km
	[475] = {55},	--Sabre 7l/100km
	[476] = {150}, --Rustler
	[477] = {45},	--ZR-350  10l/100km
	[478] = {55},		--Walton  11l/100km
	[479] = {55},	--Regina  7l/100km
	[480] = {55},	--Comet 7l/100km
	-- 481 is bycicle
	[482] = {200},	--Mule  20l/100km
	[483] = {75},	--Camper  14l/100km
	-- 484 is boat
	-- 485 Baggage according to San Andreas is Electric
	[486] = {500},	--Dozer  40l/100km
	[487] = {500},  -- Maverick 
	[488] = {200}, -- News Chopper
	[489] = {75},	--Rancher  15l/100km
	[490] = {75},	--FBI Rancher  17l/100km
	[491] = {55},	--Virgo 7l/100km
	[492] = {55},	--Greenwood  8l/100km
	-- 493 is boat
	[494] = {45}, 	--Hotring 15l/100km
	[495] = {45}, 	--Sandking 25l/100km
	[496] = {45},	--Blista Compact 6l/100km
	[497] = {300}, -- Police maverick
	[498] = {200},	--Boxville  20l/100km
	[499] = {200},	--Benson  18/100km
	[500] = {75},	--Mesa  13l/100km
	-- 501 is remote controllled vehicle
	[502] = {45}, 	--Hotring A 15l/100km
	[503] = {45}, 	--Hotring B 15l/100km
	[504] = {45}, 	--Bloodring Banger 15l/100km
	[505] = {75},	--Rancher {lure}, 15l/100km
	[506] = {45},		--Super GT  11l/100km
	[507] = {55},	--Elegant  6l/100km
	[508] = {75},	--Journey  19l/100km
	-- 509 is bycicle
	-- 510 is bycicle
	[511] = {400}, -- Beagle
	[512] = {150}, -- Cropduster
	[513] = {150}, --Stuntplane
	[514] = {500},	--Petrol {truck},  37l/100km
	[515] = {700},	--Roadtrain {truck},  42l/100km
	[516] = {55},	--Nebula  6l/100km
	[517] = {55},	--Majestic 7l/100km
	[518] = {55},	--Buccaneer 7l/100km
	[519] = {5000}, -- Shamal  is plane
	[520] = {500}, --Hydra is plane
	[521] = {10},	--FCR-900 5l/100km
	[522] = {10},	--NRG-500 5l/100km
	[523] = {10},	--HPV-1000 4l/100km
	[524] = {500},	--Cement truck  25l/100km
	[525] = {75},	--Towtruck  17l/100km
	[526] = {45},	--Fortune
	[527] = {55},	--Cadrona
	[528] = {75},	--FBI Truck
	[529] = {55},	--Williard
	[530] = {45},	--Forklift
	[531] = {90},	--Tractor
	[532] = {110},	--Combine
	[533] = {55},	--Feltzer
	[534] = {55},	--Remington
	[535] = {75},	--Slamvan
	[536] = {55},	--Blade
	-- 537 is train
	-- 538 is train
	-- 539 is boat
	[540] = {55},	--Vincet
	[541] = {45},	--Bullet
	[542] = {55},	--Clover
	[543] = {55},	--Sadler
	[544] = {200},	--Firetruck LS
	[545] = {55},	--Hustler
	[546] = {55},	--Intruder
	[547] = {55},	--Primo
	[548] = {2000}, -- Cargo bob is helicopter
	[549] = {55},	--Tampa
	[550] = {75},	--Sunrise
	[551] = {55},	--Merit
	[552] = {75},	--Utility van
	[553] = {1000}, --Nevada is plane
	[554] = {75},	--Yosemite
	[555] = {55},	--Windsor
	[556] = {75},	--Monster A
	[557] = {75},	--Monster B
	[558] = {55},	--Uranus
	[559] = {55},	--Jester
	[560] = {55},	--Sultan
	[561] = {75},	--Stratum
	[562] = {55},	--Elegy
	[563] = {500}, --Raindance is helicopter
	-- 564 is remote controlled vehicle
	[565] = {65},	--Flash
	[566] = {55},	--Tahoma
	[567] = {55},	--Savanna
	[568] = {45},	--Bandito
	-- 569 is train car
	-- 570 is train car
	[571] = {15},	--Kart
	[572] = {15},	--Mower
	[573] = {250},	--Duneride
	[574] = {75},	--Sweeper
	[575] = {55},	--Boradway
	[576] = {55},	--Tornado
	[577] = {200000},
	[578] = {300},	--DFT-30
	[579] = {75},	--Huntley
	[580] = {55},	--Stafford
	[581] = {10},	--BF-400
	[582] = {150},	--News van
	-- 583 according to game is electric
	-- 584 is truck trailer
	[585] = {55},	--Emperor
	[586] = {15},	--Wayfarer
	[587] = {45},	--Euros
	[588] = {125},	--Hotdog
	[589] = {55},	--Club
	-- 590 is train car
	-- 591 is truck trailer
	[592] = {200000},
	[593] = {200}, --Dodo is plane
	-- 593 is random thing
	-- 595 is boat
	[596] = {55},	--Police LS 
	[597] = {55},	--Police SF
	[598] = {55},	--Police LV
	[599] = {75},	--Ranger
	[600] = {55},	--Picador
	[601] = {150},	--Swat tank
	[602] = {55},	--Alpha
	[603] = {45},	--Phoenix
	[604] = {55},	--Glendale
	[605] = {55},	--Sabre
	-- 606 is trailer
	-- 607 is trailer
	-- 608 is trailer
	[609] = {200},	--},le
	-- 610 is trailer
	-- 611 is trailer
}

function getMaxFuel(id)
	if isElement(id) then
		id = getElementModel(id)
	end
	
	if not tonumber(id) then 
		return 
	end

	local id = tonumber(id)

	if carFuel[id] then
		return carFuel[id][1]
	else
		return 100
	end
end