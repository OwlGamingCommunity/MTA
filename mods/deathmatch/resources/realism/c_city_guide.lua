wGuidebook, buttonClose, buttonPrev, buttonNext, page = nil
click_count = 0

function createCityGuide( key, keyState )
	-- Window variables
	local Width = 460
	local Height = 520
	local screenwidth, screenheight = guiGetScreenSize()
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	
	if not (wGuidebook) then
		click_count = 0
		
		-- Create the window
		wGuidebook = guiCreateWindow(X, Y, Width, Height, "Los Santos City Guidebook", false)
		
		-- Create close, previous and Next Button
		buttonPrev = guiCreateButton( 0.85, 0.25, 0.14, 0.05, "Prev", true, wGuidebook)
		addEventHandler( "onClientGUIClick", buttonPrev, prevButtonClick, false )
		guiSetVisible(buttonPrev, false)
		
		buttonClose = guiCreateButton( 0.85, 0.45, 0.14, 0.05, "Close", true, wGuidebook)
		addEventHandler( "onClientGUIClick", buttonClose, closeButtonClick, false )
		
		buttonNext = guiCreateButton( 0.85, 0.65, 0.14, 0.05, "Next", true, wGuidebook)
		addEventHandler( "onClientGUIClick", buttonNext, nextButtonClick, false )
		
		showCursor(true)
		-- the image
		page = guiCreateStaticImage ( 0.01, 0.05, 0.8, 0.95, "guide/".. click_count ..".png", true, wGuidebook )
	else
		closeButtonClick()
	end
end
addEvent("showCityGuide", true)
addEventHandler("showCityGuide", getRootElement(), createCityGuide)

--The "prev" button's function
function prevButtonClick( )
	click_count = click_count - 1
	if (click_count <= 0) then
		guiSetVisible(buttonPrev, false)
	else
		guiSetVisible(buttonPrev, true)
	end
	
	if (click_count >= 8) then
		guiSetVisible(buttonNext, false)
	else
		guiSetVisible(buttonNext, true)
	end
	guiStaticImageLoadImage ( page,"guide/" .. click_count ..".png" )
end

--The "next" button's function
function nextButtonClick( )
	click_count = click_count + 1
	if (click_count <= 0) then
		guiSetVisible(buttonPrev, false)
	else
		guiSetVisible(buttonPrev, true)
	end
	
	if (click_count >= 8) then
		guiSetVisible(buttonNext, false)
	else
		guiSetVisible(buttonNext, true)
	end
	guiStaticImageLoadImage ( page,"guide/"..click_count..".png" )
	
end

-- The "close" button's function
function closeButtonClick( )
	click_count = 0
	destroyElement ( buttonClose )
	destroyElement ( buttonPrev )
	destroyElement ( buttonNext )
	destroyElement ( page)
	destroyElement ( wGuidebook )
	buttonClose = nil
	buttonPrev = nil
	buttonNext = nil
	page = nil
	wGuidebook = nil
	showCursor(false)
end