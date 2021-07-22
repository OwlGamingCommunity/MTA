local gMe       = getLocalPlayer();
local gRoot     = getRootElement();
local gResRoot  = getResourceRootElement( getThisResource () );

local period = math.random( 250, 750 );

local basex = 835.384765625
local basey = -2032.1591796875
local basez = 1.356987953186
local starCorona = nil

addEventHandler( 'onClientResourceStart', gResRoot,
  function()
    local star = createObject( 1247, basex, basey, basez+19 )
    setObjectScale( star, 7.0 )
	setElementDimension(star, 1)
	--setElementRotation(star, 0, 0, 90)
    
    starCorona = createMarker( basex, basey, basez+23, 'corona', 8.0, 255, 0, 0, 255 )
   
  end
);

addEventHandler( 'onClientRender', gRoot,
  function()
	if (1 == getElementDimension(getLocalPlayer())) then
		fxAddSparks( basex, basey, basez+19, 0, 0, 2, 1.5, 2, 0, 0, 0, false, 2, 1 );
		fxAddSparks( basex, basey, basez+19, 0, 0, 2, 1.5, 2, 0, 0, 0, false, 2, 1 );
		fxAddSparks( basex, basey, basez+19, 0, 0, -2, 2.5, 15, 0, 0, 0, false, 1, 2 );
		fxAddSparks( basex, basey, basez+19, 0, 0, 2, 2.5, 15, 0, 0, 0, false, 5, 2 );
		
		local ap = math.abs( math.cos( getTickCount()/250 )*255 );
		local r = math.abs( math.cos( getTickCount()/250)*255 );
		setMarkerColor( starCorona, r, 0, 0, ap );
	end
  end
);