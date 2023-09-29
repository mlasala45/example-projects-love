local continents = {}

local WorldGen_Continents = function(map)
	continents.plategen(map, TUNING.WORLDGEN.PLATE_COUNT)
	--continents.terrainpass(map)
	continents.coastpass(map)

	--continents.riverpass(map)
end

--Flood Fill
--[[local done
	repeat
		done = true
		for i,fill in ipairs(fills) do
			local rand = math.random(1,#fill)
			local cell = fill[rand]
			table.remove(fill, rand)
			local neighbors = hex.neighbors(cell)
			cell.plate = i
			for ii,v in ipairs(neighbors) do
				if v then
					if not v.plate then
						if not table.contains(fill, v) then
							table.insert(fills, v)
						end
					end
				end
			end
			if #fill > 0 then done = false end
		end
	until done]]

local function voronoi_calc(map, plates)
	local boundary_cells = {}
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			cell.worldgen = {}
			local least = -1
			local second_least = -1
			local leastindex = 0
			for i,v in ipairs(plates) do
				local d = hex.distance(cell, v.site)
				if d < least or least == -1 then
					second_least = least
					least = d
					leastindex = i
				elseif d < second_least or second_least == -1 then
					second_least = d
				end
			end
			cell.worldgen.plate = leastindex
			if math.abs(second_least - least) < 2 then table.insert(boundary_cells, cell) end
		end
	end
	return boundary_cells
end

function continents.plategen(map, n)
	--Initial Site Selection

	local plates = {}
	for i=1,n do
		local cell = map:GetCell(math.random(1,map.w-1), math.random(1,map.h-1))
		--cell.color2 = RandomColor()
		--cell.plate = i
		table.insert(plates, { site=cell })
	end

	local boundary_cells = voronoi_calc(map, plates)

	--Lloyd Relaxation
	for i=1,TUNING.WORLDGEN.RELAX_ITERS do
		local centroids = {}
		for i,v in ipairs(plates) do
			centroids[i] = {}
			centroids[i].minX = 999
			centroids[i].maxX = 0
			centroids[i].minY = 999
			centroids[i].maxY = 0
		end
		for y=0,map.h-1 do
			for x=0,map.w-1 do
				local cell = map:GetCell(x, y)
				if cell.worldgen.plate then
					local plate = centroids[cell.worldgen.plate]
					if cell.x < plate.minX then plate.minX = cell.x end
					if cell.x > plate.maxX then plate.maxX = cell.x end
					if cell.y < plate.minY then plate.minY = cell.y end
					if cell.y > plate.maxY then plate.maxY = cell.y end
				end
			end
		end
		plates = {}
		for i=1,n do
			local x = math.floor((centroids[i].minX + centroids[i].maxX) / 2)
			local y = math.floor((centroids[i].minY + centroids[i].maxY) / 2)
			local cell = map:GetCell(x, y)
			table.insert(plates, { site=cell })
		end
		boundary_cells = voronoi_calc(map, plates)
	end

	--Plate Motion Assignment
	local motion_range = 5
	for i,v in ipairs(plates) do
		v.motion = { x=math.random(-motion_range, motion_range), y=math.random(-motion_range, motion_range) }
	end

	local motion_angles = {
		150,
		90,
		30,
		330,
		270,
		210,
	}
	for i=1,#motion_angles do
		motion_angles[i]=math.rad(motion_angles[i])
	end

	--Plate Type Assignment
	for i=1,n do
		local plate = plates[i]
		local water = math.random(1,100)/100 < TUNING.WORLDGEN.WATER_RATIO
		if water then
			plate.density = math.random(-n,-1)
			plate.marine = true
		else
			plate.density = math.random(1,n)
		end
	end
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x, y)
			if plates[cell.worldgen.plate].marine then
				cell.worldgen.marine = true
			end
		end
	end

	--Plate Boundary Calculation TODO: Fix the incorrect formula
	local boundaries = {}
	for i,v in ipairs(boundary_cells) do
		for dir=1,6 do
			local other = hex.step(v, dir)
			if other and other.worldgen.plate ~= v.worldgen.plate then
				local x = plates[v.worldgen.plate].motion.x - plates[other.worldgen.plate].motion.x
				local y = plates[v.worldgen.plate].motion.y - plates[other.worldgen.plate].motion.y
				local theta = motion_angles[dir]
				local shear = x*math.cos(theta) - y*math.sin(theta)
				local stress = y*math.cos(theta) + x*math.sin(theta)
				boundaries[v] = boundaries[v] or {}
				boundaries[v][dir] = { other=other, p1=plates[v.worldgen.plate].density, p2=plates[other.worldgen.plate].density, stress=stress, shear=shear }
			end
		end
	end

	--Elevation Interpolation
	--[[for k,v in pairs(boundaries) do
		for dir,vv in pairs(v) do
			k.rivers[dir] = true
			if vv.stress > 0 then k.rivers[dir] = COLORS.RED end
		end
	end]]

	for k,v in pairs(boundaries) do
		for dir,vv in pairs(v) do
			if vv.stress > 0 and plates[vv.other.worldgen.plate].density > 0 then
				local cell = hex.shift(k, dir, vv.stress)
				if cell and math.random(1,TUNING.WORLDGEN.RIDGE_CHANCE) == 1 then
					--cell.terrain = "mountain"
					cell.worldgen.elevation = TUNING.WORLDGEN.RIDGE_ELEVATION
				end
			end
		end
	end

	continents.elevationpass(map, TUNING.WORLDGEN.RIDGE_ELEVATION)

	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			if cell.worldgen.elevation and cell.terrain ~= "mountain" then
				if math.random(1,TUNING.WORLDGEN.HILL_CHANCE_PER_ELEVATION) <= cell.worldgen.elevation then
					if cell.worldgen.elevation >= TUNING.WORLDGEN.MOUNTAIN_CUTOFF then
						cell.terrain = "mountain"
					else
						cell.terrain = "hills"
					end
				end
			end
		end
	end

	--Land Perturbation
	continents.landperturb(map, TUNING.WORLDGEN.LAND_PERTURB_ITERS/2)
	continents.landpatch(map, 1)
	continents.landperturb(map, TUNING.WORLDGEN.LAND_PERTURB_ITERS/2)
	continents.landpatch(map, 1)

	--Wind Calculation
	continents.windpass(map)

	--Heat Calculation
	--[[for y=0,map.h-1 do
		for x=0,map.w-1 do
			map:GetCell(x,y).worldgen.airheat = (map.h/2) - math.abs((map.h/2)-y)
			map:GetCell(x,y).worldgen.heat = map:GetCell(x,y).worldgen.airheat
		end
	end
	for i=1,TUNING.WORLDGEN.HEAT_ITERS do
		continents.heatpass(map)
	end]]
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local latitude = ((1-(y/map.h))*180)-90
			if math.abs(latitude) <= 20 then
				map:GetCell(x,y).worldgen.heat = 27
			else
				local diff = math.abs(latitude)-20
				map:GetCell(x,y).worldgen.heat = 27 - (diff * 0.85)
			end
			
		end
	end

	--Moisture Calculation
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			if cell.worldgen.marine then
				cell.worldgen.moisture = TUNING.WORLDGEN.OCEAN_MOISTURE
			else
				cell.worldgen.moisture = 0
			end
		end
	end
	continents.moisturepass(map, TUNING.WORLDGEN.MOISTURE_ITERS)

	--Biome Assignment

	local function PickRandomBiome()
		if math.random(1,100)/100 <= TUNING.WORLDGEN.WATER_RATIO then
			return Biomes.Ocean
		else
			return table.random(PlateBiomes)
		end
	end

	continents.biomepass(map)

	continents.biomeperturb(map, TUNING.WORLDGEN.BIOME_PERTURB_ITERS/2)
	continents.biomepatch(map, 1)
	continents.biomeperturb(map, TUNING.WORLDGEN.BIOME_PERTURB_ITERS/2)
	continents.biomepatch(map, 1)

	--[[for i=1,n do
		if plates[i].density > 0 then 
			plates[i].biome = table.random(PlateBiomes)
		else
			plates[i].biome = Biomes.Ocean
		end
	end

	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			cell.biome = plates[cell.worldgen.plate].biome
			if not cell.biome then cell.biome = Biomes.Debug end
			--if table.contains(boundary_cells, cell) then cell.biome = Biomes.Debug end
			cell.movecost = cell.biome.movecost

			if cell.biome == Biomes.Ocean then
				cell.terrain = "flat"
			end
		end
	end]]

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

	--Fix Mountains
	--[[for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x,y)
			if cell.terrain == mountain then
				--
			end
		end
	end]]
