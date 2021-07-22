function createDrawingWindow()
	local sw,sh = guiGetScreenSize()
	draw_window = guiCreateWindow((sw-512)*0.5,(sh-384)*0.5,512,384,"Drawing",false)
	guiWindowSetSizable(draw_window,false)
	button_close = guiCreateButton(352,304,96,32,"Close",false,draw_window)
	button_done = guiCreateButton(304,344,64,24,"Done",false,draw_window)
	button_clear = guiCreateButton(432,344,64,24,"Clear",false,draw_window)
	guiSetVisible(draw_window,false)
	setDefaultColors()
	brush_size = 4
	drawdest = dxCreateRenderTarget(256,256,true)
	erasedest = dxCreateRenderTarget(256,256,false)
	if not drawdest or not erasedest then return end
	black = tocolor(0,0,0,255)
	white = tocolor(255,255,255,255)
	green = tocolor(0,128,0,255)
	midblue = tocolor(0,0,192,255)
	red = tocolor(255,0,0,255)
	lime = tocolor(0,255,0,255)
	blue = tocolor(0,0,255,255)
	transparent = tocolor(255,255,255,128)
	addEventHandler("onClientGUIClick",button_close,buttonCloseDrawingWindow,false)
	addEventHandler("onClientGUIClick",button_done,buttonDoneDrawing,false)
	addEventHandler("onClientGUIClick",button_clear,buttonClearImage,false)
	brush_preview_bg = white
end

function setDefaultColors()
	local r,g,b = {},{},{}
	colors = {r = r,g = g,b = b}
	r[0x01],g[0x01],b[0x01] = 0,0,0
	r[0x02],g[0x02],b[0x02] = 255,255,255
	r[0x03],g[0x03],b[0x03] = 255,0,0
	r[0x04],g[0x04],b[0x04] = 255,255,0
	r[0x05],g[0x05],b[0x05] = 0,255,0
	r[0x06],g[0x06],b[0x06] = 0,255,255
	r[0x07],g[0x07],b[0x07] = 0,0,255
	r[0x08],g[0x08],b[0x08] = 255,0,255
	r[0x09],g[0x09],b[0x09] = 128,128,128
	r[0x0A],g[0x0A],b[0x0A] = 192,192,192
	r[0x0B],g[0x0B],b[0x0B] = 128,0,0
	r[0x0C],g[0x0C],b[0x0C] = 128,128,0
	r[0x0D],g[0x0D],b[0x0D] = 0,128,0
	r[0x0E],g[0x0E],b[0x0E] = 0,128,128
	r[0x0F],g[0x0F],b[0x0F] = 0,0,128
	r[0x10],g[0x10],b[0x10] = 128,0,128
	active_color = 1
end

function buttonCloseDrawingWindow(button,state)
	if button ~= "left" or state ~= "up" then return end
	showDrawingWindow(false)
end

function buttonClearImage(button,state)
	if button ~= "left" or state ~= "up" then return end
	addEventHandler("onClientRender",root,clearImage)
end

function clearImage()
	dxSetRenderTarget(drawdest,true)
	dxSetRenderTarget()
	removeEventHandler("onClientRender",root,clearImage)
end

function buttonDoneDrawing(button,state)
	if button ~= "left" or state ~= "up" then return end
	updateTagPNGData()
end

function updateTagPNGData()
	local current_tag = getElementData(localPlayer,"drawtag:tag")
	if not current_tag then return end
	local pixel_data = dxConvertPixels(dxGetTexturePixels(drawdest),"png")
	setElementData(current_tag,"pngdata",pixel_data)
end

function showDrawingWindow(show)
	if type(show) ~= "boolean" then return false end
	guiSetVisible(draw_window,show)
	showCursor(show)
	local toggleEventHandler = show and addEventHandler or removeEventHandler
	toggleEventHandler("onClientClick",root,clickedWindow)
	toggleEventHandler("onClientRender",root,renderDrawingWindow)
	return true
