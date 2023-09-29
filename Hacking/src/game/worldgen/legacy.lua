local legacy = {}

local WorldGen_Legacy = function(map)
	legacy.plategen(map, TUNING.WORLDGEN.LEGACY.PLATE_COUNT)
	legacy.terrainpass(map)
	legacy.coastpass(map)

	legacy.riverpass(map)
end

function legacy.plategen(map, n)
	local fills = {}
	for i=1,n do
		local cell = map:GetCell(math.random(1,map.w-1), math.random(1,map.h-1))
		cell.color2 = RandomColor()
		cell.plate = i
		table.insert(fills, cell)
	end

	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			local least = -1
			local leastindex = 0
			for i,v in ipairs(fills) do
				local d = hex.distance(cell, v)-- + (math.random(0,1)*2)-1--DBG
				if d < least or least == -1 then
					least = d
					leastindex = i
				end
			end
			cell.plate = fills[leastindex].plate
			cell.color2 = fills[leastindex].color2--HSVtoRGB((leastindex+1)/(n+1) * 360--[[least * 3.6 * 1.75]],1,1)
		end
	end

	for i,v in ipairs(fills) do
		v.color = COLORS.WHITE
	end

	local function PickRandomBiome()
		if math.random(1,100)/100 <= TUNING.WORLDGEN.LEGACY.WATER_RATIO then
			return Biomes.Ocean
		else
			return table.random(PlateBiomes)
		end
	end

	local plates = {}
	for i=1,n do
		plates[i] = PickRandomBiome()
	end

	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			cell.color = plates[cell.plate].color
			cell.tex = ASSETS.IMAGES[string.upper(plates[cell.plate].tex)]
			cell.biome = plates[cell.plate]
			cell.movecost = cell.biome.movecost
		end
	end

	--[[while #fills > 0 do
		local newfills = {}
		for i,v in ipairs(fills) do
			local fill = hex.tickfloodfill(map, v)
			if #fill > 0 then
				table.insert(newfills, fill)
			end
		end
		fills = newfills
	end]]
end

function legacy.coastpass(map)
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			if cell.biome == Biomes.Ocean then
				local coast = false
				for i,v in ipairs(hex.neighbors(cell)) do
					if not v.biome then
						local str = ""
						for kk,vv in pairs(v) do
							str = str..kk.."   "..vv.."\n"
						end
						assert(false, str)
					end
					if not v.biome.marine then
						coast = true
						break
					end
				end
				if coast then
					cell.biome = Biomes.Coast
					cell.color = Biomes.Coast.color
				end
			end
		end
	end
end

local offsets = {
	{ ox=1, oz=-1 },
	{ ox=1, oz=0 },
	{ ox=0, oz=1 },
	{ ox=-1, oz=1 },
	{ ox=-1, oz=0 },
	{ ox=0, oz=-1 },
}

function legacy.terrainpass(map)
	--Hills
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			if cell.biome ~= Biomes.Ocean and math.random(1,TUNING.WORLDGEN.LEGACY.HILL_CHANCE)==1 then
				cell.terrain = "hills"
			end
		end
	end

	--Mountains
	for i=1,TUNING.WORLDGEN.LEGACY.MOUNTAIN_COUNT do
		local x,y,cell
		while not cell or cell.biome == Biomes.Ocean do
			x = math.random(0,map.w-1)
			y = math.random(0,map.h-1)
			cell = map:GetCell(x, y)
		end

		cell.terrain = "mountain"

		local tx, ty, tz = CartesianToTrifold(x, y)
		
		for dir=1,6 do
			if math.random(1,TUNING.WORLDGEN.LEGACY.MOUNTAIN_SPREAD_CHANCE)==1 then
				local x2, y2 = TrifoldToCartesian(tx+offsets[dir].ox, tz+offsets[dir].oz)
				local cell = map:GetCell(x2, y2)
				if cell and cell.biome ~= Biomes.Ocean then
					cell.terrain = "mountain"
				end
			end
		end
	end

	local noforests = {
		Biomes.Ocean,
		Biomes.Desert,
		Biomes.Swamp,
	}

	--Forests
	for i=1,TUNING.WORLDGEN.LEGACY.FOREST_COUNT do
		local x,y,cell
		while not cell or table.contains(noforests, cell.biome) do
			x = math.random(0,map.w-1)
			y = math.random(0,map.h-1)
			cell = map:GetCell(x, y)
		end

		cell.vegetation = "forest"

		local tx, ty, tz = CartesianToTrifold(x, y)
		
		for dir=1,6 do
			if math.random(1,TUNING.WORLDGEN.LEGACY.FOREST_SPREAD_CHANCE)==1 then
				local x2, y2 = TrifoldToCartesian(tx+offsets[dir].ox, tz+offsets[dir].oz)
				local cell = map:GetCell(x2, y2)
				if cell and not table.contains(noforests, cell.biome) then cell.vegetation = "forest" end
			end
		end
	end
