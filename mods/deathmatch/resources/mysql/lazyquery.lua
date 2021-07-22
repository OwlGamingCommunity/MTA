function lazyQuery(message)
	local file = createFileIfNotExists("/maxime.log")
	if file then
		local size = fileGetSize(file)
		fileSetPos(file, size)
		fileWrite(file, message .. "\r\n")
		fileFlush(file)
		fileClose(file)
		
		return true
	else 
		outputDebugString("[LOGS] lazyQuery / createFileIfNotExists / Could not open or create log file.")
		return false
	end
end

function createFileIfNotExists(filename)
	local file = nil
	if fileExists ( filename ) then
		file = fileOpen(filename)
	else
		file = fileCreate(filename)
	end
	return file
end