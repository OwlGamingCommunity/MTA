local lastLogType = -1
local lastData = ""
local lastLogsource = getRootElement()
local sourceResourceName
local LOG_FILE
local timer
local yearday = getRealTime().yearday
local LOG_FILE_NAME = "logs/log-" .. yearday .. ".log"

local accounts_table = {}
local characters_table = {}
local vehicles_table = {}
local interiors_table = {}
local phones_table = {}
local factions_table = {}
local objects_table = {}

-- Log Structure, toJSON
--[[
	logEntry = {
		date = unixtimestamp, -- OR an ISO datetime format
		action = 123,
		source = "ch123" or "ac123", -- For character number or account
		content = "log text",
		-- AFFECTED
		characters = [],
		accounts = [],
		vehicles = [],
		interiors = [],
		phones = [],
		factions = [],
		objects = []
	}
]]

-- Log prefixes
-- ac	AccountID
-- ch	CharacterID
-- ve	Vehicle
-- fa	Faction
-- in	Interior
-- ph	Phone
-- ob 	Object

-- Action ID's
-- 1 Admin chat /h			x
-- 2 Admin chat /l			x
-- 3 Admin chat /a			x
-- 4 Admin command
-- 5 Anticheat
-- 6 Vehicle related things
-- 7 Player /say			x
-- 8 Player /b				x
-- 9 Player /r				x
-- 10 Player /d				x
-- 11 Player /f				x
-- 12 Player /me's			x
-- 13 Player /destrict's		x
-- 14 Player /do's			x
-- 15 Player /pm's			x
-- 16 Player /gov			x
-- 17 Player /don			x
-- 18 Player /o				x
-- 19 Player /s				x
-- 20 Player /m				x
-- 21 Player /w				x
-- 22 Player /c				x
-- 23 Player /n				x
-- 24 Gamemaster chat /g	x
-- 25 Cash transfer			x
-- 26 GameCoins				x
-- 27 Connection			x
-- 28 Roadblocks			x
-- 29 Phone logs			x
-- 30 SMS logs				x
-- 31 Int/Vehicle actions (locking/unlocking/start/enter/exit)x
-- 32 UCP logs
-- 33 Stattransfers			x
-- 34 Kill logs/Lost items	x
-- 35 Faction actions		x
-- 36 Ammunation			x
-- 37 Interior related things		x
-- 38 Admin Reports
-- 39 Item Movement			x
-- 40 Player /ame /ado
-- 41 Business Chat
-- 42 /st

addEventHandler("onResourceStart", resourceRoot, function()
	if fileExists(LOG_FILE_NAME) then
		LOG_FILE = fileOpen(LOG_FILE_NAME)
		fileSetPos(LOG_FILE, fileGetSize(LOG_FILE))
	else
		fileCreate(LOG_FILE_NAME)
		LOG_FILE = fileOpen(LOG_FILE_NAME)
	end
	deleteOldFiles()
end)

addEventHandler("onResourceStop", resourceRoot, function()
	fileClose(LOG_FILE)
end)

local function resetElementTables()
	accounts_table = {}
	characters_table = {}
	vehicles_table = {}
	interiors_table = {}
	phones_table = {}
	factions_table = {}
	objects_table = {}
end

local function elementTablesAreEmpty()
	return #characters_table == 0
			and #accounts_table == 0
			and #vehicles_table == 0
			and #interiors_table == 0
			and #phones_table == 0
			and #factions_table == 0
			and #objects_table == 0
end

function dbLog(logSource, actionID, affected, data)
	resetElementTables()

	lastLogType = actionID
	lastData = data
	lastLogsource = logSource
	sourceResourceName = getResourceName(sourceResource)

	-- Check the source
	if logSource == nil then
		printError("No logSource on " .. tostring(actionID), sourceResourceName, data)
		return false
	end
	local sourceStr = dbLogDetectTypeSource(logSource)
	if not sourceStr then
		printError("No sourceStr on " .. tostring(actionID), sourceResourceName, data)
		return false
	end

	-- Check the action
	if actionID == nil then
		printError("No actionID", sourceResourceName, data)
		return false
	end
	if not tonumber(actionID) then
		printError("actionID is not numeric", sourceResourceName, data)
		return false
	end

	-- check affected people
	if affected == nil then
		printError("No affected", sourceResourceName, data)
		return false
	end
	generateElementTables(affected)

	if elementTablesAreEmpty() then
		printError("No affected in tables", sourceResourceName, data)
		return false
	end

	-- Check data
	if not data then
		printError("No passed data", sourceResourceName, data)
		data = "N/A"
	end
    
    -- Get current date and time
    local dt = getRealTime()
	-- Structure the data
	local buffer = {
		date = string.format("%03d-%02d-%02dT%02d:%02d:%02d", dt.year + 1900, dt.month + 1, dt.monthday, dt.hour, dt.minute, dt.second),
		-- date = tonumber(getRealTime().timestamp) * 1000, -- We want miliseconds, not seconds. (Disabled temporary until MTA solves their float issues with JSON.)
		action = tonumber(actionID),
		origin = sourceStr, -- Use origin because 'source' conflicts with elasticsearch
		content = data,
		-- AFFECTED
		characters = characters_table,
		accounts = accounts_table,
		vehicles = vehicles_table,
		interiors = interiors_table,
		phones = phones_table,
		factions = factions_table,
		objects = objects_table
	}
	--local buffer = buffer:sub(2, -2)]] -- If we kept the [] then it would be a JSON array and not a JSON object. We want a JSON object for Elasticsearch
	return logData(toJSON(buffer, true):sub(2, -2))
