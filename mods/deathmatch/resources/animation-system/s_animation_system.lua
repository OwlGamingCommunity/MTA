--[[
function bindKeysOnJoin()
	bindKey(source, "space", "down", stopAnimation)
end
addEventHandler("onPlayerJoin", getRootElement(), bindKeysOnJoin)
]]

function bindAnimationStopKey()
	bindKey(source, "space", "down", stopAnimation)
end
addEvent("bindAnimationStopKey", false)
addEventHandler("bindAnimationStopKey", getRootElement(), bindAnimationStopKey)

function forcedAnim()
	exports.anticheat:changeProtectedElementDataEx(source, "forcedanimation", 1, false)
end
addEvent("forcedanim", true)
addEventHandler("forcedanim", getRootElement(), forcedAnim)

function unforcedAnim()
	exports.anticheat:changeProtectedElementDataEx(source, "forcedanimation", 0, false)
end
addEvent("unforcedanim", true)
addEventHandler("unforcedanim", getRootElement(), unforcedAnim)

function unbindAnimationStopKey()
	unbindKey(source, "space", "down", stopAnimation)
end
addEvent("unbindAnimationStopKey", true)
addEventHandler("unbindAnimationStopKey", getRootElement(), unbindAnimationStopKey)

function stopAnimation(thePlayer)
	if not getElementData( thePlayer, "superman:flying" ) and getElementData(thePlayer, 'animation') and ( getElementData( thePlayer, 'forcedanimation' ) or 0 ) == 0 then
		setPedAnimation ( thePlayer )
		toggleAllControls( thePlayer, true, true, false )
		-- stop jumping for a sec
		toggleControl ( thePlayer, 'jump', false )
		setTimer( toggleControl, 1000, 1, thePlayer, 'jump', true )
		exports.anticheat:setEld( thePlayer, 'animation', nil, 'all' )
		unbindKey( thePlayer , "space", "down", stopAnimation )
	end
end
addCommandHandler("stopanim", stopAnimation, false, false)
addCommandHandler("stopani", stopAnimation, false, false)

-- making sure noone is stuck in any animation when resource stops.
addEventHandler( 'onResourceStop', resourceRoot, function()
	for i, thePlayer in pairs( getElementsByType('player') ) do
		if getElementData(thePlayer, 'animation') then
			setPedAnimation ( thePlayer )
			toggleAllControls( thePlayer, true, true, false )
			exports.anticheat:setEld( thePlayer, 'animation', nil, 'all' )
		end
	end
end)

--[[
function stopAnimationFix2(localPlayer)
	setPedAnimation (localPlayer)
end
addEvent("stopAnimationFix2", true)
addEventHandler( "stopAnimationFix2", getRootElement(), stopAnimationFix2 )
]]

function animationList(thePlayer)
	outputChatBox("/piss /wank /slapass /fixcar /handsup /hailtaxi /scratch /fu /carchat /tired /cover", thePlayer, 255, 194, 14)
	outputChatBox("/strip 1-2 /lightup /drink /beg /mourn /cheer 1-3 /dance 1-3 /crack 1-4 /walk(2) 1-37", thePlayer, 255, 194, 14)
	outputChatBox("/gsign 1-5 /puke /rap 1-3 /sit 1-5 /smoke 1-3 /smokelean /laugh /startrace /bat 1-3", thePlayer, 255, 194, 14)
	outputChatBox("/daps 1-2 /shove /bitchslap /shocked /dive /what /fall /fallfront /cpr /copaway", thePlayer, 255, 194, 14)
	outputChatBox("/copcome /copleft /copstop /wait /think /shake /idle /lay 1-2 /cry /aim /drag /win 1-2", thePlayer, 255, 194, 14)
	outputChatBox("/stopanim or press the space bar to cancel animations.", thePlayer, 255, 194, 14)
end
addCommandHandler("animlist", animationList, false, false)
addCommandHandler("animhelp", animationList, false, false)
addCommandHandler("anims", animationList, false, false)
addCommandHandler("animations", animationList, false, false)

