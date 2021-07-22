function checkPlate(theText)
	local foundSpace, valid = false, true
	local spaceBefore = false
	local current = ''
	for i = 1, #theText do
		local char = theText:sub( i, i )
		if char == ' ' then -- it's a space
			if i == #theText or i == 1 or spaceBefore then -- space at the end or beginning or two spaces are not allowed
				valid = false
				break
			end
			current = ''
			spaceBefore = true
		elseif ( char >= 'a' and char <= 'z' ) or ( char >= 'A' and char <= 'Z' ) then -- can have letters anywhere in the name
			current = current .. char
			spaceBefore = false
		elseif ( char >= '0' and char <= '9') then
			current = current .. char
			spaceBefore = false
		else -- unrecognized char (special chars)
			valid = false
			break
		end
	end
	
	if valid  and #theText < 9 and #theText > 3 then
		return true
	else
		return false
	end
end