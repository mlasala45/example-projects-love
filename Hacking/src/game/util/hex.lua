hex = {}

function hex.neighbors(cell)
	local tx, ty, tz = CartesianToTrifold(cell.x, cell.y)
	local trifolds = {
		{ x=tx-1, z=tz },
		{ x=tx-1, z=tz+1 },
		{ x=tx, z=tz+1 },
		{ x=tx+1, z=tz },
		{ x=tx+1, z=tz-1 },
		{ x=tx, z=tz-1 },
	}
	local ret = {}
	for i,v in ipairs(trifolds) do
		local cx, cy = TrifoldToCartesian(v.x, v.z)
		table.insert(ret, cell.map:GetCell(cx, cy))
	end
	return ret
end

--[[function hex.neighbors(cell)
	return hex.ring(cell.x, cell.y, 1)
end]]

--Don't give this a negative
function hex.range(x, y, r)
	local t = {}
	for i=1,r do
		for _,v in ipairs(hex.ring(x, y, i)) do
			table.insert(t, v)
		end
	end
	table.insert(t, {x=x,y=y})
	return t
end

--Same
function hex.ring(x, y, r)
	local t = {}
	local tx, ty, tz = CartesianToTrifold(x, y)
	tx = tx-r
	ty = ty
	tz = tz+r
	for i=1,r do
		table.insert(t, {x=tx,z=tz})
		tx = tx + 1
		ty = ty - 1
	end
	for i=1,r do
		table.insert(t, {x=tx,z=tz})
		tx = tx + 1
		tz = tz - 1
	end
	for i=1,r do
		table.insert(t, {x=tx,z=tz})
		ty = ty + 1
		tz = tz - 1
	end
	for i=1,r do
		table.insert(t, {x=tx,z=tz})
		ty = ty + 1
		tx = tx - 1
	end
	for i=1,r do
		table.insert(t, {x=tx,z=tz})
		tz = tz + 1
		tx = tx - 1
	end
	for i=1,r do
		table.insert(t, {x=tx,z=tz})
		tz = tz + 1
		ty = ty - 1
	end
	local ret = {}
	for i,v in ipairs(t) do
		local cx, cy = TrifoldToCartesian(v.x, v.z)
		table.insert(ret, {x=cx,y=cy})
	end
	return ret
end

function hex.distance(a, b)
	a = a or { x=0, y=0 }
	b = b or { x=0, y=0 }
	local tx1, ty1, tz1 = CartesianToTrifold(a.x, a.y)
	local tx2, ty2, tz2 = CartesianToTrifold(b.x, b.y)

	local dx = math.abs(tx2-tx1)
	local dy = math.abs(ty2-ty1)
	local dz = math.abs(tz2-tz1)

	return math.max(math.max(dx,dy),dz)
end

function hex.path(start, destination)
	local file = love.filesystem.newFile("log.txt")
	file:open("w")
	local log = function(msg) file:write(msg.."\n") end
	local ts = function(cell) return cell.x.." "..cell.y end
	local estimate = function(a,b) return hex.distance(a,b) end --TODO
	local closed = {}
	local queue = { { priority=0, value={ cost=0, last=start, prev={} } } }
	log("BEGIN START "..ts(start).." DEST "..ts(destination))
	while #queue > 0 do
		local path = queue[1].value
		table.remove(queue, 1)
		local last = path.last
		log("LAST "..ts(last))
		if not (table.contains(closed, last)) then
			log("PROCEED")
			if (last == destination) then
				log("DONE")
				--path = path.prev
				local ret = {}
				while path.last do
					log(ts(path.last))
					table.insert(ret, path.last)
					path = path.prev
				end
				ret = table.reverse(ret)
				return ret
			end
			table.insert(closed, last);
			for i,v in ipairs(hex.neighbors(last)) do
				log("NEIGHBOR "..ts(v))
				local d = v.movecost
				log("COST "..d)
				local newPath = { cost=path.cost +d, last=v, prev=path }
				log("TOTAL "..newPath.cost)
				table.insert(queue, { priority=newPath.cost+estimate(v,destination), value=newPath })
				log("PRIORITY "..queue[#queue].priority)
				table.sort(queue, function(a,b) return a.priority < b.priority end)
			end
		end
	end
	file:flush()
	file:close()
end

local offsets = {
	{ ox=1, oz=-1 },
	{ ox=1, oz=0 },
	{ ox=0, oz=1 },
	{ ox=-1, oz=1 },
	{ ox=-1, oz=0 },
	{ ox=0, oz=-1 },
}

function hex.step(cell, dir)
	local tx, ty, tz = CartesianToTrifold(cell.x, cell.y)
	local cx, cy = TrifoldToCartesian(tx+offsets[dir].ox, tz+offsets[dir].oz)
	local c1 = cell.map:GetCell(cx, cy)
	return c1
end

function hex.shift(cell, dir, n)
	local tx, ty, tz = CartesianToTrifold(cell.x, cell.y)
	local cx, cy = TrifoldToCartesian(tx+(offsets[dir].ox*n), tz+(offsets[dir].oz*n))
	local c1 = cell.map:GetCell(cx, cy)
	return c1
end

--[[function hex.tickfloodfill(map, ff)
	local newqueue = {}
	newqueue.target = ff.target
	newqueue.color = ff.color
	for i,v in ipairs(ff) do
		local cell = map.cells[v.x] and map.cells[v.x][v.y]
		cell.color = ff.color
		for ii,vv in ipairs(hex.neighbors(v.x, v.y)) do
			local neighbor = map.cells[vv.x] and map.cells[vv.x][vv.y]
			if neighbor and neighbor.color == ff.target then
				table.insert(newqueue, { x=vv.x, y=vv.y })
			end
		end
	end
	return newqueue
end]]