end

function dbLogDetectTypeSource(theElement)
	local sourceType = type(theElement)
	if sourceType == 'string' then
		return theElement
	elseif sourceType == 'userdata' then
		-- an Element
		local possibleResult = getElementLogString(theElement)
		if not possibleResult then
			printError("Unknown element theElement on " .. tostring(lastLogType) .. ":" .. tostring(lastLogsource), sourceResourceName, data)
			return
		end
		return possibleResult
	end
	return false
end

function getElementLogString(theElement)
	if isElement(theElement) then
		local elementType = getElementType(theElement)
		if (elementType == 'player') then
			local dbid = getElementData(theElement, "dbid")
			if dbid then
				return "ch" .. tostring(dbid)
			end
			printError("Source character ID missing", sourceResourceName, data)
		else
			printError("Source Log type mismatch: " .. getElementType(theElement), sourceResourceName, data)
		end
	end
	return false
end

local function getLogAffectedFromUserData(element)
	local elementType = getElementType(element)
	if (elementType == 'player') then
		local dbid = getElementData(element, "dbid")
		if dbid then
			table.insert(characters_table, dbid)
		end
	elseif (elementType == 'vehicle') then
		local dbid = getElementData(element, "dbid")
		if dbid then
			table.insert(vehicles_table, dbid)
		end
	elseif (elementType == 'team') then
		local dbid = getElementData(element, "id")
		if dbid then
			table.insert(factions_table, dbid)
		end
	elseif (elementType == 'interior') then
		local dbid = getElementData(element, "dbid")
		if dbid then
			table.insert(interiors_table, dbid)
		end
	elseif (elementType == 'object') then
		local dbid = getElementData(element, "id")
		if dbid then
			table.insert(objects_table, dbid)
		end
	else
		printError("Log type mismatch: " .. getElementType(affected), sourceResourceName, data)
	end
end

local function getLogAffectedFromString(affected)
	if string.find(affected, 'ph') then
		local affected = affected:gsub('ph', '')
		local affected = tonumber(affected)
		if affected then
			table.insert(phones_table, affected)
		end
	elseif string.find(affected, "ac") then
		local affected = affected:gsub('ac', '')
		local affected = tonumber(affected)
		if affected then
			table.insert(accounts_table, affected)
		end
	elseif string.find(affected, "in") then
		local affected = affected:gsub('in', '')
		local affected = tonumber(affected)
		if affected then
			table.insert(interiors_table, affected)
		end
	elseif string.find(affected, "ve") then
		local affected = affected:gsub('ve', '')
		local affected = tonumber(affected)
		if affected then
			table.insert(vehicles_table, affected)
		end
	elseif string.find(affected, "ch") then
		local affected = affected:gsub('ch', '')
		local affected = tonumber(affected)
		if affected then
			table.insert(characters_table, affected)
		end
	elseif string.find(affected, "fa") then
		local affected = affected:gsub('fa', '')
		local affected = tonumber(affected)
		if affected then
			table.insert(factions_table, affected)
		end
	else
		printError("Unknown string given for affected", sourceResourceName, data)
	end
end

function generateElementTables(affected)
	local sourceType = type(affected)
	if sourceType == 'string' then
		getLogAffectedFromString(affected)
	elseif sourceType == 'userdata' then
		if isElement(affected) then
			getLogAffectedFromUserData(affected)
		end
	elseif sourceType == 'table' then
		for _, element in pairs(affected) do
			if isElement(element) then
				getLogAffectedFromUserData(element)
			elseif type(element) == 'string' then
				getLogAffectedFromString(element)
			end
		end
	end
end

function flushFile()
	if LOG_FILE then
		fileFlush(LOG_FILE)
	end
	timer = nil
end

function logData(jsondata)
	if LOG_FILE then
		fileWrite(LOG_FILE, jsondata .. "\r\n")
		if getRealTime().yearday ~= yearday then
			changeFile()
			deleteOldFiles()
		elseif not timer then
			timer = setTimer(flushFile, 1000, 1)
		end
		return true
	end
	return false
end

function changeFile()
	yearday = getRealTime().yearday
	LOG_FILE_NAME = "logs/log-" .. yearday .. ".log"
	fileClose(LOG_FILE)
	LOG_FILE = fileCreate(LOG_FILE_NAME)
end

function deleteOldFiles()
	-- Deletes files that are 3 days old
	local max_yearday = 365 -- Because 0 is included
	local tempDay = 0
	if yearday <= 2 then
		tempDay = max_yearday + yearday - 2
	else
		tempDay = yearday - 3
	end
	local tempName = "logs/log-" .. tempDay .. ".log"
	if fileExists(tempName) then
		fileDelete(tempName)
	end
end

function printError(error, resourceName, data)
	outputDebugString("logs:dbLog: " .. error .. " from " .. resourceName .. " " .. tostring(data))
end
