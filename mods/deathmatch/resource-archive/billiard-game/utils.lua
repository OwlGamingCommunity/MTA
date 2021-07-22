ballNames={
	[2995]="One stripped",
	[2996]="Two stripped",
	[2997]="Three stripped",
	[2998]="Four stripped",
	[2999]="Five stripped",
	[3000]="Six stripped",
	[3001]="Seven stripped",

	[3002]="One solid", 

	[3003]="Cue ball",

	[3100]="Two solid",
	[3101]="Three solid",
	[3102]="Four solid",
	[3103]="Five solid",
	[3104]="Six solid",
	[3105]="Seven solid",
	[3106]="Eight-ball",
}


function shuffle(t)
  local n = #t
 
  while n >= 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end
 
  return t
end

function findRotation(startX, startY, targetX, targetY)	-- Doomed-Space-Marine
	local t = -math.deg(math.atan2(targetX - startX, targetY - startY))
	
	if t < 0 then
		t = t + 360
	end
	
	return t
end