function resetAnimation(thePlayer)
	exports.global:removeAnimation(thePlayer)
end

-- /cover animtion -------------------------------------------------
function coverAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "ped", "duck_cower", -1, false, false, false)
	end
end
addCommandHandler("cover", coverAnimation, false, false)

-- /cpr animtion -------------------------------------------------
function cprAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "medic", "cpr", 8000, false, true, false)
	end
end
addCommandHandler("cpr", cprAnimation, false, false)

-- cop away Animation -------------------------------------------------------------------------
function copawayAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "police", "coptraf_away", 1300, true, false, false)
	end
end
addCommandHandler("copaway", copawayAnimation, false, false)

-- Cop come animation
function copcomeAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "POLICE", "CopTraf_Come", -1, true, false, false)
	end
end
addCommandHandler("copcome", copcomeAnimation, false, false)

-- Cop Left Animation -------------------------------------------------------------------------
function copleftAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "POLICE", "CopTraf_Left", -1, true, false, false)
	end
end
addCommandHandler("copleft", copleftAnimation, false, false)

-- Cop Stop Animation -------------------------------------------------------------------------
function copstopAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "POLICE", "CopTraf_Stop", -1, true, false, false)
	end
end
addCommandHandler("copstop", copstopAnimation, false, false)

-- Wait Animation -------------------------------------------------------------------------
function pedWait(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
	end
end
addCommandHandler ( "wait", pedWait, false, false )

-- Think Animation (/wait modifier) ---------------------------------------------------------------
function pedThink(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "COP_AMBIENT", "Coplook_think", -1, true, false, false)
	end
end
addCommandHandler ( "think", pedThink, false, false )

-- Shake Animation(/wait modifier) ---------------------------------------------------------------
function pedShake(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "COP_AMBIENT", "Coplook_shake", -1, true, false, false)
	end
end
addCommandHandler ( "shake", pedShake, false, false )

-- Lean Animation -------------------------------------------------------------------------
function pedLean(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "GANGS", "leanIDLE", -1, true, false, false)
	end
end
addCommandHandler ( "lean", pedLean, false, false )

-- /idle animtion -------------------------------------------------
function idleAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "DEALER", "DEALER_IDLE_01", -1, true, false, false)
	end
end
addCommandHandler("idle", idleAnimation, false, false)

-- Piss Animation -------------------------------------------------------------------------
function pedPiss(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "PAULNMAC", "Piss_loop", -1, true, false, false)
	end
end
addCommandHandler ( "piss", pedPiss, false, false )

-- Wank Animation -------------------------------------------------------------------------
function pedWank(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "PAULNMAC", "wank_loop", -1, true, false, false)
	end
end
addCommandHandler ( "wank", pedWank, false, false )

-- Slap Ass Animation -------------------------------------------------------------------------
function pedSlapAss(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "SWEET", "sweet_ass_slap", 2000, true, false, false)
	end
end
addCommandHandler ( "slapass", pedSlapAss, false, false )

-- fix car Animation -------------------------------------------------------------------------
function pedCarFix(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "CAR", "Fixn_Car_loop", -1, true, false, false)
	end
end
--addCommandHandler ( "fixcar", pedCarFix, false, false )

-- Hands Up Animation -------------------------------------------------------------------------
function pedHandsup(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "ped", "handsup", -1, false, false, false)
	end
end
addCommandHandler ( "handsup", pedHandsup, false, false )

-- Hail Taxi -----------------------------------------------------------------------------------
function pedTaxiHail(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "MISC", "Hiker_Pose", -1, false, true, false)
	end
end
addCommandHandler ("hailtaxi", pedTaxiHail, false, false )

-- Scratch Balls Animation -------------------------------------------------------------------------
function pedScratch(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "MISC", "Scratchballs_01", -1, true, true, false)
	end
end
addCommandHandler ( "scratch", pedScratch, false, false )

-- F*** You Animation -------------------------------------------------------------------------
function pedFU(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "RIOT", "RIOT_FUKU", 800, false, true, false)
	end
end
addCommandHandler ( "fu", pedFU, false, false )

