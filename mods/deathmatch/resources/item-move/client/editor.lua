local editing, editingObject -- dimension we're currently working in
local original = { pos = { 0, 0, 0 }, rot = { 0, 0, 0 },  }
local wInfo, eInfo, bReset, bClose, bProtect = nil, {}
local screenX, screenY = guiGetScreenSize( )
local ignoreGUIInput, ignoreKeyInput = false, false

function getObjectName( model )
  str = ''
  if isElement(model) then
    model = getElementModel(model)
  end
  return engineGetModelNameFromID( model ) .. ' [' .. model .. ']' .. str
end

local function getFancyRotation( rx, ry, rz )
  local t = {rx, ry, rz}
  for i = 0, 360, 45 do
    for k, v in ipairs(t) do
      if v > i-0.6 and v < i+0.6 then
        t[k] = i%360
      end
    end
  end
  return unpack(t)
end

local function canEditObject( object )
  return exports.integration:isStaffOnDuty(localPlayer) or exports.integration:isPlayerScripter(localPlayer)
end

addEvent('item:move', true)
addEventHandler('item:move', root,
  function(object)
    if not object then return end
    local itemID = getElementData(object, "itemID")
    if itemID == 169 then --disable for keypadlock / maxime
      return false
    end
    editing = object and getElementDimension(object) or nil
    --guiSetInputEnabled(true)
    -- just destroy the old menus anyhow.
    if wInfo then
      reset( )

      destroyElement( wInfo )
      wInfo = nil

      removeEventHandler( 'onClientElementDestroy', root, destroyed )
      removeEventHandler( 'onClientRender', root, render )
      removeEventHandler( 'onClientKey', root, captureKeys )
      resetController( )
      setElementFrozen( localPlayer, false )
      setObject( )
    end

    if editing and object then
      -- the info panel for the object attributes
      wInfo = guiCreateWindow( screenX - 250, screenY - 265, 250, 265, '', false)
      guiWindowSetSizable( wInfo, false )
      guiWindowSetMovable( wInfo, false )

      for k, name in ipairs({'Model', 'PosX', 'PosY', 'PosZ', 'RotX', 'RotY', 'RotZ'}) do
        local y = k * 25
        guiCreateLabel( 15, y + 2, 35, 20, name .. ':', false, wInfo )
        eInfo[k] = guiCreateEdit( 55, y, 200, 20, '', false, wInfo )

        addEventHandler( 'onClientGUIFocus', eInfo[k], function( ) ignoreKeyInput = true end, false )
        addEventHandler( 'onClientGUIBlur', eInfo[k], function( ) ignoreKeyInput = false end, false )
        addEventHandler( 'onClientGUIChanged', eInfo[k],
          function( )
            if not ignoreGUIInput then
              local x, y, z = tonumber(guiGetText(eInfo[2])), tonumber(guiGetText(eInfo[3])), tonumber(guiGetText(eInfo[4]))
              local rx, ry, rz = tonumber(guiGetText(eInfo[5])), tonumber(guiGetText(eInfo[6])), tonumber(guiGetText(eInfo[7]))
              if x and y and z and rx and ry and rz then
                setElementPosition( editingObject, x, y, z )
                setElementRotation( editingObject, rx, ry, rz )
              end
            end
          end, false)
      end
      guiEditSetReadOnly( eInfo[1], true )

      bProtect = guiCreateButton( 5, 200, 65, 20, 'Protect', false, wInfo )
      addEventHandler( 'onClientGUIClick', bProtect,
        function( button, state )
          if button == 'left' and state == 'up' then
            triggerEvent("item:move:protect", editingObject)
          end
        end, false
      )

      bReset = guiCreateButton( 75, 200, 65, 20, 'Reset', false, wInfo )
      addEventHandler( 'onClientGUIClick', bReset,
        function( button, state )
          if button == 'left' and state == 'up' then
            reset( )
            updateInfoPanel( )
          end
        end, false
      )

      bSave = guiCreateButton( 145, 200, 65, 20, 'Save', false, wInfo )
      addEventHandler( 'onClientGUIClick', bSave,
        function( button, state )
          if button == 'left' and state == 'up' then
            save( )
            updateInfoPanel( )
          end
        end, false
      )

      bClose = guiCreateButton( 215, 200, 30, 20, 'Close', false, wInfo )
      addEventHandler( 'onClientGUIClick', bClose,
        function( button, state )
          if button == 'left' and state == 'up' then
            close( )
          end
        end, false
      )

      local controls = guiCreateLabel( 15, 225, 240, 40, "Moving: WASDF, Arrow Up/Down\nRotating: Arrow Left/Right", false, wInfo )

      setObject( object )
      updateInfoPanel( )

      --

      addEventHandler( 'onClientElementDestroy', root, destroyed )
      addEventHandler( 'onClientRender', root, render )
      addEventHandler( 'onClientKey', root, captureKeys )
    end
  end, false
)

function destroyed( )
  if source == editingObject then
    setObject( )
    updateInfoPanel( )

    triggerEvent('item:move', root)
  end
end

function updateInfoPanel( )
  if editingObject then
    ignoreGUIInput = true


    guiSetSize( wInfo, 250, 265, false )
    guiSetPosition( wInfo, screenX - 250, screenY - 265, false )
    guiSetText( wInfo, 'Object' )

    -- new & shiny coords
    guiSetText( eInfo[1], getObjectName( editingObject ) )
    for k, v in ipairs({getElementPosition(editingObject)}) do
      guiSetText( eInfo[k+1], ("%.2f"):format(v) )
    end
    local rx, ry, rz = getFancyRotation(getElementRotation(editingObject))
    guiSetText( eInfo[5], ("%.1f"):format(rx) )
    guiSetText( eInfo[6], ("%.1f"):format(ry) )
    guiSetText( eInfo[7], ("%.1f"):format(rz) )

    ignoreGUIInput = false

    guiSetVisible( wInfo, true )
    --guiSetText( bClose, isChanged() and 'Save' or 'Close' )
  elseif isElement( wInfo ) then
    guiSetVisible( wInfo, false )
  end