end

function isDrawingWindowVisible()
	return guiGetVisible(draw_window)
end

function renderDrawingWindow()
	local prevblend = dxGetBlendMode()
	local x,y = guiGetPosition(draw_window,false)
	drawToPicture(x+32,y+32)
	editBrush(x+320,y+48)
	renderPicture(x+32,y+32)
	renderColorList(x+68,y+312)
	renderBrushEditor(x+320,y+32)
	dxSetBlendMode(prevblend)

	local cx,cy = getCursorPosition()
	local sw,sh = guiGetScreenSize()
	cx,cy = cx*sw,cy*sh
	if drawing ~= false and cx >= x+32 and cy >= y+32 and cx < x+288 and cy < y+288 then
		local color = tocolor(colors.r[active_color],colors.g[active_color],colors.b[active_color],255)
		drawTrimmedCircle(cx,cy,brush_size,color,x+32,y+32,x+288,y+288)
	end
end

function drawToPicture(x,y)
	if not isCursorShowing() then return end
	dxSetBlendMode("modulate_add")
	local cx,cy = getCursorPosition()
	local sw,sh = guiGetScreenSize()
	cx,cy = cx*sw-x,cy*sh-y
	cx,cy = cx,cy
	if drawing then
		dxSetRenderTarget(drawdest)
		local color = tocolor(colors.r[active_color],colors.g[active_color],colors.b[active_color],255)
		dxDrawLine(px,py,cx,cy,color,brush_size*2)
		drawCircle(px,py,brush_size,color)
		drawCircle(cx,cy,brush_size,color)
		dxSetRenderTarget()
	end
	px,py = cx,cy
end

function editBrush(x,y)
	if not editingcolor and not editingsize or not isCursorShowing() then return end
	if not getKeyState("mouse1") and not getKeyState("mouse2") then stopEditingColor() return end
	local cx = getCursorPosition()
	local sw = guiGetScreenSize()
	cx = cx*sw-x
	if editingcolor then
		local new_color = cx*256/160
		if editingsnap then
			new_color = math.floor((new_color+8)/16)*16
		end
		new_color = math.min(math.max(new_color,0),255)
		editingcolor[active_color] = new_color
	elseif editingsize then
		local new_size = cx*32/160
		if editingsnap then
			new_size = math.floor(new_size+0.5)
		end
		new_size = math.min(math.max(new_size,1),32)
		brush_size = new_size
	end
end

function drawCircle(x,y,r,color)
	for yoff = math.floor(-r)+0.5,r+0.5 do
		local xoff = math.sqrt(r*r-yoff*yoff)
		dxDrawRectangle(x-xoff,y+yoff,2*xoff,1,color)
	end
end

function drawTrimmedCircle(x,y,r,color,x1,y1,x2,y2)
	local dy1,dy2 = math.max(-r,y1-y),math.min(r,y2-y-1)
	for yoff = math.floor(dy1)+0.5,dy2+0.5 do
		local xoff = math.sqrt(r*r-yoff*yoff)
		local dx1,dx2 = math.max(x-xoff,x1),math.min(x+xoff,x2)
		dxDrawRectangle(dx1,y+yoff,dx2-dx1,1,color,true)
	end
end

function renderPicture(x,y)
	dxSetBlendMode("blend")
	dxDrawRectangle(x-4,y-4,264,264,green,true)
	dxDrawImageSection(x,y,256,256,getTickCount()*0.004,0,256,256,"imgs/transparent.png",0,0,0,white,true)
	dxSetBlendMode("add")
	dxDrawImage(x,y,256,256,drawdest,0,0,0,white,true)
end

function renderColorList(x,y)
	dxSetBlendMode("blend")
	dxDrawRectangle(x-8,y-8,200,56,white,true)
	for c = 1,16 do
		local cx = x+(c-1)%8*24
		local cy = y+math.floor((c-1)/8)*24
		dxDrawRectangle(cx-3,cy-3,22,22,(c == active_color) and midblue or black,true)
		dxDrawRectangle(cx,cy,16,16,tocolor(colors.r[c],colors.g[c],colors.b[c],255),true)
	end
