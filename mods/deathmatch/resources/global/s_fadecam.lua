function fadeToBlack(player)
	if isElement(player) then
		fadeCamera ( player, true, 0, 0, 0, 0 )
		fadeCamera ( player, false, 1, 0, 0, 0 )
	end
end

function fadeFromBlack(player)
	if isElement(player) then
		fadeCamera ( player, false, 0, 0, 0, 0 )
		fadeCamera ( player, true, 1, 0, 0, 0 )
	end
end