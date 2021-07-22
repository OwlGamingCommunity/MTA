dxImage = {}
dxImage_mt = { __index = dxImage }
local g_screenX,g_screenY = guiGetScreenSize()
local visibleImages = {}
local idImages = {}
local idCounter = 0
------
local defaults = {
	fX							= 0.5,
	fY							= 0.5,
	fWidth						= 0,
	fHeight						= 0,
	bRelativePosition			= true,
	bRelativeSize				= true,
	fRot						= 0,
	fRotXOff					= 0,
	fRotYOff					= 0,
	strPath						= "",
	tColor 						= {255,255,255,255},
	bPostGUI 					= false,
	bVisible 					= true,
	element 					= nil,
	pd 							= false,
	text 						= "",
	text2 						= false,
	text2lines 					= false,
	inRadar 					= false,
	hideFromRadar 				= false
}

function dxImage:getByID ( id )
	return idImages[id]
end

function setWidgetText(widget, texts)
	widgett = widget
	widget.text = texts
	visibleImages[widgett] = widget
end
function setWidgetText2(widget, texts, lines)
	widgett = widget
	widget.text2 = texts
	widget.text2lines = lines
	visibleImages[widgett] = widget
end

function setWidgetPath(widget, path)
	widgett = widget
	widget.strPath = path
	visibleImages[widgett] = widget
end

function setWidgetHideFromRadar(widget, state)
	widgett = widget
	widget.hideFromRadar = state
	visibleImages[widgett] = widget
end

function setWidgetIsInRadar(widget, blipIn)
	widgett = widget
	widget.inRadar = blipIn
	visibleImages[widgett] = widget
end

function dxImage:create( path, x, y, width, height, relative, pd, element, text )
	assert(not self.fX, "attempt to call method 'create' (a nil value)")
	if ( type(path) ~= "string" ) or ( not tonumber(x) ) or ( not tonumber(y) ) then
		outputDebugString ( "dxImage:create - Bad argument", 0, 112, 112, 112 )
		return false
	end
    local new = {}
	setmetatable( new, dxImage_mt )
	--Add default settings
	for i,v in pairs(defaults) do
		new[i] = v
	end
	new.fX = x or new.fX
	new.fY = y or new.fY
	new.strPath = path
	new.fWidth = width or new.fWidth
	new.fHeight = height or new.fHeight
	new.pd = pd or new.pd
	new.element = element or new.element
	new.text = text or new.text
	new.inRadar = false
	new.hideFromRadar = false
	idCounter = idCounter + 1
	idImages[idCounter] = new
	new.id = idCounter
	if type(relative) == "boolean" then
		new.bRelativePosition = relative
		new.bRelativeSize = relative
	end
	visibleImages[new] = true
	return new
end

function dxImage:path(path)
	if type(path) ~= "string" then return self.strPath end
	self.strPath = path
	return true
end

function dxImage:position(x,y,relative)
	if not tonumber(x) then return self.fX, self.fY end
	self.fX = x
	self.fY = y
	if type(relative) == "boolean" then
		self.bRelativePosition = relative
	else
		self.bRelativePosition = true
	end
	return true
end

function dxImage:size(x,y,relative)
	if not tonumber(x) then return self.fWidth, self.fHeight end
	self.fWidth = x
	self.fHeight = y
	if type(relative) == "boolean" then
		self.bRelativeSize = relative
	else
		self.bRelativeSize = true
	end
	return true
end

function dxImage:color(r,g,b,a)
	if not tonumber(r) then return unpack(self.tColor) end
	g = g or self.tColor[2]
	b = b or self.tColor[3]
	a = a or self.tColor[4]
	self.tColor = { r,g,b,a }
	return true
end

function dxImage:rotation(rot,xoff,yoff)
	if not tonumber(rot) then return self.fRot,self.fRotXOff,self.fRotYOff end
	self.fRot = rot or self.fRot
	self.fRotXOff = xoff or self.fRotXOff
	self.fRotYOff = yoff or self.fRotYOff
	return true
end

function dxImage:visible(bool)
	if type(bool) ~= "boolean" then return self.bVisible end
	self.bVisible = bool
	if bool then
		visibleImages[self] = true
	else
		visibleImages[self] = nil
	end
	return true
end

function dxImage:destroy()
	self.bDestroyed = true
	setmetatable( self, self )
	idImages[self.id] = nil
	return true
