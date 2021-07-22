local holes = {
	{1332.34765625, 2742.2587890625, 10.96875 - 1},
	{1303.1796875, 2810.5126953125, 10.96875-1},
	{1213.4873046875, 2832.666015625, 10.96875-1},
	{1265.568359375, 2745.318359375, 10.963585853577-1},
	{1135.025390625, 2771.5576171875, 10.96875-1},
	{1134.6279296875, 2806.0341796875, 10.96875-1},
	{1224.0302734375, 2851.9814453125, 10.96875-1},
	{1300.34765625, 2857.2265625, 10.960994720459-1},
	{1381.009765625, 2776.8232421875, 10.96875-1}
}

for k, v in pairs(holes) do
	createObject(2993, v[1], v[2], v[3])
end

function spawnBall(x, y, z, player)
	local ball = createObject(1974, x, y, z)
	setElementVelocity(ball, 100, 0, 0)
	setElementData(player, "golf:ball", ball)
	triggerClientEvent(player, "golf:gui", resourceRoot, ball)
	triggerEvent('sendAme', player, "places their ball on the ground.")
end
addEvent("golf:spawnball", true)
addEventHandler("golf:spawnball", resourceRoot, spawnBall)

function moveBall(ballX, ballY, ballZ, endBallX, endBallY, endBallZ, golfBall, height, betweenDistance, player, rollX, rollY, rollZ, club)
	doSwingAnimation(player)
	triggerEvent('sendAme', player, "swings their club golf club in a motion.")
	if club == "putter" then
		moveObject(golfBall, 1500, endBallX, endBallY, endBallZ)
		local tempTimer = nil
		tempTimer = setTimer(function (timer)
			for k, v in pairs(holes) do
				if isElement(golfBall) then
					local ex, ey, ez = getElementPosition(golfBall)
					local holeDistance = getDistanceBetweenPoints3D(v[1], v[2], v[3], ex, ey, ez)
					if holeDistance < 0.2 then
						exports.global:sendLocalText(player, " *" .. getPlayerName(player):gsub("_"," ") .. "'s ball rolls into the hole!", 255, 51, 102)
						stopObject(golfBall)
						setElementPosition(golfBall, v[1], v[2], v[3]+1)
						killTimer(tempTimer)
						setTimer(function()
							moveObject(golfBall, 2000, v[1], v[2], v[3] - 1)
						end, 1000, 1)
						setTimer(function()
							if isElement(golfBall) then
									destroyElement(golfBall)
									setElementData(player, "golf:ball", false)
							end
						end, 3000, 1)
						break
					end
				end
			end
		end, 50, 30, tempTimer)		
	else
		local hxc=(ballX+endBallX)/2   --x center of player and target 
		local hyc=(ballY+endBallY)/2   --y center of player and target 
		local hzc=ballZ+height             --z center of player and target 

		local hxs=(ballX+hxc)/2               --x center of player and hxc
		local hys=(ballY+hyc)/2               --y center of player and hyc
		local hzs=ballZ+(height/2)                     --z center of player and hzc


		local hxe=(hxc+endBallX)/2  --x center of hxc and target
		local hye=(hyc+endBallY)/2  --y center of hyc and target
		local hze=ballZ+(height/2)                     --z center of hzc and target

		local tablet = {hxc, hyc, hzc, hxs, hys, hzs, hxe, hye, hze}

		local mSpeed = 1000 --Ball speed
		local timer = 500
		setTimer(moveObject,50,1,golfBall,mSpeed,hxs,hys,hzs)  --1st position

		timer = mSpeed
		setTimer(moveObject, timer,1,golfBall,mSpeed,hxc,hyc,hzc) --2nd position

		timer = timer + mSpeed
		setTimer(moveObject, timer,1,golfBall,mSpeed,hxe,hye,hze) --3rd position
		
		timer = timer + mSpeed
		setTimer(moveObject, timer,1,golfBall,mSpeed,endBallX,endBallY,endBallZ) --4th (target) position
		
		timer = timer + mSpeed

		setTimer(moveObject, timer,1,golfBall,mSpeed,rollX,rollY,rollZ)

		local tempTimer = nil
		tempTimer = setTimer(function (timer)
			for k, v in pairs(holes) do
				if isElement(golfBall) then
					local ex, ey, ez = getElementPosition(golfBall)
					local holeDistance = getDistanceBetweenPoints3D(v[1], v[2], v[3], ex, ey, ez)
					if holeDistance < 0.2 then
						exports.global:sendLocalText(player, " *" .. getPlayerName(player):gsub("_"," ") .. "'s ball rolls into the hole!", 255, 51, 102)
						stopObject(golfBall)
						setElementPosition(golfBall, v[1], v[2], v[3]+1)
						killTimer(tempTimer)
						setTimer(function()
							moveObject(golfBall, 2000, v[1], v[2], v[3] - 1)
						end, 1000, 1)
						setTimer(function()
							if isElement(golfBall) then
									destroyElement(golfBall)
									setElementData(player, "golf:ball", false)
							end
						end, 3000, 1)
						break
					end
				end
			end
		end, 50, timer/50, tempTimer)	
	end
end
addEvent("golf:shootgolf", true)
addEventHandler("golf:shootgolf", resourceRoot, moveBall)

function doSwingAnimation(player)
	setPedAnimation(player, "baseball", "bat_3", -1, false)
	setTimer(function()
		setPedAnimation(player)
	end, 600, 1)
end

function resetGolf(thePlayer)
	local hasBall = getElementData(thePlayer, "golf:ball")
	if hasBall then
		destroyElement(hasBall)
		setElementData(thePlayer, "golf:ball", false)
		outputChatBox("Your ball has been removed.", thePlayer)
	else
		outputChatBox("You have no active ball.", thePlayer)
	end
end
addCommandHandler("resetgolf", resetGolf)

function sweepBall()
	local hasBall = getElementData(source, "golf:ball")
	if hasBall then
		destroyElement(hasBall)
		outputChatBox("Your ball has been removed.", source)
	end	
end
addEventHandler("onPlayerQuit", resourceRoot, sweepBall)
addCommandHandler("resetgolf", resetGolf)