-- Strip Animation -------------------------------------------------------------------------
function pedStrip( thePlayer, cmd, arg )
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "STRIP", "STR_Loop_C", -1, false, true, false)
		else
			exports.global:applyAnimation( thePlayer, "STRIP", "strip_D", -1, false, true, false)
		end
	end
end
addCommandHandler ( "strip", pedStrip, false, false )

-- Light up Animation -------------------------------------------------------------------------
function pedLightup (thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "SMOKING", "M_smk_in", 4000, true, true, false)
	end
end
addCommandHandler ( "lightup", pedLightup, false, false )

-- Light up Animation -------------------------------------------------------------------------
function pedHeil (thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "ON_LOOKERS", "Pointup_in", 999999, false, true, false)
	end
end
addCommandHandler ( "heil", pedHeil, false, false )

-- Drink Animation -------------------------------------------------------------------------
function pedDrink( thePlayer )
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "BAR", "dnk_stndM_loop", 2300, false, false, false)
	end
end
addCommandHandler ( "drink", pedDrink, false, false )

-- Lay Animation -------------------------------------------------------------------------
function pedLay( thePlayer, cmd, arg )
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "BEACH", "sitnwait_Loop_W", -1, true, false, false)
		else
			exports.global:applyAnimation( thePlayer, "BEACH", "Lay_Bac_Loop", -1, true, false, false)
		end
	end
end
addCommandHandler ( "lay", pedLay, false, false )

-- beg Animation -------------------------------------------------------------------------
function begAnimation( thePlayer )
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "SHOP", "SHP_Rob_React", 4000, true, false, false)
	end
end
addCommandHandler ( "beg", begAnimation, false, false )

-- Mourn Animation -------------------------------------------------------------------------
function pedMourn( thePlayer )
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "GRAVEYARD", "mrnM_loop", -1, true, false, false)
	end
end
addCommandHandler ( "mourn", pedMourn, false, false )

-- Cry Animation -------------------------------------------------------------------------
function pedCry( thePlayer )
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "GRAVEYARD", "mrnF_loop", -1, true, false, false)
	end
end
addCommandHandler ( "cry", pedCry, false, false )

-- Cheer Amination -------------------------------------------------------------------------
function pedCheer(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "OTB", "wtchrace_win", -1, true, false, false)
		elseif arg == 3 then
			exports.global:applyAnimation( thePlayer, "RIOT", "RIOT_shout", -1, true, false, false)
		else
			exports.global:applyAnimation( thePlayer, "STRIP", "PUN_HOLLER", -1, true, false, false)
		end
	end
end
addCommandHandler ( "cheer", pedCheer, false, false )

-- Dance Animation -------------------------------------------------------------------------
function danceAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "DANCING", "DAN_Down_A", -1, true, false, false)
		elseif arg == 3 then
			exports.global:applyAnimation( thePlayer, "DANCING", "dnce_M_d", -1, true, false, false)
		else
			exports.global:applyAnimation( thePlayer, "DANCING", "DAN_Right_A", -1, true, false, false)
		end
	end
end
addCommandHandler ( "dance", danceAnimation, false, false )

-- Crack Animation -------------------------------------------------------------------------
function crackAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "CRACK", "crckidle1", -1, true, false, false)
		elseif arg == 3 then
			exports.global:applyAnimation( thePlayer, "CRACK", "crckidle3", -1, true, false, false)
		elseif arg == 4 then
			exports.global:applyAnimation( thePlayer, "CRACK", "crckidle4", -1, true, false, false)
		else
			exports.global:applyAnimation( thePlayer, "CRACK", "crckidle2", -1, true, false, false)
		end
	end
end
addCommandHandler ( "crack", crackAnimation, false, false )

-- /gsign animtion -------------------------------------------------
function gsignAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation(thePlayer, "GHANDS", "gsign2", 4000, true, false, false)
		elseif arg == 3 then
			exports.global:applyAnimation(thePlayer, "GHANDS", "gsign3", 4000, true, false, false)
		elseif arg == 4 then
			exports.global:applyAnimation(thePlayer, "GHANDS", "gsign4", 4000, true, false, false)
		elseif arg == 5 then
			exports.global:applyAnimation(thePlayer, "GHANDS", "gsign5", 4000, true, false, false)
		else
			exports.global:applyAnimation(thePlayer, "GHANDS", "gsign1", 4000, true, false, false)
		end
	end
