local movespeed = 0.02
local slowmovespeed = 0.004
local fastmovespeed = 0.08
local rotatespeed = 1
local slowrotatespeed = 0.2
local fastrotatespeed = 3

local controller = {
  slow = false, fast = false,
  left = false, right = false, forwards = false, backwards = false, -- controller movement works independently of 'real' keys
  up = 0, down = 0,
  rx_0 = 0, rx_1 = 0, ry_0 = 0, ry_1 = 0, rz_0 = 0, rz_1 = 0, rz_2 = 0, rz_3 = 0,
  deselect = false, reset = false, next = false, prev = false }
local frame = 0

local _getAnalogControlState = getAnalogControlState
function getAnalogControlState( key )
  return controller[key] and 1 or _getAnalogControlState(key)
end

-- mapped keys -> controls

local keys = {}
local function map(target, what, ...)
  for k, v in ipairs({...}) do
    keys[v] = {target, what}
  end
end
map(true, 'forwards', 'w')
map(true, 'backwards', 's')
map(true, 'left', 'a')
map(true, 'right', 'd')
map(true, 'fast', 'joy6', 'lshift')
map(true, 'slow', 'joy5', 'lalt')

map(true, 'reset', 'joy7', 'joy9')
map(true, 'deselect', 'joy8', 'joy10')
map(true, 'next', 'axis_9')
map(true, 'prev', 'axis_10')

map(1, 'up', 'joy4', 'axis_12', 'arrow_u')
map(1, 'down', 'joy1', 'axis_6', 'arrow_d')
map(1, 'rz_1', 'joy3', 'arrow_l')
map(1, 'rz_0', 'joy2', 'arrow_r')
map(1, 'rz_2', 'mouse_wheel_up')
map(1, 'rz_3', 'mouse_wheel_down')

function resetController( )
  for k, v in pairs(controller) do
    controller[k] = type(v) == 'number' and 0 or false
  end
end

function captureKeys( key, state )
  local info = keys[key]
  if info then
    if key:sub(1,5) == 'mouse' and isMouseOverGUI( ) then
      state = false
    end

    if type(info[1]) == 'number' then
      state = state and 1 or 0
    end
    controller[info[2]] = state
  end
end

--

function getCameraRotation( )
  local cx, cy, _, tx, ty = getCameraMatrix ( )
  return math.deg( math.atan2( tx - cx, ty - cy ) )
end

function updateKeys( object )
  local next, prev = false, false
  if frame == 0 then
    next, prev = controller.next, controller.prev
    frame = 10
  else
    frame = frame - 1
  end

  if object then
    local x, y, z = getElementPosition( object )
    local rx, ry, rz = getElementRotation( object )
    local rot = getCameraRotation( )
    local speed = movespeed

    if getElementData(object, "protected") then 
      return false
    end
    
    -- moving the object somewhere
    local function move( n, dist )
      if math.abs(dist) < 0.03 then
        return
      end
      x, y = getInFrontOf( x, y, -(rot + 90*n), dist * speed )
    end

    if controller.slow ~= controller.fast then
      speed = controller.fast and fastmovespeed or slowmovespeed
    end
    move( 0, getAnalogControlState( 'forwards' ) - getAnalogControlState( 'backwards' ) )
    move( 1, getAnalogControlState( 'right' ) - getAnalogControlState( 'left' ) )
    z = z + ( controller.up - controller.down ) * speed * 1/3

    -- let's rotate this, maybe
    local speed = rotatespeed
    if controller.slow ~= controller.fast then
      speed = controller.fast and fastrotatespeed or slowrotatespeed
    end

    rx = rx + ( controller.rx_0 - controller.rx_1 ) * speed
    ry = ry + ( controller.ry_0 - controller.ry_1 ) * speed
    rz = rz + ( controller.rz_0 - controller.rz_1 + ( controller.rz_2 - controller.rz_3 ) * 5 ) * speed

    local deselect, reset = controller.deselect, controller.reset
    for k, v in pairs({deselect = false, reset = false, rz_2 = 0, rz_3 = 0}) do
      controller[k] = v
    end

    return x, y, z, rx, ry, rz, deselect, reset, next, prev
  end
  return nil, nil, nil, nil, nil, nil, false, false, next, prev
end
