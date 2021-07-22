--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client-side script: The grid
--Last updated 12.03.2015 by Exciter
--Copyright 2008-2015, The Roleplay Project (www.roleplayproject.com)

local loadingWrapper, animTimer, loadimg, loadNum = nil, nil, nil, 1

function showLoading(region)
	if loadingWrapper then return false end
	local sx, sy = guiGetScreenSize()
	local wrapperW, wrapperH = 455, 430
	local loaderW, loaderH = 319, 320
	local iconW, iconH = 213, 215

	local x = (sx / 2) - (wrapperW / 2)
	local y = (sy / 2) - (wrapperH / 2)

	loadingWrapper = guiCreateStaticImage(x, y, wrapperW, wrapperH, "images/trans.png", false)

	loadimg = guiCreateStaticImage((wrapperW/2)-(loaderW/2), 0, loaderW, loaderH, "images/loadcircle"..tostring(loadNum)..".png", false, loadingWrapper)
	local iconimg = guiCreateStaticImage((wrapperW/2)-(iconW/2), 55, iconW, iconH, "images/icon_earth.png", false, loadingWrapper)

	local captionBg = guiCreateStaticImage(0, loaderH+10, wrapperW, 60, "images/0.png", false, loadingWrapper)
	
	local caption = "LOADING REGION"
	if region then
		local regionstr = tostring(region)
		local strlenght = string.len(regionstr)
		local splitted = split(regionstr, "")
		local strlenght = #splitted
		if region == 0 then
			caption = caption.." (50,50)"
		elseif strlenght == 4 and splitted then
			local gridx = splitted[1]..splitted[2]
			local gridy = splitted[3]..splitted[4]
			caption = caption.." ("..tostring(gridx)..","..tostring(gridy)..")"
		elseif strlenght == 3 and splitted then
			local gridx = "0"..splitted[1]
			local gridy = splitted[2]..splitted[3]
			caption = caption.." ("..tostring(gridx)..","..tostring(gridy)..")"
		elseif strlenght == 2 and splitted then
			local gridx = "00"
			local gridy = splitted[1]..splitted[2]
			caption = caption.." ("..tostring(gridx)..","..tostring(gridy)..")"
		elseif strlength == 1 then
			caption = caption.." (00,0"..regionstr..")"
		end
	end

	local lbl1 = guiCreateLabel(0, 0, wrapperW, 20, "LOADING REGION", false, captionBg)
		guiLabelSetHorizontalAlign(lbl1, "center", false)
	local lbl2 = guiCreateLabel(0, 20, wrapperW, 20, "PLEASE WAIT", false, captionBg)
		guiLabelSetHorizontalAlign(lbl2, "center", false)
	statusLabel = guiCreateLabel(0, 40, wrapperW, 20, "", false, captionBg)
		guiLabelSetHorizontalAlign(statusLabel, "center", false)

	animTimer = setTimer(animateLoading, 1000, 0)
end

function animateLoading()
	if not loadNum then loadNum = 1 end
	loadNum = loadNum + 1
	if loadNum > 4 then loadNum = 1 end
	guiStaticImageLoadImage(loadimg, "images/loadcircle"..tostring(loadNum)..".png")
end

function hideLoading()
	if loadingWrapper then
		if isElement(loadingWrapper) then
			destroyElement(loadingWrapper)
			loadingWrapper = nil
			if animTimer then
				killTimer(animTimer)
				animTimer = nil
			end
		end
	end
end

function updateLoadingStatus(text)
	if loadingWrapper and statusLabel then
		if not text then text = "" end
		guiSetText(statusLabel, tostring(text))
		outputConsole(tostring(text))
	end
end