end

function dxImage:postGUI(bool)
	if type(bool) ~= "boolean" then return self.bPostGUI end
	self.bPostGUI = bool
	return true
end

addEventHandler ( "onClientRender", getRootElement(),
	function()
		for self,_ in pairs(visibleImages) do
			while true do
				if self.bDestroyed then
					visibleImages[self] = nil
					break
				end
				local x,y,width,height = self.fX,self.fY,self.fWidth,self.fHeight
				if self.bRelativePosition then
					x = x/g_screenX
					y = y/g_screenY
				end
				if self.bRelativeSize then
					width = (width/g_screenX)
					height = (height/g_screenY)
				end
				local cameraTarget = getCameraTarget()
				local radarRadius = getRadarRadius()
				local toF11Map = isPlayerMapVisible()

				if self.hideFromRadar and not toF11Map then
					break
				end

				local camX,camY,_,camTargetX,camTargetY = getCameraMatrix()
				streamout = false
				if not self.inRadar then
					streamout = true
				end
				if not cameraTarget then
					x1,y1 = camX,camY
				else
					x1,y1 = getElementPosition(cameraTarget)
				end
				if not toF11Map and self.pd then
					width = width - (10/1920*g_screenX)
					height = height - (10/1050*g_screenY)
					x = x + (5/1920*g_screenX)
					y = y + (5/1050*g_screenY)
					if not string.find(self.strPath, "vehicle") then -- Is a ped
						width = width - (5/1920*g_screenX)
						height = height - (5/1050*g_screenY)
						x = x + (2.5/1920*g_screenX)
						y = y + (2.5/1050*g_screenY)
					end
				end
				local colors = self.tColor
				if (colors[1] == 255 or colors[3] == 255) and colors[2] == 0 and self.pd then -- Is flashing
					local current = getTickCount() - 250
					if (self.tick or current) <= current then -- Change the color
						if colors[1] == 255 then
							r1, g1, b1 = 0, 0, 255
						else
							r1, g1, b1 = 255, 0, 0
						end
						self.tick = getTickCount()
						setWidgetColor(self, r1, g1, b1)
					end
				end
				if self.text and self.text ~= "" and (not streamout or toF11Map and not isMTAWindowActive()) then
					--if self.element and self.pd and self.text ~= "" and (not streamout or toF11Map and not isMTAWindowActive()) then
					local textL=dxGetTextWidth(self.text,1,"sans")
					local textH=dxGetFontHeight(1,"sans")
					tt = 0
					if toF11Map and not isMTAWindowActive() then
						textL = textL+10
						tt = 2
					end
					local text2L, text2H
					if self.text2 and self.text2 ~= "" then
						text2L=dxGetTextWidth(self.text2,1,"default")
						text2H=dxGetFontHeight(1,"default")
						if self.text2lines then
							local lines = tonumber(self.text2lines) or 1
							text2H = text2H * lines
						end
					end
					if self.pd then
						dxDrawRectangle(x-1,y,textL+width*1.4,height,tocolor(0, 0, 0, 160))
						dxDrawText(self.text,x+width+5,y+(height/2)-6-tt,textL+5000,height+1300,tocolor(255, 255, 255, 255),1,"sans",'left','top',true,false,false)
					else
						if self.text2 and self.text2 ~= "" then
							local greaterL
							if textL > text2L then greaterL = textL else greaterL = text2L end
							dxDrawRectangle(x+width,y,greaterL+15,textH+text2H+5,tocolor(0, 0, 0, 160))
						else
							dxDrawRectangle(x+width,y,textL,textH+5,tocolor(0, 0, 0, 160))
						end
						dxDrawText(self.text,x+width+5,y+2,textL+5000,textH+1300,tocolor(255, 255, 255, 255),1,"sans",'left','top',true,false,false)
						if self.text2 and self.text2 ~= "" then
							dxDrawText(self.text2,x+width+10,(y+2)+textH,textL+5000,text2H+1300,tocolor(255, 255, 255, 255),1,"default",'left','top',true,false,false)
						end
					end
				end
				dxDrawImage ( x,y, width, height, self.strPath, self.fRot, self.fRotXOff, self.fRotYOff, tocolor(unpack(self.tColor)), self.bPostGUI )
				break
			end
		end
	end
)

