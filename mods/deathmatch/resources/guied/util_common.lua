--[[--------------------------------------------------
	GUI Editor
	client & server
	menu.lua
	
	cross-usable utility functions
--]]--------------------------------------------------


_DEBUG = true
_DEBUG_CATEGORIES = {
	MOVER = false,
	CREATOR = false,
	GUI_CODE_GENERATION = false,
	RESOLUTION_PREVIEW = false,
	MULTILINE_EDITBOX = false,
	UNDO_REDO = false,
	INVALID_DATA = false,
	GENERAL = false,
	LOAD_CODE = true,
	LOAD_CODE_INTERNAL = false,
	POSITION_CODER = false,
	MENU_ITEM = false,
	TEXT_EFFECT_LOAD = true,
	UNDO_REDO_CONDITION = false
}


--[[--------------------------------------------------
	debug things
--]]--------------------------------------------------
function outputDebug(message, category, level)
	if _DEBUG then
		message = tostring(message)
		
		if category then
			if not _DEBUG_CATEGORIES[category] then
				return
			end
			
			message = message .. " ["..category.."]"
		end

		local source = ""
		local line = ""

		for title, info in pairs(debug.getinfo(2, "lS")) do
			if tostring(title) == "source" then
				local s, e = tostring(info):find('\\mods\\deathmatch\\resources\\', 0, true)
				
				if s and e then
					source = tostring(info):sub(e)
				end
			elseif tostring(title) == "currentline" then
				line = tostring(info)
			end
		end	

		outputDebugString(source..":"..line..": " .. message, level or 3)
	end
end