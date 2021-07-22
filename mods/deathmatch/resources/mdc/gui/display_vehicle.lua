--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )
vehW = {}
------------------------------------------
function getTime( day, month, timestamp )
	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	local days = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
	local time = nil
	local ts = nil

	if timestamp then
		time = getRealTime( timestamp )
	else
		time = getRealTime( )
	end

	ts = ( tonumber( time.hour ) >= 12 and tostring( tonumber( time.hour ) - 12 ) or time.hour ) .. ":"..("%02d"):format(time.minute)..( tonumber( time.hour ) >= 12 and " PM" or " AM" )

	if month then
		ts =  months[ time.month + 1 ] .. " ".. time.monthday .. ", " .. ts
	end

	if day then
		ts = days[ time.weekday + 1 ].. ", " .. ts
	end

	return ts
end

function getShortTime( timestamp )
	local months = { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" }
	local time = nil
	local ts = nil

	if timestamp then
		time = getRealTime( timestamp )
	else
		time = getRealTime( )
	end

	ts = time.hour .. ":"..("%02d"):format(time.minute)
	ts =  months[ time.month + 1 ] .. " ".. time.monthday .. ", " .. tostring( tonumber( time.year ) + 1900 ) .. " " .. ts

	return ts
end

function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end

local color11, color22 = nil
function color1_tocolor()
	local colors = fromJSON ( color11 )
	dxDrawRectangle ( x + 105, y + 70, 18, 18, tocolor( colors[ 1 ], colors[ 2 ], colors[ 3 ] ), true )
end
function color2_tocolor()
	local colors = fromJSON ( color22 )
	dxDrawRectangle ( x + 105, y + 90, 18, 18, tocolor( colors[ 1 ], colors[ 2 ], colors[ 3 ] ), true )
end

------------------------------------------
function display_vehicle ( id, model, color1, color2, color3, color4, plate, faction, owner, owner_type, impound, stolen, crimes )
	closeVehWin()
	togWin( mainW.window, false )
	local width = 500
	local height = 520
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	vehW.window = guiCreateWindow( x, y, width, height, "Mobile Data Computer - MDC Search - Vehicle: ".. plate, false )

	vehW.nameLabel	= guiCreateLabel( 10, 30, 180, 20, "Vehicle: ", false, vehW.window )
	vehW.plateLabel 	= guiCreateLabel( 10, 50, 180, 20, "Plate: ", false, vehW.window )
	vehW.primaryLabel	= guiCreateLabel( 10, 70, 180, 20, "Primary Color: ", false, vehW.window )
	vehW.secondLabel	= guiCreateLabel( 10, 90, 180, 20, "Secondary Color: ", false, vehW.window )
	vehW.vinLabel		= guiCreateLabel( 10, 110, 180, 20, "VIN Number: ", false, vehW.window )
	vehW.ownerLabel	= guiCreateLabel( 10, 130, 220, 20, "Owner: ", false, vehW.window )
	vehW.impoundLabel	= guiCreateLabel( 10, 150, 220, 20, "Impounded: ", false, vehW.window )
	vehW.stolenLabel	= guiCreateLabel( 10, 170, 220, 20, "Stolen: ", false, vehW.window )

	color11 = color1
	color22 = color2
	--addEventHandler( "onClientRender", root, color1_tocolor )
	--addEventHandler( "onClientRender", root, color2_tocolor )

	vehW.name2Label		= guiCreateLabel( 105, 30, 390, 20, tonumber(model) and getVehicleNameFromModel ( model ) or model, false, vehW.window )
	vehW.plate2Label		= guiCreateLabel( 105, 50, 180, 20, plate, false, vehW.window )
	vehW.vin2Label		= guiCreateLabel( 105, 110, 180, 20, id, false, vehW.window )
	if owner_type ~= 1 then
		vehW.owner2Label		= guiCreateLabel( 105, 130, 220, 20, owner:gsub( "_", " " ), false, vehW.window )
	else
		vehW.ownerButton		= guiCreateButton( 105, 130, 220, 20, owner:gsub( "_", " " ), false, vehW.window )
		addEventHandler( "onClientGUIClick", vehW.ownerButton,
			function ()
				removeEventHandler( "onClientRender", root, color1_tocolor )
				removeEventHandler( "onClientRender", root, color2_tocolor )
				guiSetInputEnabled ( false )
				guiSetVisible( vehW.window, false )
				destroyElement( vehW.window )
				window = { }
				triggerServerEvent( resourceName .. ":search", localPlayer, owner, 0 )
			end
		, false )
	end

	local impoundText = "No"
	if impound[1] ~=0 then
		if impound[2] == 1 then
			impoundText = "LSPD | Release"
		elseif impound[2] == 59 then
			impoundText = "SCoSA | Release"
		else
			impoundText = "RT"
		end
	end
	vehW.impoundButton_release	= guiCreateButton( 105, 150, 220, 20, impoundText, false, vehW.window )
	vehW.stolen2Button	= guiCreateButton( 105, 170, 220, 20, ( tonumber( stolen ) == 1 and "Yes" or "No" ), false, vehW.window )
	if impound[1] == 0 then
		guiSetEnabled(vehW.impoundButton_release, false)
	end

	addEventHandler( 'onClientGUIClick', vehW.window,
		function ()
			if source == vehW.stolen2Button then
				triggerServerEvent( 'mdc:updateVehicleStolen', localPlayer, id )
				stolen = 1 - tonumber( stolen )
				guiSetText( vehW.stolen2Button, ( tonumber( stolen ) == 1 and "Yes" or "No" ) )
			elseif source == vehW.impoundButton_release then
				local org, level, can = canAccess( localPlayer, 'impound_can_see' )
				if can and org == impound[2] then
					triggerServerEvent("tow:unimpoundedVeh", localPlayer, tonumber(id))
					closeMainW()
				else
					outputChatBox("Your account is not authorized to release this vehicle.", 255,0,0)
					exports.global:playSoundError()
				end
			end
		end
	)

	vehW.mainPanel	= guiCreateTabPanel ( 10, 190, width - 20, 270, false, vehW.window )
	vehW.crimesTab	= guiCreateTab( "Speeding Violations", vehW.mainPanel )
	vehW.crimesTable	= guiCreateGridList ( 10, 10, width - 40, 230, false, vehW.crimesTab )
	vehW.dateCol		= guiGridListAddColumn( vehW.crimesTable, "Date", 0.3 )
	vehW.speedCol		= guiGridListAddColumn( vehW.crimesTable, "Speed", 0.14 )
	vehW.locCol		= guiGridListAddColumn( vehW.crimesTable, "Location", 0.24)
	vehW.personCol	= guiGridListAddColumn( vehW.crimesTable, "Person", 0.28 )

	local function drawImpReportDetail(text)
		if text then
			if vehW.imp_reports_list and isElement(vehW.imp_reports_list) then
				guiSetVisible(vehW.imp_reports_list, false)
				if vehW.reportdetails and isElement(vehW.reportdetails) then
					destroyElement(vehW.reportdetails)
					destroyElement(vehW.back)
				end
				local btnH = 20
				vehW.reportdetails = guiCreateMemo( 10, 10, width - 40, 200, text,false, vehW.imp_reports_tab )
				vehW.back = guiCreateButton( 10, 220, width - 40, btnH, "Back" ,false, vehW.imp_reports_tab )
				addEventHandler( "onClientGUIClick", vehW.back,
					function ( )
						if source == vehW.back then
							destroyElement(vehW.reportdetails)
							destroyElement(vehW.back)
							guiSetVisible(vehW.imp_reports_list, true)
						end
					end
				, false )
			end
		end
	end

	if impound[3] and #impound[3] > 0 then
		vehW.imp_reports_tab	= guiCreateTab( "Impound reports", vehW.mainPanel )
		vehW.imp_reports_list	= guiCreateGridList ( 10, 10, width - 40, 230, false, vehW.imp_reports_tab )
		--vehW.imp_reports_list_scriptid		= guiGridListAddColumn( vehW.imp_reports_list, "#", 0.05 )
		vehW.imp_reports_list_id		= guiGridListAddColumn( vehW.imp_reports_list, "Report No.", 0.3 )
		vehW.imp_reports_list_reporter		= guiGridListAddColumn( vehW.imp_reports_list, "Reporter", 0.3 )
		vehW.imp_reports_list_date		= guiGridListAddColumn( vehW.imp_reports_list, "Date", 0.3 )

		for i, report in ipairs(impound[3]) do
			local row = guiGridListAddRow ( vehW.imp_reports_list )
			guiGridListSetItemText( vehW.imp_reports_list, row, vehW.imp_reports_list_id, report.id, false, true )
			guiGridListSetItemText( vehW.imp_reports_list, row, vehW.imp_reports_list_reporter, report.reporter, false, false )
			guiGridListSetItemText( vehW.imp_reports_list, row, vehW.imp_reports_list_date, report.date, false, false )
			--guiGridListSetItemText( vehW.imp_reports_list, row, vehW.imp_reports_list_scriptid, i, false, true )
		end
		addEventHandler( "onClientGUIDoubleClick", vehW.imp_reports_list,
			function ( )
				local selectedRow, selectedCol = guiGridListGetSelectedItem( vehW.imp_reports_list )
				selectedRow = selectedRow + 1
				if selectedRow > 0 then
					drawImpReportDetail(impound[3][selectedRow].content)
				end
			end
		, false )
	end

	if ( #crimes > 0 ) then
		for i = 1, #crimes, 1 do
			local row = guiGridListAddRow ( vehW.crimesTable )
			guiGridListSetItemText( vehW.crimesTable, row, vehW.dateCol, crimes[ i ][ 1 ], false, false )
			guiGridListSetItemText( vehW.crimesTable, row, vehW.speedCol, crimes[ i ][ 2 ], false, false )
			guiGridListSetItemText( vehW.crimesTable, row, vehW.locCol, crimes[ i ][ 3 ], false, false )
			guiGridListSetItemText( vehW.crimesTable, row, vehW.personCol, crimes[ i ][ 4 ], false, false )
		end
	else
		local row = guiGridListAddRow ( vehW.crimesTable )
		guiGridListSetItemText ( vehW.crimesTable, row, vehW.dateCol, "No Speeding Violations", false, false )
	end


	vehW.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, vehW.window )
	addEventHandler( "onClientGUIClick", vehW.closeButton,
		function ()
			closeVehWin()
			--[[
			if getElementData( localPlayer, "mdc_close_to" ) then
				triggerServerEvent( resourceName .. ":search", localPlayer, getElementData( localPlayer, "mdc_close_to" ), getElementData( localPlayer, "mdc_close_type" ) )
			else
				triggerServerEvent( resourceName .. ":main", localPlayer )
			end
			]]
		end
	, false )
end

function closeVehWin()
	if vehW.window and isElement(vehW.window) then
		--removeEventHandler( "onClientRender", root, color1_tocolor )
		--removeEventHandler( "onClientRender", root, color2_tocolor )
		--colors = {}
		guiSetInputEnabled ( false )
		guiSetVisible( vehW.window, false )
		destroyElement(vehW.window)
		togWin(mainW.window, true)
	end
end

------------------------------------------
addEvent( resourceName .. ":display_vehicle", true )
addEventHandler( resourceName .. ":display_vehicle", root, display_vehicle)
