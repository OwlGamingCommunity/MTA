myWindow = nil

function bmxRules()
	if ( myWindow == nil ) then
		local xmlServerRules = xmlLoadFile( "bmxrules.xml" )

		local width, height = 375, 450
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		myWindow = guiCreateWindow(x, y, width, height, "Skatepark Roleplay - Rules", false)

		local memoRules = guiCreateMemo ( 0, 0.075, 1, 0.8, xmlNodeGetValue( xmlServerRules ), true, myWindow )
		guiMemoSetReadOnly(memoRules, true)

		close = guiCreateButton(0.1, 0.9, 0.75, 0.1, "Close", true, myWindow)
		addEventHandler("onClientGUIClick", close, closeRules)

		showCursor( true )
	end
end
addCommandHandler("sprules", bmxRules)

function closeRules()
	if (source == close) then
		destroyElement(myWindow)
		myWindow = nil
		showCursor(false)
	end
end

bmxCol = createColPolygon(
	1862.216796875, -1450.5458984375,
	1862.216796875, -1450.5458984375,
	1862.185546875, -1351.2451171875,
	1976.10546875, -1351.2451171875,
	1976.10546875, -1450.31640625
)

local gMe   = getLocalPlayer();
local gRoot = getRootElement();

local minus = false;
local plus  = false;
local left  = false;
local right  = false;

addEventHandler( 'onClientResourceStart', gRoot,
  function ( res )
    if res == getThisResource() then
      bindKey( 'arrow_l', 'both', turnRotation );
      bindKey( 'q', 'both', turnRotation );
      bindKey( 'arrow_r', 'both', turnRotation );
      bindKey( 'e', 'both', turnRotation );
    end;
  end
);

function turnRotation( key, keyState )
  if key == 'arrow_l' or key == 'q' then
    if keyState == 'down' then
      if not left and not plus and not minus and not right then
        left = true;
        addEventHandler( 'onClientPreRender', gRoot, leftRotation );
      end;
    else
      left = false
      removeEventHandler( 'onClientPreRender', gRoot, leftRotation );
    end;
  elseif key == 'arrow_r' or key == 'e' then
    if keyState == 'down'then
      if not right and not plus and not minus and not left then
        right = true;
        addEventHandler( 'onClientPreRender', gRoot, rightRotation );
      end;
    else
      right = false;
      removeEventHandler( 'onClientPreRender', gRoot, rightRotation );
    end;
	end;
end;

function leftRotation()
	local px, py, pz = getElementPosition(localPlayer)
	local ground = getGroundPosition (px, py, pz)
	local distance = getDistanceBetweenPoints3D(px, py, pz, px, py, ground)
	if distance > 2 then
		local bike = getPedOccupiedVehicle( gMe );
		if bike and getElementModel(bike) == 481 and isElementWithinColShape(localPlayer, bmxCol) and not isVehicleOnGround(bike) then
			setElementAngularVelocity(bike, 0, 0, 0.075)
		end
	end
end

function rightRotation()
	local px, py, pz = getElementPosition(localPlayer)
	local ground = getGroundPosition (px, py, pz)
	local distance = getDistanceBetweenPoints3D(px, py, pz, px, py, ground)
	if distance > 2 then
		local bike = getPedOccupiedVehicle( gMe );
		if bike and getElementModel(bike) == 481 and isElementWithinColShape(localPlayer, bmxCol) and not isVehicleOnGround(bike) then
			setElementAngularVelocity(bike, 0, 0, -0.075)
		end
	end
end
