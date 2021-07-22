--[[--------------------------------------------------
	GUI Editor
	server
	server.lua
	
	various server side functions needed in the editor
--]]--------------------------------------------------


--[[--------------------------------------------------
	get files by type
--]]--------------------------------------------------

local getImageTime = {}
local getFontTime = {}

local images = {
	routine,
	images = {},
	waiting = {},
}

local files = {}

local resourceName = getResourceName(getThisResource())


addEventHandler("onResourceStart", resourceRoot, 
	function()
		if _DEBUG then
			for _,p in ipairs(getElementsByType("player")) do
				bindKey(p, "F2", "up", 
					function() 
						restartResource(resource)
					end
				)
			end
			
			addEventHandler("onPlayerJoin", root,
				function()
					bindKey(source, "F2", "up", 
						function() 
							restartResource(resource)
						end
					)				
				end
			)
		end
	end
)

addEvent("guieditor:server_getImages", true)
addEventHandler("guieditor:server_getImages", root,
	function()
		-- stop people being able to spam this
		if getImageTime[client] then
			if getImageTime[client] > (getTickCount() - 30000) then
				triggerClientEvent(client, "guieditor:client_getImages", client, false)
				return
			end
		end
		
		getImageTime[client] = getTickCount()
		
		files.png = { waiting = {}, files = {}, routine}
		
		files.png.waiting[client] = true
		
		if not files.png.routine or coroutine.status(files.png.routine) == "dead" then
			files.png.routine = coroutine.create(findFilesByType)
			coroutine.resume(files.png.routine, "png", "client_getImages")
		end
	end
)


addEvent("guieditor:server_getFonts", true)
addEventHandler("guieditor:server_getFonts", root,
	function()
		-- stop people being able to spam this
		if getFontTime[client] then
			if getFontTime[client] > (getTickCount() - 30000) then
				triggerClientEvent(client, "guieditor:client_getFonts", client)
				return
			end
		end
		
		getFontTime[client] = getTickCount()
		
		files.ttf = { waiting = {}, files = {}, routine}
		
		files.ttf.waiting[client] = true
		
		if not files.ttf.routine or coroutine.status(files.ttf.routine) == "dead" then
			files.ttf.routine = coroutine.create(findFilesByType)
			coroutine.resume(files.ttf.routine, "ttf", "client_getFonts")
		end
	end
)


