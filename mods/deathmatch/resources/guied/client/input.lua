--[[--------------------------------------------------
	GUI Editor
	client
	input.lua
	
	provides filters for various text input types (eg: int, string, variable, etc)
--]]--------------------------------------------------


gFilters = {
	characters = 0, -- default, all characters
	charactersBasic = 1, -- just numbers and letters
	numberFloat = 2,
	numberInt = 3,
	variable = 4, -- anything usable in a lua variable name
	resolution = 5, -- numberXnumber
	noSpace = 6,
}


function filterInput(filter, text, fix)
	if filter == gFilters.characters then
		return true
	elseif filter == gFilters.charactersBasic then
		for i = 1, #text do
			local b = text:byte(i)
			
			if (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or (b == 32) then
				-- all good in the hood
			else
				return false
			end
		end	
		
		return true
	elseif filter == gFilters.numberInt then
		if tonumber(text) and not text:find(" ") and not text:find(".", 0, true) then 
			return true
		else
			if fix then
				fix = fixInput(filter, text)
			end
			
			return false, fix
		end
	elseif filter == gFilters.numberFloat then
		if tonumber(text) and not text:find(" ") then 
			return true
		else
			if fix then
				fix = fixInput(filter, text)
			end
			
			return false, fix
		end		
	elseif filter == gFilters.variable then
		for i = 1, #text do
			local b = text:byte(i)
			
			if (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or (b == 91) or (b == 93) or (b == 95) or (b == 46) then
				-- all good in the hood
			else
				return false
			end
		end	

		return true
	elseif filter == gFilters.resolution then
		local x = false
		
		for i = 1, #text do
			local b = text:byte(i)

			if (b >= 48 and b <= 57) or ( ((b == 88) or (b == 120)) and i > 1) then
				if ((b == 88) or (b == 120)) then
					if x then
						return false
					end
					
					x = true
				end
				-- all good in the hood
			else
				return false
			end
		end	
	elseif filter == gFilters.noSpace then
		for i = 1, #text do
			local b = text:byte(i)
			
			if b < 33 then
				if fix then
					fix = fixInput(filter, text)
				end
				
				return false, fix
			end
		end		

		return true
	end
	
	return true
end

--[[--------------------------------------------------
	parts originally taken from the map editor
	editor_gui\client\editingControls.lua
--]]--------------------------------------------------
function fixInput(filter, text)
	if filter == gFilters.numberInt then
		local sign = ""
		if text:sub(1,1) == '-' then
			sign = '-'
		end

		changedText = string.gsub( text, "[^%d]", "" )
		
		return sign .. changedText
	elseif filter == gFilters.numberFloat then
		local sign = ""
		if text:sub(1,1) == '-' then
			sign = '-'
		end
			
		changedText = string.gsub( text, "[^%.%d]", "" )
			
		local numberParts = split( changedText, string.byte('.') )
		if #numberParts > 0 then
			if #numberParts > 1 then
				local decimalPart = table.concat(numberParts,'',2)
				if decimalPart == "" then
					changedText = numberParts[1]
				else
					changedText = numberParts[1] .. '.' .. decimalPart
				end
			else
				changedText = numberParts[1]
			end
		end
			
		return sign .. changedText
	elseif filter == gFilters.noSpace then
		return text:gsub(" ", "")
	end
end



addEventHandler("onClientGUIChanged", root,
	function()
		if not gEnabled then
			return
		end
	
		if getElementData(source, "guieditor:filter") then
			local correct, fix = filterInput(getElementData(source, "guieditor:filter"), guiGetText(source), true)
			
			if not correct then
				guiSetText(source, fix)
			end
		end
	end
)