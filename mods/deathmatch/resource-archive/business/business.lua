--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

mysql = exports.mysql

-- GLOBAL VARIABLES
local p = { }
local b = { }

function getPlayerBusinesses( player )
	return p[ player ]
end

function isPlayerInBusiness( player, business )
	if not p[ player ] then
		return false
	end
	for i, k in pairs( p[ player ] ) do
		if k == business then
			return true
		end
	end
	return false
end

function putPlayerInBusiness( player, business, rank, wage, phone, address )
	if isPlayerInBusiness( player, tonumber( business ) ) then
		return false
	end

	if not rank then rank = 'Unset Rank' end
	if not wage then wage = 0 end
	if not phone then phone = 0 end
	if not address then address = 'None' end
	local character = getElementData( player, "dbid" )
	local leader = 0
	local dateHired =  tostring( getRealTime().year + 1900 ) .. '-' .. tostring( getRealTime().month + 1 ) .. '-' .. tostring( getRealTime().monthday )

	local values = { character, business, rank, wage, phone, address, leader }
	mysql:query_free( "INSERT INTO `business_members` (`character`, `business`, `rank`, `wage`, `phone`, `address`, `leader`, `date_hired`) VALUES ('" .. table.concat( values, "','") .. "', NOW())" )
	-- mysql:insert( "business_members", { character = getElementData( player, "dbid" ), business = business, rank = rank, wage = wage, phone = phone, address = address, date_hired = dateHired, leader = 0 } )
	if not p[ player ] then
		p[ player ] = { }
	end
	table.insert( p[ player ], business )

	-- update the business cache
	if b[ tonumber( business ) ] then
		b[ tonumber( business ) ].employees = mysql:select( 'business_members', { business = business } )
	else
		loadBusiness( tonumber( business ))
	end
	return true
end

function updateEmployee( character, rank, wage, phone, address, leader )
	mysql:update( "business_members", { rank = rank, wage = wage, phone = phone, address = address, leader = leader } )
	return true
end

function setPlayerBusinessLeader( player, business, leader )
	mysql:update( "business_members", { leader = ( leader and 1 or 0 ) }, { character = getElementData( player, "dbid" ), business = tonumber( business ) } )
end

function removePlayerFromBusiness( character, business )
	mysql:delete( "business_members", { character = character, business = business } )
end

function createBusiness( player, title )

	mysql:insert( "businesses", { title = title, created_by = getElementData( player, "dbid" ) } )

	local business = mysql:insert_id()

	-- get the ATM number we'll link to the account
	local numSum = false
	while true do 
		local num1 = tostring(math.random(0,9999))
		local num2 = tostring(math.random(0,9999))
		local num3 = tostring(math.random(0,9999))
		local num4 = tostring(math.random(0,9999))
		numSum = num1.." "..num2.." "..num3.." "..num4
		--outputDebugString(numSum)
		if string.len(numSum) == 19 then
			local checkNumber = mysql:query_fetch_assoc("SELECT `card_number` FROM `atm_cards` WHERE `card_number`='"..numSum.."' ")
			if (not checkNumber or checkNumber["card_number"]==mysql_null() or checkNumber["card_number"] ~= numSum) then
				break
			end
		end
	end

	if not numSum then
		exports.hud:sendBottomNotification(player, "SQL Error", "An SQL Error CODE01 has occured in Bank System. Please report this on http://bugs.owlgaming.net")
		return false
	end

	if not exports.global:hasSpaceForItem(player, 150, 1) then
		exports.hud:sendBottomNotification(player, "Inventory", "Your inventory is full. Please clear them up and retry.")
		return false
	end

	if not exports.global:giveItem(player, 150, numSum..";"..( 0 - business )..";1") then
		exports.hud:sendBottomNotification(player, "Internal Error", "An SQL Error CODE0223 has occured in Bank System. Please report this on http://bugs.owlgaming.net.")
		return false
	end
	
	local makeNewCard = mysql:query_free("INSERT INTO `atm_cards`(`card_owner`, `card_number`, `limit_type`) VALUES ('"..tostring( 0 - business ).."', '"..numSum.."', '1') ")
	if not makeNewCard then 
		exports.hud:sendBottomNotification(player, "SQL Error", "An SQL Error CODE02 has occured in Bank System. Please report this on http://bugs.owlgaming.net.")
		return false
	end

	mysql:update( 'businesses', { bank_card = numSum }, { id = business } )


	putPlayerInBusiness( player, business )
	setPlayerBusinessLeader( player, business, true )
	return true
end

--

function loadPlayerBusinesses( player )
	local businesses = { }
	local character = getElementData( player, "dbid" )

	local query = mysql:query( 'SELECT `business` FROM `business_members` WHERE `character` = ' .. character )
	while true do
		local row = mysql:fetch_assoc( query )
		if not row then break end
		table.insert( businesses, tonumber( row.business ))
	end
	p[ player ] = businesses
end

function loadBusiness( businessID )
	local business = mysql:select_one( 'businesses', { id = businessID } )
	local employees = mysql:select( 'business_members', { business = businessID } )
	local accounts = mysql:select( 'business_accounts', { business = businessID } )
	local rentals = mysql:select( 'business_rentals', { business = businessID } )

	local banking = { }
	local bankingQuery = mysql:query( "SELECT * FROM `wiretransfers` WHERE `from_card` = '".. business.bank_card .."' OR `to_card` = '".. business.bank_card .."' " )
	while true do
		local row = mysql:fetch_assoc( bankingQuery )
		if not row then break end
		table.insert( banking, row )
	end

	local vehicles = { }
	local vehiclesQuery = mysql:query( " SELECT vehicles.id, lastUsed, plate, vehbrand, vehmodel, vehyear FROM `vehicles` LEFT JOIN `vehicles_shop` ON vehicles.vehicle_shop_id = vehicles_shop.id ")
	while true do
		local row = mysql:fetch_assoc( vehiclesQuery )
		if not row then break end
		table.insert( vehicles, row )
	end

	local properties = { }

	b[ tonumber( businessID ) ] = { id = business.id, title = business.title, bank_card = business.bank_card, created_by = business.created_by, employees = employees, accounts = accounts, rentals = rentals, banking = banking, vehicles = vehicles, properties = properties }
end

function getBusiness( business )
	if not b[ tonumber( business ) ] then
		loadBusiness( business )
	end
	return b[ tonumber( business ) ]
end

function getBusinessName( business )
	if not b[ tonumber( business ) ] then
		loadBusiness( business )
	end
	return b[ tonumber( business ) ].title
end

function outputBusiness( message, business, r, g, b )
	for _, player in pairs( getElementsByType( 'player' ) ) do
		if isPlayerInBusiness( player, tonumber( business ) ) then
			outputChatBox( message, player, r, g, b )
		end
	end
end

addEventHandler( 'account:character:spawned', root,
	function()
		loadPlayerBusinesses( source )
	end
)

addEventHandler( 'onResourceStart', resourceRoot,
	function()
		for index, player in pairs( getElementsByType( "player" ) ) do
			if getElementData( player, 'dbid' ) then
				loadPlayerBusinesses( player )
			end
		end
	end
)