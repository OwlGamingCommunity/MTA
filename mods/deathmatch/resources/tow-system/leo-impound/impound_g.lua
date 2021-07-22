-- MAXIME / 2015.1.31

function getPlayerNameFirstLast(player)
	local name = exports.global:getPlayerName(player)
	local parts = exports.global:explode(" ", name)
	return parts[1], parts[#parts]
end