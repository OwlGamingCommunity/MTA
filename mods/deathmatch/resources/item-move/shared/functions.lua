function getInFrontOf( x, y, rot, dist )
  return x + (dist or 1) * math.sin( math.rad( -rot ) ), y + (dist or 1) * math.cos( math.rad( -rot ) )
end