end

function isChanged( )
  if editingObject then
    local difference = 0
    local x, y, z = getElementPosition(editingObject)
    local rx, ry, rz = getFancyRotation(getElementRotation(editingObject))
    local new = {{x, y, z}, {rx, ry, rz}}
    local keys = { 'pos', 'rot' }

    --for k, v in ipairs(new) do
      --local o = original[keys[k]]
      --[[if type(o) ~= type(v) then
        difference = 1000
      elseif type(v) == 'table' then
        for kx, vx in ipairs(v) do
          difference = math.max(difference, math.abs(vx - o[kx]))
        end
      end
    end]]
    --local hasChanged = difference > 0.001
    local hasChanged = true
    return hasChanged, new, x, y, z, rx, ry, rz
  end

  return false
end

function save( )
  if editingObject then
    -- did anyone even touch this?

    local changed, new, x, y, z, rx, ry, rz = isChanged()
    if changed then
      setElementRotation(editingObject, rx, ry, rz)
      setElementCollisionsEnabled(editingObject, true)

      triggerServerEvent( 'item:move:save', editingObject, x, y, z, rx, ry, rz )
      original.pos = new[1]
      original.rot = new[2]
    else
      setObject( )
      triggerEvent('item:move', root)
    end
  end
end

function close( )
  setObject( )
  if wInfo then
    reset( )

    destroyElement( wInfo )
    --guiSetInputEnabled(false)
    wInfo = nil

    removeEventHandler( 'onClientElementDestroy', root, destroyed )
    removeEventHandler( 'onClientRender', root, render )
    removeEventHandler( 'onClientKey', root, captureKeys )
    resetController( )
    setElementFrozen( localPlayer, false )
    setObject( )
  end
end

function reset( )
  if editingObject then
    local x, y, z = unpack( original.pos )
    local rx, ry, rz = unpack( original.rot )
    setElementPosition( editingObject, x, y, z )
    setElementRotation( editingObject, rx, ry, rz )
    setElementCollisionsEnabled(editingObject, true)
  end
end

--
-- mostly just for keeping data up to date

function getObject( )
  return editingObject
end

function setObject( obj )
  editingObject = obj
  if obj then
    original = { pos = { getElementPosition( obj ) }, rot = { getElementRotation( obj ) } }
    setElementCollisionsEnabled(obj, false)
  end
  updateCamera( )
end

function updateCamera( )
  if editingObject and isCursorShowing( ) and not isMTAWindowActive( ) then
    --setCameraMatrix( getCameraMatrix( ) )
    if getElementAlpha( localPlayer ) == 255 then
      setElementAlpha( localPlayer, 63 )
    end
  else
    if getCameraTarget( ) ~= localPlayer then
      --setCameraTarget( localPlayer )
    end
    if getElementAlpha( localPlayer ) == 63 then
      setElementAlpha( localPlayer, 255 )
    end
  end
end

--
-- fancy key actions

function render( )
  if editing ~= getElementDimension( localPlayer ) then
    triggerEvent('item:move', root)
  else
    setElementFrozen( localPlayer, isCursorShowing( ) )
    local x, y, z, rx, ry, rz, deselect, reset_, next, prev = updateKeys( editingObject )
    updateCamera( )
    if not isMTAWindowActive( ) and not ignoreKeyInput then
      if editingObject then
        renderLines( editingObject )
      end
      if not isCursorShowing( ) then return end

      if editingObject then
        if reset_ then
          reset( )
        elseif x then
          setElementPosition( editingObject, x, y, z )
          setElementRotation( editingObject, rx, ry, rz )
        end
      end

      if not reset_ and (next or prev or deselect) then
        save( )

        if deselect then
          guiGridListSetSelectedItem( gExisting, 0, 0 )
        else
          local row = guiGridListGetSelectedItem( gExisting )
          local max = guiGridListGetRowCount( gExisting ) - 1
          if prev then
            row = row - 1
            if row < -1 then
              row = max
            end
          elseif next then
            row = row + 1
            if row > max then
              row = -1
            end
          end
          guiGridListSetSelectedItem( gExisting, row, 1 )
        end
        triggerEvent( 'onClientGUIClick', gExisting, 'left', 'up' )
      end

      updateInfoPanel( )
    end
  end
end

addEventHandler( 'onClientResourceStop', resourceRoot,
  function( )
    if editing then
      setElementFrozen( localPlayer, false )
      if getElementAlpha( localPlayer ) == 63 then
        setElementAlpha( localPlayer, 255 )
      end
    end
  end
)

--

function isMouseOverGUI( cx, cy )
  if not cx then
    cx, cy = getCursorPosition( )
    cx, cy = cx * screenX, cy * screenY
  end
  for k, v in ipairs( getElementsByType( 'gui-window' ) ) do
    if guiGetVisible( v ) then
      local ax, ay = guiGetPosition( v, false )
      local bx, by = guiGetSize( v, false )
      bx, by = bx + ax, by + ay
      if cx >= ax and cx <= bx and cy >= ay and cy <= by then
        return true
      end
    end
  end
end

addEventHandler( 'onClientElementDataChange', resourceRoot,
  function( name )
    if name == 'moving' and source == editingObject then
      setObject( )
    end
  end
)
