--[[--------------------------------------------------
	GUI Editor
	client
	code_generation.lua
	
	generate the output code from the created elements
--]]--------------------------------------------------


gDecimalPlaces = 2
gNumberFormat = "%."..tostring(gDecimalPlaces).."f"
gDXNumberFormat = "%.4f"

Generation = {
	indent = "    ",
	usingScreenSize = false,
	usingScreenSizeForDX = false,
	usingBasicCode = false,
	usingCustomFont = false,
	usingDefaultVariables = {},
	elementsUsingDefaultVariables = {},
	biggestWidth = 0,
}


function Generation.generateCode()
	Generation.usingDefaultVariables = {}
	Generation.elementsUsingDefaultVariables = {}
	Generation.usingScreenSize = false
	Generation.usingScreenSizeForDX = false
	Generation.usingCustomFont = false
	Generation.usingCustomImage = false
	Generation.biggestWidth = 0
	
	Generation.fonts = {}
	Generation.dxFonts = {}
	Generation.variableTables = {}
	
	reindexPlaceholders()
	
	local guiElements = guiGetScreenElements()

	local code = ""
	
	for i, element in ipairs(guiElements) do
		local c = Generation.process(element, 1)
		
		if c and c ~= "" then
			local count = 1
			while string.sub(c, -string.len("\n")) == "\n" do
				c = string.sub(c, 0, #c - string.len("\n"))
				
				count = count + 1
				if count > 10 then break end
			end

			-- between each high level (screen) element
			code = code .. c .. (i == #guiElements and "" or "\n\n")
		end
	end
	
	
	local dxcode = ""
	local dxcodePrefix = ""
	
	for i,dx in ipairs(DX_Element.instances) do
		local dxCommon = generateCode_commonDX(dx.element, dx)
		
		if dx.dxType == gDXTypes.line then
			--dxDrawLine(dx.startX, dx.startY, dx.endX, dx.endY, tocolor(unpack(dx.colour_)), dx.width, dx.postGUI_)
			dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawLine(%s, tocolor(%i, %i, %i, %i), %i, %s)", dxCommon.position, dx.colour_[1], dx.colour_[2], dx.colour_[3], dx.colour_[4], dx.width, tostring(dx.postGUI_))
		elseif dx.dxType == gDXTypes.rectangle then
			--dxDrawRectangle(dx.x, dx.y, dx.width, dx.height, tocolor(unpack(dx.colour_)), dx.postGUI_)
			
			-- no point doing both, check outline first since it encompases shadow anyway
			if dx:outline() then
				--dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawRectangle(%s, %s, tocolor(%i, %i, %i, %i), %s)", dxCommon.outline.position, dxCommon.outline.size, 0, 0, 0, 255, tostring(dx.postGUI_))	
			
				for i = 1, 4 do
					dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawLine(%s, tocolor(%i, %i, %i, %i), %i, %s)", dxCommon["outline" .. i].position, dx.outlineColour_[1], dx.outlineColour_[2], dx.outlineColour_[3], dx.outlineColour_[4], 1, tostring(dx.postGUI_))
				end				
			elseif dx:shadow() then
				--dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawRectangle(%s, %s, tocolor(%i, %i, %i, %i), %s)", dxCommon.shadow.position, dxCommon.size, 0, 0, 0, 255, tostring(dx.postGUI_))
			
				for i = 1, 2 do
					dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawLine(%s, tocolor(%i, %i, %i, %i), %i, %s)", dxCommon["shadow" .. i].position, dx.shadowColour_[1], dx.shadowColour_[2], dx.shadowColour_[3], dx.shadowColour_[4], 1, tostring(dx.postGUI_))
				end					
			end	
			
			dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawRectangle(%s, %s, tocolor(%i, %i, %i, %i), %s)", dxCommon.position, dxCommon.size, dx.colour_[1], dx.colour_[2], dx.colour_[3], dx.colour_[4], tostring(dx.postGUI_))
		elseif dx.dxType == gDXTypes.image then
			--dxDrawImage(dx.x, dx.y, dx.width, dx.height, dx.filepath, dx.rotation_, dx.rOffsetX_, dx.rOffsetY_, tocolor(unpack(dx.colour_)), dx.postGUI_)
			dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawImage(%s, %s, \"%s\", %d, %d, %d, tocolor(%i, %i, %i, %i), %s)", dxCommon.position, dxCommon.size, dx.filepath, dx.rotation_, dx.rOffsetX_, dx.rOffsetY_, dx.colour_[1], dx.colour_[2], dx.colour_[3], dx.colour_[4], tostring(dx.postGUI_))
		elseif dx.dxType == gDXTypes.text then
			--dxDrawText(dx.text_, dx.x, dx.y, dx.x + dx.width, dx.y + dx.height, tocolor(unpack(dx.colour_)), dx.scale_, dx.font_, dx.alignX_, dx.alignY_, dx.clip_, dx.wordwrap_, dx.postGUI_, dx.colourCoded_, dx.subPixelPositioning)
			local text = dx.text_
			text = text:gsub("\n", "\\n") or ""
			text = text:gsub("\"", "\\\"") or ""
			
			if dx:outline() then
				--	4 --- 2
				--	|     |
				--	|     |
				--	3 --- 1	
				
				for i = 1, 4 do
					dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawText(\"%s\", %s, %s, tocolor(%i, %i, %i, %i), " .. gNumberFormat .. ", %s, \"%s\", \"%s\", %s, %s, %s, %s, %s)", text, dxCommon["outline" .. i].position, dxCommon["outline" .. i].size, dx.outlineColour_[1], dx.outlineColour_[2], dx.outlineColour_[3], dx.outlineColour_[4], dx.scale_, dxCommon.fontString or tostring(dx.font_), tostring(dx.alignX_), tostring(dx.alignY_), tostring(dx.clip_), tostring(dx.wordwrap_), tostring(dx.postGUI_), tostring(dx.colourCoded_), tostring(dx.subPixelPositioning))
				end
				
				--dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawText(\"%s\", %s, %s, tocolor(%i, %i, %i, %i), " .. gNumberFormat .. ", %s, \"%s\", \"%s\", %s, %s, %s, %s, %s)", text, dxCommon.shadow.position, dxCommon.shadow.size, 0, 0, 0, 255, dx.scale_, dxCommon.fontString or tostring(dx.font_), tostring(dx.alignX_), tostring(dx.alignY_), tostring(dx.clip_), tostring(dx.wordwrap_), tostring(dx.postGUI_), tostring(dx.colourCoded_), tostring(dx.subPixelPositioning))
			elseif dx:shadow() then
				dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawText(\"%s\", %s, %s, tocolor(%i, %i, %i, %i), " .. gNumberFormat .. ", %s, \"%s\", \"%s\", %s, %s, %s, %s, %s)", text, dxCommon.shadow.position, dxCommon.shadow.size, dx.shadowColour_[1], dx.shadowColour_[2], dx.shadowColour_[3], dx.shadowColour_[4], dx.scale_, dxCommon.fontString or tostring(dx.font_), tostring(dx.alignX_), tostring(dx.alignY_), tostring(dx.clip_), tostring(dx.wordwrap_), tostring(dx.postGUI_), tostring(dx.colourCoded_), tostring(dx.subPixelPositioning))
			end	

			dxcode = dxcode .. "\n" .. string.rep(Generation.indent, 2) .. string.format("dxDrawText(\"%s\", %s, %s, tocolor(%i, %i, %i, %i), " .. gNumberFormat .. ", %s, \"%s\", \"%s\", %s, %s, %s, %s, %s)", text, dxCommon.position, dxCommon.size, dx.colour_[1], dx.colour_[2], dx.colour_[3], dx.colour_[4], dx.scale_, dxCommon.fontString or tostring(dx.font_), tostring(dx.alignX_), tostring(dx.alignY_), tostring(dx.clip_), tostring(dx.wordwrap_), tostring(dx.postGUI_), tostring(dx.colourCoded_), tostring(dx.subPixelPositioning))
		end
		
		if dxCommon.fontCreationString then
			dxcodePrefix = dxcodePrefix .. tostring(dxCommon.fontCreationString)
		end
	end	
	
	if Settings.loaded.output_window_autosize.value then
		for i,l in ipairs(string.lines(dxcode)) do
			local w = dxGetTextWidth(l)

			if w > Generation.biggestWidth then
				Generation.biggestWidth = w
			end
		end
	end
	
	if Generation.usingScreenSizeForDX and not Generation.usingScreenSize then
		dxcodePrefix = dxcodePrefix .. "\nlocal screenW, screenH = guiGetScreenSize()"
	end
	
	
	local prefix, suffix = "", ""
	local notes
	
	if Generation.usingCustomFont or Generation.usingCustomImage then
		notes = true
		prefix = "--[[-------------------------------------------------\n"
		prefix = prefix .. "Notes:\n"
	end
	
	if Generation.usingCustomFont then
		prefix = prefix .. "\n> This code is using a custom font. This will only work as long as the location it is from always exists, and the resource it is part of is running.\n    To ensure it does not break, it is highly encouraged to move custom fonts into your local resource and reference them there."
	end
	
	
	if Generation.usingCustomImage then
		prefix = prefix .. "\n> This code is using a relative image filepath. This will only work as long as the location it is from always exists, and the resource it is part of is running.\n    To ensure it does not break, it is highly encouraged to move images into your local resource and reference them there."	
	end

	
	if notes then
		prefix = prefix .. "\n--]]-------------------------------------------------\n\n"
	end
	

	-- create tables for all the default variable names (if they are being used)
	--[[
	local tableDeclaration

	for elementType,using in pairs(Generation.usingDefaultVariables) do
		if using then
			if not tableDeclaration then
				prefix = prefix .. (Generation.usingScreenSize and "\n" or "") .. "GUIEditor = {\n"
				tableDeclaration = true
			end
			
			prefix = prefix .. Generation.indent .. stripGUIPrefix(elementType) .. " = {},\n"
		end
	end
	
	if tableDeclaration then
		--prefix = prefix .. "}"
	end
	]]
	
	-- actually, merge these into the other variable generation
	-- this prevents people from generating 2 'GUIEditor' tables (1 default and 1 custom)
	for elementType,using in pairs(Generation.usingDefaultVariables) do
		if using then
			Generation.variableTables["GUIEditor." .. stripGUIPrefix(elementType) .."[n]"] = true
		end
	end
	
	
	-- generate table declaration structures for custom tables (if any are being used)
	local vTables = {}
	local variableString = ""
	
	for var in pairs(Generation.variableTables) do
		local c = ""
		local remainder = var
		local parent = vTables

		while #remainder > 0 and (remainder:find(".", 0, true) or remainder:find("[", 0, true)) do
			local s, e = remainder:find(".", 0, true)
			local s2, e2 = remainder:find("[", 0, true)
			
			-- if we found a matching . first
			if (s and not s2) or (s and s2 and s < s2) then
				local part = remainder:sub(0, s - 1)
				
				if #part == 0 then
					break
				end
				
				if not parent[part] then
					parent[part] = {}
				end
				parent = parent[part]
				
				-- abc.def.ghi -> def.ghi
				remainder = remainder:sub(e + 1)
				
			-- matching [ first
			else
				local part = remainder:sub(0, s2 - 1)
				
				if #part == 0 then
					break
				end
				
				if not parent[part] then
					parent[part] = {}
				end
				parent = parent[part]	

				-- abc[1].def -> [1].def
				remainder = remainder:sub(e2)
				
				local broken = false
				
				-- in case we have more than 1 [n] block (ie: abc[1][1][1].def)
				while #remainder > 0 and remainder:sub(0, 1) == "[" do
					local s3, e3 = remainder:find("]", 0, true)
					
					if s3 and e3 then
						-- block == "[n]"
						local block = remainder:sub(0, e3)
						
						remainder = remainder:sub(e3 + 1)
						
						if remainder:sub(0, 1) == "." then
							remainder = remainder:sub(2)
						end
						
						if #remainder > 0 then
							if not parent[block] then
								parent[block] = {}
							end
							parent = parent[block]
						end
						
					-- uh oh
					else
						broken = true
						break
					end					
				end
				
				if broken then
					break
				end
			end
		end		
	end
	
	local function loop(t, level)
		local i = 1
		for k,v in pairs(t) do
			variableString = variableString .. "\n" .. string.rep(Generation.indent, level) .. k .. " = {"

			local size = 0
			
			if type(v) == "table" then
				loop(v, level + 1)
				
				size = table.count(v)
			end
			
			variableString = variableString .. (size > 0 and "\n" .. string.rep(Generation.indent, level) or "") .. ((level == 0 or i == table.count(t)) and "}" or "},")
			
			i = i + 1
		end
	end
	
	loop(vTables, 0)

	
	prefix = prefix .. variableString
	
	
	if Generation.usingBasicCode and #code > 0 then
		prefix = prefix .. (true and "\n" or "") .. "addEventHandler(\"onClientResourceStart\", resourceRoot,\n" .. Generation.indent .. "function()"
		suffix = Generation.indent .. "\n" .. Generation.indent .. "end\n)"
	end

	
	-- trim newlines off the end
	while string.find(code:sub(-2), "\n") do
		code = code:sub(0, -2)
	end
	
	code = code .. suffix
	

	if #DX_Element.instances > 0 then
		code = code .. (#dxcodePrefix > 0 and "\n" or "") .. dxcodePrefix
		
		code = code .. "\n\naddEventHandler(\"onClientRender\", root,\n" .. Generation.indent .. "function()"
		
		code = code .. dxcode
		
		code = code .. "\n" .. Generation.indent .. "end\n)"
	end	
	
	
	if Generation.usingScreenSize then
		prefix = prefix .. "\nlocal screenW, screenH = guiGetScreenSize()"
	end
	
	code = prefix .. code
	
	--Output.show(code, tableDeclaration)
	return code, table.count(vTables) > 0
end



function Generation.process(element, level)
	local code = ""
	
	if relevant(element) and not getElementData(element, "guieditor.internal:dxElement") then
		code = Generation.generateElementCode(element) --[[.. "\n"]]
		
		outputDebug("generate code "..asString(element), "GUI_CODE_GENERATION")
		
		local c = getElementChildren(element)
		
		if #c > 0 then
			local done = false
			
			for _, child in ipairs(c) do
				if relevant(child) then
					if not done then
						code = code .. "\n"
						done = true
					end
					
					outputDebug("process child "..asString(element).." ("..asString(child)..")", "GUI_CODE_GENERATION")
				
					code = code .. Generation.process(child, level + 1)
				end
			end
			
			if done then
				code = code .. "\n"
			end
		end
	end
	
	return code
end	


function Generation.generateElementCode(element)
	local elementType = getElementType(element)
	
	elementType = stripGUIPrefix(elementType)
	
	if _G["generateCode_" .. elementType] then
		local code = "\n" .. --[[(Generation.usingBasicCode and string.rep(Generation.indent, 2) or "") ..]] (_G["generateCode_" .. elementType](element, generateCode_common(element)))
		
		if Generation.usingBasicCode then
			code = code:gsub("\n", "\n" .. string.rep(Generation.indent, 2))
		end
		
		if Settings.loaded.output_window_autosize.value then
			for i,l in ipairs(string.lines(code)) do
				local w = dxGetTextWidth(l)

				if w > Generation.biggestWidth then
					Generation.biggestWidth = w
				end
			end
		end
		
		return code
	end
	
	return ""
end


function generateCode_common(element)
	local common = {}
	local placeholder
	local elementType = getElementType(element)
	
	if not gDefaults.properties[elementType] then
		local parent, args = nil, {}
		
		if elementType == "gui-tab" then
			parent = createGUIElementFromType("tabpanel", 0, 0, 0, 0, false)
		end
		
		if elementType == "gui-staticimage" then
			args = {":"..tostring(getResourceName(resource)).."/images/arrow_out.png"}
		end
		
		local e = createGUIElementFromType(stripGUIPrefix(elementType), 0, 0, 0, 0, false, parent, unpack(args))
		
		cacheProperties(e)
		
		destroyElement(e)
		
		if parent then
			destroyElement(parent)
		end
	end
	
	common.elementType = elementType
	common.variable, placeholder = getElementVariable(element)
	
	if placeholder then
		Generation.usingDefaultVariables[elementType] = true
		Generation.elementsUsingDefaultVariables[#Generation.elementsUsingDefaultVariables + 1] = element
	else
		if common.variable:find(".", 0, true) then
			Generation.variableTables[common.variable] = true
		end
	end
	
	if getElementData(element, "guieditor:positionCode") then
		local w, h = guiGetSize(element, false)
		local p = getElementData(element, "guieditor:positionCode")
		
		p = p:gsub("width", w)
		p = p:gsub("height", h)
		
		if not guiGetParent(element) then
			p = p:gsub("parentW", "screenW")
			p = p:gsub("parentH", "screenH")
			Generation.usingScreenSize = true
		else
			-- get the size info of the parent and substitute it
			local width, height = guiGetSize(guiGetParent(element), false)
			
			p = p:gsub("parentW", tostring(width))
			p = p:gsub("parentH", tostring(height))			
		end
		
		common.position = p
	else
		local x, y = guiGetPosition(element, getElementData(element, "guieditor:relative"))
		
		if getElementData(element, "guieditor:relative") then
			common.position = string.format(gNumberFormat..", "..gNumberFormat, x, y)
		else
			common.position = x .. ", ".. y
		end
	end
	
		
	local w, h = guiGetSize(element, getElementData(element, "guieditor:relative"))
	if getElementData(element, "guieditor:relative") then
		common.size = string.format(gNumberFormat..", "..gNumberFormat, w, h)
	else
		common.size = w .. ", ".. h
	end
	
	common.relative = tostring(getElementData(element, "guieditor:relative"))

	common.text = guiGetText(element):gsub("\n", "\\n") or ""
	common.text = string.gsub(common.text, "\"", "\\\"")
	common.alphaString = ""
	
	if guiGetAlpha(element) and math.floor((guiGetAlpha(element) * 100) + 0.5) ~= gDefaults.alpha[elementType]then
		common.alpha = string.format(gNumberFormat, guiGetAlpha(element))
		
		if common.alpha then
			common.alphaString = "\nguiSetAlpha(".. common.variable ..", ".. common.alpha ..")"
		end		
	end
	
	if guiGetParent(element) then
		common.parent = ", " .. tostring(getElementVariable(guiGetParent(element))) .. ")"
	else
		common.parent = ")"
	end
	
	if hasColour(element) then
		local r, g, b, a = guiGetColour(element)
		
		if gDefaults.colour[elementType] and (gDefaults.colour[elementType].r ~= r or gDefaults.colour[elementType].g ~= g or gDefaults.colour[elementType].b ~= b or gDefaults.colour[elementType].a ~= a) then
			common.colour = {r = r, g = g, b = b, a = a}
		end
	end
	

	local properties = getElementData(element, "guieditor:properties") or {}
	
	common.propertiesString = ""
	
	for name in pairs(properties) do
		local value = guiGetProperty(element, name)
	
		if value ~= nil then
			if value ~= gDefaults.properties[elementType][name] then
				common.propertiesString = common.propertiesString .. "\nguiSetProperty(".. common.variable ..", \"".. name .."\", \"".. value .."\")"
			end
		-- if there are no defaults, just accept them all
		elseif gDefaults.properties[elementType] == nil and value ~= nil then
			common.propertiesString = common.propertiesString .. "\nguiSetProperty(".. common.variable ..", \"".. name .."\", \"".. value .."\")"
		end
	end
	
	common.fontString = ""
	
	if not gDefaults.font[elementType] or guiGetFont(element) ~= gDefaults.font[elementType] then
		if getElementData(element, "guieditor:font") then
			local f = getElementData(element, "guieditor:font")
			local fontName = FontPicker.fontNameFromPath(f)
			local s = tostring(getElementData(element, "guieditor:fontSize") or FontPicker.defaultFontSize)
			local var = Generation.fonts[f .. s] or "font" .. table.count(Generation.fonts) .. "_" .. fontName
			
			if not Generation.fonts[f .. s] then		
				Generation.fonts[f .. s] = var
					
				common.fontString = "\nlocal " .. var .. " = guiCreateFont(\"".. f .. "\", " .. s .. ")"
				
				Generation.usingCustomFont = true
			end
			
			common.fontString = common.fontString .. "\nguiSetFont(".. common.variable ..", ".. var ..")"
		else
			common.fontString = "\nguiSetFont(".. common.variable ..", \"".. tostring(guiGetFont(element)) .."\")"
		end
	end
	
	return common
end	


function generateCode_commonDX(element, dx, recursive, offset)
	local common = {}
	
	if not recursive then
		if dx:shadow() ~= nil then
			local eX, eY = guiGetPosition(element, false)
			local eW, eH = guiGetSize(element, false)
			
			if dx.dxType == gDXTypes.text then
				local e = guiCreateLabel(eX, eY, eW, eH, "", false)
				setElementData(e, "guieditor:relative", getElementData(element, "guieditor:relative"))			
				common.shadow = generateCode_commonDX(e, dx, true, gDXAnchor.bottomRight)
				destroyElement(e)
			elseif dx.dxType == gDXTypes.rectangle then
				-- >
				local e = guiCreateLabel(eX, eY + eH, eW, 0, "", false)		
				setElementData(e, "guieditor:relative", getElementData(element, "guieditor:relative"))				
				common.shadow1 = generateCode_commonDX(e, {dxType = gDXTypes.line, anchor = gDXAnchor.bottomLeft}, true, true)
				destroyElement(e)
				
				-- ^
				e = guiCreateLabel(eX + eW, eY, 0, eH, "", false)	
				setElementData(e, "guieditor:relative", getElementData(element, "guieditor:relative"))
				common.shadow2 = generateCode_commonDX(e, {dxType = gDXTypes.line, anchor = gDXAnchor.bottomRight}, true, true)
				destroyElement(e)
			end			
		end
		
		if dx:outline() ~= nil then
			local eX, eY = guiGetPosition(element, false)
			local eW, eH = guiGetSize(element, false)
			
			if dx.dxType == gDXTypes.rectangle then
				-- \/
				local e = guiCreateLabel(eX, eY, 0, eH, "", false)		
				setElementData(e, "guieditor:relative", getElementData(element, "guieditor:relative"))
				common.outline1 = generateCode_commonDX(e, {dxType = gDXTypes.line, anchor = gDXAnchor.topLeft}, true, true)
				destroyElement(e)	

				-- <
				e = guiCreateLabel(eX, eY, eW, 0, "", false)				
				setElementData(e, "guieditor:relative", getElementData(element, "guieditor:relative"))				
				common.outline2 = generateCode_commonDX(e, {dxType = gDXTypes.line, anchor = gDXAnchor.topRight}, true, true)
				destroyElement(e)					

				-- >
				e = guiCreateLabel(eX, eY + eH, eW, 0, "", false)	
				setElementData(e, "guieditor:relative", getElementData(element, "guieditor:relative"))
				common.outline3 = generateCode_commonDX(e, {dxType = gDXTypes.line, anchor = gDXAnchor.bottomLeft}, true, true)
				destroyElement(e)
				
				-- ^
				e = guiCreateLabel(eX + eW, eY, 0, eH, "", false)	
				setElementData(e, "guieditor:relative", getElementData(element, "guieditor:relative"))
				common.outline4 = generateCode_commonDX(e, {dxType = gDXTypes.line, anchor = gDXAnchor.bottomRight}, true, true)
				destroyElement(e)	
			elseif dx.dxType == gDXTypes.text then				
				local e = guiCreateLabel(eX, eY, eW, eH, "", false)		
				setElementData(e, "guieditor:relative", getElementData(element, "guieditor:relative"))
				common.outline1 = generateCode_commonDX(e, dx, true, gDXAnchor.topLeft)
				common.outline2 = generateCode_commonDX(e, dx, true, gDXAnchor.topRight)
				common.outline3 = generateCode_commonDX(e, dx, true, gDXAnchor.bottomLeft)
				common.outline4 = generateCode_commonDX(e, dx, true, gDXAnchor.bottomRight)
				destroyElement(e)				
			end
		end
	end
	

	--local w, h = guiGetSize(element, getElementData(element, "guieditor:relative"))
	local w, h = guiGetSize(element, false)
	
	if getElementData(element, "guieditor:relative") then
		common.size = string.format("screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat, w / gScreen.x, h / gScreen.y)
		Generation.usingScreenSizeForDX = true
	else
		common.size = w .. ", ".. h
	end

	if getElementData(element, "guieditor:positionCode") then
		local w, h = guiGetSize(element, false)
		local p = getElementData(element, "guieditor:positionCode")
		
		if dx.dxType == gDXTypes.line then
			local posParts = split(p, ',')
			
			if dx.anchor == 1 then
				p = posParts[1]:gsub("width", w) .. ", " .. posParts[2]:gsub("height", h)
				p = p .. ", (" .. posParts[1]:gsub("width", w) .. ") + " .. w .. ", (" .. posParts[2]:gsub("height", h) .. ") + " .. h
			elseif dx.anchor == 2 then
				p = "(" .. posParts[1]:gsub("width", w) .. ") + " .. w .. ", " .. posParts[2]:gsub("height", h)
				p = p .. ", " .. posParts[1]:gsub("width", w) .. ", (" .. posParts[2]:gsub("height", h) .. ") + " .. h
			elseif dx.anchor == 3 then
				p = posParts[1]:gsub("width", w).. ", (" .. posParts[2]:gsub("height", h) .. ") + " .. h
				p = p .. ", (" .. posParts[1]:gsub("width", w).. ") + " .. w .. ", " .. posParts[2]:gsub("height", h)
			elseif dx.anchor == 4 then
				p = "(" .. posParts[1]:gsub("width", w) .. ") + " .. w .. ", (" .. posParts[2]:gsub("height", h) .. ") + " .. h
				p = p .. ", " .. posParts[1]:gsub("width", w) .. ", " .. posParts[2]:gsub("height", h)
			end
		else
			p = p:gsub("width", w)
			p = p:gsub("height", h)
		end
		
		if dx.dxType == gDXTypes.text then
			local posParts = split(p, ',')
			
			common.size = "(" .. posParts[1] .. ") + " .. w .. ", " .. "(" .. posParts[2] .. ") + " .. h		
			common.size = string.gsub(common.size, "parentW", "screenW")
			common.size = string.gsub(common.size, "parentH", "screenH")
		end
		
		p = p:gsub("parentW", "screenW")
		p = p:gsub("parentH", "screenH")
		Generation.usingScreenSizeForDX = true		
		
		common.position = p
	else
		local x, y = guiGetPosition(element, false)

		if getElementData(element, "guieditor:relative") then
			common.position = string.format("screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat, x / gScreen.x, y / gScreen.y)
			Generation.usingScreenSizeForDX = true			
		else
			common.position = x .. ", ".. y
		end
		
		if dx.dxType == gDXTypes.line then
			common.position = common.position .. ", " .. common.size
				
			if getElementData(element, "guieditor:relative") then
				if dx.anchor == gDXAnchor.topLeft then
					if not offset then
						-- standard
						common.position = string.format(
							"screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat .. ", screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat, 
							x / gScreen.x, 
							y / gScreen.y,
							(x + w) / gScreen.x,
							(y + h) / gScreen.y
						)					
					else
						-- offset (e.g. outline or shadow)
						common.position = string.format(
							"(screenW * " .. gDXNumberFormat .. ") - 1, (screenH * " .. gDXNumberFormat .. ") - 1, (screenW * " .. gDXNumberFormat .. ") - 1, screenH * " .. gDXNumberFormat .. "", 
							x / gScreen.x, 
							y / gScreen.y,
							(x + w) / gScreen.x,
							(y + h) / gScreen.y
						)
					end
					--common.position = x .. ", " .. y .. ", " .. (x + w) .. ", " .. (y + h)
				elseif dx.anchor == gDXAnchor.topRight then
					if not offset then
						common.position = string.format(
							"screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat .. ", screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat, 
							(x + w) / gScreen.x, 
							y / gScreen.y,
							x / gScreen.x,
							(y + h) / gScreen.y
						)
					else
						common.position = string.format(
							"screenW * " .. gDXNumberFormat .. ", (screenH * " .. gDXNumberFormat .. ") - 1, (screenW * " .. gDXNumberFormat .. ") - 1, (screenH * " .. gDXNumberFormat .. ") - 1", 
							(x + w) / gScreen.x, 
							y / gScreen.y,
							x / gScreen.x,
							(y + h) / gScreen.y
						)					
					end
					--common.position = (x + w) .. ", " .. y .. ", " .. x .. ", " .. (y + h)
				elseif dx.anchor == gDXAnchor.bottomLeft then
					if not offset then
						common.position = string.format(
							"screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat .. ", screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat, 
							x / gScreen.x, 
							(y + h) / gScreen.y,
							(x + w) / gScreen.x,
							y / gScreen.y
						)		
					else
						common.position = string.format(
							"(screenW * " .. gDXNumberFormat .. ") - 1, screenH * " .. gDXNumberFormat .. ", screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat .. "", 
							x / gScreen.x, 
							(y + h) / gScreen.y,
							(x + w) / gScreen.x,
							y / gScreen.y
						)							
					end
					--common.position = x .. ", " .. (y + h) .. ", " .. (x + w) .. ", " .. y
				elseif dx.anchor == gDXAnchor.bottomRight then
					if not offset then
						common.position = string.format(
							"screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat .. ", screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat, 
							(x + w) / gScreen.x, 
							(y + h) / gScreen.y,
							x / gScreen.x,
							y / gScreen.y
						)
					else
						common.position = string.format(
							"screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat .. ", screenW * " .. gDXNumberFormat .. ", (screenH * " .. gDXNumberFormat .. ") - 1", 
							(x + w) / gScreen.x, 
							(y + h) / gScreen.y,
							x / gScreen.x,
							y / gScreen.y
						)
					end
					--common.position = (x + w) .. ", " .. (y + h) .. ", " .. x .. ", " .. y
				end	
			else
				if dx.anchor == gDXAnchor.topLeft then
					-- offset indicates outline or shadow
					if not offset then
						common.position = x .. ", " .. y .. ", " .. (x + w) .. ", " .. (y + h)
					else
						common.position = x .. " - 1, " .. y .. " - 1, " .. (x + w) .. " - 1, " .. (y + h)
					end
				elseif dx.anchor == gDXAnchor.topRight then
					if not offset then
						common.position = (x + w) .. ", " .. y .. ", " .. x .. ", " .. (y + h)
					else
						common.position = (x + w) .. ", " .. y .. " - 1, " .. x .. " - 1, " .. (y + h) .. " - 1"
					end
				elseif dx.anchor == gDXAnchor.bottomLeft then
					if not offset then
						common.position = x .. ", " .. (y + h) .. ", " .. (x + w) .. ", " .. y
					else
						common.position = x .. " - 1, " .. (y + h) .. ", " .. (x + w) .. ", " .. y
					end
				elseif dx.anchor == gDXAnchor.bottomRight then
					if not offset then
						common.position = (x + w) .. ", " .. (y + h) .. ", " .. x .. ", " .. y
					else
						common.position = (x + w) .. ", " .. (y + h) .. ", " .. x .. ", " .. y .. " - 1"
					end
				end	
			end
		elseif dx.dxType == gDXTypes.text then
			if getElementData(element, "guieditor:relative") then
				if not offset then
					common.size = string.format("screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat, (x + w) / gScreen.x, (y + h) / gScreen.y)
				elseif offset == gDXAnchor.topLeft then
					common.size = string.format("(screenW * " .. gDXNumberFormat .. ") - 1, (screenH * " .. gDXNumberFormat .. ") - 1", (x + w) / gScreen.x, (y + h) / gScreen.y)
				elseif offset == gDXAnchor.topRight then
					common.size = string.format("(screenW * " .. gDXNumberFormat .. ") + 1, (screenH * " .. gDXNumberFormat .. ") - 1", (x + w) / gScreen.x, (y + h) / gScreen.y)
				elseif offset == gDXAnchor.bottomLeft then
					common.size = string.format("(screenW * " .. gDXNumberFormat .. ") - 1, (screenH * " .. gDXNumberFormat .. ") + 1", (x + w) / gScreen.x, (y + h) / gScreen.y)
				elseif offset == gDXAnchor.bottomRight then
					common.size = string.format("(screenW * " .. gDXNumberFormat .. ") + 1, (screenH * " .. gDXNumberFormat .. ") + 1", (x + w) / gScreen.x, (y + h) / gScreen.y)							
				end	
			
				Generation.usingScreenSizeForDX = true
			else
				if not offset then
					common.size = x + w .. ", " .. y + h	
				elseif offset == gDXAnchor.topLeft then
					common.size = x + w .. " - 1, " .. y + h .. " - 1"
				elseif offset == gDXAnchor.topRight then
					common.size = x + w .. " + 1, " .. y + h .. " - 1"
				elseif offset == gDXAnchor.bottomLeft then
					common.size = x + w .. " - 1, " .. y + h .. " + 1"
				elseif offset == gDXAnchor.bottomRight then
					common.size = x + w .. " + 1, " .. y + h .. " + 1"		
				end					
			end
			
			if getElementData(element, "guieditor:relative") then
				if not offset then
					common.position = string.format("screenW * " .. gDXNumberFormat .. ", screenH * " .. gDXNumberFormat, x / gScreen.x, y / gScreen.y)
				elseif offset == gDXAnchor.topLeft then
					common.position = string.format("(screenW * " .. gDXNumberFormat .. ") - 1, (screenH * " .. gDXNumberFormat .. ") - 1", x / gScreen.x, y / gScreen.y)
				elseif offset == gDXAnchor.topRight then
					common.position = string.format("(screenW * " .. gDXNumberFormat .. ") + 1, (screenH * " .. gDXNumberFormat .. ") - 1", x / gScreen.x, y / gScreen.y)
				elseif offset == gDXAnchor.bottomLeft then
					common.position = string.format("(screenW * " .. gDXNumberFormat .. ") - 1, (screenH * " .. gDXNumberFormat .. ") + 1", x / gScreen.x, y / gScreen.y)
				elseif offset == gDXAnchor.bottomRight then
					common.position = string.format("(screenW * " .. gDXNumberFormat .. ") + 1, (screenH * " .. gDXNumberFormat .. ") + 1", x / gScreen.x, y / gScreen.y)				
				end
				
				Generation.usingScreenSizeForDX = true			
			else
				if not offset then
					common.position = x .. ", ".. y
				elseif offset == gDXAnchor.topLeft then
					common.position = x .. " - 1, ".. y .. " - 1"
				elseif offset == gDXAnchor.topRight then
					common.position = x .. " + 1, ".. y .. " - 1"
				elseif offset == gDXAnchor.bottomLeft then
					common.position = x .. " - 1, ".. y .. " + 1"
				elseif offset == gDXAnchor.bottomRight then
					common.position = x .. " + 1, ".. y .. " + 1"		
				end				
			end
		end
	end
	
	if not recursive then
		if dx.font_ and type(dx.font_) ~= "string" then
			if dx.fontPath and type(dx.fontPath) == "string" then
				local fontName = FontPicker.fontNameFromPath(dx.fontPath)
				local s = tostring(dx.fontSize or FontPicker.defaultFontSize)
				local var = Generation.dxFonts[fontName .. s] or "dxfont" .. table.count(Generation.dxFonts) .. "_" .. fontName
					
				if not Generation.dxFonts[fontName .. s] then		
					Generation.dxFonts[fontName .. s] = var
							
					common.fontCreationString = "\nlocal " .. var .. " = dxCreateFont(\"".. dx.fontPath .."\", " .. s .. ")"
						
					Generation.usingCustomFont = true
				end
					
				common.fontString = var
			end
		elseif dx.font_ and type(dx.font_) == "string" then
			common.fontString = "\""..tostring(dx.font_).."\""
		else
			common.fontString = "\""..tostring(dx.font_).."\""
		end	
	end
	
	return common
end


function generateCode_window(element, common)
	local output = common.variable .." = guiCreateWindow(".. common.position ..", ".. common.size ..", \"".. common.text .."\", " .. common.relative .. common.parent
	
	if not guiWindowGetMovable(element) then
		output = output .. "\nguiWindowSetMovable(".. common.variable .. ", false)"
	end
	
	if not guiWindowGetSizable(element) then
		output = output .. "\nguiWindowSetSizable(".. common.variable .. ", false)"
	end
	
	output = output .. common.alphaString
	output = output .. common.fontString
	output = output .. common.propertiesString
	
	if common.colour then
		output = output .. "\nguiSetProperty(".. common.variable ..", \"CaptionColour\", \"".. rgbaToHex(common.colour.r, common.colour.g, common.colour.b, common.colour.a) .."\")"
	end
	
	return output
end


function generateCode_button(element, common)
	local output = common.variable .." = guiCreateButton(".. common.position ..", ".. common.size ..", \"".. common.text .."\", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.fontString
	output = output .. common.propertiesString	
	
	if common.colour then
		output = output .. "\nguiSetProperty(".. common.variable ..", \"NormalTextColour\", \"".. rgbaToHex(common.colour.r, common.colour.g, common.colour.b, common.colour.a) .."\")"
	end
	
	return output
end


function generateCode_memo(element, common)
	common.text = string.sub(common.text, 0, -3)
	local output = common.variable .." = guiCreateMemo(".. common.position ..", ".. common.size ..", \"".. common.text .."\", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.fontString
	output = output .. common.propertiesString	
	
	if common.colour then
		output = output .. "\nguiSetProperty(".. common.variable ..", \"NormalTextColour\", \"".. rgbaToHex(common.colour.r, common.colour.g, common.colour.b, common.colour.a) .."\")"
	end
	
	if guiGetReadOnly(element) then
		output = output .. "\nguiMemoSetReadOnly(".. common.variable ..", true)"
	end
	
	return output
end


function generateCode_label(element, common)
	local output = common.variable .." = guiCreateLabel(".. common.position ..", ".. common.size ..", \"".. common.text .."\", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.fontString
	output = output .. common.propertiesString	
	
	if common.colour then
		output = output .. "\nguiLabelSetColor(".. common.variable ..", ".. common.colour.r ..", ".. common.colour.g ..", ".. common.colour.b ..")"
	end
	
	if guiLabelGetHorizontalAlign(element) ~= "left" or guiLabelGetWordwrap(element) then
		output = output .. "\nguiLabelSetHorizontalAlign(".. common.variable ..", \"".. guiLabelGetHorizontalAlign(element) .."\", ".. tostring(guiLabelGetWordwrap(element)) ..")"
	end
	
	if guiLabelGetVerticalAlign(element) ~= "top" then
		output = output .. "\nguiLabelSetVerticalAlign(".. common.variable ..", \"".. guiLabelGetVerticalAlign(element) .."\")"
	end
	
	return output
end


function generateCode_checkbox(element, common)
	local output = common.variable .." = guiCreateCheckBox(".. common.position ..", ".. common.size ..", \"".. common.text .."\", ".. tostring(guiCheckBoxGetSelected(element))..", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.fontString
	output = output .. common.propertiesString	
	
	if common.colour then
		output = output .. "\nguiSetProperty(".. common.variable ..", \"NormalTextColour\", \"".. rgbaToHex(common.colour.r, common.colour.g, common.colour.b, common.colour.a) .."\")"
	end
	
	--if guiCheckBoxGetSelected(element) then
	--	output = output .. "\nguiCheckBoxSetSelected(".. common.variable ..", true)"
	--end
	
	return output
end


function generateCode_edit(element, common)
	local output = common.variable .." = guiCreateEdit(".. common.position ..", ".. common.size ..", \"".. common.text .."\", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.fontString
	output = output .. common.propertiesString	
	
	if common.colour then
		output = output .. "\nguiSetProperty(".. common.variable ..", \"NormalTextColour\", \"".. rgbaToHex(common.colour.r, common.colour.g, common.colour.b, common.colour.a) .."\")"
	end
	
	if guiGetReadOnly(element) then
		output = output .. "\nguiEditSetReadOnly(".. common.variable ..", true)"
	end
	
	if guiEditGetMasked(element) then
		output = output .. "\nguiEditSetMasked(".. common.variable ..", true)"
	end
	
	if guiEditGetMaxLength(element) ~= 65535 then
		output = output .. "\nguiEditSetMaxLength(".. common.variable ..", "..tostring(guiEditGetMaxLength(element))..")"
	end
	
	return output
end


function generateCode_progressbar(element, common)
	local output = common.variable .." = guiCreateProgressBar(".. common.position ..", ".. common.size ..", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.propertiesString	
	
	if guiProgressBarGetProgress(element) > 0 then
		output = output .. "\nguiProgressBarSetProgress(".. common.variable ..", "..tostring(guiProgressBarGetProgress(element))..")"
	end

	return output
end


function generateCode_radiobutton(element, common)
	local output = common.variable .." = guiCreateRadioButton(".. common.position ..", ".. common.size ..", \"".. common.text .."\", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.fontString
	output = output .. common.propertiesString	
	
	if common.colour then
		output = output .. "\nguiSetProperty(".. common.variable ..", \"NormalTextColour\", \"".. rgbaToHex(common.colour.r, common.colour.g, common.colour.b, common.colour.a) .."\")"
	end
	
	if guiRadioButtonGetSelected(element) then
		output = output .. "\nguiRadioButtonSetSelected(".. common.variable ..", true)"
	end
	
	return output
end


function generateCode_gridlist(element, common)
	local output = common.variable .." = guiCreateGridList(".. common.position ..", ".. common.size ..", " .. common.relative .. common.parent
	
	for i = 1, guiGridListGetColumnCount(element) do
		local text = getElementData(element, "guieditor:gridlistColumnTitle."..tostring(i))

		output = output .. "\nguiGridListAddColumn(".. common.variable ..", \"".. tostring(text or "") .."\", ".. string.format("%.1f", 0.9 / guiGridListGetColumnCount(element)) ..")"					
	end
	
	if guiGridListGetRowCount(element) > 1 then
		output = output .. "\nfor i = 1, ".. tostring(guiGridListGetRowCount(element)) .." do\n    guiGridListAddRow(".. common.variable ..")\nend"
	elseif guiGridListGetRowCount(element) == 1 then
		output = output .. "\nguiGridListAddRow(".. common.variable ..")"
	end
	
	for row = 1, guiGridListGetRowCount(element) do
		for i = 1, guiGridListGetColumnCount(element) do
			output = output .. "\nguiGridListSetItemText(".. common.variable ..", "..tostring(row - 1)..", "..tostring(i)..", \"".. tostring(guiGridListGetItemText(element, row - 1, i)) .."\", false, false)"
			
			local r, g, b, a = guiGridListGetItemColor(element, row - 1, i)
			if r and (r ~= 255 or g ~= 255 or b ~= 255 or a ~= 255) then
				output = output .. "\nguiGridListSetItemColor(".. common.variable ..", "..tostring(row - 1)..", "..tostring(i)..", "..tostring(r)..", "..tostring(g)..", "..tostring(b)..", "..tostring(a)..")"
			end
		end
	end	
	
	output = output .. common.alphaString
	output = output .. common.propertiesString	
	
	return output
end


function generateCode_tabpanel(element, common)
	local output = common.variable .." = guiCreateTabPanel(".. common.position ..", ".. common.size ..", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.propertiesString	
	
	return output
end


function generateCode_tab(element, common)
	local parent = guiGetParent(element)
	
	-- if this happens bad stuff has gone down
	if not parent then
		return ""
	end

	local output = common.variable .." = guiCreateTab(\"".. tostring(guiGetProperty(element, "Text")) .."\", ".. tostring(getElementVariable(parent)) ..")"
	
	output = output .. common.propertiesString	
	
	return output	
end


function generateCode_staticimage(element, common)
	local path = getElementData(element, "guieditor:imagePath")
	
	if path:sub(1, 1) == ":" then
		Generation.usingCustomImage = true
	end
	
	local output = common.variable .." = guiCreateStaticImage(".. common.position ..", ".. common.size ..", \"".. tostring(path) .."\", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.propertiesString	
	
	if common.colour then
		local col = rgbaToHex(common.colour.r, common.colour.g, common.colour.b, common.colour.a)

		output = output .. "\nguiSetProperty(".. common.variable ..", \"ImageColours\", \"tl:".. col .." tr:".. col .." bl:".. col .." br:".. col .."\")"
	end
	
	return output
end


function generateCode_scrollbar(element, common)
	local vertical = toBool(guiGetProperty(element, "VerticalScrollbar"))
	local output = common.variable .." = guiCreateScrollBar(".. common.position ..", ".. common.size ..", ".. (vertical and "false" or "true") ..", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.propertiesString	
	
	if guiScrollBarGetScrollPosition(element) > 0 then
		output = output .. "\nguiScrollBarSetScrollPosition(".. common.variable ..", ".. string.format("%.1f", guiScrollBarGetScrollPosition(element)) ..")"
	end
	
	return output
end


function generateCode_scrollpane(element, common)
	local output = common.variable .." = guiCreateScrollPane(".. common.position ..", ".. common.size ..", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.propertiesString	

	return output
end


function generateCode_combobox(element, common)
	local output = common.variable .." = guiCreateComboBox(".. common.position ..", ".. common.size ..", \"".. common.text .."\", " .. common.relative .. common.parent
	
	output = output .. common.alphaString
	output = output .. common.fontString
	output = output .. common.propertiesString	
	
	if common.colour then
		output = output .. "\nguiSetProperty(".. common.variable ..", \"NormalEditTextColour\", \"".. rgbaToHex(common.colour.r, common.colour.g, common.colour.b, common.colour.a) .."\")"
	end
	
	for i = 1, guiComboBoxGetItemCount(element) do
		output = output .. "\nguiComboBoxAddItem(".. common.variable ..", \""..tostring(guiComboBoxGetItemText(element, i - 1)).."\")"
	end
	
	local selected = guiComboBoxGetSelected(element)
	
	if selected and selected ~= -1 then
	--	output = output .. "\nguiComboBoxSetSelected(".. common.variable ..", "..tostring(selected)..")"
	end
	
	return output
end



--[[
addEventHandler("onClientResourceStart",resourceRoot,
	function()
		guiCreateButton(100,400,40,40,"",false)
		guiCreateCheckBox(100,450,40,40,"",false,false)
		guiCreateEdit(100,500,40,40,"",false)
		guiCreateGridList(100,550,40,40,false)
		guiCreateMemo(100,600,40,40,"",false)
		
		guiCreateProgressBar(200,400,40,40,false)
		guiCreateRadioButton(200,450,40,40,"",false)
		guiCreateScrollBar(200,500,40,40,false,false)
		guiCreateScrollPane(200,550,40,40,false)
		guiCreateStaticImage(200,600,40,40,":freeroam/playerblip.png",false)
		
		guiCreateTabPanel(300,400,40,40,false)
		guiCreateTab("tab",guiCreateTabPanel(300,450,40,40,false))	
		guiCreateLabel(300,500,40,40,"label",false)
		guiCreateWindow(300,550,40,40,"",false)
		guiCreateComboBox(300,600,40,40,"",false)
		
		addEventHandler("onClientMouseEnter",root,
			function()
				if hasColour(source) then
					local r, g, b, a = guiGetColour(source)
					outputDebug(string.format("%s: %i %i %i %i",getElementType(source), r, g, b, a))
				end
			end
		)			
	end
)
]]