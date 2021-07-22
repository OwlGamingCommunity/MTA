mysql = exports.mysql

function increaseLanguageSkill(player, language)
	local hasLanguage, slot = doesPlayerHaveLanguage(player, language)
	if (hasLanguage) then
		local currSkill = tonumber(getElementData(player, "languages.lang" .. slot .. "skill"))
		if currSkill < 100 then
			local chance = math.random(1, math.max( math.ceil( currSkill / 3 ), 8 ) )
			if chance == 1 then
				triggerClientEvent(player, "increaseInSkill", player, language)
				exports.anticheat:changeProtectedElementDataEx(player, "languages.lang" .. slot .. "skill", currSkill+1, false)
				dbExec(exports.mysql:getConn("mta"), "UPDATE characters SET lang" .. slot .. "skill = ? WHERE id = ?", currSkill + 1, getElementData(player, "dbid"))
			end
		end
	end
end

function doesPlayerHaveLanguage(player, language)
	if not player or not isElement(player) then
		return false, nil
	end
	local lang1 = getElementData(player, "languages.lang1")
	local lang2 = getElementData(player, "languages.lang2")
	local lang3 = getElementData(player, "languages.lang3")
	
	if (lang1==language) then
		return true, 1
	elseif (lang2==language) then
		return true, 2
	elseif (lang3==language) then
		return true, 3
	else
		return false, nil
	end
end

function removeLanguage(player, language)
	local hasLanguage, slot = doesPlayerHaveLanguage(player, language)
	
	if (hasLanguage) then
		-- unbindKey(player, tostring(slot), "down", "chatbox")
		exports.anticheat:changeProtectedElementDataEx(player, "languages.lang" .. slot, 0, false)
		exports.anticheat:changeProtectedElementDataEx(player, "languages.lang" .. slot .. "skill", 0, false)
		dbExec(exports.mysql:getConn("mta"), "UPDATE characters SET lang"..slot.." = 0, lang"..slot.."skill = 0 WHERE id = ?", getElementData(player, "dbid"))
		return true
	else
		return false
	end
end

function getSkillFromLanguage(player, language)
	local lang1 = getElementData(player, "languages.lang1")
	local lang2 = getElementData(player, "languages.lang2")
	local lang3 = getElementData(player, "languages.lang3")
	
	if (lang1==language) then
		return getElementData(player, "languages.lang1skill")
	elseif (lang2==language) then
		return getElementData(player, "languages.lang2skill")
	elseif (lang3==language) then
		return getElementData(player, "languages.lang3skill")
	else
		return 0
	end
end

function applyLanguage(from, player, message, language)
	local level, duty = getElementData( player, "admin_level" ), getElementData( player, "duty_admin" )
	if not level or level == 0 or not duty or duty == 0 then
		local skill = getSkillFromLanguage(player, language)
		local fromskill = getSkillFromLanguage(from, language)
		
		local length = message and string.len(message) or 0
		local percent = 100 - math.min( skill, fromskill )
		local replace = (percent/100) * length
		
		local i = 1
		
		while ( i < replace ) do
			local char = string.sub(message, i, i)
			if (char~="") and (char~=" ") then
				local replacechar
				
				if (string.byte(char)>=65 and string.byte(char)<=90) then -- upper char
					replacechar = string.char(math.random(65, 90))
				elseif (string.byte(char)>=97 and string.byte(char)<=122) then -- lower char
					replacechar = string.char(math.random(97, 122))
				end
				
				if (string.byte(char)>=65 and string.byte(char)<=90) or (string.byte(char)>=97 and string.byte(char)<=122) then
					message = string.gsub(message, tostring(char), replacechar, 1)
				end
			end
			i = i + 1
		end
		
		if fromskill > skill or skill < 85 then
			increaseLanguageSkill(player, language)
		end
	end
	return message
end

-- Bind Keys required
function bindKeys()
	local players = exports.pool:getPoolElementsByType("player")
	for k, arrayPlayer in ipairs(players) do
		if not(isKeyBound(arrayPlayer, "F6", "down", showLanguages)) then
			bindKey(arrayPlayer, "F6", "down", showLanguages)
		end
	end
end

function bindKeysOnJoin()
	bindKey(source, "F6", "down", showLanguages)
end
addEventHandler("onResourceStart", getResourceRootElement(), bindKeys)
addEventHandler("onPlayerJoin", getRootElement(), bindKeysOnJoin)

function showLanguages(player)
	local langs = { }
	local count = 1
	
	for i = 1, 3 do
		local language = getElementData(player, "languages.lang" .. i)
		local skill = getElementData(player, "languages.lang" .. i .. "skill")
		if (language) and (language>0) then
			langs[i] = { language, skill }
		end
	end

	local currLang = getElementData(player, "languages.current") or 1
	
	triggerClientEvent(player, "showLanguages", player, langs, currLang)
end

function getNextLanguageSlot(player)
	local lang1 = getElementData(player, "languages.lang1")
	local lang2 = getElementData(player, "languages.lang2")
	local lang3 = getElementData(player, "languages.lang3")
	
	if lang1>0 then return 1
	elseif lang2>0 then return 1
	elseif lang3>0 then return 1
	else return 0
	end
end

