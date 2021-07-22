--[[
	Todo:
		Make proper transitions (old setting -> new setting) when updating the snow settings
		Spring clean
		Expose more settings to users? (eg: rotate true/false, jitter speed, alpha blending)
--]]


local snowflakes = {}
local snowing = false

local box_width, box_depth, box_height, box_width_doubled, box_depth_doubled = 4,4,4,8,8
local position = {0,0,0}
local flake_removal = nil
local snow_fadein = 10
local snow_id = 1

sx,sy = guiGetScreenSize()
sx2,sy2 = sx/2,sy/2
localPlayer = getLocalPlayer()



--local random = math.random
function random(lower,upper)
	return lower+(math.random()*(upper-lower))
end

function startSnow()
	if not snowing then
		snowflakes = {}
			
		local lx,ly,lz = getWorldFromScreenPosition(0,0,1)
		local rx,ry,rz = getWorldFromScreenPosition(sx,0,1)
		box_width = getDistanceBetweenPoints3D(lx,ly,lz,rx,ry,rz)+3 -- +1.5 each side of the screen
		box_depth = box_width
		
		box_width_doubled = box_width*2
		box_depth_doubled = box_depth*2

		lx,ly,lz = getWorldFromScreenPosition(sx2,sy2,box_depth)
		position = {lx,ly,lz}		
		
		-- let it snow
		for i=1, settings.density do
			local x,y,z = random(0,box_width*2),random(0,box_depth*2),random(0,box_height*2)
			createFlake(x-box_width,y-box_depth,z-box_height,0)
		end
		
	--	outputChatBox(string.format("Width/Depth: %.1f",box_width))
		addEventHandler("onClientRender",root,drawSnow)
		snowing = true
	--	outputChatBox("Snow started")
		return true
	else
	--	outputChatBox("Its already snowing")
		return false
	end
	return false
end

function toggleSnow()
	if snowing then
		stopSnow()
	else
		startSnow() 
	end
end


addCommandHandler("snow",function()
	if snowToggle then 
		toggleSnow()
	else
		outputChatBox("Snow toggling is disabled.")
	end
end)


function showSnowToggleBind()
	if getKeyState("lctrl") or getKeyState("rctrl") then
		if snowToggle then 
			toggleSnow()
		else
			outputChatBox("Snow toggling is disabled.")
		end
	end
end
addCommandHandler("Snow Toggle (hold ctrl)",showSnowToggleBind)
bindKey("s","down","Snow Toggle (hold ctrl)")


function stopSnow()
	if snowing then
		removeEventHandler("onClientRender",root,drawSnow)
		for i,flake in pairs(snowflakes) do
			snowflakes[i] = nil
		end
		snowflakes = nil
		flake_removal = nil
		snowing = false
	--	outputChatBox("Snow stopped")
		return true
	end
	return false
end
addEventHandler("onClientResourceStop",resourceRoot,stopSnow)


function updateSnowType(type)
	if type then
		settings.type = type
	--	outputChatBox("Snow type set to "..type)
		return true
	end
	return false
end


function updateSnowDensity(dense,blend,speed)
	if dense and tonumber(dense) then
		dense = tonumber(dense)
		if snowing then
			if blend then
				-- if we are blending in more flakes
				if dense > settings.density then
					-- default speed
					if not tonumber(speed) then
						speed = 300
					end
					-- create 1/20 of the new amount every 'speed'ms for 20 iterations
					setTimer(function(old,new)
						for i=1, (new-old)/20, 1 do
							local x,y = random(0,box_width*2),random(0,box_depth*2)
							createFlake(x-box_width,y-box_depth,box_height,0)							
						end
					end,tonumber(speed),20,settings.density,dense)
				
				-- if we are blending out existing flakes, just flag that we should stop recreating them and check in createFlake()
				elseif dense < settings.density then
					if not tonumber(speed) then
						speed = 10
					end
					flake_removal = {settings.density-dense,0,tonumber(speed)}
				end
				
				if not tonumber(speed) then
					speed = 0
				end
			else
				speed = 0
				if dense > settings.density then
					for i=settings.density+1, dense do
						local x,y = random(0,box_width*2),random(0,box_depth*2)
						createFlake(x-box_width,y-box_depth,box_height,0)				
					end
				elseif dense < settings.density then
					for i=density, dense+1, -1 do
						table.remove(snowflakes,i)
					end
				end
			end
		else
			speed = 0
		end
		
	--	outputChatBox("Snow density set to "..dense.." (b: "..((blend ~= nil) and "yes" or "no").." - "..((dense > settings.density) and "in" or "out").." at "..tonumber(speed).."ms : "..settings.density..","..dense..")")
		settings.density = tonumber(dense)
		return true
	end
	return false
