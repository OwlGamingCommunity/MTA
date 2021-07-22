local scX, scY = guiGetScreenSize();
local lps = { x = 383.705, y = -2028.377, z = 7.835, rz = 90 };  -- Position where player will be teleported after he leaves a cabin
local bdKey = { 'h', 'h' };                                      -- Keys to get inside [1] and outside [2] of the cabin ('K' and 'L' by default)
local tstgs = {
  text = "Press '"..bdKey[ 1 ].."' to enter the cabin as a passenger",       -- Text that will show up when cabin gets closer to a player (Default, change it below also, lines 33 and 65)
  font = "bankgothic",  -- Text font (can be a custom font too)
  scale = 0.7,                                                   -- Text scale
  color = tocolor( 255, 255, 255, 255 ),                         -- Text color
  shadow = tocolor( 0, 0, 0, 255 )                               -- Text shadow color
};

addEventHandler( 'onClientResourceStart', resourceRoot, function()
  engineReplaceCOL( engineLoadCOL( 'ferris/fcabin.col' ), 3752 );
  triggerServerEvent( 'client_getCabinsCollision', localPlayer );
end );

addEventHandler( 'onClientResourceStop', resourceRoot, function()
  setCameraClip( true, true );
end );

addEvent( 'server_sendCabinsCollision', true );
addEventHandler( 'server_sendCabinsCollision', root, function( t )
  for i, col in ipairs( t ) do
    addEventHandler( 'onClientColShapeHit', col, function( player, dim )
      if player == localPlayer and dim then
        bindKey( bdKey[ 1 ], 'down', getInside, col );
        tstgs.text = "Press '"..bdKey[ 1 ].."' to enter the cabin";
        addEventHandler( 'onClientRender', root, drawNotice );
        setCameraClip( false, true );
      end;
    end );

    addEventHandler( 'onClientColShapeLeave', col, function( player, dim )
      if player == localPlayer and dim then
        removeEventHandler( 'onClientRender', root, drawNotice );
        unbindKey( bdKey[ 1 ], 'down', getInside );
        unbindKey( bdKey[ 2 ], 'down', leaveCabin );
        setCameraClip( true, true );
      end;
    end );
  end;
end );

addEventHandler( 'onClientPlayerWasted', localPlayer, function()
  unbindKey( bdKey[ 1 ], 'down', getInside );
  unbindKey( bdKey[ 2 ], 'down', leaveCabin );
  removeEventHandler( 'onClientRender', root, drawNotice );
end );

function drawNotice()
  dxDrawText( tstgs.text, scX*0.5 - dxGetTextWidth( tstgs.text, tstgs.scale, tstgs.font )/2, scY*0.85 + 1, scX, scY, tstgs.shadow, tstgs.scale, tstgs.font );
  dxDrawText( tstgs.text, scX*0.5 - dxGetTextWidth( tstgs.text, tstgs.scale, tstgs.font )/2, scY*0.85, scX, scY, tstgs.color, tstgs.scale, tstgs.font );
end;

function getInside( key, state, col )
  local x, y, z = getElementPosition( col );
  setElementPosition( localPlayer, x - 0.5, y, z );

  tstgs.text = "Press '"..bdKey[ 2 ].."' to exit the cabin";
  unbindKey( bdKey[ 1 ], 'down', getInside );
  bindKey( bdKey[ 2 ], 'down', leaveCabin );
end;

function leaveCabin( key, state )
  setElementPosition( localPlayer, lps.x, lps.y, lps.z );
  setElementRotation( localPlayer, 0, 0, lps.rz );
  unbindKey( bdKey[ 2 ], 'down', leaveCabin );
end;
