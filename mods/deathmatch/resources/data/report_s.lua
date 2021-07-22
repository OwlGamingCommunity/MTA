mysql = exports.mysql
reports = { }

function saveReports(reports1)
	if reports1 and type(reports1) == "table" then
		reports = reports1
		outputDebugString("Saved "..#reports1.." reports.")
		return true
	else
		outputDebugString("Nothing to save.")
		return false
	end
end

function loadReports()
	if reports and type(reports) == "table" then
		outputDebugString("Loaded "..#reports.." reports.")
		return reports
	else
		outputDebugString("Nothing to load")
		return false
	end
end
