local gMe       = getLocalPlayer();
local gRoot     = getRootElement();
local gResRoot  = getResourceRootElement( getThisResource () );
local xenabled = true
local period = math.random( 250, 750 );
local starCorona = nil
basex = 1479.455078125
basey = -1686.5869140625
basez = 11.046875

local treeBall = {
  { basex-3, basey-3, basez+8, 'corona', 3.0, 255, 0, 255, 255 },
  { basex+3, basey+3, basez+8, 'corona', 3.0, 255, 0, 0, 255 },
  { basex+3, basey-3, basez+8, 'corona', 3.0, 255, 255, 0, 255 },
  { basex-3, basey+3, basez+8, 'corona', 4.0, 255, 150, 255, 255 },
  
  { basex-1, basey-3, basez+10, 'corona', 4.0, 0, 150, 255, 255 },
  { basex+1, basey+3, basez+9, 'corona', 3.0, 0, 255, 255, 255 },
  { basex+1, basey-3, basez+10, 'corona', 3.0, 0, 65, 255, 255 },
  { basez-1, basey+3, basez+11, 'corona', 3.0, 255, 0, 255, 255 },
  
  { basex-4, basey+3, basez+13, 'corona', 3.0, 255, 0, 255, 255 },
  { basex+3, basey-3, basez+13, 'corona', 4.0, 255, 150, 10, 255 },
  { basex+1, basey+3, basez+13, 'corona', 3.0, 255, 65, 65, 255 },
  { basex-3, basey-3, basez+13, 'corona', 3.0, 255, 255, 65, 255 },
  
  { basex-2, basey+3, basez+16, 'corona', 3.0, 255, 0, 18, 255 },
  { basex+3, basey-3, basez+17, 'corona', 4.0, 255, 65, 10, 255 },
  { basex+2, basey+3, basez+17.5, 'corona', 4.0, 255, 180, 65, 255 },
  { basex-3, basey-3, basez+16, 'corona', 3.0, 255, 0, 65, 255 },
  
};

local ball = {};

function startRes()
    local star = createObject( 1247, basex, basey, basez+23 )
    setObjectScale( star, 10.0 )
    
    starCorona = createMarker( basex, basey, basez+23, 'corona', 8.0, 255, 0, 0, 255 )
    startTree()
end

function startTree()

    for i,tball in ipairs( treeBall ) do
      ball[i] = createMarker( tball[1], tball[2], tball[3], tball[4], tball[5], tball[6], tball[7], tball[8], tball[9] )
      setElementData( ball[i], 'period', math.random( 250, 750 ) )
    end
end
addEventHandler( 'onClientResourceStart', gResRoot, startRes)

function stopTree()
	for a, b in ipairs( (ball) ) do
		destroyElement(b)
		ball[a] = nil
	end
end
local posZ = 22;

addEventHandler( 'onClientRender', gRoot,
  function()
	if xenabled then
		fxAddSparks( basex, basey, basez+23, 0, 0, 2, 1.5, 2, 0, 0, 0, false, 2, 1 );
		fxAddSparks( basex, basey, basez+23, 0, 0, 2, 1.5, 2, 0, 0, 0, false, 2, 1 );
		fxAddSparks( basex, basey, basez+23, 0, 0, -2, 2.5, 15, 0, 0, 0, false, 1, 2 );
		fxAddSparks( basex, basey, basez+23, 0, 0, 2, 2.5, 15, 0, 0, 0, false, 5, 2 );
		
		local ap = math.abs( math.cos( getTickCount()/250 )*255 );
		local r = math.abs( math.cos( getTickCount()/250)*255 );
		setMarkerColor( starCorona, r, 0, 0, ap );
		
		for k, treeBalls in ipairs( ball ) do
		  local ap = math.abs( math.cos( getTickCount()/getElementData( treeBalls, 'period' ) )*255 );
		  local r, g, b = getMarkerColor( treeBalls );
		  setMarkerColor( treeBalls, r, g, b, ap );
		end;
	end
  end
);
local function togTree()
	xenabled = not xenabled
	if xenabled then
		startTree()
	else
		stopTree()
	end
end

addCommandHandler("tree", togTree)