end


function updateSnowWindDirection(xdir,ydir)
	if xdir and tonumber(xdir) and ydir and tonumber(ydir) then
		settings.wind_direction = {tonumber(xdir)/100,tonumber(ydir)/100}
	--	outputChatBox("Snow winddirection set to "..xdir..","..ydir)
		return true
	end
	return false
end


function updateSnowWindSpeed(speed)
	if speed and tonumber(speed) then
		settings.wind_speed = tonumber(speed)
	--	outputChatBox("Snow windspeed set to "..settings.wind_speed)
		return true
	end
	return false
end


function updateSnowflakeSize(min,max)
	if min and tonumber(min) and max and tonumber(max) then
		settings.snowflake_min_size = tonumber(min)
		settings.snowflake_max_size = tonumber(max)
	--	outputChatBox("Snowflake size set to "..min.." - "..max)
		return true
	end
	return false
end


function updateSnowFallSpeed(min,max)
	if min and tonumber(min) and max and tonumber(max) then
		settings.fall_speed_min = tonumber(min)
		settings.fall_speed_max = tonumber(max)
		return true
	end
	return false
end


function updateSnowAlphaFadeIn(alpha)
	if alpha and tonumber(alpha) then
		snow_fadein = tonumber(alpha)
	--	outputChatBox("Snow fade in alpha set to "..alpha)
		return true
	end
	return false
end


function updateSnowJitter(jit)
	settings.jitter = jit
end


function createFlake(x,y,z,alpha,i)	
	if flake_removal then
		if (flake_removal[2] % flake_removal[3]) == 0 then
			flake_removal[1] = flake_removal[1] - 1
			if flake_removal[1] == 0 then
				flake_removal = nil
			end
			table.remove(snowflakes,i)
			return
		else
			flake_removal[2] = flake_removal[2] + 1
		end
	end
	
	snow_id = (snow_id % 4) + 1
	
	if i then
		local randy = math.random(0,180)
		snowflakes[i] = {x = x, y = y, z = z, 
						 speed = math.random(settings.fall_speed_min,settings.fall_speed_max)/100, 
						 size = 2^math.random(settings.snowflake_min_size,settings.snowflake_max_size), 
						 section = {(snow_id % 2 == 1) and 0 or 32,  (snow_id < 3) and 0 or 32},
						 rot = randy, 
						 alpha = alpha, 
						 jitter_direction = {math.cos(math.rad(randy*2)), -math.sin(math.rad(math.random(0,360)))}, 
						 jitter_cycle = randy*2,
						 jitter_speed = 8
						}
	else
		local randy = math.random(0,180)
		table.insert(snowflakes,{x = x, y = y, z = z, 
								 speed = math.random(settings.fall_speed_min,settings.fall_speed_max)/100, 
								 size = 2^math.random(settings.snowflake_min_size,settings.snowflake_max_size),
								 section = {(snow_id % 2 == 1) and 0 or 32,  (snow_id < 3) and 0 or 32},
								 rot = randy, 
								 alpha = alpha,
								 jitter_direction = {math.cos(math.rad(randy*2)), -math.sin(math.rad(math.random(0,360)))}, 
								 jitter_cycle = randy*2,
								 jitter_speed = 8
								}					 
					)
	end
end



