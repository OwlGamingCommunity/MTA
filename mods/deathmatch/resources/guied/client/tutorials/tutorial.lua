--[[--------------------------------------------------
	GUI Editor
	client
	tutorial.lua
	
	main tutorial class, handles all common tutorial actions and functionality
--]]--------------------------------------------------


Tutorial = {
	instances = {},
	constructors = {},
	
	pageHeight = 245,
	pageWidth = 260,
	
	crushSpeed = 200,

	startByID = function(id)
		if Tutorial.instances[id] then
			Tutorial.instances[id]:start()
		end
	end,
	
	active = function()
		for _,t in pairs(Tutorial.instances) do
			if t.active then
				return t
			end
		end

		return false	
	end
}

Tutorial.__index = Tutorial



function Tutorial:create(id, title, closable)
	--[[--------------------------------------------------
		main window
	--]]--------------------------------------------------
	local wndMain = guiCreateWindow((gScreen.x - 280) - 10, (gScreen.y - 300) / 2, 280, 300, title or "Tutorial", false)
	guiWindowSetSizable(wndMain, false)
	guiSetVisible(wndMain, false)
	setElementData(wndMain, "guieditor:alwaysVisible", true)
	
	--[[--------------------------------------------------
		back / forward controls
	--]]--------------------------------------------------
	-- can't go back on the first page, so disable back
	lblBack = guiCreateLabel(20, 265, 120, 25, "", false, wndMain)
	lblForward = guiCreateLabel(140, 265, 120, 25, ">>", false, wndMain)
	setRolloverColour(lblBack, gColours.primary, gColours.defaultLabel)
	setRolloverColour(lblForward, gColours.primary, gColours.defaultLabel)
	guiLabelSetHorizontalAlign(lblBack, "center")
	guiLabelSetVerticalAlign(lblBack, "center")
	guiLabelSetHorizontalAlign(lblForward, "center")
	guiLabelSetVerticalAlign(lblForward, "center")
	
	navigationAreaTopLeft, navigationAreaTopRight = divider(wndMain, 10, 265, 260, gAreaColours.primary)
	navigationAreaBottomLeft, navigationAreaBottomRight = divider(wndMain, 10, 290, 260, gAreaColours.primary)

	navigationAreaDivide = guiCreateStaticImage(140, 265, 1, 25, "images/dot_white.png", false, wndMain)	
	guiSetProperty(navigationAreaDivide, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))		

	
	local new = setmetatable(
		{
			gui = {},
			pages = {},
			currentPage = 0,
			active = false,
			interruptible = false,
			title = title,
			base = wndMain,
			back = lblBack,
			forward = lblForward,
			id = id,
			nextTick = 0,
			previousTick = 0,
		},
		Tutorial
	)
	
	
	if closable then
		guiWindowTitlebarButtonAdd(wndMain, "Close", "right", function() new:stop() end)		
	end	
	
	addEventHandler("onClientGUIClick", lblBack, 
		function(button, state)
			if button == "left" and state == "up" then
				new:pagePrevious()
			end
		end
	, false)
	
	addEventHandler("onClientGUIClick", lblForward, 
		function(button, state)
			if button == "left" and state == "up" then
				new:pageNext()
			end
		end
	, false)
	
	
	Tutorial.instances[id] = new
	
	doOnChildren(wndMain, setElementData, "guieditor.internal:noLoad", true)
	
	return new
end


function Tutorial:addPage(title, body)
	self.pages[#self.pages + 1] = {}

	-- main page base element that contains all the page elements
	self.pages[#self.pages].base = guiCreateLabel(10, 20, Tutorial.pageWidth, Tutorial.pageHeight, "", false, self.base)
	
	self.pages[#self.pages].title = guiCreateLabel(0, 0, Tutorial.pageWidth, 20, title, false, self.pages[#self.pages].base)
	guiLabelSetHorizontalAlign(self.pages[#self.pages].title, "center")
	guiLabelSetVerticalAlign(self.pages[#self.pages].title, "top")
	guiSetFont(self.pages[#self.pages].title, "clear-normal")
	guiSetColour(self.pages[#self.pages].title, unpack(gColours.secondary))
	
	self.pages[#self.pages].body = guiCreateLabel(0, 20, Tutorial.pageWidth, Tutorial.pageHeight - 20, body or title, false, self.pages[#self.pages].base)
	guiLabelSetHorizontalAlign(self.pages[#self.pages].body, "center", true)
	guiLabelSetVerticalAlign(self.pages[#self.pages].body, "top")

	if #self.pages > 1 then
		-- add a crush to the previous page
		lblCrush = guiCreateLabel(0, 0, 0, 0, "", false, self.pages[#self.pages].base)
		setCrushToggle(lblCrush, Tutorial.crushSpeed, Tutorial.pageWidth, self.pages[#self.pages - 1].base, self.pages[#self.pages].base, true)
		self.pages[#self.pages - 1].crush = lblCrush
		
		guiSetSize(self.pages[#self.pages].base, 0, Tutorial.pageHeight, false)
	end
	
	doOnChildren(self.base, setElementData, "guieditor.internal:noLoad", true)
	
	return self.pages[#self.pages]
end


function Tutorial:start()
	if Tutorial.active() then
		ContextBar.add("Another tutorial is already running")
		return
	end
	
	if self.onStart then
		self.onStart()
	end
	
	self.active = true
	
	guiSetVisible(self.base, true)
	
	guiSetVisible(self.pages[1].base, true)
	self.currentPage = 1
	
	self:setupPage()
end


function Tutorial:stop()
	if self.onStop then
		self.onStop()
	end
	
	self.active = false
	
	guiSetVisible(self.base, false)
	
	for i = #self.pages, 1, -1 do
		if self.pages[i].crush then
			if getCrush(self.pages[i].crush).direction == -1 then
				triggerEvent("onClientGUIClick", self.pages[i].crush, "left", "up")
			end				
		end
	end
end


function Tutorial:setupPage(lastPage)
	guiSetText(self.forward, ">>")
	guiSetText(self.back, "<<")			
			
	if self.currentPage == #self.pages then
		guiSetText(self.forward, "Done")
	end
	
	if self.currentPage == 1 then
		guiSetText(self.back, "")
	end
	
	if self.onPageChange then
		self.onPageChange(self.currentPage, lastPage)
	end
end


function Tutorial:pageNext()
	if self.currentPage > 0 then
		if self.nextTick + Tutorial.crushSpeed > getTickCount() then
			return
		end
		
		self.nextTick = getTickCount()
		
		if #self.pages > self.currentPage then
			triggerEvent("onClientGUIClick", self.pages[self.currentPage].crush, "left", "up")
			
			self.currentPage = self.currentPage + 1
			
			self:setupPage(self.currentPage - 1)
		else
			self:stop()
		end
	end
end


function Tutorial:pagePrevious()
	if self.currentPage > 0 then
		if self.previousTick + Tutorial.crushSpeed > getTickCount() then
			return
		end
		
		self.previousTick = getTickCount()
		
		if self.currentPage > 1 then
			triggerEvent("onClientGUIClick", self.pages[self.currentPage - 1].crush, "left", "up")
			
			self.currentPage = self.currentPage - 1
			
			self:setupPage(self.currentPage + 1)
		end
	end
end


