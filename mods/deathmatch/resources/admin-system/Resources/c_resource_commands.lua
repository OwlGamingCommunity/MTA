function clearDebugScript()
	for i = 1, 50 do
		outputDebugString("")
	end
end
addCommandHandler("cleardebugscript", clearDebugScript, false, false)