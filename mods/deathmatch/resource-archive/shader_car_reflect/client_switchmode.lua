----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchCarPaintRefLite", root, true )
--
--	To switch off:
--			triggerEvent( "switchCarPaintRefLite", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- Switch effect on or off
--------------------------------
function switchCarPaintRefLite( )
	if getElementData(localPlayer, "graphic_shaderveh") ~= "0" then
		startCarPaintRefLite()
	else
		stopCarPaintRefLite()
	end
end
addEvent( "accounts:settings:graphic_shaderveh", false )
addEventHandler("accounts:settings:graphic_shaderveh", root, switchCarPaintRefLite)
addEventHandler("onClientResourceStart", resourceRoot, switchCarPaintRefLite)
