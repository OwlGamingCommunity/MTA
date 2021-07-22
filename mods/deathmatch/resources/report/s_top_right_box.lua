local thisResourceElement = getResourceRootElement(getThisResource())

--MAXIME MAGIC
function updateUnansweredReports()
	local info = {}
	table.insert(info, {string.upper(" Unanswered Reports"), 255,194,14,255,1,"default-bold" })
	
	local count = 0
	for i = 1, 300 do
		local report = reports[i]
		if report then
			local reporter = report[1]
			local reported = report[2]
			local timestring = report[4]
			local admin = report[5]
			local staff, _, name, abrv, r, g, b = getReportInfo(report[7])
			local seenReport = { }
			
			local handler = ""
			if (isElement(admin)) then
			--handler = tostring(getPlayerName(admin))
			else
				handler = "None."
				if staff then
					for k,v in ipairs(staff) do
						if string.find(adminTeams, v) and not seenReport[i] then
							table.insert(info, {abrv.." Report #" .. tostring(i) .. ": '" .. tostring(getPlayerName(reporter)) .. "' reporting '" .. tostring(getPlayerName(reported)) .. "' at " .. timestring .. ". Handler: " .. handler .. "", r, g, b})
							seenReport[i] = true
						end
					end
					count = count + 1
				end
			end
		end
	end
	
	if count == 0 then
		table.insert(info, {"None."})
	else
		--
	end

	setElementData(thisResourceElement, "urAdmin", info, true)
end

function updateUnansweredReportsGMs()
	local info = {}
	table.insert(info, {string.upper(" Unanswered GameMaster Reports"), 255,194,14,255,1,"default-bold" })
	
	local count = 0
	for i = 1, 300 do
		local report = reports[i]
		if report then
			local reporter = report[1]
			local reported = report[2]
			local timestring = report[4]
			local admin = report[5]
			local staff, _, name, abrv, r, g, b = getReportInfo(report[7])
			local seenReport = { }
			
			local handler = ""
			if (isElement(admin)) then
			--handler = tostring(getPlayerName(admin))
			else
				handler = "None."
				if staff then
					for k,v in ipairs(staff) do
						if SUPPORTER == v and not seenReport[i] then
							table.insert(info, {abrv.." Report #" .. tostring(i) .. ": '" .. tostring(getPlayerName(reporter)) .. "' reporting '" .. tostring(getPlayerName(reported)) .. "' at " .. timestring .. ". Handler: " .. handler .. "", r, g, b})
							seenReport[i] = true
						end
					end
					count = count + 1
				end
			end
		end
	end
	
	if count == 0 then
		table.insert(info, {"None."})
	else
		--
	end
	
	setElementData(thisResourceElement, "urGM", info, true)
end

function updateReports()
	local info = {}
	table.insert(info, {string.upper(" All Reports"), 255,194,14,255,1,"default-bold" })
	
	local count = 0
	for i = 1, 300 do
		local report = reports[i]
		if report then
			local reporter = report[1]
			local reported = report[2]
			local timestring = report[4]
			local admin = report[5]
			local staff, _, name, abrv, r, g, b = getReportInfo(report[7])
			local seenReport = { }
			
			local handler = ""
			
			if (isElement(admin)) then
				handler = getElementData(admin, "account:username")
			else
				handler = "None."
			end
			if staff then
				for k,v in ipairs(staff) do
					if not seenReport[i] then
						table.insert(info, {abrv.." Report #" .. tostring(i) .. ": '" .. tostring(getPlayerName(reporter)) .. "' reporting '" .. tostring(getPlayerName(reported)) .. "' at " .. timestring .. ". Handler: " .. handler .. "", r, g, b})
						seenReport[i] = true
					end
				end
				count = count + 1
			end
		end
	end
	
	if count == 0 then
		table.insert(info, {"None."})
	end
	
	setElementData(thisResourceElement, "allReports", info, true)
	
end
setTimer(updateUnansweredReports, 4000, 0)
setTimer(updateUnansweredReportsGMs, 5000, 0)
setTimer(updateReports, 6000, 0)