end


function continents.coastpass(map)
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

--Hugely inefficient?
function continents.elevationpass(map, n)
	for i=1,n do
		for y=0,map.h-1 do
			for x=0,map.w-1 do
				local cell = map:GetCell(x, y)
				if (not cell.worldgen.elevation) or cell.worldgen.elevation == 0 then
					local highest = 0
					for _,v in ipairs(hex.neighbors(cell)) do
						if v.worldgen.elevation and v.worldgen.elevation > highest then
							highest = v.worldgen.elevation
						end
					end
					cell.worldgen.elevation = math.max(highest - 1, 0)
				end
			end
		end
	end
end

local wind_zones = {
	{ start=-90, dir=90  }, --Easterlies
	{ start=-60, dir=270 }, --Westerlies
	{ start=-38, dir=0   }, --Horse Latitudes
	{ start=-30, dir=90  }, --Trade Winds
	{ start= -4, dir=0   }, --Doldrums
	{ start=  4, dir=270 }, --Trade Winds
	{ start= 30, dir=0   }, --Horse Latitudes
	{ start= 38, dir=90  }, --Westerlies
	{ start= 60, dir=270 }, --Easterlies
}
function continents.windpass(map)
	local wind_dirs = { 90, 270, 90, 270, 90, 270 }
	for y=0,map.h-1 do
		local dir
		local i = math.floor(6*y/map.h)+1
		local t = (y%math.round(map.h/6))/(map.h/6)
		if y > map.h/2 then
			t = 1 - t
			dir = wind_dirs[i] + (t * -60)
		else
			dir = wind_dirs[i] + (t * 60)
		end
		--dir = wind_dirs[i]
		dir = (dir+360) % 360
		for x=0,map.w-1 do
			map:GetCell(x,y).worldgen.wind = dir
		end
	end