end
addCommandHandler("gsign", gsignAnimation, false, false)

-- /puke animtion -------------------------------------------------
function pukeAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "FOOD", "EAT_Vomit_P", 8000, true, false, false)
	end
end
addCommandHandler("puke", pukeAnimation, false, false)

-- /rap animtion -------------------------------------------------
function rapAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "LOWRIDER", "RAP_B_Loop", -1, true, false, false)
		elseif arg == 3 then
			exports.global:applyAnimation( thePlayer, "LOWRIDER", "RAP_C_Loop", -1, true, false, false)
		else
			exports.global:applyAnimation( thePlayer, "LOWRIDER", "RAP_A_Loop", -1, true, false, false)
		end
	end
end
addCommandHandler("rap", rapAnimation, false, false)

-- /aim animtion -------------------------------------------------
function aimAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "SHOP", "ROB_Loop_Threat", 99999999, true, false, false)
	end
end
addCommandHandler("aim", aimAnimation, false, false)

-- /sit animtion -------------------------------------------------
function sitAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if isPedInVehicle( thePlayer ) then
			if arg == 2 then
				setPedAnimation( thePlayer, "CAR", "Sit_relaxed" )
			else
				setPedAnimation( thePlayer, "CAR", "Tap_hand" )
			end
			source = thePlayer
			bindAnimationStopKey()
		else
			if arg == 2 then
				exports.global:applyAnimation( thePlayer, "FOOD", "FF_Sit_Look", -1, true, false, false)
			elseif arg == 3 then
				exports.global:applyAnimation( thePlayer, "Attractors", "Stepsit_loop", -1, true, false, false)
			elseif arg == 4 then
				exports.global:applyAnimation( thePlayer, "BEACH", "ParkSit_W_loop", 1, true, false, false)
			elseif arg == 5 then
				exports.global:applyAnimation( thePlayer, "BEACH", "ParkSit_M_loop", 1, true, false, false)
			else
				exports.global:applyAnimation( thePlayer, "ped", "SEAT_idle", -1, true, false, false)
			end
		end
	end
end
addCommandHandler("sit", sitAnimation, false, false)

-- /smoke animtion -------------------------------------------------
function smokeAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "SMOKING", "M_smkstnd_loop", -1, true, false, false)
		elseif arg == 3 then
			exports.global:applyAnimation( thePlayer, "LOWRIDER", "M_smkstnd_loop", -1, true, false, false)
		else
			exports.global:applyAnimation( thePlayer, "GANGS", "smkcig_prtl", -1, true, false, false)
		end
	end
end
addCommandHandler("smoke", smokeAnimation, false, false)

-- /smokelean animtion -------------------------------------------------
function smokeleanAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "LOWRIDER", "M_smklean_loop", -1, true, false, false)
	end
end
addCommandHandler("smokelean", smokeleanAnimation, false, false)

-- /drag animtion -------------------------------------------------
function smokedragAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "SMOKING", "M_smk_drag", 4000, true, false, false)
	end
end
addCommandHandler("drag", smokedragAnimation, false, false)

-- /laugh animtion -------------------------------------------------
function laughAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "RAPPING", "Laugh_01", -1, true, false, false)
	end
end
addCommandHandler("laugh", laughAnimation, false, false)

-- /startrace animtion -------------------------------------------------
function startraceAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "CAR", "flag_drop", 4200, true, false, false)
	end
end
addCommandHandler("startrace", startraceAnimation, false, false)

-- /carchat animtion -------------------------------------------------
function carchatAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "CAR_CHAT", "car_talkm_loop", -1, true, false, false)
	end
end
addCommandHandler("carchat", carchatAnimation, false, false)

-- /tired animtion -------------------------------------------------
function tiredAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "FAT", "idle_tired", -1, true, false, false)
	end
