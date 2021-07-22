--[[
	@title
		Advanced Look System
	@author
		Cyanide (some way, i suppose)
		mabako
	@copyright
		2012 - Valhalla Gaming
	@description
		http://bugs.mta.vg/view.php?id=559
--]]

local advlook_window = nil
local advlook_edit_window = nil
local advlook_editvalue_window = nil
local screen_x, screen_y = guiGetScreenSize( )

function toggleMouseDependingOnWindows( )
	showCursor( ( advlook_window or advlook_edit_window or advlook_editvalue_window ) and true or false )
	guiSetInputEnabled( advlook_editvalue_window and true or false )
end

local currentLookData = {}

--
-- Look window, i.e. if you look at someone else
--
function createLookWindow( name, description, attributes, picture, editFunction )
	hideLookWindow( )

	local usePicture, pictureSmallUrl, pictureLargeUrl = false, nil, nil
	if picture then
		local url = tostring(picture)
		if verifyImageURL(url, true) then
			usePicture = true
			local index = string.find(url, ".[^.]*$")
			local exploded = {}
			exploded[1] = string.sub(url, 0, index-1)
			exploded[2] = string.sub(url, index+1)
			if string.find(exploded[1], "s", -1) then
				pictureSmallUrl = url
				pictureLargeUrl = string.sub(exploded[1], 0, -2).."."..exploded[2]
			else
				pictureSmallUrl = exploded[1].."s."..exploded[2]
				pictureLargeUrl = url
			end
		end
	end
	
	local addX = 0
	if usePicture then
		addX = 110
	end
	
	advlook_window = guiCreateWindow( 298, 168, 630+addX, 400, name, false )
	guiWindowSetSizable( advlook_window, false )

	-- Text with all info
	local label = guiCreateLabel( 8+addX, 25, 612, 230, description, false, advlook_window )
	guiSetFont( label, "clear-normal" )
	guiLabelSetHorizontalAlign( label, "left", true )
	
	-- Grid that contains masks and badges
	local grid = guiCreateGridList( 11+addX, 250, 690, 101, false, advlook_window )
	local column = guiGridListAddColumn( grid, "Objects being worn (Ex: Badges, Helmets, Ski Mask)", 0.95)
	for index, i in ipairs( attributes ) do
		local row = guiGridListAddRow( grid )
		guiGridListSetItemText( grid, row, column, i, false, false )
	end
	
	local x = ( (600+addX) - 130 ) / 2
	if editFunction then
		x = x - 140 / 2
		
		local edit = guiCreateButton( x, 360, 130, 25, "Edit", false, advlook_window )
		addEventHandler( "onClientGUIClick", edit, editFunction, false )
		
		x = x + 140
	end
	local close = guiCreateButton( x, 360, 130, 25, "Close", false, advlook_window )
	addEventHandler( "onClientGUIClick", close, function( ) hideLookWindow( ) end, false )
	
	toggleMouseDependingOnWindows( )

	if usePicture then
		local browser = guiCreateBrowser(13, 30, 90, 90, false, true, false, advlook_window)
		local theBrowser = guiGetBrowser(browser)
		addEventHandler("onClientBrowserCreated", theBrowser, 
			function()
				loadBrowserURL(source, pictureSmallUrl)
			end
		)
		addEventHandler("onClientGUIClick", browser, 
			function()
				if largePictureWindow then
					hideLargePictureWindow( )
				else
					local width, height = 500, 500
					local sw, sh = screen_x, screen_y
					local x = (sw/2)-(width/2)
					local y = (sh/2)-(height/2)
					largePictureWindow = guiCreateWindow(x, y, width, height, "Picture of "..tostring(name), false)
					local close2 = guiCreateButton((width/2)-(130/2), height-30, 130, 25, "Close", false, largePictureWindow )
					addEventHandler( "onClientGUIClick", close2, function( ) hideLargePictureWindow( ) end, false )
					local largeBrowser = guiCreateBrowser(5, 10, width-10, height-10-35, false, true, false, largePictureWindow)
					local theLargeBrowser = guiGetBrowser(largeBrowser)
					addEventHandler("onClientBrowserCreated", theLargeBrowser, 
						function()
							loadBrowserURL(source, pictureLargeUrl)
						end
					)
				end
		end, false)
		requestBrowserDomains({ "i.imgur.com" })
		addEventHandler("onClientBrowserWhitelistChange", root,
			 function(newDomains)
				 if newDomains[1] == "i.imgur.com" then
					loadBrowserURL(theBrowser, pictureSmallUrl)
					if theLargeBrowser then
						loadBrowserURL(theLargeBrowser, pictureLargeUrl)
					end
			 end
		end
		)
	end