end

local opposites = { 4, 5, 6, 1, 2, 3 }
local angles = { 300, 0, 60, 120, 180, 240 }
for i=1,6 do angles[i] = math.rad(angles[i]) end
function continents.heatpass(map)
	local airHeat = {}
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x, y)
			local wind = cell.worldgen.wind
			local outflows = {}
			local totalOutflow = 0
			for dir=1,6 do
				outflows[dir] = math.cos(angles[dir]-math.rad(wind))
				if outflows[dir] > 0 then totalOutflow = totalOutflow + outflows[dir] end
			end
			for dir=1,6 do
				if outflows[dir] > 0 then
					local other = hex.step(cell, dir)
					if other then
						local deposit = math.min(TUNING.WORLDGEN.HEAT_DEPOSIT_SIZE, other.worldgen.airheat)
						local outflow = (cell.worldgen.airheat - deposit)*outflows[dir]/totalOutflow
						airHeat[other] = airHeat[other] or 0
						airHeat[other] = airHeat[other] + outflow
					end
				end
			end
		end
	end
	for cell,v in pairs(airHeat) do
		local deposit = math.min(TUNING.WORLDGEN.HEAT_DEPOSIT_SIZE, airHeat[cell])
		cell.worldgen.heat = cell.worldgen.heat + deposit
		cell.worldgen.airheat = airHeat[cell] - deposit
	end
end

--Temporary?
function continents.moisturepass(map, n)
	for i=1,n do
		for y=0,map.h-1 do
			for x=0,map.w-1 do
				local cell = map:GetCell(x, y)
				local highest = cell.worldgen.moisture + 1
				for _,v in ipairs(hex.neighbors(cell)) do
					local moisture = v.worldgen.moisture
					if v.terrain == "mountain" then moisture = moisture * 0 end
					if v.worldgen.moisture and v.worldgen.moisture > highest then
						highest = v.worldgen.moisture
					end
				end
				cell.worldgen.moisture = math.max(highest - 1, 0)
			end
		end
	end
end

