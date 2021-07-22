wBook, buttonClose, buttonPrev, buttonNext, page, cover, pgNumber, xml, pane = nil
pageNumber = 0
totalPages = 0

function createBook( bookName, bookTitle )
	
	-- Window variables
	local Width = 460
	local Height = 520
	local screenwidth, screenheight = guiGetScreenSize()
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2

	if not (wBook) then
		pageNumber = 0
		
		-- Create the window
		wBook = guiCreateWindow(X, Y, Width, Height, bookTitle, false)
		
		cover = guiCreateStaticImage ( 0.01, 0.05, 0.8, 0.95, "books/".. bookName ..".png", true, wBook ) -- display the cover image.
		
		-- Create close, previous and Next Button
		buttonPrev = guiCreateButton( 0.85, 0.25, 0.14, 0.05, "Prev", true, wBook)
		addEventHandler( "onClientGUIClick", buttonPrev, prevButtonClick, false )
		guiSetVisible(buttonPrev, false)

		buttonClose = guiCreateButton( 0.85, 0.45, 0.14, 0.05, "Close", true, wBook)
		addEventHandler( "onClientGUIClick", buttonClose, closeButtonClick, false )
		
		buttonNext = guiCreateButton( 0.85, 0.65, 0.14, 0.05, "Next", true, wBook)
		addEventHandler( "onClientGUIClick", buttonNext, nextButtonClick, false )

		showCursor(true)
		
		-- the pages
		pane = guiCreateScrollPane(0.01, 0.05, 0.8, 0.9, true, wBook)
		guiScrollPaneSetScrollBars(pane, false, true)
		page = guiCreateLabel(0.01, 0.05, 0.8, 2.0, "", true, pane) -- create the page but leave it blank.
		guiLabelSetHorizontalAlign (page, "left", true)
		pgNumber = guiCreateLabel(0.95, 0.0, 0.05, 1.0, "",true, wBook) -- page number at the bottom.
		guiSetVisible(pane, false)
		
		xml = xmlLoadFile( "/books/" .. bookName .. ".xml" ) 	-- load the xml.

		local numpagesNode = xmlFindChild(xml,"numPages", 0)	-- get the children of the root node "content". Should return the "page"..pageNumber nodes in a table.
		totalPages = tonumber(xmlNodeGetValue(numpagesNode))
	end
end
addEvent("showBook", true)
addEventHandler("showBook", getRootElement(), createBook)

--The "prev" button's function
function prevButtonClick( )
	
	pageNumber = pageNumber - 1
	
	if (pageNumber == 0) then
		guiSetVisible(buttonPrev, false)
		guiSetVisible(pane, false)
	else
		guiSetVisible(buttonPrev, true)
		guiSetVisible(pane, true)
	end
	
	if (pageNumber == totalPages) then
		guiSetVisible(buttonNext, false)
	else
		guiSetVisible(buttonNext, true)
	end
	
	if (pageNumber>0) then -- if the new page is not the cover
		
		local pageNode = xmlFindChild (xml, "page", pageNumber-1)
		local contents = xmlNodeGetValue( pageNode )
		
		guiSetText (page, contents)
		guiSetText (pgNumber, pageNumber)
	
	else -- if we are moving to the cover
		guiSetVisible(buttonNext, true)
		guiSetVisible(cover, true)
		guiSetText (page, "")
		guiSetText (pgNumber, "")
	end
end

--The "next" button's function
function nextButtonClick( )
	
	pageNumber = pageNumber + 1
	
	if (pageNumber == 0) then
		guiSetVisible(buttonPrev, false)
		guiSetVisible(pane, false)
	else
		guiSetVisible(buttonPrev, true)
		guiSetVisible(pane, true)
	end

	if (pageNumber == totalPages) then
		guiSetVisible(buttonNext, false)
	else
		guiSetVisible(buttonNext, true)
	end
	
	if (pageNumber-1==0) then -- If the last page was the cover page remove the cover image.
		guiSetVisible(cover, false)
	end

	local pageNode = xmlFindChild (xml, "page", pageNumber-1)
	local contents = xmlNodeGetValue( pageNode )
	guiSetText ( page, contents )
	guiSetText ( pgNumber, pageNumber )
end

-- The "close" button's function
function closeButtonClick( )
	pageNumber = 0
	totalPages = 0
	destroyElement ( page )
	destroyElement ( pane )
	destroyElement ( buttonClose )
	destroyElement ( buttonPrev )
	destroyElement ( buttonNext )
	destroyElement ( cover)
	destroyElement ( pgNumber )
	destroyElement ( wBook )
	buttonClose = nil
	buttonPrev = nil
	buttonNext = nil
	pane = nil
	page = nil
	cover = nil
	pgNumber = nil
	wBook = nil
	showCursor(false)
	xmlUnloadFile(xml)
	xml = nil