end

function renderBrushEditor(x,y)
	local r = colors.r[active_color]
	local g = colors.g[active_color]
	local b = colors.b[active_color]
	dxDrawImage(x,y,160,24,"imgs/red.png",0,0,0,tocolor(255,g,b,255),true)
	dxDrawImage(x,y+48,160,24,"imgs/green.png",0,0,0,tocolor(r,255,b,255),true)
	dxDrawImage(x,y+96,160,24,"imgs/blue.png",0,0,0,tocolor(r,g,255,255),true)
	dxDrawImage(x,y+144,160,24,"imgs/size.png",0,0,0,white,true)
	local rx = x+r*160/256
	local gx = x+g*160/256
	local bx = x+b*160/256
	local sx = x+brush_size*160/32
	dxDrawRectangle(rx-3,y-3,6,30,white,true)
	dxDrawRectangle(rx-2,y-2,4,28,red,true)
	dxDrawRectangle(gx-3,y+48-3,6,30,white,true)
	dxDrawRectangle(gx-2,y+48-2,4,28,lime,true)
	dxDrawRectangle(bx-3,y+96-3,6,30,white,true)
	dxDrawRectangle(bx-2,y+96-2,4,28,blue,true)
	dxDrawRectangle(sx-3,y+144-3,6,30,white,true)
	dxDrawRectangle(sx-2,y+144-2,4,28,black,true)

	dxDrawRectangle(x+32,y+180,96,80,white,true)
	dxDrawRectangle(x+36,y+184,88,72,brush_preview_bg,true)
	drawTrimmedCircle(x+80,y+220,brush_size,tocolor(r,g,b,255),x+40,y+188,x+120,y+252)
end

function clickedWindow(button,state,x,y)
	if state == "down" then
		local wx,wy = guiGetPosition(draw_window,false)
		x,y = x-wx,y-wy
		if button == "left" then
			selectColor(x,y)
			startDrawing(x,y)
		end
		if button == "left" or button == "right" then
			startEditingBrush(button,x,y)
		end
		if button == "left" then
			changeBrushPreviewBackground(x,y)
		end
	else
		if button == "left" then
			stopDrawing()
		end
	end
end

function selectColor(x,y)
	x,y = x-68,y-312
	if x < 0 or x >= 192 or y < 0 or y >= 48 then return end
	if x%24 >= 16 or y%24 >= 16 then return end
	active_color = math.floor(y/24)*8+math.floor(x/24)+1
end

function startDrawing(x,y)
	x,y = x-32,y-32
	if x < 0 or x >= 256 or y < 0 or y >= 256 then return end
	px,py = x,y
	drawing = true
end

function stopDrawing()
	drawing = nil
end

function startEditingBrush(btn,x,y)
	x,y = x-320,y-32
	if x < 0 or x >= 160 or y < 0 or y >= 192 then return end
	if y%48 >= 24 then return end
	y = math.floor(y/48)
	if y == 0 then
		editingcolor = colors.r
	elseif y == 1 then
		editingcolor = colors.g
	elseif y == 2 then
		editingcolor = colors.b
	elseif y == 3 then
		editingsize = true
	end
	editingsnap = btn == "right"
end

function stopEditingColor()
	editingcolor = nil
	editingsize = nil
	editingsnap = nil
end

function changeBrushPreviewBackground(x,y)
	x,y = x-320-36,y-32-184
	if x < 0 or x >= 88 or y < 0 or y >= 72 then return end
	brush_preview_bg = brush_preview_bg == white and black or white
end

---------------------------------------

function setEditorTexture(pngdata)
	local tex = dxCreateTexture(pngdata)
	local plaindata = dxGetTexturePixels(tex)
	destroyElement(tex)
	return dxSetTexturePixels(drawdest,plaindata)
end

