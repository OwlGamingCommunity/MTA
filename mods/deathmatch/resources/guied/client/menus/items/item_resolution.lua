--[[--------------------------------------------------
	GUI Editor
	client
	item_resolution.lua
	
	define the resolution right click menu items
--]]--------------------------------------------------


function createItem_resolution()
	return MenuItem_Toggle:create(false, "Preview in resolution"):set({onClick = resolutionPreview.setup})
end


function createItem_resolutionCustomTitle()
	return MenuItem_Text:create("Use Custom"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__sibling:11", "__parentItem"}})
end


function createItem_resolutionCustom()
	return MenuItem_Text:create("Custom: %value"):set({onClickClose = false, clickable = false, replaceValue = "WIDTHxHEIGHT", editbox = {filter = gFilters.resolution}})
end


function createItem_resolution640x480()
	return MenuItem_Text:create("640 x 480"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


function createItem_resolution800x600()
	return MenuItem_Text:create("800 x 600"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


function createItem_resolution1024x768()
	return MenuItem_Text:create("1024 x 768"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


function createItem_resolution1280x768()
	return MenuItem_Text:create("1280 x 768"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


function createItem_resolution1280x1024()
	return MenuItem_Text:create("1280 x 1024"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


function createItem_resolution1440x900()
	return MenuItem_Text:create("1440 x 900"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


function createItem_resolution1680x1050()
	return MenuItem_Text:create("1680 x 1050"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


function createItem_resolution1920x1080()
	return MenuItem_Text:create("1920 x 1080"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


function createItem_resolution1920x1200()
	return MenuItem_Text:create("1920 x 1200"):set({onClick = resolutionPreview.setResolution, onClickArgs = {"__self", "__parentItem"}})
end


--[[
640x480
800x600
1024x768
1280x768
1280x1024
1440x900
1680x1050
1920x1080
1920x1200
]]