function learnLanguage(player, lang, showmessages, skill)
	local hasLanguage, slot = doesPlayerHaveLanguage(player, lang)

	if (hasLanguage) then
		if showmessages then
			outputChatBox("You already know " .. languages[lang] .. ".", player, 255, 0, 0)
		end
		
		if skill then
			exports.anticheat:changeProtectedElementDataEx(player, "languages.lang" .. slot .. "skill", skill, false)
			dbExec(exports.mysql:getConn("mta"), "UPDATE characters SET lang"..slot.." = ?, lang"..slot.."skill = ? WHERE id = ?", lang, skill or 0, getElementData(player, "dbid"))
			return true
		end
		return false, "Already knows " .. languages[lang]
	else
		local freeslot = getNextEmptyLanguageSlot(player)

		if (freeslot==0) then
			if showmessages then
				outputChatBox("You do not have enough space to learn this language.", player, 255, 0, 0)
			end
			return false, "Not enough Space"
		else
			
			exports.anticheat:changeProtectedElementDataEx(player, "languages.lang" .. freeslot, lang, false)
			exports.anticheat:changeProtectedElementDataEx(player, "languages.lang" .. freeslot .. "skill", skill or 0, false)
			dbExec(exports.mysql:getConn("mta"), "UPDATE characters SET lang"..freeslot.." = ?, lang"..freeslot.."skill = ? WHERE id = ?", lang, skill or 0, getElementData( player, "dbid" ))
			
			-- bindKey(player, tostring( freeslot ), "down", "chatbox", getLanguageName( lang ))

			return true
		end
	end
	return false, "?"
end

function getNextEmptyLanguageSlot(player)
	local lang1 = getElementData(player, "languages.lang1")
	local lang2 = getElementData(player, "languages.lang2")
	local lang3 = getElementData(player, "languages.lang3")

	if (not lang1) or (lang1==0) then
		return 1
	elseif (not lang2) or (lang2==0) then
		return 2
	elseif (not lang3) or (lang3==0) then
		return 3
	else
		return 0
	end
end

function useLanguage(lang)
	local hasLanguage, slot = doesPlayerHaveLanguage(source, lang)
	
	if (hasLanguage) then
		outputChatBox("You are now using " .. getLanguageName(lang) .. " as your language.", source, 255, 194, 14)
		exports.anticheat:changeProtectedElementDataEx(source, "languages.current", slot, false)
		dbExec(exports.mysql:getConn("mta"), "UPDATE characters SET currLang = ? WHERE id = ?", slot, getElementData(source, "dbid"))
		
		showLanguages(source)
	end
end
addEvent("useLanguage", true)
addEventHandler("useLanguage", getRootElement(), useLanguage)

function unlearnLanguage(lang)
	local hasLanguage, slot = doesPlayerHaveLanguage(source, lang)
	
	if (hasLanguage) then
		removeLanguage(source, lang)
		outputChatBox("You have unlearned " .. getLanguageName(lang) .. ".", source, 255, 194, 14)
		
		local nextSlot = getNextLanguageSlot(source)
		exports.anticheat:changeProtectedElementDataEx(source, "languages.current", nextSlot, false)
		dbExec(exports.mysql:getConn("mta"), "UPDATE characters SET currLang = ? WHERE id = ?", nextSlot, getElementData(source, "dbid"))
		showLanguages(source)
	end
end
addEvent("unlearnLanguage", true)
addEventHandler("unlearnLanguage", getRootElement(), unlearnLanguage)

-- ////////////////////////////////////
-- //		CHATBOX BINDS			 //
-- ////////////////////////////////////
for key, value in pairs( languages ) do
	function speakLang( thePlayer, commandName, ... )
		if doesPlayerHaveLanguage( thePlayer, key ) then
			call( getResourceFromName( "chat-system" ), "localIC", thePlayer, table.concat({...}, " "), key )
		else
			outputChatBox( "You do not speak " .. value .. ".", thePlayer, 255, 0, 0 )
		end
	end
	
	addCommandHandler( value, speakLang, false, false )
	
	if key == 1 then
		addCommandHandler( "en", speakLang, false, false ) -- English
	elseif key == 4 then -- disable /fr for french
		addCommandHandler( "fre", speakLang, false, false )
	elseif key == 15 then
		addCommandHandler( "ws", speakLang, false, false ) -- Welsh
	else
		addCommandHandler( flags[key], speakLang, false, false )
	end
end

--[[
-- requires fix for http://bugs.mtasa.com/view.php?id=4927, otherwise the keys wouldn't unbind on character change
addEventHandler( "savePlayer", getRootElement(),
	function( reason )
		if reason == "Change Character" then
			for i = 1, 3 do
				unbindKey(source, tostring(i), "down", "chatbox")
			end
		end
	end
)

--

function loadBinds(source)
	for i = 1, 3 do
		if tonumber( getElementData( source, "languages.lang" .. i ) ) ~= 0 then
			local name = getLanguageName( tonumber( getElementData( source, "languages.lang" .. i ) ) )
			if name then
				bindKey(source, tostring(i), "down", "chatbox", name)
			end
		end
	end
end

addEventHandler( "onCharacterLogin", getRootElement(), function() loadBinds( source ) end )
addEventHandler( "onResourceStart", getResourceRootElement(),
	function( )
		for k, v in pairs(getElementsByType("player")) do
			if getElementData(v, "logged") == 1 then
				loadBinds(v)
			end
		end
	end
)]]