end
addCommandHandler("tired", tiredAnimation, false, false)

-- /daps animtion -------------------------------------------------
function handshakeAnimation(thePlayer, cmd, otherGuy)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		if otherGuy then
			local otherPlayer = exports.global:findPlayerByPartialNick(thePlayer, otherGuy)
			if otherPlayer then
				if (getPedOccupiedVehicle(thePlayer) == false and getPedOccupiedVehicle(otherPlayer) == false)  then
					local x, y, z = getElementPosition(thePlayer)
					local tx, ty, tz = getElementPosition(otherPlayer)
					if (getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)<1) then -- Are they standing next to each other?
					exports.global:applyAnimation( thePlayer, "GANGS", "hndshkfa", -1, false, false, false)
					exports.global:applyAnimation( otherPlayer, "GANGS", "hndshkfa", -1, false, false, false)
					else
					outputChatBox("You are too far away to daps this player.", thePlayer, 255, 0, 0)
					end
				else
				outputChatBox("You can't daps if you or the other player is in a vehicle.", thePlayer, 255, 0, 0)
				end
			end
		else
			exports.global:applyAnimation( thePlayer, "GANGS", "hndshkfa", -1, false, false, false)
		end
	end
end
addCommandHandler("daps", handshakeAnimation, false, false)

-- /shove animtion -------------------------------------------------
function shoveAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "GANGS", "shake_carSH", -1, true, false, false)
	end
end
addCommandHandler("shove", shoveAnimation, false, false)

-- /bitchslap animtion -------------------------------------------------
function bitchslapAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "MISC", "bitchslap", -1, true, false, false)
	end
end
addCommandHandler("bitchslap", bitchslapAnimation, false, false)

-- /shocked animtion -------------------------------------------------
function shockedAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "ON_LOOKERS", "panic_loop", -1, true, false, false)
	end
end
addCommandHandler("shocked", shockedAnimation, false, false)

-- /dive animtion -------------------------------------------------
function diveAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation(thePlayer, "ped", "EV_dive", -1, false, true, false)
	end
end
addCommandHandler("dive", diveAnimation, false, false)

-- /what Amination -------------------------------------------------------------------------
function whatAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "RIOT", "RIOT_ANGRY", -1, true, false, false)
	end
end
addCommandHandler ( "what", whatAnimation, false, false )

-- /fallfront Amination -------------------------------------------------------------------------
function fallfrontAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "ped", "FLOOR_hit_f", -1, false, false, false)
	end
end
addCommandHandler ( "fallfront", fallfrontAnimation, false, false )

-- /fall Amination -------------------------------------------------------------------------
function fallAnimation(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "ped", "FLOOR_hit", -1, false, false, false)
	end
end
addCommandHandler ( "fall", fallAnimation, false, false )

-- /walk animation -------------------------------------------------------------------------
local walk = {
	"WALK_armed", "WALK_civi", "WALK_csaw", "WOMAN_walksexy", "WALK_drunk", "WALK_fat", "WALK_fatold", "WALK_gang1", "WALK_gang2", "WALK_old",
	"WALK_player", "WALK_rocket", "WALK_shuffle", "Walk_Wuzi", "woman_run", "WOMAN_runbusy", "WOMAN_runfatold", "woman_runpanic", "WOMAN_runsexy", "WOMAN_walkbusy",
	"WOMAN_walkfatold", "WOMAN_walknorm", "WOMAN_walkold", "WOMAN_walkpro", "WOMAN_walksexy", "WOMAN_walkshop", "run_1armed", "run_armed", "run_civi", "run_csaw",
	"run_fat", "run_fatold", "run_gang1", "run_old", "run_player", "run_rocket", "Run_Wuzi"
}
function walkAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
	
		if getPedOccupiedVehicle(thePlayer) then
			return
		end
		
		if not walk[arg] then
			arg = 2
		end
		
		exports.global:applyAnimation( thePlayer, "PED", walk[arg], -1, true, true, false)
		
		--[[if cmd == "walk2" then
			local tempSkin = getElementModel(thePlayer)
		
			local vehicle, veholdstate = getPedOccupiedVehicle ( thePlayer ), nil
			if vehicle then
				veholdstate = getVehicleEngineState ( vehicle )
			end
			setElementModel(thePlayer, 0)
			setElementModel(thePlayer, tempSkin)
			if vehicle then
				setTimer(setVehicleEngineState, 200, 1, vehicle, veholdstate)
			end
		end]]
	end
