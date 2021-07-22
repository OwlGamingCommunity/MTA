--[[--------------------------------------------------
	GUI Editor
	client
	load_gui_code.lua
	
	allows chunks of lua code to be loaded into the editor,
	parsing out the relevant gui information
--]]--------------------------------------------------


local loadCodeOverrides_prefix = 
[[
___PositionCoder___ = PositionCoder
local __loadCodeString = "local parentW, parentH = guiGetScreenSize(); local width, height = %s, %s; return %s, %s, %s, %s"


function __processPositionCode(tokens)
	if tokens and type(tokens) == "table" then
		local func, errorMessage = loadstring(string.format(__loadCodeString, tokens[3], tokens[4], tokens[1], tokens[2], tokens[3], tokens[4]))
			
		if not errorMessage then
			local ran, rX, rY, rW, rH = pcall(func)

			if ran and rX and rY and rW and rH then
				return {rX, rY}
			else
				--outputDebug("did not run in __processPositionCode: "..tostring(rX))
			end
		else
			--outputDebug("errorMessage in __processPositionCode: "..tostring(errorMessage))
		end
	else
		--outputDebug("no token in __processPositionCode")
	end
	
	return
end



guiCreateWindow__ = guiCreateWindow
function guiCreateWindow(x, y, w, h, t, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, t, r, p = y, w, h, t, r, p, _x
	end

	local e = guiCreateWindow__(x, y, w, h, t, r, p)
	
	if not e then
		outputDebug(string.format("Could not load window %s [%d, %d, %d, %d]", t, x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end

	return e
end

guiCreateButton__ = guiCreateButton
function guiCreateButton(x, y, w, h, t, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, t, r, p = y, w, h, t, r, p, _x
	end

	local e = guiCreateButton__(x, y, w, h, t, r, p)
	
	if not e then
		outputDebug(string.format("Could not load button %s [%d, %d, %d, %d]", t, x, y, w, h), "LOAD_CODE")
		return
	end	
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	return e
end


guiCreateMemo__ = guiCreateMemo
function guiCreateMemo(x, y, w, h, t, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, t, r, p = y, w, h, t, r, p, _x
	end

	local e = guiCreateMemo__(x, y, w, h, t, r, p)
	
	if not e then
		outputDebug(string.format("Could not load memo %s [%d, %d, %d, %d]", t, x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)

	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	return e
end


guiCreateLabel__ = guiCreateLabel
function guiCreateLabel(x, y, w, h, t, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, t, r, p = y, w, h, t, r, p, _x
	end
	
	local e = guiCreateLabel__(x, y, w, h, t, r, p)
	
	if not e then
		outputDebug(string.format("Could not load label %s [%d, %d, %d, %d]", t, x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	return e
end


guiCreateEdit__ = guiCreateEdit
function guiCreateEdit(x, y, w, h, t, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, t, r, p = y, w, h, t, r, p, _x
	end
	
	local e = guiCreateEdit__(x, y, w, h, t, r, p)
	
	if not e then
		outputDebug(string.format("Could not load edit %s [%d, %d, %d, %d]", t, x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)

	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	return e
end	


guiCreateCheckBox__ = guiCreateCheckBox
function guiCreateCheckBox(x, y, w, h, t, s, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, t, s, r, p = y, w, h, t, s, r, p, _x
	end
	
	local e = guiCreateCheckBox__(x, y, w, h, t, s, r, p)
	
	if not e then
		outputDebug(string.format("Could not load checkbox %s [%d, %d, %d, %d]", t, x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	return e
end


guiCreateRadioButton__ = guiCreateRadioButton
function guiCreateRadioButton(x, y, w, h, t, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, t, r, p = y, w, h, t, r, p, _x
	end
	
	local e = guiCreateRadioButton__(x, y, w, h, t, r, p)
	
	if not e then
		outputDebug(string.format("Could not load radiobutton %s [%d, %d, %d, %d]", t, x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)

	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	return e
end


guiCreateProgressBar__ = guiCreateProgressBar
function guiCreateProgressBar(x, y, w, h, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, t, r, p = y, w, h, t, r, p, _x
	end
	
	local e = guiCreateProgressBar__(x, y, w, h, r, p)
	
	if not e then
		outputDebug(string.format("Could not load progressbar [%d, %d, %d, %d]", x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)

	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	return e
end


guiCreateScrollBar__ = guiCreateScrollBar
function guiCreateScrollBar(x, y, w, h, horz, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, horz, r, p = y, w, h, horz, r, p, _x
	end
	
	local e = guiCreateScrollBar__(x, y, w, h, horz, r, p)
	
	if not e then
		outputDebug(string.format("Could not load scrollbar [%d, %d, %d, %d]", x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)

	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	return e
end


guiCreateTabPanel__ = guiCreateTabPanel
function guiCreateTabPanel(x, y, w, h, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, r, p = y, w, h, r, p, _x
	end
	
	local e = guiCreateTabPanel__(x, y, w, h, r, p)
	
	if not e then
		outputDebug(string.format("Could not load tabpanel [%d, %d, %d, %d]", x, y, w, h), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end		
	
	return e
end


guiCreateTab__ = guiCreateTab
function guiCreateTab(t, p)
	local e = guiCreateTab__(t, p)
	
	if not e then
		outputDebug(string.format("Could not load tab %s", t), "LOAD_CODE")
		return
	end
	
	setupGUIElement(e)
	
	return e
end


guiCreateScrollPane__ = guiCreateScrollPane
function guiCreateScrollPane(x, y, w, h, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, r, p = y, w, h, r, p, _x
	end
	
	local e = guiCreateScrollPane__(x, y, w, h, r, p)
	
	if not e then
		outputDebug(string.format("Could not load scrollpane [%d, %d, %d, %d]", x, y, w, h), "LOAD_CODE")
		return
	end	
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end		
	
	return e
end


guiCreateComboBox__ = guiCreateComboBox
function guiCreateComboBox(x, y, w, h, c, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, c, r, p = y, w, h, c, r, p, _x
	end
	
	local e = guiCreateComboBox__(x, y, w, h, c, r, p)
	
	if not e then
		outputDebug(string.format("Could not load combobox %s [%d, %d, %d, %d]", c, x, y, w, h), "LOAD_CODE")
		return
	end	
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end		
	
	return e
end


guiCreateStaticImage__ = guiCreateStaticImage
function guiCreateStaticImage(x, y, w, h, f, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, f, r, p = y, w, h, f, r, p, _x
	end
	
	local e = guiCreateStaticImage__(x, y, w, h, f, r, p)
	
	if not e then
		outputDebug(string.format("Could not load image %s [%d, %d, %d, %d]", f, x, y, w, h), "LOAD_CODE")
		return
	end	
	
	setElementData(e, "guieditor:imagePath", f)
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	local iW, iH = getImageSize(f)
	if iW and iH then
		setElementData(e, "guieditor:imageSize", {width = iW, height = iH})	
	end
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end			
	
	return e
end


guiCreateGridList__ = guiCreateGridList
function guiCreateGridList(x, y, w, h, r, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, r, p = y, w, h, r, p, _x
	end
	
	local e = guiCreateGridList__(x, y, w, h, r, p)
	
	if not e then
		outputDebug(string.format("Could not load gridlist [%d, %d, %d, %d]", x, y, w, h), "LOAD_CODE")
		return
	end		
	
	setupGUIElement(e)
	setElementData(e, "guieditor:relative", r)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end		
	
	return e
end


guiGridListAddColumn__ = guiGridListAddColumn
function guiGridListAddColumn(e, t, s)
	guiGridListAddColumn__(e, t, s)

	setElementData(e, "guieditor:gridlistColumnTitle."..tostring(guiGridListGetColumnCount(e)), t)
end


guiCreateFont__ = guiCreateFont
function guiCreateFont(font)
	local f = guiCreateFont__(font)
	
	local fontName = string.reverse(font)
				
	local s = fontName:find("\\", 0, true) or fontName:find("/", 0, true)
				
	if s then
		fontName = fontName:sub(0, s - 1)
	end
				
	fontName = string.reverse(fontName)

	local found = false
					
	for _,data in pairs(gCustomFonts) do
		if data.name == fontName then
			found = true
			break
		end
	end
					
	if not found then
		gCustomFonts[f] = {name = fontName, path = font}	
	end
	
	setElementData(f, "guieditor:font", font)

	return f
end


guiMemoSetReadOnly__ = guiMemoSetReadOnly
function guiMemoSetReadOnly(element, readOnly)
	guiMemoSetReadOnly__(element, readOnly)
	
	if readOnly then
		setElementData(element, "guieditor:readOnly", true)
	end
end


guiEditSetReadOnly__ = guiEditSetReadOnly
function guiEditSetReadOnly(element, readOnly)
	guiEditSetReadOnly__(element, readOnly)
	
	if readOnly then
		setElementData(element, "guieditor:readOnly", true)
	end	
end

cacheProperties__ = cacheProperties
function cacheProperties()
	return
end


dxDrawLine__ = dxDrawLine
function dxDrawLine(sx, sy, ex, ey, c, width, p, _x)
	local result, tokens

	if type(sx) == "table" then
		tokens = sx
		
		local resultStart = __processPositionCode(sx)
		local resultEnd = __processPositionCode({sx[3], sx[4], sx[1], sx[2]})
		
		if resultStart and resultEnd then
			local rSX, rSY = unpack(resultStart)
			local rEX, rEY = unpack(resultEnd)
			
			result = {math.min(rSX, rEX), math.min(rSY, rEY)}

			tokens = {
				rSX <= rEX and sx[1] or sx[3],
				rSY <= rEY and sx[2] or sx[4],
			}
		end
		
		sx, sy, ex, ey, c, width, p = sy, ex, ey, c, width, p, _x
	end
	
	local x, y, w, h = math.min(sx, ex), math.min(sy, ey), math.max(sx, ex) - math.min(sx, ex), math.max(sy, ey) - math.min(sy, ey)
	
	sx = math.round(sx)
	sy = math.round(sy)
	ex = math.round(ex)
	ey = math.round(ey)
	
	local r, g, b, a = fromcolor(c)
	local e = createGUIElementFromType("dx_line", x, y, w, h, false, nil)
	local dx = DX_Element.getDXFromElement(e)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end		

	dx:colour(r, g, b, a)
	dx.width = width or 1
	dx.postGUI_ = p == true
	dx.startX = sx
	dx.startY = sy
	dx.endX = ex
	dx.endY = ey
	
	if sx <= ex then
		if sy <= ey then
			dx.anchor = 1
		else
			dx.anchor = 3
		end
	else
		if sy <= ey then
			dx.anchor = 2
		else
			dx.anchor = 4
		end					
	end			
end


dxDrawRectangle__ = dxDrawRectangle
function dxDrawRectangle(x, y, w, h, c, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, c, p = y, w, h, c, p, _x
	end
	
	x = math.round(x)
	y = math.round(y)
	w = math.round(w)
	h = math.round(h)	
	
	local r, g, b, a = fromcolor(c)
	local e = createGUIElementFromType("dx_rectangle", x, y, w, h, false, nil)
	local dx = DX_Element.getDXFromElement(e)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end	
	
	dx:colour(r or 255, g or 255, b or 255, a or 255)
	dx.postGUI_ = p == true
end


dxDrawImage__ = dxDrawImage
function dxDrawImage(x, y, w, h, f, rot, rx, ry, c, p, _x)
	local result, tokens

	if type(x) == "table" then
		tokens = x
		result = __processPositionCode(x)
		x, y, w, h, f, rot, rx, ry, c, p = y, w, h, f, rot, rx, ry, c, p, _x
	end
	
	x = math.round(x)
	y = math.round(y)
	w = math.round(w)
	h = math.round(h)	
	
	local r, g, b, a = fromcolor(c)
	local e = createGUIElementFromType("dx_image", x, y, w, h, false, nil, f)
	local dx = DX_Element.getDXFromElement(e)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end		
	
	dx:colour(r or 255, g or 255, b or 255, a or 255)
	dx.postGUI_ = p == true
	dx.rotation_ = rot or 0
	dx.rOffsetX_ = rx or 0
	dx.rOffsetY_ = ry or 0
	dx.filepath = f
	
	local iW, iH = getImageSize(f)
	if iW and iH then
		setElementData(e, "guieditor:imageSize", {width = iW, height = iH})	
	end	
end


dxDrawText__ = dxDrawText
function dxDrawText(text, l, t, r, b, c, scale, font, ax, ay, clip, wordwrap, p, colourCoded, subpixel, _x)
	local result, tokens

	if type(text) == "table" then
		tokens = text
		result = __processPositionCode(text)
		text, l, t, r, b, c, scale, font, ax, ay, clip, wordwrap, p, colourCoded, subpixel = l, t, r, b, c, scale, font, ax, ay, clip, wordwrap, p, colourCoded, subpixel, _x
	end
	
	r = math.round(r)
	l = math.round(l)
	t = math.round(t)
	b = math.round(b)		

	local r_, g_, b_, a_ = fromcolor(c)
	local e = createGUIElementFromType("dx_text", l, t, (r or l) - l, (b or t) - t, false, nil)
	local dx = DX_Element.getDXFromElement(e)
	
	if result then
		___PositionCoder___.setPositionCode(e, tokens[1], tokens[2], result[1], result[2])
	end			
	
	if type(font) ~= "string" then
		dx.fontPath = getElementData(font, "guieditor:font")
	end

	dx:colour(r_ or 255, g_ or 255, b_ or 255, a_ or 255)
	dx.postGUI_ = p	== true
	dx.text_ = text
	dx.scale_ = scale or 1
	dx.font_ = font or "default"
	dx.alignX_ = ax or "left"
	dx.alignY_ = ay or "top"
	dx.clip_ = clip == true
	dx.wordwrap_ = wordwrap == true
	dx.colourCoded_ = colourCoded == true
	dx.subPixelPositioning = subpixel == true
end


dxCreateFont__ = dxCreateFont
function dxCreateFont(font)
	local f_ = dxCreateFont__(font)
	
	if f_ then
		guiCreateFont(font)
		
		setElementData(f_, "guieditor:font", font)
	end
	
	return f_
end



addEventHandler__ = addEventHandler
function addEventHandler(event, element, func)
	func()
end


function __loadCode()
]]


local loadCodeOverrides_suffix = 
[[

end

__loadCode()
]]


local loadCodeOverrides_cleanup =
[[
guiCreateWindow = guiCreateWindow__
guiCreateWindow__ = nil
guiCreateButton = guiCreateButton__
guiCreateButton__ = nil
guiCreateMemo = guiCreateMemo__
guiCreateMemo__ = nil
guiCreateLabel = guiCreateLabel__
guiCreateLabel__ = nil
guiCreateEdit = guiCreateEdit__
guiCreateEdit__ = nil
guiCreateCheckBox = guiCreateCheckBox__
guiCreateCheckBox__ = nil
guiCreateRadioButton = guiCreateRadioButton__
guiCreateRadioButton__ = nil
guiCreateProgressBar = guiCreateProgressBar__
guiCreateProgressBar__ = nil
guiCreateScrollBar = guiCreateScrollBar__
guiCreateScrollBar__ = nil
guiCreateTabPanel = guiCreateTabPanel__
guiCreateTabPanel__ = nil
guiCreateTab = guiCreateTab__
guiCreateTab__ = nil
guiCreateScrollPane = guiCreateScrollPane__
guiCreateScrollPane__ = nil
guiCreateComboBox = guiCreateComboBox__
guiCreateComboBox__ = nil
guiCreateStaticImage = guiCreateStaticImage__
guiCreateStaticImage__ = nil
guiCreateGridList = guiCreateGridList__
guiCreateGridList__ = nil

guiCreateFont = guiCreateFont__
guiCreateFont__ = nil
guiMemoSetReadOnly = guiMemoSetReadOnly__
guiMemoSetReadOnly__ = nil
guiEditSetReadOnly = guiEditSetReadOnly__
guiEditSetReadOnly__ = nil
guiGridListAddColumn = guiGridListAddColumn__
guiGridListAddColumn__ = nil
cacheProperties = cacheProperties__
cacheProperties__ = nil

dxDrawLine = dxDrawLine__
dxDrawLine__ = nil
dxDrawRectangle = dxDrawRectangle__
dxDrawRectangle__ = nil
dxDrawImage = dxDrawImage__
dxDrawImage__ = nil
dxDrawText = dxDrawText__
dxDrawText__ = nil
dxCreateFont = dxCreateFont__
dxCreateFont__ = nil

addEventHandler = addEventHandler__
addEventHandler__ = nil

PositionCoder = ___PositionCoder___
___PositionCoder___ = nil

__processPositionCode = nil

__loadCode = nil
]]

	
function loadGUICode(code)
	local preLoadDXCount = #DX_Element.instances
	
	code = processCode(code)

	-- wrap the code in our overwride functions
	code = loadCodeOverrides_prefix .. "\n" .. code:gsub("local ", "") .. "\n" .. loadCodeOverrides_suffix
	
	local func, errorMessage = loadstring(code)
	
	if errorMessage then
		outputDebug("loadGUICode loading error: "..errorMessage)
		return false, errorMessage
	end
	
	
	local hitFunc = false
	local variables = {}
	
	-- create a new metatable
	local tempMeta = {
		-- when a new variable is created
		__newindex = function (t, key, value)
			outputDebug("newindex: "..tostring(t)..", key: "..tostring(key)..", val: "..tostring(value), "LOAD_CODE_INTERNAL")
			
			if hitFunc then
				variables[tostring(key)] = value
			end
			
			-- this is the last thing that will happen before the variables get set
			-- (assuming no funny business in the code we are loading)
			if key == "__loadCode" then
				hitFunc = true
			end
			
			rawset(t, key, value)
			
			return 
		end,
		
		-- when an existing variable is accessed
		__index = function(t, key)
			--outputDebug("index: t: "..tostring(t)..", key: "..tostring(key))
			
			return rawget(t, key)
		end,
	}

	-- a list of internal tables that we don't want people overwriting
	local protectedTables = {
		LoadCode = LoadCode, Menu = Menu, MenuItem = MenuItem, MenuItem_Text = MenuItem_Text, MenuItem_Slider = MenuItem_Slider,
		MenuItem_Radio = MenuItem_Radio, MenuItem_Toggle = MenuItem_Toggle, DX_Checkbox = DX_Checkbox, DX_Editbox = DX_Editbox, 
		DX_Radiobutton = DX_Radiobutton, DX_Slider = DX_Slider, gMenus = gMenus, Creator = Creator, Mover = Mover, Sizer = Sizer,
		Generation = Generation, resolutionPreview = resolutionPreview, --[[PositionCoder = PositionCoder,]] UndoRedo = UndoRedo,
		colorPicker = colorPicker, Snapping = Snapping, Settings = Settings, Tutorial = Tutorial, MessageBox_Info = MessageBox_Info,
		MessageBox_InputDouble = MessageBox_InputDouble, MessageBox_Input = MessageBox_Input, MessageBox_Continue = MessageBox_Continue,
		MessageBox_Error = MessageBox_Error, MessageBox = MessageBox, Offset = Offset, Multiple = Multiple, Output = Output, 
		ContextBar = ContextBar, Properties = Properties, FontPicker = FontPicker, ImagePicker = ImagePicker, ExpandingGridList = ExpandingGridList,
		HelpWindow = HelpWindow, Share = Share
	}


	-- set all protected tables to new, empty tables (so we can catch all variable assignments)
	-- and assign our own metatable
	for name,t in pairs(protectedTables) do
		_G[name] = {}
		setmetatable(_G[name], tempMeta)
	end
	
	-- replace the global metatable with our own (temporarily)
	local meta = getmetatable(_G)
	setmetatable(_G, tempMeta)
	

	
	-- run the code
	local ran, e = pcall(func) 
	
	-- revert everything we changed
	pcall(loadstring(loadCodeOverrides_cleanup))
	
	
	-- set the metatable back to what it was before
	setmetatable(_G, meta)
	
	-- set all protected tables back to their originals
	for name,t in pairs(protectedTables) do
		_G[name] = t
	end
	
	if not ran then
		outputDebug("loadGUICode running error: "..tostring(e))
		return false, tostring(e)
	end

	-- erase the variables used in the code, and set the correct element variables (using the same naming structure)
	for a,b in pairs(variables) do
		outputDebug("vars: "..tostring(a)..", "..tostring(b), "LOAD_CODE_INTERNAL")
		
		if exists(b) then
			if not isDefaultVariable(b, a) then
				outputDebug("var: "..tostring(b)..", "..tostring(a).." ["..tostring(isDefaultVariable(b, a)).."]", "LOAD_CODE_INTERNAL")
				
				setElementVariable(b, a)
			end
		elseif type(b) == "table" then
			local t = findElements(b, "")
			
			for i,v in pairs(t) do
				outputDebug("subvar: "..tostring(i)..", "..tostring(a)..tostring(v).." ["..tostring(isDefaultVariable(i, a..v)).."]", "LOAD_CODE_INTERNAL")
				
				if exists(i) and not isDefaultVariable(i, a..v) then
					setElementVariable(i, a..v)
				end
			end
		end

		_G[a] = nil
	end
	
	processDXEffects(preLoadDXCount)

	return true
end


-- slightly modified deep copy behaviour
function findElements(t, variable)
	if type(t) ~= 'table' then 
		return t 
	end
	
	local res = {}
	
	for k,v in pairs(t) do
		if type(v) == 'table' then
			v = findElements(v, variable .. (tonumber(k) and "[" .. k .. "]" or "." .. k))
		end
		
		if exists(v) then
			res[v] = variable .. (tonumber(k) and "[" .. k .. "]" or "." .. k)
		else
			if type(v) == "table" then
				for e,n in pairs(v) do
					res[e] = n
				end
			end
		end
	end

	return res
end


--[[
local screenW, screenH = guiGetScreenSize()
w1 = guiCreateWindow((screenW - 173) / 2, (screenH - 142) / 2, 173, 142, "", false)
w2 = guiCreateWindow(1326, 129, 173, 148, "", false)
w3 = guiCreateWindow(1300, 120, 170, 140, "guiCreateWindow(11, 11, 11, 11, \"\", false)", false)


local sx,sy = guiGetScreenSize()
    dxDrawRectangle(sx - 149, sy - 145, 139.0, 125.0, tocolor(0, 0, 0, 255), false)
    dxDrawRectangle(sx - 148, sy - 143, 136.0, 122.0, tocolor(32, 168, 188, 255), false)
    dxDrawRectangle(sx - 143, sy - 137, 125.0, 111.0, tocolor(0, 0, 0, 255), false)
	
	local msPassed = 0


	dxDrawText("/"..tostring(2), sx - 69, sy - 103, sx - 17, sy - 83, tocolor(32, 168, 188, 255), 2.0, "default-bold", "left", "top", false, false, false)
	dxDrawText(msPassed, sx - 142, sy - 80, sx - 17, sy - 60, tocolor(32, 168, 188, 255), 2.0, "default-bold", "center", "top", false, false, false)	
	dxDrawText("1/10", sx - 142, sy - 55, sx - 17, sy - 31, tocolor(32, 168, 188, 255), 2.0, "default-bold", "center", "top", false, false, false)


local screenW, screenH = guiGetScreenSize()
addEventHandler("onClientRender", root,
    function()
        dxDrawLine((screenW - 109) / 2, ((screenH - 77) / 2) + 77, ((screenW - 109) / 2) + 109, (screenH - 77) / 2, tocolor(255, 255, 255, 255), 1, true)
    end
)
]]

-- this is probably slow as hell, so it should be made optional
-- it is also very unstable and will only work properly in ideal circumstances
function processCode(code)
	if not Settings.loaded.load_code_parse_calculations.value then
		return code
	end

	local matches = {
		window = "guiCreateWindow(", 
		button = "guiCreateButton(",
		label = "guiCreateLabel(",
		checkbox = "guiCreateCheckBox(",
		memo = "guiCreateMemo(",
		edit = "guiCreateEdit(",
		gridlist = "guiCreateGridList(",
		progressbar = "guiCreateProgressBar(",
		tabpanel = "guiCreateTabPanel(",
		radiobutton = "guiCreateRadioButton(",
		staticimage = "guiCreateStaticImage(",
		scrollpane = "guiCreateScrollPane(",
		scrollbar = "guiCreateScrollBar(",
		combobox = "guiCreateComboBox(",
		dxrectangle = "dxDrawRectangle(",
		dximage = "dxDrawImage(",
		dxline = "dxDrawLine(",
		dxtext = "dxDrawText(",
	}
	
	local screenStrings = {
		parentW = {"parentW", "screenW", "screenWidth", "Screen.x", "screen.X", "screen.w", "screen.width", "screenX", "sx", "parentWidth", "swidth"},
		parentH = {"parentH", "screenH", "screenHeight", "Screen.y", "screen.Y", "screen.h", "screen.height", "screenY", "sy", "parentHeight", "sheight"},
	}
	
	local selfStrings = {
		width = {" Width", " w", " x", "%(Width", "%(w", "%(x"},
		height = {" Height", " h", " y", "%(Height", "%(h", "%(y"},
	}
	
	for eType,match in pairs(matches) do
		local matchS, matchE = string.find(code, match, 0, true)
		
		while matchS and matchE and matchS ~= -1 and matchE ~= -1 do
			--outputDebug("Found match for " .. match)
			local tokens = {}
			local lastE = matchE + 1
			
			local prefix = string.sub(code, 0, matchE)
			local _, doubleCount = string.gsub(prefix, "\"", "x")
			local _, singleCount = string.gsub(prefix, "'", "x")
			
			-- if we have an odd number of string characters we must be inside a string, so ignore the match
			if doubleCount % 2 == 0 and singleCount % 2 == 0 then			
				-- get the first 4 tokens, split on ',' (which are generally x, y, w, h)
				while true do
					local ts, te = string.find(code, ',', lastE, true)
					
					if ts and te and ts ~= -1 and te ~= -1 then
						tokens[#tokens + 1] = clean(string.sub(code, lastE, ts - 1))
						lastE = te + 1
						--outputDebug("Found tokens: " .. ts .. " - " .. te .. ": '" .. tokens[#tokens] .. "'")
						if eType ~= "dxline" then
							for replace,t in pairs(selfStrings) do
								for _,m in ipairs(t) do
									tokens[#tokens] = string.gsubIgnoreCase(tokens[#tokens], m, replace)
								end
							end
						end						
						
						for replace,t in pairs(screenStrings) do
							for _,m in ipairs(t) do
								tokens[#tokens] = string.gsubIgnoreCase(tokens[#tokens], m, replace)
							end
						end

						--if string.contains(tokens[#tokens], "\"") or string.contains(tokens[#tokens], "'") then
						--	tokens = nil
						--	break
						--end
					else
						break
					end
					
					if (eType ~= "dxtext" and #tokens == 4) or (#tokens == 5) then
						break
					end
				end
				
				if tokens and #tokens >= 4 then
					if eType == "dxtext" then
						table.remove(tokens, 1)
					end	
				
					local numerical = true
					
					for k,t in ipairs(tokens) do
						if not tonumber(t) then
							numerical = false
						end
					end

					-- if they are all just regular numbers, do nothing
					if not numerical then
						if eType == "dxtext" then
						
						elseif eType ~= "dxline" then
							-- if the x position uses some calculation
							if not tonumber(tokens[1]) then
								-- replace all refences to the width value with the word 'width'
								-- width is a global set in the position code (top of this file)
								tokens[1] = string.gsub(tokens[1], "[^%d]"..tokens[3].."[^%d]", 
									function(m)
										return m:sub(1, 1) .. "width" .. m:sub(-1)
									end
								)
							end

							if not tonumber(tokens[2]) then
								tokens[2] = string.gsub(tokens[2], "[^%d]"..tokens[4].."[^%d]", 
									function(m)
										return m:sub(1, 1) .. "height" .. m:sub(-1)
									end
								)
							end
						end

						--code = string.overwrite(code, "{'" .. table.concat(tokens, "','") .. "'}," .. table.concat(tokens, ",") .. ",", matchE, lastE - 1)
						code = string.insert(code, "{'" .. table.concat(tokens, "','") .. "'},", matchE)
					end
				end
			end
			
			matchS, matchE = string.find(code, match, matchE, true)
		end
	end
	--outputDebugString(code)
	return code
end


function processDXEffects(preLoadDXCount)
	outputDebug("Pre: "..tostring(preLoadDXCount)..", Post: "..tostring(#DX_Element.instances), "TEXT_EFFECT_LOAD")
	
	local removal = {}
	
	-- if we loaded any dx
	if #DX_Element.instances > preLoadDXCount then
		-- loop backwards because shadows/outlines can only exist before their parent in the draw queue
		for i = #DX_Element.instances, (preLoadDXCount + 1), -1 do
			-- if there is anything new before this item
			if i > (preLoadDXCount + 1) then
				local dx = DX_Element.instances[i]
				
				if dx.dxType == gDXTypes.rectangle or dx.dxType == gDXTypes.text then
					local shadow, outline = {}, {}
					
					-- loop the remaining dx elements and see if any are effects for the current dx element (i)
					for k = (i - 1), (preLoadDXCount + 1), -1 do
						local other = DX_Element.instances[k]
						
						if dx:match(other) then
							-- does (other) match an effect pattern for (i)
							if dx.dxType == gDXTypes.rectangle then
								local outlineCorner = dx:isOutline(other)
								local shadowCorner = dx:isShadow(other)
								
								if outlineCorner then
									-- Group is defined in util.lua
									Group.addOrCreate(outline, outlineCorner, k)
									--outputDebug("Found ".. i .." outline: " .. k .. "(" .. outlineCorner .. ", " .. table.count(outline)..")", "TEXT_EFFECT_LOAD")
								end
								
								if shadowCorner then
									--shadow[#shadow + 1] = k
									Group.addOrCreate(shadow, shadowCorner, k)
									--outputDebug("Found ".. i .." shadow: " .. k, "TEXT_EFFECT_LOAD")
								end
							elseif dx.dxType == gDXTypes.text then
								local corner = dx:isOutline(other)
								
								if corner then
									Group.addOrCreate(outline, corner, k)
									--outputDebug("Found ".. i .." outline part: " .. k .. "[".. corner .. "]", "TEXT_EFFECT_LOAD")
								end
								
								if dx:isShadow(other) then
									shadow[#shadow + 1] = k
									--outputDebug("Found ".. i .." shadow: " .. k, "TEXT_EFFECT_LOAD")
								end							
							end
						end
					end	
					
					if #outline > 0 then
						local removed = false
						local colour = {0, 0, 0, 255}
						
						for _,id in ipairs(outline) do
							if type(id) == "number" then
								removal[id] = true
								removed = true
								colour = DX_Element.instances[id].colour_
							elseif type(id) == "table" then
								-- only remove them if we found all 4 corners, "id" is a Group type
								if id:count() == 4 then
									for _, otherID in pairs(id.items) do
										removal[otherID] = true
										removed = true
										colour = DX_Element.instances[otherID].colour_
									end
									
									--outputDebug("Found ".. i .." full outline", "TEXT_EFFECT_LOAD")
								else
									--outputDebug("Found ".. i .." partial outline: " .. id:count(), "TEXT_EFFECT_LOAD")
								end
							end
						end
						
						dx.outline_ = removed
						dx.outlineColour_ = colour
					end
					
					if #shadow > 0 then
						local removed = false
						local colour = {0, 0, 0, 255}
						
						for _,id in ipairs(shadow) do
							if type(id) == "number" then
								if not removal[id] then
									removal[id] = true
									removed = true
									colour = DX_Element.instances[id].colour_
								end
							elseif type(id) == "table" then
								-- only remove them if we found the correct 2 corners, "id" is a Group type
								if id:count() == 2 and id:contains(gDXAnchor.bottomLeft) and id:contains(gDXAnchor.bottomRight) then
									local usingValidCorners = true
									
									-- this ensures we aren't using corners that have already been flagged as part of a valid outline
									for _, otherID in pairs(id.items) do
										if removal[otherID] then
											usingValidCorners = false
											break
										end
									end	
										
									if usingValidCorners then
										for _, otherID in pairs(id.items) do
											removal[otherID] = true
											removed = true
											colour = DX_Element.instances[otherID].colour_
										end

										--outputDebug("Found ".. i .." full shadow", "TEXT_EFFECT_LOAD")
									end
								else
									--outputDebug("Found ".. i .." partial shadow", "TEXT_EFFECT_LOAD")
								end
							end
						end
	
						dx.shadow_ = removed
						dx.shadowColour_ = colour
					end
				end
			end
		end
		
		-- remove anything we have flagged as being a shadow/outline
		for i = #DX_Element.instances, (preLoadDXCount + 1), -1 do
			if removal[i] then
				local dx = DX_Element.instances[i]
				local element = dx.element
				
				dx:dxRemove(true)
				destroyElement(element)
			end
		end
	end
end


function clean(code)
	--code = code:gsub("%s+", "")
	code = string.trim(code)
	
	-- trimEnd by reversing
	code = string.reverse( string.trim(string.reverse(code)) )

	local first = code:sub(1, 1)
	
	if first == "," then
		return code:sub(2)
	end
	
	return code
end





LoadCode = {
	gui = {},
	items = {},
	fileQueue = {},
}


addEvent("guieditor:client_getOutputFiles", true)
addEventHandler("guieditor:client_getOutputFiles", root,
	function(files)
		for name,size in pairs(files) do
			LoadCode.addItem(name, size)
		end
	end
)



addEvent("guieditor:client_getOutputFile", true)
addEventHandler("guieditor:client_getOutputFile", root,
	function(filepath, purpose, chunk, chunkID, chunks, size)
		if filepath then
			if not LoadCode.fileQueue[filepath] then
				LoadCode.fileQueue[filepath] = {parts = {[chunkID] = chunk}, start = getTickCount()}
			else
				-- if all the chunks have not arrived in 5 seconds, assume they never will
				if (LoadCode.fileQueue[filepath].start + 5000) < getTickCount() then
					LoadCode.fileQueue[filepath] = {parts = {[chunkID] = chunk}, start = getTickCount()}
				else
					LoadCode.fileQueue[filepath].parts[chunkID] = chunk
				end
			end
			
			if #LoadCode.fileQueue[filepath].parts == chunks then	
				if LoadCode.gui.wndPreview and purpose == "preview" then
					guiSetText(LoadCode.gui.memPreview, table.concat(LoadCode.fileQueue[filepath].parts, ""))
					guiBringToFront(LoadCode.gui.wndPreview)
				end	

				if LoadCode.manualInput then
					LoadCode.addItem(filepath, size)
					
					LoadCode.manualInput = false
				end
				
				if purpose == "load" then
					local ran, e = loadGUICode(table.concat(LoadCode.fileQueue[filepath].parts, ""))
					
					if not ran then
						local mbox = MessageBox_Info:create("Error", "Could not properly load file\n'"..filepath.."'\n\n"..tostring(e))
					else
						ContextBar.add("Finished loading GUI code")
						guiBringToFront(LoadCode.gui.wndMain)
					end
				end
				
				LoadCode.fileQueue[filepath] = nil
			end
		else
			if LoadCode.gui.wndPreview then
				--destroyElement(LoadCode.gui.wndPreview)
				--LoadCode.gui.wndPreview = nil
				
				local mbox = MessageBox_Info:create("Not accessible", "An error occured and the file could not be opened")
			end
			
			if LoadCode.manualInput and purpose == "new" then
				local mbox = MessageBox_Info:create("Not found", "Could not find a file with the path:\n"..tostring(LoadCode.manualInput))
				
				LoadCode.manualInput = false
			end
		end
	end
)



function LoadCode.create()
	LoadCode.gui.wndMain = guiCreateWindow((gScreen.x - 420) / 2, (gScreen.y - 200) / 2, 420, 200, "Load Code", false)
	guiWindowSetSizable(LoadCode.gui.wndMain, false)
	guiWindowTitlebarButtonAdd(LoadCode.gui.wndMain, "Close", "right", LoadCode.close)
	guiWindowTitlebarButtonAdd(LoadCode.gui.wndMain, "Load by name", "left", 
		function()
			local mbox = MessageBox_Input:create(false, "Load file from filepath", "Enter the full path to the file you want to load", "Load file")
			mbox.onAccept = 
				function(text)
					if text ~= "" then
						triggerServerEvent("guieditor:server_getOutputFile", localPlayer, text, "new")
						LoadCode.manualInput = text
					end
				end
		end
	)
	
	guiWindowTitlebarButtonAdd(LoadCode.gui.wndMain, "Paste", "left", 
		function()
			if LoadCode.gui.wndPaste then
				guiSetVisible(LoadCode.gui.wndPaste, true)
				guiSetText(LoadCode.gui.memPaste, "")
				guiBringToFront(LoadCode.gui.memPaste)
				return
			end
			
			LoadCode.gui.wndPaste = guiCreateWindow((gScreen.x - 600) / 2, (gScreen.y - 400) / 2, 600, 400, "Paste Code (Ctrl + V)", false)
			guiWindowTitlebarButtonAdd(LoadCode.gui.wndPaste, "Close", "right", function() destroyElement(LoadCode.gui.wndPaste) LoadCode.gui.wndPaste = nil end)					
			guiWindowTitlebarButtonAdd(LoadCode.gui.wndPaste, "Load this code", "left", 
				function() 
					local ran, e = loadGUICode(guiGetText(LoadCode.gui.memPaste))
					
					if not ran then
						local mbox = MessageBox_Info:create("Error", "Could not properly load pasted code\n\n"..tostring(e))
					else
						ContextBar.add("Successfully loaded pasted GUI code")
						
						destroyElement(LoadCode.gui.wndPaste) 
						LoadCode.gui.wndPaste = nil
						
						guiBringToFront(LoadCode.gui.wndMain)
					end					
				end
			)	
			setElementData(LoadCode.gui.wndPaste, "guiSizeMinimum", {w = 350, h = 200})
			
			LoadCode.gui.memPaste = guiCreateMemo(10, 25, 580, 375, "", false, LoadCode.gui.wndPaste)
			setElementData(LoadCode.gui.memPaste, "guiSnapTo", {[gGUISides.left] = 10, [gGUISides.right] = 10, [gGUISides.top] = 25, [gGUISides.bottom] = 10})
						
			guiBringToFront(LoadCode.gui.memPaste)
			doOnChildren(LoadCode.gui.wndPaste, setElementData, "guieditor.internal:noLoad", true)
		end
	)	
	
	
	LoadCode.gui.scpMain = guiCreateScrollPane(10, 25, 400, 165, false, LoadCode.gui.wndMain)
	guiSetProperty(LoadCode.gui.scpMain, "ClippedByParent", "False")
	guiSetProperty(LoadCode.gui.scpMain, "ForceVertScrollbar", "True")
	
	LoadCode.gui.imgEdge = guiCreateStaticImage(5, 25, 1, 165, "images/dot_white.png", false, LoadCode.gui.wndMain)
	local r, g, b = unpack(gColours.primary)
	guiSetColour(LoadCode.gui.imgEdge, r, g, b, 150)
	
	LoadCode.gui.lblEmpty = guiCreateLabel(0, 0, 400, 165, "No files to load", false, LoadCode.gui.scpMain)
	guiSetColour(LoadCode.gui.lblEmpty, unpack(gColours.primary))
	guiLabelSetHorizontalAlign(LoadCode.gui.lblEmpty, "center")
	guiLabelSetVerticalAlign(LoadCode.gui.lblEmpty, "center")
	guiSetFont(LoadCode.gui.lblEmpty, "default-bold-small")    
	
	guiSetVisible(LoadCode.gui.wndMain, false)
	doOnChildren(LoadCode.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
end	


function LoadCode.addItem(name, size)
	if name and size then
		if guiGetVisible(LoadCode.gui.lblEmpty) then
			guiSetVisible(LoadCode.gui.lblEmpty, false)
		end
		
		local friendlySize = (tonumber(size) and size or 0) / 1024
			
		if friendlySize > 1024 then
			friendlySize = friendlySize / 1024
			friendlySize = string.format("%.2f MB", friendlySize)
		else
			friendlySize = string.format("%.2f KB", friendlySize)
		end
			
		local label = guiCreateLabel(0, #LoadCode.items * 35, 380, 35, " File: "..tostring(name).."\n Size: "..friendlySize, false, LoadCode.gui.scpMain)
		guiLabelSetVerticalAlign(label, "center")			
		setRolloverColour(label, gColours.primary, gColours.defaultLabel)
		setElementData(label, "guieditor.internal:noLoad", true)
		setElementData(label, "guieditor.internal:filePath", name)
			
		addEventHandler("onClientGUIClick", label,
			function(button, state)
				if button == "left" and state == "up" then
					triggerServerEvent("guieditor:server_getOutputFile", localPlayer, getElementData(source, "guieditor.internal:filePath"), "load")
				end
			end,
		false)			
			
		local img = guiCreateStaticImage(380 - 22, 35 - 20, 20, 20, "images/arrow_out.png", false, label)
		guiSetColour(img, 200, 200, 200, 200)
		setRolloverColour(img, {255, 255, 255, 255}, {200, 200, 200, 200})
		setElementData(img, "guieditor.internal:noLoad", true)
			
		-- add one at the top
		if #LoadCode.items == 0 then
			local divider = guiCreateStaticImage(0, 0, 380, 1, "images/dot_white.png", false, LoadCode.gui.scpMain)
			local colour = "FF453B"
			guiSetProperty(divider, "ImageColours", string.format("tl:64%s tr:00%s bl:64%s br:00%s", colour, colour, colour, colour))
			setElementData(divider, "guieditor.internal:noLoad", true)		
		end
				
		local divider = guiCreateStaticImage(0, (#LoadCode.items + 1) * 35, 380, 1, "images/dot_white.png", false, LoadCode.gui.scpMain)
		local colour = "FF453B"
		guiSetProperty(divider, "ImageColours", string.format("tl:64%s tr:00%s bl:64%s br:00%s", colour, colour, colour, colour))
		setElementData(divider, "guieditor.internal:noLoad", true)
	
		addEventHandler("onClientGUIClick", img,
			function(button, state)
				if button == "left" and state == "up" then
					if LoadCode.gui.wndPreview then
						LoadCode.manualInput = false
						triggerServerEvent("guieditor:server_getOutputFile", localPlayer, getElementData(guiGetParent(source), "guieditor.internal:filePath"), "preview")
						return
					end
						
					LoadCode.gui.wndPreview = guiCreateWindow((gScreen.x - 600) / 2, (gScreen.y - 400) / 2, 600, 400, "Preview", false)
					guiWindowTitlebarButtonAdd(LoadCode.gui.wndPreview, "Close", "right", function() destroyElement(LoadCode.gui.wndPreview) LoadCode.gui.wndPreview = nil end)
					guiWindowTitlebarButtonAdd(LoadCode.gui.wndPreview, "Copy all", "left", 
						function()
							guiSetProperty(LoadCode.gui.memPreview, "CaratIndex", 0)
							guiSetProperty(LoadCode.gui.memPreview, "SelectionLength", guiGetText(LoadCode.gui.memPreview):len())
							setClipboard(guiGetText(LoadCode.gui.memPreview))
							ContextBar.add("Code copied to clipboard")
						end
					)						
					setElementData(LoadCode.gui.wndPreview, "guiSizeMinimum", {w = 350, h = 200})
					
					LoadCode.gui.memPreview = guiCreateMemo(10, 25, 580, 375, "", false, LoadCode.gui.wndPreview)
					guiSetReadOnly(LoadCode.gui.memPreview, true)
					setElementData(LoadCode.gui.memPreview, "guiSnapTo", {[gGUISides.left] = 10, [gGUISides.right] = 10, [gGUISides.top] = 25, [gGUISides.bottom] = 10})

					LoadCode.manualInput = false
					triggerServerEvent("guieditor:server_getOutputFile", localPlayer, getElementData(guiGetParent(source), "guieditor.internal:filePath"), "preview")
						
					guiBringToFront(LoadCode.gui.wndPreview)
					doOnChildren(LoadCode.gui.wndPreview, setElementData, "guieditor.internal:noLoad", true)
				end
			end,
		false)
			
		LoadCode.items[#LoadCode.items + 1] = label
		
		
		local w = guiGetSize(LoadCode.gui.scpMain, false)
		
		if #LoadCode.items == 5 then
			guiSetSize(LoadCode.gui.wndMain, 420, 235, false)
			guiSetSize(LoadCode.gui.scpMain, w, 200, false)	
			guiSetSize(LoadCode.gui.imgEdge, 1, 200, false)
		elseif #LoadCode.items == 6 then
			guiSetSize(LoadCode.gui.wndMain, 420, 270, false)
			guiSetSize(LoadCode.gui.scpMain, w, 235, false)	
			guiSetSize(LoadCode.gui.imgEdge, 1, 235, false)			
		elseif #LoadCode.items == 7 then
			guiSetSize(LoadCode.gui.wndMain, 420, 305, false)
			guiSetSize(LoadCode.gui.scpMain, w, 270, false)		
			guiSetSize(LoadCode.gui.imgEdge, 1, 270, false)
		elseif #LoadCode.items > 7 then
			guiSetSize(LoadCode.gui.wndMain, 420, 340, false)
			guiSetSize(LoadCode.gui.scpMain, w, 305, false)	
			guiSetSize(LoadCode.gui.imgEdge, 1, 305, false)
		end
	end
end


function LoadCode.load()
	for i,v in ipairs(LoadCode.items) do
		destroyElement(v)
	end
	
	LoadCode.items = {}
	
	triggerServerEvent("guieditor:server_getOutputFiles", localPlayer)
end


function LoadCode.open()
	if not LoadCode.gui.wndMain then
		LoadCode.create()
	end
	
	if guiGetVisible(LoadCode.gui.wndMain) then
		return
	end
	
	LoadCode.load()
	guiSetVisible(LoadCode.gui.wndMain, true)
	guiBringToFront(LoadCode.gui.wndMain)
end


function LoadCode.close()
	if not LoadCode.gui.wndMain then
		return
	end
	
	guiSetVisible(LoadCode.gui.wndMain, false)
	
	if LoadCode.gui.wndPreview then
		destroyElement(LoadCode.gui.wndPreview)
		LoadCode.gui.wndPreview = nil
	end
	
	if LoadCode.gui.wndPaste then
		destroyElement(LoadCode.gui.wndPaste)
		LoadCode.gui.wndPaste = nil
	end
end