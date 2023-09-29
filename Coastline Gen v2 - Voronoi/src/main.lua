require "util/color"
require "util/math"
require "util/input"

perlin = require("lib/perlin")

SITE_COUNT = 500
SITE_VARIANCE = 300

VALUEFIELD_RESOLUTION = 512
VALUEFIELD_SIZE = SITE_VARIANCE*2

ERODE_COUNT = 10
TERRACE_COUNT = 16
ISLAND_TOLERANCE = 10

ACC_CAP = 10

function love.load()
	WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getMode()
	MID_X = WINDOW_WIDTH / 2
	MID_Y = WINDOW_HEIGHT / 2

	WINDOW_DIAGONAL = math.dist(WINDOW_WIDTH, WINDOW_HEIGHT)

	Sites = {}

	for i=1,SITE_COUNT do
		local x = math.random(-SITE_VARIANCE, SITE_VARIANCE)
		local y = math.random(-SITE_VARIANCE, SITE_VARIANCE)

		local dist = math.dist(x, y)
		--x = x*math.sqrt(dist) / 20
		--y = y*math.sqrt(dist) / 20

		Sites[i] = {
			x = MID_X + x,
			y = MID_Y + y,
			id = i
		}
	end

	ValueField_Size = VALUEFIELD_SIZE
	ValueField_MinX = MID_X - VALUEFIELD_SIZE/2
	ValueField_MinY = MID_Y - VALUEFIELD_SIZE/2
	ValueField_CellSize = VALUEFIELD_SIZE / VALUEFIELD_RESOLUTION

	RecalcCoastline(300)
	RecalcDistanceField()

	Relax()
	Relax()
	Relax()
	

	ACC = 0
end

function RecalcDistanceField()
	--Distance Field
	local highest = 0
	ValueField = {}
	for y=1,VALUEFIELD_RESOLUTION do
		ValueField[y] = {}
		for x=1,VALUEFIELD_RESOLUTION do
			local wx = ValueField_MinX + x*ValueField_CellSize
			local wy = ValueField_MinY + y*ValueField_CellSize
			local best = WINDOW_DIAGONAL
			local bestid
			for i,v in ipairs(Sites) do
				local dy = math.abs(wy - v.y)
				local dx = math.abs(wx - v.x)
				local dist = math.dist(dx, dy)
				local val = dist
				if val < best then
					best = val
					bestid = v.id
				end
			end
			local val2 = bestid--bestid / #Sites
			ValueField[y][x] = val2
			highest = math.max(highest, val2)
		end
	end

	--Normalize
	for y=1,VALUEFIELD_RESOLUTION do
		for x=1,VALUEFIELD_RESOLUTION do
			--ValueField[y][x] = ValueField[y][x] / highest
		end
	end
end

function FindVoronoiCentroids()
	local Centroids = {}
	for i=1,SITE_COUNT do
		Centroids[i] = {
			x = 0,
			y = 0,
			id = i,
			pixel_count = 0,
		}
	end

	for y=1,VALUEFIELD_RESOLUTION do
		for x=1,VALUEFIELD_RESOLUTION do
			local wx = ValueField_MinX + ValueField_CellSize*x
			local wy = ValueField_MinY + ValueField_CellSize*y
			local id = ValueField[y][x]
			Centroids[id].x = Centroids[id].x + wx
			Centroids[id].y = Centroids[id].y + wy
			Centroids[id].pixel_count = Centroids[id].pixel_count + 1
		end
	end

	for i=1,SITE_COUNT do
		Centroids[i].x = Centroids[i].x / Centroids[i].pixel_count
		Centroids[i].y = Centroids[i].y / Centroids[i].pixel_count
	end

	return Centroids
end

function Relax()
	Sites = FindVoronoiCentroids()
	RecalcDistanceField()
end

function RecalcCoastline(param)
	local coastfn = function(x, y, param)
		--local sample = perlin.Simplex2D(x, y)
		local sample = perlin.Simplex2D(math.angle(x,y), 0)
		sample = (sample + 1)/2
		local noiseMult = (120 / 200) * param
		return math.dist(x, y) < (param - (sample * noiseMult))
	end

	for i=1,SITE_COUNT do
		Sites[i].is_coast = coastfn(Sites[i].x - MID_X, Sites[i].y - MID_Y, param)
	end
end

