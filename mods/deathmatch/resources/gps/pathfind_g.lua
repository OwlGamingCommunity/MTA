local function calculatePath(db, nodeFrom, nodeTo)
	local next = next
	
	local g = { [nodeFrom] = 0 }		-- { node = g }
	local hcache = {}					-- { node = h }
	local parent = {}					-- { node = parent }
	local openheap = MinHeap.new()
	
	local function h(node)
		if hcache[node] then
			return hcache[node]
		end
		local x, y, z = node.x - nodeTo.x, node.y - nodeTo.y, node.z - nodeTo.z
		hcache[node] = x*x + y*y + z*z
		return hcache[node]
	end
	local nodeMT = {
		__lt = function(a, b)
			return g[a] + h(a) <  g[b] + h(b)
		end,
		__le = function(a, b)
			if not g[a] or not g[b] then
				outputConsole(debug.traceback())
			end
			return g[a] + h(a) <= g[b] + h(b)
		end
	}
	setmetatable(nodeFrom, nodeMT)
	openheap:insertvalue(nodeFrom)
	
	local current
	while not openheap:empty() do
		current = openheap:deleteindex(0)
		if current == nodeTo then
			break
		end
		
		local successors = {}
		for id,distance in pairs(current.neighbours) do
			local successor = getNodeByID(db, id)
			local successor_g = g[current] + distance*distance
			if not g[successor] or g[successor] > successor_g then
				setmetatable(successor, nodeMT)
				
				g[successor] = successor_g
				openheap:insertvalue(successor)
				parent[successor] = current
			end
		end
	end
	
	if current == nodeTo then
		local path = {}
		repeat
			table.insert(path, 1, current)
			current = parent[current]
		until not current
		return path
	else
		return false
	end
end

function calculatePathByCoords(x1, y1, z1, x2, y2, z2)
	local x = findNodeClosestToPoint(vehicleNodes, x1, y1, z1)
	local y = findNodeClosestToPoint(vehicleNodes,x2, y2, z2)
	if x and y then
		return calculatePath(vehicleNodes, x, y)
	end
end

function calculatePathByNodeIDs(node1, node2)
	node1 = getNodeByID(vehicleNodes, node1)
	node2 = getNodeByID(vehicleNodes, node2)
	if node1 and node2 then
		return calculatePath(vehicleNodes, node1, node2)
	else
		return false
	end
end

