-- Displaying the increase in skill
local sx, sy, text, count, addedEvent, alpha
local langInc = 0

function increaseInSkill(language)
	local localPlayer = getLocalPlayer()
	
	local x, y, z = getPedBonePosition(localPlayer, 6)
	sx, sy = getScreenFromWorldPosition(x, y, z+0.2, 100, false)
	
	langInc = langInc + 1
	
	text = "+" .. langInc .. " " .. languages[language] .. " (" .. string.gsub(getPlayerName(source), "_", " ") .. ")"
	
	count = 0
	alpha = 255
	if not (addedEvent) then
		addedEvent = true
		addEventHandler("onClientRender", getRootElement(), renderText)
	end
end
addEvent("increaseInSkill", true)
addEventHandler("increaseInSkill", getRootElement(), increaseInSkill)

function renderText()
	if not sx or not sy then return end
	count = count + 1
	dxDrawText(text, sx-150, sy, sx+200, sy+50, tocolor(255, 255, 255, alpha), 1, "diploma", "center", "center")
	
	sy = sy - 3
	alpha = alpha - 6
	
	if (alpha<0) then alpha = 0 end
	
	if (count>50) then
		removeEventHandler("onClientRender", getRootElement(), renderText)
		addedEvent = false
		langInc = 0
	end
end

tlanguages = nil
currslot = nil
wLanguages = nil
function displayGUI(remotelanguages, rcurrslot)
	local logged = getElementData(getLocalPlayer(), "loggedin")
	if (logged == 1) then
	if not (wLanguages) then
		local width, height = 600, 400
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)
		
		wLanguages = guiCreateWindow(x, y, width, height, "Languages: " .. string.gsub(getPlayerName(localPlayer), "_", " "), false)
		
		tlanguages = remotelanguages
		currslot = tonumber(rcurrslot)

		local offset = 0.06

		for i = 1, 3 do
			local L = tlanguages[i]
			if L then
				local lang, skill = unpack(L)
				local imgLang = guiCreateStaticImage(0.05, 0.1+offset, 0.025, 0.025, ":social/images/flags/" .. (flags[lang] or 'zz') .. ".png", true, wLanguages)
				local lLangName = guiCreateLabel(0.1, 0.092+offset, 0.9, 0.1, getLanguageName(lang), true, wLanguages)
				guiSetFont(lLangName, "default-bold-small")
				
				if languages[lang] then
					local pLangSkill = guiCreateProgressBar(0.1, 0.14+offset, 0.6, 0.05, true, wLanguages)
					guiProgressBarSetProgress(pLangSkill, skill)
					
					local lLang1Skill = guiCreateLabel(0.73, 0.14+offset, 0.2, 0.1, skill .. "/100", true, wLanguages)
					guiSetFont(lLang1Skill, "default-bold-small")
					
					if currslot == i then
						guiSetText(lLangName, guiGetText(lLangName) .. " (Current)")
					else
						local bUse = guiCreateButton(0.83, 0.08+offset, 0.2, 0.05, "Use", true, wLanguages)
						addEventHandler('onClientGUIClick', bUse,
							function(button)
								if button == 'left' then
									triggerServerEvent("useLanguage", localPlayer, lang)
								end
							end, false)
					end
				end

				if currslot ~= i then
					local bUnlearnLang = guiCreateButton(0.83, 0.14+offset, 0.2, 0.05, "Un-learn", true, wLanguages)
					addEventHandler('onClientGUIClick', bUnlearnLang,
						function(button)
							if button == 'left' then
								unlearnLanguage(lang)
							end
						end, false)
				end
				offset = offset + 0.3
			end
		end
		
		showCursor(true)
		local bClose = guiCreateButton(0.05, 0.92, 0.9, 0.07, "Close", true, wLanguages)
		addEventHandler("onClientGUIClick", bClose, hideGUI, false)
	else
		guiSetInputEnabled(false)
		hideGUI()
	end
end
end
addEvent("showLanguages", true)
addEventHandler("showLanguages", getLocalPlayer(), displayGUI)

function useLanguage(button, state)
	if (button=="left") then
		local lang = 0
		
		if (source==bUse1) then lang = tlanguages[1][1] end
		if (source==bUse2) then lang = tlanguages[2][1] end
		if (source==bUse3) then lang = tlanguages[3][1] end

		if (lang>0) then
			hideGUI()
			triggerServerEvent("useLanguage", localPlayer, lang)
		end
	end
end

function unlearnLanguage(lang)
	if lang > 0 then
		if not languages[lang] then
			hideGUI()
			triggerServerEvent("unlearnLanguage", localPlayer, lang)
		else
			local sx, sy = guiGetScreenSize() 
			wConfirmUnlearn = guiCreateWindow(sx/2 - 125,sy/2 - 50,250,100,"Leaving Confirmation", false)
			local lQuestion = guiCreateLabel(0.05,0.25,0.9,0.3,"Do you really want to forget all your knowledge of " .. getLanguageName( lang ) .. "?",true,wConfirmUnlearn)
			guiLabelSetHorizontalAlign (lQuestion,"center",true)
			local bYes = guiCreateButton(0.1,0.65,0.37,0.23,"Yes",true,wConfirmUnlearn)
			local bNo = guiCreateButton(0.53,0.65,0.37,0.23,"No",true,wConfirmUnlearn)
			addEventHandler("onClientGUIClick", getRootElement(), 
				function(button)
					if button=="left" and ( source == bYes or source == bNo ) then
						if source == bYes then
							hideGUI()
							triggerServerEvent("unlearnLanguage", localPlayer, lang)
						end
						if wConfirmUnlearn then
							destroyElement(wConfirmUnlearn)
							wConfirmUnlearn = nil
						end
					end
				end
			)
		end
	end
end

function hideGUI()
	if (wLanguages) then
		destroyElement(wLanguages)
	end
	wLanguages = nil
	
	if wConfirmUnlearn then
		destroyElement(wConfirmUnlearn)
	end
	wConfirmUnlearn = nil
	
	bUnlearnLang1 = nil
	bUnlearnLang2 = nil
	bUnlearnLang3 = nil
	
	showCursor(false)
	
end