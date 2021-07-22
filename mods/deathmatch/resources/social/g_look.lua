local function checkLength( value )
	return value and #value >= 0 and #value <= 165
end

local allowedImageHosts = {
	["imgur.com"] = true,
}
local imageExtensions = {
	[".jpg"] = true,
	[".png"] = true,
	[".gif"] = true,
}
function verifyImageURL(url, notEmpty)
	if not notEmpty then
		if not url or url == "" then
			return true
		end
	end
	if string.find(url, "http://", 1, true) or string.find(url, "https://", 1, true) then
		local domain = url:match("[%w%.]*%.(%w+%.%w+)") or url:match("^%w+://([^/]+)")
		if allowedImageHosts[domain] then
			local _extensions = ""
			for extension, _ in pairs(imageExtensions) do
				if _extensions ~= "" then
					_extensions = _extensions..", "..extension
				else
					_extensions = extension
				end
				if string.find(url, extension, 1, true) then
					return true
				end
			end			
		end
	end
	return false
end

editables = {
	{ name = "Weight", index = "weight", verify = function( v ) return tonumber( v ) and tonumber( v ) >= 30 and tonumber( v ) <= 200 end, instructions = "Enter weight in kg, between 30 and 200." },
	{ name = "Height", index = "height", verify = function( v ) return tonumber( v ) and tonumber( v ) >= 70 and tonumber( v ) <= 220 end, instructions = "Enter height in cm, between 70 and 220." },
	{ name = "Hair Color", index = 1, verify = checkLength },
	{ name = "Hair Style", index = 2, verify = checkLength },
	{ name = "Facial Features", index = 3, verify = checkLength },
	{ name = "Physical Features", index = 4, verify = checkLength },
	{ name = "Clothing", index = 5, verify = checkLength },
	{ name = "Accessories", index = 6, verify = checkLength },
	{ name = "Picture", index = 7, verify = verifyImageURL, instructions = "Enter a imgur link to a picture showing what your character looks like." }
}