--Manhattan dist for now
function Erode()
	local NewValueField = {}
	for y=1,VALUEFIELD_RESOLUTION do
		NewValueField[y] = {}
		local distfn = function(dx, dy)
			local fractionFromCenterOfSide = math.abs(30 - (math.angle(dx, dy) % 60)) / 30
			return 1 / (math.lerp(math.sqrt(0.75),1,math.pow(fractionFromCenterOfSide,2)) * math.dist(dx, dy))
		end
		distfn = math.dist
		for x=1,VALUEFIELD_RESOLUTION do
			local val = 0
			local div = 0
			local scanSize = 2
			for dx=-scanSize,scanSize do
				for dy=-scanSize,scanSize do
					if not(dx == 0 and dy == 0) then --Redundant
						local cx = x+dx
						local cy = y+dy
						if cx >= 1 and cx <= VALUEFIELD_RESOLUTION and cy >= 1 and cy <= VALUEFIELD_RESOLUTION then
							local dist = math.dist(dx, dy)
							val = val + ValueField[cy][cx]/dist
							div = div + (1/dist)
						end
					end
				end
			end
			NewValueField[y][x] = val / div
		end
	end

	ValueField = NewValueField
end

function Normalize()
	local best = 0
	for y=1,VALUEFIELD_RESOLUTION do
		for x=1,VALUEFIELD_RESOLUTION do
			best = math.max(best, ValueField[y][x])
		end
	end
	for y=1,VALUEFIELD_RESOLUTION do
		for x=1,VALUEFIELD_RESOLUTION do
			ValueField[y][x] = ValueField[y][x] / best
		end
	end
end

function Terrace()
	for y=1,VALUEFIELD_RESOLUTION do
		for x=1,VALUEFIELD_RESOLUTION do
			ValueField[y][x] = math.floor(ValueField[y][x] * TERRACE_COUNT) / TERRACE_COUNT
		end
	end
end

function Cast()
	for y=1,VALUEFIELD_RESOLUTION do
		for x=1,VALUEFIELD_RESOLUTION do
			local val = 0
			if Sites[ValueField[y][x]].is_coast then val = 1 end
			ValueField[y][x] = val
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end

	if key == "r" and not isrepeat then
		love.load()
	end

	if key == "g" and not isrepeat then
		GRAYSCALE = not GRAYSCALE
	end

	if key == "t" and not isrepeat then
		Terrace()
	end

	if key == "c" and not isrepeat then
		Cast()
	end

	if key == "w" and not isrepeat then
		MONO = not MONO
	end

	if key == "m" and not isrepeat then
		RAWMODE = not RAWMODE
	end

	if key == "e" and not isrepeat then
		for i=1,10 do
			Erode()
			Normalize()
		end
	end

	if key == "l" and not isrepeat then
		Relax()
		RecalcCoastline()
	end

	if key == "space" and not isrepeat then
		PAUSED = not PAUSED
	end
end

BIOMES = false
GRAYSCALE = true
MONO = false
RAWMODE = false

PAUSED = false

biomecolors = {
	[0] = { 0, 0, 1, 1 },
	[1] = { 1, 1, 0, 1 },
	[2] = { 0, 1, 0, 1 },
	[3] = { 0.5, 0.5, 0.5, 1 }
}

function love.draw()
	if not PAUSED then ACC = ACC + love.timer.getDelta() end
	if ACC >= ACC_CAP then
		ACC = ACC - ACC_CAP
	end

	local t = ACC/ACC_CAP

	local param = math.lerp(0, 300, t)
	RecalcCoastline(param)

	for y=1,VALUEFIELD_RESOLUTION do
		for x=1,VALUEFIELD_RESOLUTION do
			local sample = ValueField[y][x]

			local hue

			if RAWMODE then
				hue = ValueField[y][x]
			else
				hue = (sample / (SITE_COUNT*2))
				if Sites[sample].is_coast then hue = hue + 0.5 end
				if MONO then hue = math.floor(hue * 2) / 2 end
			end

			local wx = ValueField_MinX + x*ValueField_CellSize
			local wy = ValueField_MinY + y*ValueField_CellSize

			if GRAYSCALE then
				love.graphics.setColor(hslToRgb(0, 0, hue, 1))
			elseif BIOMES then
				love.graphics.setColor(biomecolors[math.floor((1-sample) * 3)])
			else
				love.graphics.setColor(hslToRgb(hue, 1, 0.5, 1))
			end
			love.graphics.rectangle("fill", wx, wy, ValueField_CellSize, ValueField_CellSize)
		end
	end

	love.graphics.setColor(COLORS.WHITE)

	love.graphics.circle("line", MID_X, MID_Y, param)

	love.graphics.print("ACC: "..tostring(t), 0, 0)
	love.graphics.print("PAUSED: "..tostring(PAUSED), 0, 20)
end