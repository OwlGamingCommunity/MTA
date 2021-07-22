local _toJSON = toJSON
function toJSON(str)
	return base64Encode(_toJSON(str))
end

local _fromJSON = fromJSON
function fromJSON(str)
	return _fromJSON(base64Decode(str))
end

function jsonGET(file, private)
	if private then
		file = "@JSON_FILES/"..file..".json"
	else
		file = "JSON_FILES/"..file..".json"
	end
	local fileHandle
	local jsonDATA = {}
	if not fileExists(file) then
		return {}
	else
		fileHandle = fileOpen(file)
	end
	if fileHandle then
		local buffer
		local allBuffer = ""
		while not fileIsEOF(fileHandle) do
			buffer = fileRead(fileHandle, 500)
			allBuffer = allBuffer..buffer
		end
		jsonDATA = fromJSON(allBuffer)
		fileClose(fileHandle)
	end
	return jsonDATA
end

function jsonSAVE(file, data, private)
	if private then
		file = "@JSON_FILES/"..file..".json"
	else
		file = "JSON_FILES/"..file..".json"
	end
	if fileExists(file) then
		fileDelete(file)
	end
	local fileHandle = fileCreate(file)
	fileWrite(fileHandle, toJSON(data))
	fileFlush(fileHandle)
	fileClose(fileHandle)
	return true
end