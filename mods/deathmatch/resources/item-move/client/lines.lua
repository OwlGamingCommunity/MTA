local function drawLine(a, b, color)
  dxDrawLine3D( a[1], a[2], a[3], b[1], b[2], b[3], color, 1, true )
end

-- renders the selected object similar to the normal editor
local function getRelative(matrix, vx, vy, vz)
  local offX = vx * matrix[1][1] + vy * matrix[2][1] + vz * matrix[3][1] + matrix[4][1]
  local offY = vx * matrix[1][2] + vy * matrix[2][2] + vz * matrix[3][2] + matrix[4][2]
  local offZ = vx * matrix[1][3] + vy * matrix[2][3] + vz * matrix[3][3] + matrix[4][3]
  return offX, offY, offZ
end

function renderLines( object )
  if not isElementStreamedIn( object ) then return end

  local minx, miny, minz, maxx, maxy, maxz = getElementBoundingBox( object )
  if not minx then return end

  -- x/y/z lines
  local x, y, z = getElementPosition( object )
  local matrix = getElementMatrix( object, false )
  local r = getElementRadius( object ) * 1.3
  drawLine({x, y, z}, {getRelative(matrix, r, 0, 0)}, tocolor(200, 0, 0, 200))
  drawLine({x, y, z}, {getRelative(matrix, 0, r, 0)}, tocolor(0, 200, 0, 200))
  drawLine({x, y, z}, {getRelative(matrix, 0, 0, r)}, tocolor(0, 0, 200, 200))
end
