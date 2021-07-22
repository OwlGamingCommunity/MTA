job = 0
localPlayer = getLocalPlayer()

function playerSpawn()
	local logged = getElementData(localPlayer, "loggedin")

	if (logged==1) then
		job = tonumber(getElementData(localPlayer, "job"))
		if (job==1) then -- TRUCKER
			exports["job-system-trucker"]:displayTruckerJob()
		else
			exports["job-system-trucker"]:resetTruckerJob()
		end
		
		if (job==2) then -- TAXI
			displayTaxiJob()
		else
			resetTaxiJob()
		end
		
		if (job==3) then -- BUS
			displayBusJob()
		else
			resetBusJob()
		end
	end
end
addEventHandler("onClientPlayerSpawn", localPlayer, 
	function()
		setTimer(playerSpawn, 1000, 1)
	end
)

function quitJob(job)
	if (job==1) then -- TRUCKER JOB
		exports["job-system-trucker"]:resetTruckerJob()
		outputChatBox("You have now quit your job as a delivery driver.", 0, 255, 0)
	elseif (job==2) then -- TAXI JOB
		resetTaxiJob()
		outputChatBox("You have now quit your job as a taxi driver.", 0, 255, 0)
	elseif (job==3) then -- BUS JOB
		resetBusJob()
		outputChatBox("You have now quit your job as a bus driver.", 0, 255, 0)
	elseif (job==4) then -- CITY MAINTENANCE
		outputChatBox("You have now quit your job as a city maintenance worker.", 0, 255, 0)
		triggerServerEvent("cancelCityMaintenance", localPlayer)
	elseif (job==5) then -- MECHANIC
		outputChatBox("You have now quit your job as a mechanic.", 0, 255, 0)
	elseif (job==6) then -- LOCKSMITH
		outputChatBox("You have now quit your job as a locksmith.", 0, 255, 0)
	end
end
addEvent("quitJob", true)
addEventHandler("quitJob", getLocalPlayer(), quitJob)
