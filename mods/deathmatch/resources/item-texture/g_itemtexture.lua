--item-texture
--Script that handles texture replacements for world items
--Created by Exciter, 24.06.2014 (DD.MM.YYYY).
--Based upon iG texture-system (based on Exciter's uG/RPP texture-system) and OwlGaming/Cat's fixes to texture-system based on mabako-clothingstore.

maxFileSize = 100000 --100kb
maxHeight, maxWidth = 1024, 1024

local allowedImageHosts = {
	--hosts with an API for doing checks before server downloads image
	--if you add another public host here, make sure to also add use of its API in s_vehtex.lua validateVehicleTexture()
	["imgur.com"] = true,
	["icweb.org"] = true,
}

function isURL(url)
	if string.find(url, "http://", 1, true) or string.find(url, "https://", 1, true) then
		return true
	else
		return false
	end
end
function isHostAllowed(url)
	if string.find(url, "http://", 1, true) or string.find(url, "https://", 1, true) then
		local domain = url:match("[%w%.]*%.(%w+%.%w+)") or url:match("^%w+://([^/]+)")
		if allowedImageHosts[domain] then
			return true
		end
	end
	return false
end
function getHost(url)
	if string.find(url, "http://", 1, true) or string.find(url, "https://", 1, true) then
		local domain = url:match("[%w%.]*%.(%w+%.%w+)") or url:match("^%w+://([^/]+)")
		if allowedImageHosts[domain] then
			return domain
		end
	end
	return false
end