end
addCommandHandler("walk", walkAnimation, false, false)
addCommandHandler("walk2", walkAnimation, false, false)

-- /bat animtion -------------------------------------------------
function batAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "CRACK", "Bbalbat_Idle_02", -1, true, false, false)
		elseif arg == 3 then
			exports.global:applyAnimation( thePlayer, "Baseball", "Bat_IDLE", -1, true, false, false)
		else
			exports.global:applyAnimation( thePlayer, "CRACK", "Bbalbat_Idle_01", -1, true, false, false)
		end
	end
end
addCommandHandler("bat", batAnimation, false, false)

-- /win Amination -------------------------------------------------------------------------
function winAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	arg = tonumber(arg)
	
	if (logged==1) then
		if arg == 2 then
			exports.global:applyAnimation( thePlayer, "CASINO", "manwinb", 2000, false, false, false)
		else
			exports.global:applyAnimation( thePlayer, "CASINO", "manwind", 2000, false, false, false)
		end
	end
end
addCommandHandler ( "win", winAnimation, false, false )

-- /kickballs Amination -------------------------------------------------------------------------
function kickballsAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "FIGHT_E", "FightKick_B", 1, false, false, false)
	end
end
addCommandHandler ( "kickballs", kickballsAnimation, false, false )

-- /grabbottle Amination -------------------------------------------------------------------------
function grabbAnimation(thePlayer, cmd, arg)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		exports.global:applyAnimation( thePlayer, "BAR", "Barserve_bottle", 2000, false, false, false)
	end
end
addCommandHandler ( "grabbottle", grabbAnimation, false, false )

-- /kiss by Equinox
function kissingAnimation( thePlayer, commandName, target )
	local logged = getElementData(thePlayer, "loggedin")
	if not target or target == "" then
		outputChatBox( "SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14 )
		return false
	end
	local targetPlayer = exports.global:findPlayerByPartialNick(thePlayer, target)
	if not(logged==1) then
		return false
	end	
		
	if not (targetPlayer) then
		outputChatBox( "SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14 )
		return false
	end

	local x, y, z = getElementPosition(thePlayer)
	local tx, ty, tz = getElementPosition(targetPlayer)
	if (getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)<1) and getPedOccupiedVehicle(thePlayer) == false and getPedOccupiedVehicle(targetPlayer) == false then
		exports.global:applyAnimation( thePlayer, "KISSING", "Grlfrd_Kiss_01", -1, false, false, false )
		exports.global:applyAnimation( targetPlayer, "KISSING", "Grlfrd_Kiss_01", -1, false, false, false )
	end
end
addCommandHandler( "kiss", kissingAnimation, false, false )

-- /handshake animation -------------------------------------------------
function realHandshakeAnimation(thePlayer, cmd, otherGuy)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		if otherGuy then
			local otherPlayer = exports.global:findPlayerByPartialNick(thePlayer, otherGuy)
			if otherPlayer then
				if (getPedOccupiedVehicle(thePlayer) == false and getPedOccupiedVehicle(otherPlayer) == false)  then
					local x, y, z = getElementPosition(thePlayer)
					local tx, ty, tz = getElementPosition(otherPlayer)
					if (getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)<1.5) then -- Are they standing next to each other?
						exports.global:applyAnimation( thePlayer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false)
						exports.global:applyAnimation( otherPlayer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false)
					else
						outputChatBox("You are too far away to handshake this player.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("You can't handshake if you or the other player is in a vehicle.", thePlayer, 255, 0, 0)
				end
			end
		else
			exports.global:applyAnimation( thePlayer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false)
		end
	end
end
addCommandHandler("handshake", realHandshakeAnimation, false, false)