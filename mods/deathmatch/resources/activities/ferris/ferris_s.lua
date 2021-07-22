local fcabin = { obj = {}, step = {}, col = {} };
local interval = 7000;

addEventHandler( 'onResourceStart', resourceRoot, function()
  removeWorldModel( 3752, 500, 390.34, -2028.42, 22.47 );
  removeWorldModel( 3751, 500, 390.34, -2028.42, 22.47 );
  
  for i, t in ipairs( ferPos ) do
    fcabin.obj[ i ] = createObject( 3752, t[ 1 ], t[ 2 ], t[ 3 ], 0, 0, 0, false );
    attachElements( createMarker( 0, 0, 0, 'corona', 3.0, rnd(), rnd(), rnd(), 80 ), fcabin.obj[ i ], 0, 0, 1.65 );
    fcabin.col[ i ] = createColSphere( 0, 0, 0, 2.35 );
    attachElements( fcabin.col[ i ], fcabin.obj[ i ] );
  end;
  
  local iter = 1;
  for i, t in ipairs( mov_ferPos ) do
    if i % 2 ~= 0 then fcabin.step[ iter ] = i; iter = iter + 1; end;
  end;
  
  moveCabins();
  setTimer( moveCabins, interval, 0 );
  --createBlip( 390.34, -2028.42, 22.47, 46, 2, 255, 255, 255, 255, 0, 350 );
end );

addEvent( 'client_getCabinsCollision', true );
addEventHandler( 'client_getCabinsCollision', root, function()
  triggerClientEvent( client, 'server_sendCabinsCollision', root, fcabin.col );
end );

function moveCabins()
  for i = 1, #fcabin.obj do
    fcabin.step[ i ] = fcabin.step[ i ] + 1;
    if fcabin.step[ i ] > #mov_ferPos then fcabin.step[ i ] = 1; end;
    moveObject( fcabin.obj[ i ], interval, mov_ferPos[ fcabin.step[ i ] ][ 1 ], mov_ferPos[ fcabin.step[ i ] ][ 2 ], mov_ferPos[ fcabin.step[ i ] ][ 3 ] );
  end;
end;

function rnd()
  return math.random( 0, 255 );
end;