function drawSnow()	
	local tick = getTickCount()
	
	local cx,cy,cz = getCameraMatrix()

	local lx,ly,lz = getWorldFromScreenPosition(sx2,sy2,box_depth)

	--local hit,hx,hy,hz = processLineOfSight(lx,ly,lz,lx,ly,lz+20,true,true,false,true,false,true,false,false,localPlayer)
	if (isLineOfSightClear(cx,cy,cz,cx,cy,cz+20,true,false,false,true,false,true,false,localPlayer) or
		isLineOfSightClear(lx,ly,lz,lx,ly,lz+20,true,false,false,true,false,true,false,localPlayer)) then
		
		-- if we are underwater, substitute the water level for the ground level
		local check = getGroundPosition
		if testLineAgainstWater(cx,cy,cz,cx,cy,cz+20) then
			check = getWaterLevel
		end
	--	local gz = getGroundPosition(lx,ly,lz)
	
		-- split the box into a 3x3 grid, each section of the grid takes its own ground level reading to apply for every flake within it	
		local gpx,gpy,gpz = lx+(-box_width),ly+(-box_depth),lz+15
				
		local ground = {}
		
		for i=1, 3 do
			local it = box_width_doubled*(i*0.25)
			ground[i] = {
				check(gpx+(it), gpy+(box_depth_doubled*0.25), gpz),
				check(gpx+(it), gpy+(box_depth_doubled*0.5), gpz),
				check(gpx+(it), gpy+(box_depth_doubled*0.75), gpz)
			}
		end	
			
		--	outputDebugString(string.format("Gn: %.1f %.1f %.1f",ground[i][1],ground[i][2],ground[i][3]))
		--	outputDebugString(string.format("Gy: %.1f %.1f %.1f",groundy[i][1],groundy[i][2],groundy[i][3]))

	--	outputDebugString(string.format("%.1f %.1f %.1f, %.1f %.1f %.1f, %.1f %.1f %.1f",ground[1][1],ground[1][2],ground[1][3],ground[2][1],ground[2][2],ground[2][3],ground[3][1],ground[3][2],ground[3][3]))
	--	outputDebugString(string.format("%.1f %.1f %.1f, %.1f %.1f %.1f",(-box_width)+grid[1],(-box_width)+grid[1]*3,(-box_width)+grid[1]*5,(-box_depth)+grid[2],(-box_depth)+grid[2]*3,(-box_depth)+grid[2]*5))
	
		local dx,dy,dz = position[1]-lx,position[2]-ly,position[3]-lz
	
		--local alpha = (math.abs(dx) + math.abs(dy) + math.abs(dz))*15
		
	--	outputDebugString(tostring(alpha))
	

		for i,flake in pairs(snowflakes) do
			if flake then				
				-- check the flake hasnt moved beyond the box or below the ground
				-- actually, to preserve a constant density allow the flakes to fall past ground level (just dont show them) and remove once at the bottom of the box
			--	if (flake.z+lz) < ground[gx][gy] or flake.z < (-box_height) then
				if flake.z < (-box_height) then
				--	outputDebugString(string.format("Flake removed. %.1f %.1f %.1f",flake.x,flake.y,flake.z))
					-- createFlake(x, y, z, alpha, index)
					createFlake(random(0,box_width*2) - box_width, random(0,box_depth*2) - box_depth, box_height, 0, i)	
				else

					-- find the grid section the flake is in				
					local gx,gy = 2,2
					if flake.x <= (box_width_doubled*0.33)-box_width then gx = 1
					elseif flake.x >= (box_width_doubled*0.66)-box_width then gx = 3
					end
						
					if flake.y <= (box_depth_doubled*0.33)-box_depth then gy = 1
					elseif flake.y >= (box_depth_doubled*0.66)-box_depth then gy = 3
					end
					
					-- check it hasnt moved past the ground
					if ground[gx][gy] and (flake.z+lz) > ground[gx][gy] then
						local draw_x, draw_y, jitter_x, jitter_y = nil,nil,0,0
						
						-- draw all onscreen flakes
						if settings.jitter then
							local jitter_cycle = math.cos(flake.jitter_cycle) / flake.jitter_speed
							
							jitter_x = (flake.jitter_direction[1] * jitter_cycle )
							jitter_y = (flake.jitter_direction[2] * jitter_cycle )
						end
						
						draw_x,draw_y = getScreenFromWorldPosition(flake.x + lx + jitter_x, flake.y + ly + jitter_y ,flake.z + lz, 15, false)	
						
						if draw_x and draw_y then
							--	outputDebugString(string.format("Drawing flake %.1f %.1f",draw_x,draw_y))
						
							-- only draw flakes that are infront of the player
							-- peds seem to have very vague collisions, resulting in a dome-like space around the player where no snow is drawn, so leave this out due to it looking rediculous
							--	if isLineOfSightClear(cx,cy,cz,flake.x+lx,flake.y+ly,flake.z+lz,true,true,true,true,false,false,false,true) then
							--dxDrawImage(draw_x,draw_y,flake.size,flake.size,"flakes/snowflake"..tostring(flake.image).."_".. settings.type ..".png",flake.rot,0,0,tocolor(222,235,255,flake.alpha))
							dxDrawImageSection(draw_x, draw_y, flake.size, flake.size, flake.section[1], flake.section[2], 32, 32, "flakes/".. settings.type .. "_tile.png", flake.rot, 0, 0, tocolor(222,235,255,flake.alpha))
							--	end
							
							-- rotation and alpha (do not need to be done if the flake isnt being drawn)
							flake.rot = flake.rot + settings.wind_speed
										
							if flake.alpha < 255 then
								flake.alpha = flake.alpha + snow_fadein --[[+ alpha]]
								if flake.alpha > 255 then flake.alpha = 255 end
							end	
						else
						--	outputDebugString(string.format("Cannot find screen pos. %.1f %.1f %.1f",flake.x+lx,flake.y+ly,flake.z+lz))
						end
					end
	
				
					if settings.jitter then
						flake.jitter_cycle = (flake.jitter_cycle % 360) + 0.1
					end
					
					-- horizontal movement
					flake.x = flake.x + (settings.wind_direction[1] * settings.wind_speed)
					flake.y = flake.y + (settings.wind_direction[2] * settings.wind_speed)
				
					-- vertical movement
					flake.z = flake.z - flake.speed
					
					-- update flake position based on movement of the camera				
					flake.x = flake.x + dx
					flake.y = flake.y + dy
					flake.z = flake.z + dz
	
				--	outputDebugString(string.format("Diff: %.1f, %.1f, %.1f",position[1]-lx,position[2]-ly,position[3]-lz))
					
					if flake.x < -box_width or flake.x > box_width or
						flake.y < -box_depth or flake.y > box_depth or
						flake.z > box_height then

						--	outputDebugString(string.format("Flake removed (move). %.1f %.1f %.1f",flake.x,flake.y,flake.z))
						
						-- mirror flakes that were removed due to camera movement onto the opposite side of the box (and hope nobody notices)
						flake.x = flake.x - dx
						flake.y = flake.y - dy
						local x,y,z = (flake.x > 0 and -flake.x or math.abs(flake.x)),(flake.y > 0 and -flake.y or math.abs(flake.y)),random(0,box_height*2)
					
						createFlake(x, y, z - box_height, 255, i)	
					end
				end
			end
		end
	else
	--	outputDebugString("Not clear (roof)")
	end
	position = {lx,ly,lz}
	
	--outputDebugString(string.format("Snow took: %.6f",getTickCount() - tick))
end

addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),startSnow)

--debug
--[[
addCommandHandler("ssize",function()
	if snowflakes then
		outputDebugString("Snowflake table size: "..#snowflakes)
	end
end)

addCommandHandler("swdir",function(cmd,xdir,ydir)
	updateSnowWindDirection(xdir,ydir)
end)

addCommandHandler("swspeed",function(cmd,speed)
	updateSnowWindSpeed(speed)
end)

addCommandHandler("sdensity",function(cmd,dense,blend,speed)
	updateSnowDensity(dense,blend,speed)
end)

addCommandHandler("salpha",function(cmd,alpha)
	updateSnowAlphaFadeIn(alpha)
end)
]]