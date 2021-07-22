--[[
	panel.lua
	The panel for business members to view information of their business.
	
	Author: CourtezBoi
	Since: 1/12/2015
]]
local p = { }

function showBusinessPanel ( player, command )
	local character = tonumber( getElementData( player, "dbid" ) ) -- the ID of the character who issued the command.

	if character then -- check if the player is logged in.
		local businesses = getPlayerBusinesses( player ) or { } -- fetch the businesses this player is associated with.
		if table.getn( businesses ) > 0 then
			if p [ player ] then
				triggerClientEvent( player, "business:close", player )
				p[ player ] = nil
				return
			else
				triggerClientEvent( player, "business:open", player )
				p[ player ] = true
				for _, business in pairs( businesses ) do
					local b = getBusiness( business )
					triggerClientEvent( player, "business:add", player, b.id, b.title, b.bank_card, b.created_by )

					for i, employee in pairs( b.employees ) do
						local query = mysql:query("SELECT charactername, DATEDIFF(NOW(), lastlogin) AS lastlogin FROM characters WHERE `id` ='" .. employee.character .. "' LIMIT 1")
						local row = mysql:fetch_assoc( query )
						if row then
							b.employees[ i ].charactername = row.charactername
							b.employees[ i ].lastlogin = row.lastlogin
						else
							b.employees[ i ].charactername = ''
							b.employees[ i ].lastlogin = 0
						end
						mysql:free_result( query )
					end
					triggerClientEvent( player, "business:employees", player, b.id, b.employees )
				end
			end
		else
			outputChatBox( 'You are not in any businesses.', player, 255, 100, 100 )
		end
	end
end
addCommandHandler( 'business', showBusinessPanel, false, false )

addEvent( 'business:close', true )
addEventHandler( 'business:close', root,
	function ( )
		p[ client ] = nil
	end)


addCommandHandler( 'createbusiness',
	function ( player, command, ... )
		local title = table.concat( { ... }, " " )
		if #title > 0 then
			if exports.global:takeMoney( player, 20000 ) then
				if createBusiness( player, title ) then
					outputChatBox( "You have successfully created the business '" .. title .. "'.", player, 100, 255, 100 )
				end
			else
				outputChatBox( 'You do not have $20,000 on you to start a business.', player, 255, 100, 100 )
			end
		else
			outputChatBox( 'SYNTAX: /' .. command .. ' [Business Title]', player, 255, 255, 255 )
		end
	end
)

function hireEmployee( business, name, rank, wage, phone, address )
	if putPlayerInBusiness( getPlayerFromName( name:gsub(" ", "_") ), business, rank, wage, phone, address ) then

		local id = mysql:insert_id()
		local character = getElementData( getPlayerFromName( name:gsub(" ", "_") ), "dbid")
		local employee = { id = id, character = character, business = business, rank = rank, wage = wage, phone = phone, address = address, leader = 0 }

		local query = mysql:query("SELECT charactername, DATEDIFF(NOW(), lastlogin) AS lastlogin FROM characters WHERE `id` ='" .. character .. "' LIMIT 1")
		local row = mysql:fetch_assoc( query )
		if row then
			employee.charactername = row.charactername
			employee.lastlogin = row.lastlogin
		else
			employee.charactername = ''
			employee.lastlogin = 0
		end
		mysql:free_result( query )
		triggerClientEvent( client, "business:employees", client, business, { employee } )
		outputBusiness( getPlayerName( client ):gsub("_", " ") .. ' has hired ' .. name:gsub("_", " ") .. ' for the position ' .. rank ..' ('.. getBusinessName( business ) ..').', business, 100, 255, 100 )
	end
end
addEvent('business:hireEmployee', true)
addEventHandler( 'business:hireEmployee', root, hireEmployee )

function manageEmployee( business, character, characterName, rank, wage, phone, address, leader, row )
	if updateEmpoyee( character, rank, wage, phone, address, leader ) then
		outputBusiness( getPlayerName( client ):gsub("_", " ") .. ' has updated employe ' .. characterName:gsub("_", " " ) .. ".", tonumber( business ), 100, 255, 100 )
		triggerClientEvent( client, 'business:updateEmployee', client, business, row, rank, wage, phone, address, leader )
	end
end
addEvent('business:manageEmployee', true)
addEventHandler( 'business:manageEmployee', root, manageEmployee )


function fireEmployee( character, characterName, business )
	if removePlayerFromBusiness( character, business ) then
		local player = getPlayerFromName( characterName )
		if player then -- the player is online
			outputChatBox( 'You have been removed from ' .. getBusinessName( business ) .. '.', player, 255, 100, 100 )
			loadPlayerBusinesses( player ) -- reload their businesses if they're online.
		end
		-- send a message to everyone online in the business.
		outputBusiness( characterName:gsub( '_', ' ') .. ' has been removed from ' .. getBusinessName( business ) .. ' by ' .. getPlayerName( client ):gsub( '_', ' ') .. '.', business, 255, 100, 100 )
	end
end
addEvent('business:fireEmployee', true)
addEventHandler( 'business:fireEmployee', root, fireEmployee )