end

function hideLargePictureWindow( )
	if largePictureWindow then
		destroyElement(largePictureWindow)
		largePictureWindow = nil
	end
end

function hideLookWindow( )
	hideLargePictureWindow( )
	if advlook_window then
		destroyElement( advlook_window )
		advlook_window = nil
		
		toggleMouseDependingOnWindows( )
	end
end

addEvent( "social:look", true )
addEventHandler( "social:look", getRootElement( ),
	function( age, race, gender, weight, height, description )
		currentLookData = {}
		currentLookData["player"] = source
		currentLookData["name"] = getPlayerName( source ):gsub( "_", " " )
		currentLookData["age"] = age
		currentLookData["race"] = race
		currentLookData["gender"] = gender
		currentLookData["weight"] = weight
		currentLookData["height"] = height
		currentLookData["description"] = description
		local editFunction = nil
		
		if source == localPlayer or exports.global:isAdminOnDuty(localPlayer) then
			editFunction = function( ) triggerEvent( "social:look:edit", localPlayer, age, race, gender, weight, height, description, description[7] ) end
		end
		local editButton = createLookWindow( currentLookData["name"],
			currentLookData["name"] .. " is a " .. ( race == 0 and "black" or race == 1 and "white" or "asian" ) .. " " .. ( gender == 1 and "female" or "male" ) ..
			" with a weight of " .. math.floor(weight * 2.2 + 0.5) .. " lb (" .. weight .. "kg)" ..
			" and a height of " .. height .. "cm.\n\n" ..
			"Hair Color: " .. description[1] .. "\n" ..
			"Hair Style: " .. description[2] .. "\n" ..
			"Facial Features: " .. description[3] .. "\n" ..
			"Physical Features: " .. description[4] .. "\n" ..
			"Clothing: " .. description[5] .. "\n" ..
			"Accessories: " .. description[6],
			description[8] or {},
			description[7],
			editFunction
		)
	end
)

--
-- Grid of properties you can edit
--

function createEditablesWindow( )
	hideEditablesWindow( )
	
	advlook_edit_window = guiCreateWindow( screen_x - 191, 172, 181, 297, "Edit Your Looks!", false )
	guiWindowSetSizable( advlook_edit_window, false )
	
	-- Grid for all editable attributes
	local grid = guiCreateGridList( 9, 23, 163, 242, false, advlook_edit_window )
	local column = guiGridListAddColumn( grid, "Properties", 0.9 )
	
	for k, v in ipairs( editables ) do
		if v.index == "height" then
			if currentLookData["age"] < 16 then
				local row = guiGridListAddRow( grid )
				guiGridListSetItemText( grid, row, column, v.name, false, false )
				guiGridListSetItemData( grid, row, column, tostring( k ), false, false )
			end
		else
			local row = guiGridListAddRow( grid )
			guiGridListSetItemText( grid, row, column, v.name, false, false )
			guiGridListSetItemData( grid, row, column, tostring( k ), false, false )
		end
	end
	addEventHandler( "onClientGUIDoubleClick", grid, selectPropertyToEdit, false )
	
	local close = guiCreateButton( 12, 266, 157, 22, "Close", false, advlook_edit_window )
	addEventHandler( "onClientGUIClick", close, function( ) hideEditablesWindow( ) end, false )
	
	toggleMouseDependingOnWindows( )
end

function hideEditablesWindow( )
	if advlook_edit_window then
		destroyElement( advlook_edit_window )
		advlook_edit_window = nil
		
		toggleMouseDependingOnWindows( )
	end