function findFilesByType(extension, event)
	files[extension].files = {}
	local tick = getTickCount() + 600
	local permission = true

	for i,res in ipairs(getResources()) do
		local resourceName = tostring(getResourceName(res))
			
		if hasObjectPermissionTo(resource, "general.ModifyOtherObjects") then
			if fileExists(":"..resourceName.."/meta.xml") then
				local root = xmlLoadFile(":"..resourceName.."/meta.xml")
					
				if root then
					local index = 0
					local node = xmlFindChild(root, "file", index)
					local count = 1
					
					while node do
						local src = xmlNodeGetAttribute(node, "src")
							
						if src and src:sub(-#extension) == extension then
							if not files[extension].files[resourceName] then
								files[extension].files[resourceName] = {}
							end

							files[extension].files[resourceName][count] = {text = src}
							count = count + 1
						end
						
						if getTickCount() > tick then
							setTimer(
								function()
									tick = getTickCount() + 600
									coroutine.resume(files[extension].routine)
								end
							, 400, 1)
						
							coroutine.yield(files[extension].routine)
						end
						
						index = index + 1
						node = xmlFindChild(root, "file", index)
					end
					
					xmlUnloadFile(root)
				end
			end
		else
			permission = false
		end
	end
	
	if not permission then
		outputDebugString("GUI Editor requires ACL permission: general.ModifyOtherObjects to get ."..tostring(extension).." file list")
	end

	for player in pairs(files[extension].waiting) do
		triggerClientEvent(player, "guieditor:" .. event, player, files[extension].files, permission)
	end
end


--[[
addEvent("guieditor:server_startResource", true)
addEventHandler("guieditor:server_startResource", root,
	function(resourceName)
		if client ~= source then
			return
		end
		
		local resource = getResourceFromName(resource)
		
		if resource then
			startResource(resource, false, false, true, false, true, false, true, true, true)
		end
	end
)
]]



--[[--------------------------------------------------
	code output
--]]--------------------------------------------------

local output = {}


addEvent("guieditor:server_output", true)
addEventHandler("guieditor:server_output", root,
	function(filename, chunk, chunkID, chunks)
		if source ~= client then
			return
		end
		
		if not output[client] then
			output[client] = {parts = {[chunkID] = chunk}, start = getTickCount()}
		else
			-- if all the chunks have not arrived in 5 seconds, assume they never will
			if (output[client].start + 5000) < getTickCount() then
				output[client] = {parts = {[chunkID] = chunk}, start = getTickCount()}
			else
				output[client].parts[chunkID] = chunk
			end
		end
		
		if #output[client].parts == chunks then
			local t = getRealTime()
			
			filename = string.format("%s_%d-%d-%d_%d-%d", filename, t.year + 1900, t.month + 1, t.monthday, t.hour, t.minute)
			local baseFilename = filename
			local i = 2
			
			while fileExists(filename .. ".txt") do
				filename = baseFilename .. "_(" .. tostring(i) .. ")"
				i = i + 1
			end
			
			filename = filename .. ".txt"
			
			local file = fileCreate(filename)
			
			if file then
				for i,c in ipairs(output[client].parts) do
					fileWrite(file, c)
				end
				
				fileClose(file)
				
				outputDebug("GUI saved to '"..tostring(filename).."'")
				
				addOutputFile(filename)
				
				output[client] = nil
				
				triggerClientEvent(client, "guieditor:client_saveSuccess", client, filename)
			else
				outputDebug("Could not create file '"..tostring(filename).."'")
				
				triggerClientEvent(client, "guieditor:client_saveFailure", client, filename)
			end
		end
	end
)


addEvent("guieditor:server_getOutputFiles", true)
addEventHandler("guieditor:server_getOutputFiles", root,
	function()
		if source ~= client then
			return
		end
		
		triggerClientEvent(client, "guieditor:client_getOutputFiles", client, loadOutputFiles())
	end
)

function loadOutputFiles()
	local t
	
	if fileExists(":"..resourceName.."/output/files.txt") then
		local file = fileOpen(":"..resourceName.."/output/files.txt")
		
		if file then
			if fileGetSize(file) > 0 then
				local files = fileRead(file, fileGetSize(file))
				
				if files and files ~= "" then
					local tArray = split(files, "\n")
					t = {}
					
					for i,v in ipairs(tArray) do
						if v ~= "" then
							if not string.find(v:sub(-4), ".txt", 0, true) then
								v = v .. ".txt"
							end
							
							if not string.find(v, "/", 0, true) then
								v = ":"..resourceName.."/output/" .. v
							end
							
							if fileExists(v) then
								local f = fileOpen(v)
								
								if f then
									t[v] = fileGetSize(f)
									
									fileClose(f)
								else
									t[v] = true
								end
							end
						end
					end
				end
			end
			
			fileClose(file)
		end
	else
		local file = fileCreate(":"..resourceName.."/output/files.txt")
		
		if file then
			fileClose(file)
		end
	end	
	
	return t or {}
end


function addOutputFile(filename)
	local file
	
	if fileExists(":"..resourceName.."/output/files.txt") then
		file = fileOpen(":"..resourceName.."/output/files.txt")
	end
	
	if not file then
		file = fileCreate(":"..resourceName.."/output/files.txt")
	end
	
	if file then
		fileSetPos(file, fileGetSize(file))
		fileWrite(file, "\n" .. filename)
		
		fileClose(file)
	end
end



addEvent("guieditor:server_getOutputFile", true)
addEventHandler("guieditor:server_getOutputFile", root,
	function(filename, purpose)
		if source ~= client then
			return
		end
		
		local chunks, size = getFileContents(filename)
		
		if chunks then
			for i,chunk in ipairs(chunks) do
				triggerClientEvent(client, "guieditor:client_getOutputFile", client, filename, purpose, chunk, i, #chunks, size)
			end
			
			if purpose == "new" then
				local files = loadOutputFiles()
			
				if not files[filename] then
					addOutputFile(filename)
				end
			end			
		else
			triggerClientEvent(client, "guieditor:client_getOutputFile", client, nil, purpose)
		end
	end
)


function getFileContents(filepath)				
	if fileExists(filepath) then
		local file = fileOpen(filepath)
		
		if file then
			if fileGetSize(file) > 0 then
				local text = fileRead(file, fileGetSize(file))
				
				if text and text ~= "" then
					local chunks = {}
					local size = 65500
					
					while text:len() > size do
						chunks[#chunks + 1] = text:sub(0, size)
						text = text:sub(size + 1)
					end
						
					chunks[#chunks + 1] = text
	
					local size = fileGetSize(file)
					
					fileClose(file)
					
					return chunks, size
				end
			end
			
			fileClose(file)
			
			return {""}, 0
		end
	end

	return
end




--[[--------------------------------------------------
	update check
--]]--------------------------------------------------

addEvent("guieditor:server_checkUpdateStatus", true)
addEventHandler("guieditor:server_checkUpdateStatus", root,
	function(automatic)
		if client ~= source then
			return
		end
		
		-- allow client into the closure
		local player = client

		local called = callRemote("http://community.mtasa.com/mta/resources.php",
			function(name, version) 
				updateResult(name, version, player, automatic) 
			end,
		"version", --[[string.lower(getResourceName(getThisResource()))]] "guieditor")
		
		if not called then
			triggerClientEvent(client, "guieditor:client_getUpdateStatus", client, automatic, nil, nil, tostring(getResourceInfo(getThisResource(),"version")))
		end
	end
)


function updateResult(name, version, player, automatic)
	-- 19/07/2014 - this 404s
	-- 05/08/2014 - now it doesn't?
	if not (string.lower(name):find("error") or version == 0) then
		local away = parseVersion(tostring(version))
		local home = parseVersion(tostring(getResourceInfo(getThisResource(),"version")))
		local update = away > home

		triggerClientEvent(player, "guieditor:client_getUpdateStatus", player, automatic, update, version, tostring(getResourceInfo(getThisResource(),"version")))
	else
		triggerClientEvent(player, "guieditor:client_getUpdateStatus", player, automatic, nil, version, tostring(getResourceInfo(getThisResource(),"version")))
	end
end


function parseVersion(version)
	local parts = split(version,string.byte("."))
	
	return tonumber(parts[1]..parts[2]..parts[3])
end



--[[--------------------------------------------------
	sharing
--]]--------------------------------------------------
local sharing = {}
local shared = {}

-- sending your code to someone else
addEvent("guieditor:server_sendShare", true)
addEventHandler("guieditor:server_sendShare", root,
	function(recipient, chunk, chunkID, chunks)
		if source ~= client then
			return
		end
		
		if not sharing[client] then
			sharing[client] = {parts = {[chunkID] = chunk}, start = getTickCount()}
		else
			-- if all the chunks have not arrived in 5 seconds, assume they never will
			if (sharing[client].start + 5000) < getTickCount() then
				sharing[client] = {parts = {[chunkID] = chunk}, start = getTickCount()}
			else
				sharing[client].parts[chunkID] = chunk
			end
		end
		
		if #sharing[client].parts == chunks then
			if not shared[client] then
				shared[client] = {}
			end
			
			shared[client].parts = sharing[client].parts
			
			if not shared[client].recipients then
				shared[client].recipients = {}
			end
			
			sharing[client] = nil
			
			if recipient and isElement(recipient) then
				shared[client].recipients[recipient] = true

				triggerClientEvent(recipient, "guieditor:client_receiveShareNotification", recipient, client)
			end
		end
	end
)


-- asking for code from someone
addEvent("guieditor:server_requestShare", true)
addEventHandler("guieditor:server_requestShare", root,
	function(from)
		if source ~= client then
			return
		end
		
		if shared[from] and shared[from].recipients then
			if shared[from].recipients[client] then
				for i,chunk in ipairs(shared[from].parts) do
					triggerClientEvent(client, "guieditor:client_receiveShare", client, from, chunk, i, #shared[from].parts)
				end
			end
		end
	end
)