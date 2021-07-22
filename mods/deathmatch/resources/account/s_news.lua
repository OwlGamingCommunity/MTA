--[[
function news_update( player )
    callRemote( newsURL,
		function( title, text, author, date )
			if title == "ERROR" then
				outputDebugString( "Fetching news failed: " .. text )
				if player then
					outputChatBox( "News failed: " .. text, player )
				end
			else
				exports.anticheat:changeProtectedElementDataEx( resourceRoot, "news:title", title )
				exports.anticheat:changeProtectedElementDataEx( resourceRoot, "news:text", text )
				exports.anticheat:changeProtectedElementDataEx( resourceRoot, "news:sub", "By: " .. author .. " on " .. date )
				if player then
					outputChatBox( "News set to: " .. title, player )
				end
			end
		end
	)
end

function rules_update(player)
	callRemote( rulesURL, 
		function( title, text)
			if title == "ERROR" then
				outputDebugString( "Fetching news failed: " .. text )
				if player then
					outputChatBox( "News failed: " .. text, player )
				end
			else
				exports.anticheat:changeProtectedElementDataEx( resourceRoot, "rules:text", text )
				if player then
					outputChatBox( "Rules set to: " .. title, player )
				end
			end
		end
	)
end

function patchNotes_update(player)
	callRemote("www.owlgaming.net/server/patchnotes.php", 
		function( title, text)
			if title == "ERROR" then
				outputDebugString( "Fetching patch notes failed: " .. text )
				if player then
					outputChatBox( "Patch notes failed: " .. text, player )
				end
			else
				exports.anticheat:changeProtectedElementDataEx( resourceRoot, "patchnotes:text", text )
				if player then
					outputChatBox( "Patch notes set to: " .. title, player )
				end
			end
		end
	)
end

function adminRules_update(player)
	callRemote("www.owlgaming.net/server/adminrules.php", 
		function( title, text)
			if title == "ERROR" then
				outputDebugString( "Fetching admin rules failed: " .. text )
				if player then
					outputChatBox( "Admin rules failed: " .. text, player )
				end
			else
				exports.anticheat:changeProtectedElementDataEx( resourceRoot, "adminrules:text", text )
				if player then
					outputChatBox( "Admin rules set to: " .. title, player )
				end
			end
		end
	)
end

function gmRules_update(player)
	callRemote("www.owlgaming.net/server/gmrules.php", 
		function( title, text)
			if title == "ERROR" then
				outputDebugString( "Fetching gamemaster rules failed: " .. text )
				if player then
					outputChatBox( "Gamemaster rules failed: " .. text, player )
				end
			else
				exports.anticheat:changeProtectedElementDataEx( resourceRoot, "gmrules:text", text )
				if player then
					outputChatBox( "Gamemaster rules set to: " .. title, player )
				end
			end
		end
	)
end

-- Fetch news every so often
setTimer( news_update, 30 * 60000, 0 )
setTimer( rules_update, 30 * 60000, 0)
setTimer( patchNotes_update, 30 * 60000, 0)
setTimer( adminRules_update, 30 * 60000, 0)
setTimer( gmRules_update, 30 * 60000, 0)

-- Initial update
news_update( )
rules_update( )
patchNotes_update( )
adminRules_update()
gmRules_update()

addCommandHandler( "updategmrules",
	function( player )
		if exports.integration:isPlayerTrialAdmin( player ) then
			gmRules_update( player )
			outputChatBox( "Fetching gamemaster rules...", player )
		end
	end 
)

addCommandHandler( "updateadminrules",
	function( player )
		if exports.integration:isPlayerTrialAdmin( player ) then
			adminRules_update( player )
			outputChatBox( "Fetching admin rules...", player )
		end
	end 
)

addCommandHandler( "updatepatchnotes",
	function( player )
		if exports.integration:isPlayerTrialAdmin( player ) then
			patchNotes_update( player )
			outputChatBox( "Fetching patch notes...", player )
		end
	end 
)

addCommandHandler( "updatenews",
	function( player )
		if exports.integration:isPlayerTrialAdmin( player ) then
			news_update( player )
			outputChatBox( "Fetching news...", player )
		end
	end
)

addCommandHandler( "updaterules",
	function( player )
		if exports.integration:isPlayerTrialAdmin( player ) then
			rules_update( player )
			outputChatBox( "Fetching rules...", player )
		end
	end
)
]]