local enum = {
	ice=1,
	tundra=2,
	grass=3,
	desert=4,
	forest=5,
	drygrass=6,
	jungle=7,
}
--[[local lookup = {
	{ enum.ice, enum.tundra, enum.grass, enum.desert, enum.desert, enum.desert },
	{ enum.ice, enum.tundra, enum.grass, enum.desert, enum.desert, enum.desert },
	{ enum.ice, enum.tundra, enum.forest, enum.forest, enum.drygrass, enum.drygrass },
	{ enum.ice, enum.tundra, enum.forest, enum.forest, enum.drygrass, enum.drygrass },
	{ enum.ice, enum.tundra, enum.forest, enum.forest, enum.jungle, enum.jungle },
	{ enum.ice, enum.tundra, enum.forest, enum.jungle, enum.jungle, enum.jungle },
}]]
local lookup = {
	{ enum.tundra, enum.drygrass, enum.grass, enum.desert },
	{ enum.tundra, enum.grass, enum.grass, enum.grass },
	{ enum.tundra, enum.grass, enum.forest, enum.forest },
	{ enum.tundra, enum.forest, enum.forest, enum.jungle },
}
local biomes = {
	[enum.ice] = Biomes.Tundra,
	[enum.tundra] = Biomes.Tundra,
	[enum.grass] = Biomes.Grasslands,
	[enum.desert] = Biomes.Desert,
	[enum.drygrass] = Biomes.Savanna,
	[enum.forest] = Biomes.Grasslands,
	[enum.jungle] = Biomes.Jungle,
}
function continents.biomepass(map)
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x, y)
			cell.worldgen.b_moisture = math.min(math.floor(cell.worldgen.moisture*4/TUNING.WORLDGEN.OCEAN_MOISTURE)+1,4)
			cell.worldgen.b_heat = math.min(math.floor((cell.worldgen.heat+35)*4/62)+1,4)
			if cell.worldgen.b_heat == 4 then
				local sine = (math.sin((x%5)*math.pi)*5)+5
				if cell.worldgen.heat < 27-sine then cell.worldgen.b_heat = 3 end 
			end
		end
	end
	for y=0,map.h-1 do
		for x=0,map.w-1 do
			local cell = map:GetCell(x, y)
			if cell.worldgen.marine then
				cell.biome = Biomes.Ocean
				cell.terrain = "flat"
			else
				local biome = lookup[cell.worldgen.b_moisture][cell.worldgen.b_heat]
				assert(biome, cell.worldgen.moisture.."  "..cell.worldgen.heat)
				cell.biome = biomes[biome]
				if biome == enum.forest and math.random(1,TUNING.WORLDGEN.FOREST_CHANCE)==1 then
					cell.vegetation = "forest"
				elseif biome == enum.jungle then
					cell.vegetation = "forest"
				end
			end
		end
	end
end

function continents.biomeperturb(map, n)
	for i=1,n do
		for y=0,map.h-1 do
			for x=0,map.w-1 do
				local cell = map:GetCell(x, y)
				if not cell.worldgen.marine then
					local candidates = {}
					for i,v in ipairs(hex.neighbors(cell)) do
						if not v.worldgen.marine then table.insert(candidates, v) end
					end
					if #candidates > 0 then
						local neighbor = table.random(candidates)
						cell.biome = neighbor.biome
					end
				end
			end
		end
	end
end

function continents.biomepatch(map, n)
	for i=1,n do
		for y=0,map.h-1 do
			for x=0,map.w-1 do
				local cell = map:GetCell(x, y)
				if not cell.worldgen.marine then
					local candidates = {}
					for i,v in ipairs(hex.neighbors(cell)) do
						if not v.worldgen.marine then
							candidates[v.biome] = (candidates[v.biome] or 0) + 1
							if candidates[v.biome] == 4 then
								cell.biome = v.biome
								break
							end
						end
					end
				end
			end
		end
	end
end

function continents.landperturb(map, n)
	for i=1,n do
		for y=0,map.h-1 do
			for x=0,map.w-1 do
				local cell = map:GetCell(x, y)
				local marine = table.random(hex.neighbors(cell)).worldgen.marine
				cell.worldgen.marine = marine
			end
		end
	end
end

function continents.landpatch(map, n)
	for i=1,n do
		for y=0,map.h-1 do
			for x=0,map.w-1 do
				local cell = map:GetCell(x, y)
				local candidates = {}
				for i,v in ipairs(hex.neighbors(cell)) do
					if v.worldgen.marine == nil then v.worldgen.marine = false end
					candidates[v.worldgen.marine] = (candidates[v.worldgen.marine] or 0) + 1
					if candidates[false] == 4 then
						cell.worldgen.marine = false
						break
					end
					if candidates[true] == 4 then
						cell.worldgen.marine = true
					end
				end
			end
		end
	end
end

return WorldGen_Continents