end

function setProperty( key, value )
	for k, v in ipairs( editables ) do
		if v.index == key then
			v.value = value
			return true
		end
	end
end

addEvent( "social:look:edit", true )
addEventHandler( "social:look:edit", localPlayer,
	function( age, race, gender, weight, height, description )
		currentLookData = {}
		currentLookData["player"] = source
		currentLookData["name"] = getPlayerName( source ):gsub( "_", " " )
		currentLookData["age"] = age
		currentLookData["race"] = race
		currentLookData["gender"] = gender
		currentLookData["weight"] = weight
		currentLookData["height"] = height
		currentLookData["description"] = description
		for i = 1, 7 do
			setProperty( i, description[i] )
		end
		setProperty( "weight", weight )
		setProperty( "height", height )
		createEditablesWindow( )
	end
)

--
-- editing a single property
--
function selectPropertyToEdit( )
	local row, column = guiGridListGetSelectedItem( source )
	if row ~= -1 and column ~= -1 then
		local key = tonumber( guiGridListGetItemData( source, row, column ) )
		
		createEditValueWindow( key )
	end
end

function createEditValueWindow( key )
	hideEditValuesWindow( )
	
	local stuff = editables[ key ]
	
	if stuff.index == "height" then
		if currentLookData["age"] > 16 then
			return false
		end
	end

	advlook_editvalue_window = guiCreateWindow( 349, 300, 285, 105, "Edit your Looks - " .. stuff.name, false )
	guiWindowSetSizable( advlook_editvalue_window, false )

	local addY = 0
	if stuff.instructions then
		addY = 20
		local instructions = guiCreateLabel(11, 72, 258, 16, tostring(stuff.instructions), false, advlook_editvalue_window)
		local extent = guiLabelGetTextExtent(instructions)
		if extent > 258 then
			guiSetSize(instructions, 258, 32, false)
			addY = 36
		end
		guiLabelSetHorizontalAlign(instructions, "left", true)
	end
	if addY > 0 then
		guiSetSize(advlook_editvalue_window, 285, 105+addY, false)
	end
	
	guiCreateLabel(11, 26, 258, 16, "You're now editing your " .. stuff.name .. ".", false, advlook_editvalue_window)
	
	local edit = guiCreateEdit(12, 46, 250, 22, tostring( stuff.value ),false,advlook_editvalue_window)
	
	local save = guiCreateButton(15,72+addY,123,21,"Save",false,advlook_editvalue_window)
	addEventHandler( "onClientGUIClick", save,
		function( )
			local editPlayer = false
			if localPlayer ~= currentLookData["player"] then
				if exports.global:isAdminOnDuty(localPlayer) then
					editPlayer = currentLookData["player"]
				else
					return
				end
			end

			triggerServerEvent( "social:look:update", localPlayer, stuff.index, guiGetText( edit ), editPlayer )
			stuff.value = guiGetText( edit )
			hideEditValuesWindow( )

			--update cache
			if stuff.index == "weight" or stuff.index == "height" then
				currentLookData[stuff.index] = stuff.value
			else
				currentLookData["description"][stuff.index] = stuff.value
			end

			--refresh look window      
			triggerEvent("social:look", localPlayer, currentLookData["age"], currentLookData["race"], currentLookData["gender"], currentLookData["weight"], currentLookData["height"], currentLookData["description"])
		end,
		false
	)

	guiSetEnabled( save, stuff.verify( stuff.value ) or false )
	addEventHandler( "onClientGUIChanged", edit, function( ) guiSetEnabled( save, stuff.verify( guiGetText( source ) ) or false ) end, false )
	
	local cancel = guiCreateButton(142,72+addY,123,21,"Cancel",false,advlook_editvalue_window)
	addEventHandler( "onClientGUIClick", cancel, function( ) hideEditValuesWindow( ) end, false )
	
	toggleMouseDependingOnWindows( )
end

function hideEditValuesWindow( )
	if advlook_editvalue_window then
		destroyElement( advlook_editvalue_window )
		advlook_editvalue_window = nil
		
		toggleMouseDependingOnWindows( )
	end
end