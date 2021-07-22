function fadeToBlack()
	fadeCamera (true, 0, 0, 0, 0 )
	fadeCamera ( false, 1, 0, 0, 0 )
end

function fadeFromBlack()
	fadeCamera (false, 0, 0, 0, 0 )
	fadeCamera (true, 1, 0, 0, 0 )
end