end

local opposites = { 4, 5, 6, 1, 2, 3 }

local function make_edge(cell, dir)
	if not cell then return {} end

	local nxt = dir + 1
	if nxt > 6 then nxt = 1 end

	local edir = dir + 2
	if edir > 6 then edir = edir - 6 end

	local c1 = hex.step(cell, dir)
	local c2 = hex.step(cell, nxt)
	return { cell = c1, other = c2, dir=edir, ccw = false }
end

local function branches(edge)
	local dir = edge.dir - 1
	if dir < 1 then dir = 6 end
	if not edge.cell then
		--[[local str = ""
		for k,v in pairs(THEDEBUGPATH) do
			str = str.."{ "
			for kk,vv in pairs(v) do str = str..kk.."   "..tostring(vv)..", " end
			str = str.."}\n"
		end
		assert(false, str)]]
	end

	if not edge.cell then return {} end

	local newCell = hex.step(edge.cell, dir)

	if not newCell then return {} end

	local dir2 = edge.dir + 1
	if dir2 > 6 then dir2 = 1 end

	local b1 = { cell = edge.cell, other = newCell, dir = dir, ccw = false }
	local b2 = { cell = newCell, other = edge.other, dir = dir2, ccw = false }

	return b1, b2
end

function legacy.riverpass(map)
	local coasts = {}
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x, y)
			if cell.biome == Biomes.Coast then
				table.insert(coasts, cell)
			end
		end
	end

	for i=1,TUNING.WORLDGEN.LEGACY.RIVER_COUNT do
		--Selects coast tile with two adjacent land tiles
		local startCell, startDir
		repeat
			startDir = nil
			startCell = table.random(coasts)
			local neighbors = hex.neighbors(startCell)
			for dir=1,6 do
				if neighbors[dir] and not neighbors[dir].marine then
					local nxt = dir + 1
					if nxt > 6 then nxt = 1 end
					if neighbors[nxt] and not neighbors[nxt].marine then
						startDir = dir
						break
					end
				end
			end
		until startDir

		local path = { make_edge(startCell,startDir) }
		THEDEBUGPATH = path

		local rnums = {}
		local prev = nil
		for j=1,TUNING.WORLDGEN.LEGACY.RIVER_LENGTH do
			if prev then
				local r = math.random(1,6)
				if r > 2 then
					prev = prev%2+1
					table.insert(rnums, prev)
				else
					table.insert(rnums, r)
					prev = r
				end
			else
				local r = math.random(1,2)
				table.insert(rnums, r)
				prev = r
			end
		end
		for j=1,TUNING.WORLDGEN.LEGACY.RIVER_LENGTH do
			local b1, b2 = branches(path[#path])
			local valid = {}
			for _,v in ipairs({ b1, b2 }) do --Gimmicky
				if (v.cell and v.other and (not v.cell.biome.marine) and (not v.other.biome.marine)) then
					table.insert(valid, v)
				end
			end
			if #valid == 0 then break end
			local r = rnums[1]
			table.remove(rnums, 1)
			local nextEdge = valid[r]
			if #valid == 1 then nextEdge = valid[1] end
			table.insert(path, nextEdge)
		end

		for ii, v in ipairs(path) do
			if v.cell then
				v.cell.rivers[v.dir] = true
				if v.cell.biome == Biomes.Desert then v.cell.biome = Biomes.Floodplain end
			end
			if v.other then
				v.other.rivers[opposites[v.dir]] = true
				if v.other.biome == Biomes.Desert then v.other.biome = Biomes.Floodplain end
			end

			--v.cell.biome = Biomes.Debug
			--v.other.biome = Biomes.Debug
		end
	end
end

return WorldGen_Legacy