end

-- For player made books. //Chaos

BookGUI = {
    edit = {},
    button = {},
    window = {},
    label = {},
    memo = {}
}

function showBook(title, author, book, readOnly, slot, id)
	if isElement(BookGUI.window[1]) then 
		return
	end

	if tonumber(readOnly) == 1 then
		readOnly = true
	else
		readOnly = false
	end

    local scr = {guiGetScreenSize() }
    local w, h = 432, 505
    local x, y = (scr[1]/2)-(w/2), (scr[2]/2)-(h/2)
	showCursor(true)
	guiSetInputEnabled( true )

    BookGUI.window[1] = guiCreateWindow(x, y, w, h, "", false)
    guiWindowSetSizable(BookGUI.window[1], false)

    BookGUI.memo[1] = guiCreateMemo(9, 54, 413, 386, "Loading Data...", false, BookGUI.window[1])
    BookGUI.label[1] = guiCreateLabel(7, 25, 81, 23, "Title:", false, BookGUI.window[1])
    guiSetFont(BookGUI.label[1], "default-bold-small")
    BookGUI.label[2] = guiCreateLabel(223, 25, 62, 25, "By:", false, BookGUI.window[1])
    guiSetFont(BookGUI.label[2], "default-bold-small")
    BookGUI.edit[1] = guiCreateEdit(44, 23, 144, 23, "", false, BookGUI.window[1])
    BookGUI.edit[2] = guiCreateEdit(250, 23, 152, 23, "", false, BookGUI.window[1])
    BookGUI.button[1] = guiCreateButton(9, 475, 413, 25, "Close", false, BookGUI.window[1])
    guiSetProperty(BookGUI.button[1], "NormalTextColour", "FFAAAAAA")
    BookGUI.button[2] = guiCreateButton(10, 440, 191, 36, "Finish Book & Save", false, BookGUI.window[1])
    guiSetProperty(BookGUI.button[2], "NormalTextColour", "FFAAAAAA")
    BookGUI.button[3] = guiCreateButton(231, 440, 191, 36, "Save", false, BookGUI.window[1])
    guiSetProperty(BookGUI.button[3], "NormalTextColour", "FFAAAAAA")

    if title then
    	guiSetText(BookGUI.window[1], title.. " by "..author)
    	guiSetText(BookGUI.edit[1], title)
    	guiSetText(BookGUI.edit[2], author)
    	guiSetText(BookGUI.memo[1], book)
    	if readOnly then
    		guiSetEnabled(BookGUI.button[2], false)
    		guiSetEnabled(BookGUI.button[3], false)
    		guiSetEnabled(BookGUI.edit[1], false)
    		guiSetEnabled(BookGUI.edit[2], false)
    		guiMemoSetReadOnly(BookGUI.memo[1], true)
    	end
    else
    	guiSetText(BookGUI.memo[1], book)
    	guiSetText(BookGUI.edit[1], "ERROR")
    	guiSetText(BookGUI.edit[2], "ERROR")
    end

    addEventHandler("onClientGUIClick", BookGUI.button[1], function()
    	destroyElement(BookGUI.window[1]) 
    	showCursor(false) 
    	guiSetInputEnabled(false)
    end, false)    

    addEventHandler("onClientGUIClick", BookGUI.button[2], function()
    	if string.find(guiGetText(BookGUI.edit[1]), ":") or string.find(guiGetText(BookGUI.edit[2]), ":") then
    		guiSetText(BookGUI.window[1], "You cannot use ':' in your title or author name.")
    		return
    	end
    	triggerServerEvent("books:setData", getLocalPlayer(), id, guiGetText(BookGUI.edit[1]), guiGetText(BookGUI.edit[2]), guiGetText(BookGUI.memo[1]), true, slot)
    	destroyElement(BookGUI.window[1]) 
    	showCursor(false) 
    	guiSetInputEnabled(false)
    end, false)

    addEventHandler("onClientGUIClick", BookGUI.button[3], function()
    	if string.find(guiGetText(BookGUI.edit[1]), ":") or string.find(guiGetText(BookGUI.edit[2]), ":") or guiGetText(BookGUI.edit[1]) == "" or guiGetText(BookGUI.edit[1]) == "" then
    		guiSetText(BookGUI.window[1], "You cannot use ':' in your title or author name.")
    		return
    	end
		triggerServerEvent("books:setData", getLocalPlayer(), id, guiGetText(BookGUI.edit[1]), guiGetText(BookGUI.edit[2]), guiGetText(BookGUI.memo[1]), false, slot)
    	destroyElement(BookGUI.window[1]) 
    	showCursor(false) 
    	guiSetInputEnabled(false)
    end, false)
end
addEvent("PlayerBook", true)
addEventHandler("PlayerBook", getRootElement(), showBook)