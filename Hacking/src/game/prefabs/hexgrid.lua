local HexGrid = Class(Prefab, function(self, x, y, w, h)
	self.base._ctor(self, "hexgrid", x, y)

	self.w = w
	self.h = h

	self.ww = HEX_RADIUS_SHORT * 2 * self.w + HEX_RADIUS_SHORT
	self.wh = (HEX_RADIUS * 1.5 * (self.h-1)) + (2 * HEX_RADIUS)

	self.rx = self.x - self.ww/2
	self.ry = self.y + self.wh/2

	self.cells = {}
	for y=0,self.h-1 do
		for x=0,self.w-1 do
			self.cells[x] = self.cells[x] or {}
			local color = COLORS.DARK_BLUE
			self.cells[x][y] = { x=x, y=y, color=color, biome=Biomes.Ocean, rivers={}, movecost=1, map=self, visibility={} }
		end
	end

	worldgen.gen(self, WORLDGEN_TYPE.CONTINENTS)

	hex.yieldpass(self)

	self.fills = {}

	self.shuffle = {}
	if ALT_MAP_DRAW then
		for i=1,50 do
			local t = table.shuffle(table.numbers(6))
			for j=1,6 do table.insert(self.shuffle, t[j]) end
		end
	end
	self.r1 = math.random(2,12)/2
	self.r2 = math.random(2,12)/2
end)

function HexGrid:Update(dt)
	local cornerX = (MID_X - (MID_X - self.rx) * TheCamera.sx) - TheCamera.x * TheCamera.sx
	local cornerY = (MID_Y - (MID_Y - self.ry) * TheCamera.sy) + TheCamera.y * TheCamera.sy
	local x,y = self:WorldToLocal(love.mouse.getX(), love.mouse.getY())
	local cx, cy = WorldToCartesian(x, y)
	self.hovered = self:GetCell(cx,cy)
end

local grid_cutoff = 0.6

--TODO: Stencils

local r = 10
local circles = {
	{ { x=0, y=0 } },
	{ { x=-10, y=0 }, { x=10, y=0 } },
	{ { x=-10, y=-8 }, { x=10, y=-8 }, { x=0, y=10 } },
	{ { x=-5, y=-5 }, { x=5, y=-5 }, { x=5, y=5 }, { x=-5, y=5 } },
}

local boxes = {}
boxes[1] = {}
boxes[2] = { { x1=-10, y1=r, x2=10, y2=-r } }
boxes[3] = { { x1=-10, y1=r+8, x2=10, y2=-r-8 } }
boxes[4] = {}

local alt_circ_2 = { { x=0, y=-10 }, { x=0, y=10 } }

local cs = { 0.6, 0.6, 0.5 }
--local clusterScale = 0.3
local function DrawYieldCluster(atlas, tex, wx, wy, num)
	local clusterScale = cs[num]
	love.graphics.scale(clusterScale)

	for i=1,num do
		local circ = circles[num][i]
		if num == 2 then
			circ = alt_circ_2[i]
		end
		Draw(atlas, tex, (wx/clusterScale)+circ.x, (wy/clusterScale)+circ.y)
	end

	love.graphics.scale(1/clusterScale)
end

local function DrawYields(wx, wy, cell)
	if table.len(cell.yields) == 0 then return end

	love.graphics.translate(wx, wy)
	love.graphics.scale(TheCamera.sx, TheCamera.sy)

	love.graphics.setColor(COLORS.THREE_QUARTER_BLACK)
	local n = table.len(cell.yields)
	for i,v in ipairs(circles[n]) do
		love.graphics.circle("fill", v.x, v.y, r)
	end
	for i,v in ipairs(boxes[n]) do
		love.graphics.polygon("fill", v.x1, v.y1, v.x2, v.y1, v.x2, v.y2, v.x1, v.y2)
	end

	love.graphics.setColor(COLORS.WHITE)
	local i = 1
	if cell.yields.food then
		DrawYieldCluster("civ_icons", "yield_food", circles[n][i].x, circles[n][i].y, cell.yields.food)
		i = i + 1
	end
	if cell.yields.prod then
		DrawYieldCluster("civ_icons", "yield_prod", circles[n][i].x, circles[n][i].y, cell.yields.prod)
		i = i + 1
	end
	if cell.yields.gold then
		DrawYieldCluster("civ_icons", "yield_gold", circles[n][i].x, circles[n][i].y, cell.yields.gold)
		i = i + 1
	end
	if cell.yields.sci then
		DrawYieldCluster("civ_icons", "yield_sci", circles[n][i].x, circles[n][i].y, cell.yields.sci)
		i = i + 1
	end
	if cell.yields.cult then
		DrawYieldCluster("civ_icons", "yield_cult", circles[n][i].x, circles[n][i].y, cell.yields.cult)
		i = i + 1
	end
	--Draw("civ_icons", "yield_food", 0, 0)

	love.graphics.origin()
end

function HexGrid:Draw()
	local cornerX = (MID_X - (MID_X - self.rx) * TheCamera.sx) - TheCamera.x * TheCamera.sx
	local cornerY = (MID_Y - (MID_Y - self.ry) * TheCamera.sy) + TheCamera.y * TheCamera.sy
	local minX, minY = WorldToCartesian(-cornerX / TheCamera.sx, (-WINDOW_HEIGHT + cornerY) / TheCamera.sy)
	local maxX, maxY = WorldToCartesian((WINDOW_WIDTH - cornerX) / TheCamera.sx, cornerY / TheCamera.sy)
	minX = math.max(minX-1,0)
	minY = math.max(minY-1,0)
	maxX = math.min(maxX+1,self.w-1)
	maxY = math.min(maxY+1,self.h-1)
	--local canvas2 = love.graphics.newCanvas()
	--local canvases = {}
	--love.graphics.setCanvas(canvas1)

	for y=minY,maxY do
		for x=minX,maxX do
			local cell = self.cells[x][y]
			--if not canvases[self.cells[x][y].tex] then canvases[self.cells[x][y].tex] = love.graphics.newCanvas() end
			--love.graphics.setCanvas(canvases[self.cells[x][y].tex])
			local wx,wy = self:GetHexCenter(x,y)

			local vis = cell.visibility[TheGameManager.player_num]
			if vis == 2 then
				love.graphics.setColor(cell.biome.color)
			elseif vis == 1 then
				love.graphics.setColor(ColorMult(cell.biome.color, 0.5))
			end

			--Heat Debug
			--[[local t = (cell.worldgen.heat+50) / (77)
			local h = 240 - (240 * t)
			local heatcolor = HSVtoRGB(h,1,1)
			love.graphics.setColor(heatcolor)]]

			--Moisture Debug
			--[[local t = cell.worldgen.moisture / (TUNING.WORLDGEN.OCEAN_MOISTURE)
			local h = 120 + (120 * t)
			local moistcolor = HSVtoRGB(h,1,1)
			love.graphics.setColor(moistcolor)]]

			--if love.keyboard.isDown("space") and cell.color2 then love.graphics.setColor(cell.color2) end
			
			--love.graphics.setShader(SHADERS.TILESHADER)
			--SHADERS.TILESHADER:send("tex", cell.tex)
			--love.graphics.setColor(COLORS.WHITE)

			if vis and vis ~= 0 or love.keyboard.isDown("space") then
				local verts = HexVerts(wx, wy, TheCamera.sx, TheCamera.sy)

				--Center Fill
				if ALT_MAP_DRAW then --constants.lua
					local pwx, pwy = wx, wy
					for i=1,6 do
						local ax = verts[((i-1)*2)+1]
						local ay = verts[((i-1)*2)+2]
						local bx = verts[((((i-1)*2)+2)%12)+1]
						local by = verts[((((i-1)*2)+3)%12)+1]
						local r, g, b = love.graphics.getColor()
						local rand = self.shuffle[math.ceil((x*self.r1+self.r2*y)%100+1)]
						local color = ColorMult({r,g,b}, 1.0-(rand*0.02))
						love.graphics.setColor(color)
						love.graphics.polygon("fill", ax, ay, bx, by, pwx, pwy)
					end
				else
					love.graphics.polygon("fill", verts)
				end

				love.graphics.setColor(COLORS.WHITE)

				--Features
				if cell.terrain == "hills" then
					Draw("hills" ,"tex", wx, wy, 0, 0.3*TheCamera.sx, 0.3*TheCamera.sy)
				elseif cell.terrain == "mountain" then
					Draw("mountain" ,"tex", wx, wy, 0, 0.47*TheCamera.sx, 0.47*TheCamera.sy)
				end

				if cell.vegetation == "forest" then
					Draw("forest" ,"tex", wx, wy, 0, 0.2*TheCamera.sx, 0.2*TheCamera.sy)
				end

				--Rivers
				love.graphics.setLineWidth(3)
				for dir=1,6 do
					if cell.rivers[dir] then
						local nxt = dir+1
						if nxt > 6 then nxt = 1 end

						local color = COLORS.BLUE
						if type(cell.rivers[dir])=="table" then
							color = cell.rivers[dir]
						end

						love.graphics.setLineWidth(6)
						love.graphics.setColor(color)
						love.graphics.line(verts[((dir-1)*2)+1], verts[((dir-1)*2)+2], verts[((nxt-1)*2)+1], verts[((nxt-1)*2)+2])
					end
				end
				love.graphics.setLineWidth(1)

				--Borders

				--Draw("hex", "tex", wx, wy, 0, TheCamera.sx*0.25, TheCamera.sy*0.25)
				--love.graphics.setShader()

				if SHOW_GRID then
					if TheCamera.sx > grid_cutoff then
						--Hex Border Line`
						love.graphics.setColor(COLORS.BLACK)
						love.graphics.polygon("line", HexVerts(wx, wy, TheCamera.sx, TheCamera.sy))
						love.graphics.setColor(COLORS.WHITE)
					end
				end

				--WIND DEBUG
				--local dirs = { 300,0,60,120,180,240 }
				--if cell.worldgen.wind then geo.drawArrow(wx, wy, cell.worldgen.wind, 15*TheCamera.sx, 7*TheCamera.sx, 30) end

				love.graphics.setColor(COLORS.WHITE)
			end
		end
	end
	local img2 = love.image.newImageData(WINDOW_WIDTH, WINDOW_HEIGHT)
	img2:mapPixel(function(x,y)
		local n = 512 * TheCamera.sx / 4
		local r = (x%n)/n
		local g = (y%n)/n
		local b = 0
		local a = 1
		return r*255, g*255, b*255, a*255
	end)
	--local canvas1 = love.graphics.newCanvas()
	--img2 = love.graphics.newImage(img2)
	--love.graphics.setCanvas(canvas1)
	--[[for k,v in pairs(canvases) do
		love.graphics.setShader(SHADERS.TILESHADER)
		--love.graphics.draw(img2,0,0,0,1,1)
		love.graphics.setShader()
	end]]
	--love.graphics.setCanvas()
	--local img1 = love.graphics.newImage(canvas1:newImageData())
	--img1 = love.graphics.newImage(img1)
	--love.graphics.setShader(SHADERS.TILESHADER)
	--love.graphics.draw(img1,0,0,0,1,1)
	--love.graphics.setShader()

	--Dynamic Selector
	if self.hovered then
		love.graphics.setColor(COLORS.HALF_BLACK)
		local wx, wy = self:GetHexCenter(self.hovered.x,self.hovered.y)
		love.graphics.setLineWidth(4)
		love.graphics.polygon("line", HexVerts(wx, wy, TheCamera.sx, TheCamera.sy))
		love.graphics.setLineWidth(1)
	end

	--Static Selector (After click)
	if self.selected then
		love.graphics.setColor(COLORS.WHITE)
		local wx, wy = self:GetHexCenter(self.selected.x,self.selected.y)
		love.graphics.setLineWidth(4)
		love.graphics.polygon("line", HexVerts(wx, wy, TheCamera.sx, TheCamera.sy))
		love.graphics.setLineWidth(1)
	end

	--Final Color Reset
	love.graphics.setColor(COLORS.WHITE)
	--love.graphics.circle("fill",MID_X,MID_Y,10)
end

function HexGrid:DrawYields()
	if SHOW_YIELDS then
		for y=minY,maxY do
			for x=minX,maxX do
				local cell = self.cells[x][y]
				local wx,wy = self:GetHexCenter(x,y)
			end
			DrawYields(wx, wy, cell)
		end
	end
	love.graphics.setColor(COLORS.WHITE)
end

function HexGrid:GetCell(x, y)
	return self.cells[x] and self.cells[x][y]
end

function HexGrid:GetUnit(x, y)
	--assert(false)
	return self.cells[x] and self.cells[x][y].unit
end

function HexGrid:GetCity(x, y)
	return self.cells[x] and self.cells[x][y].feature and self.cells[x][y].feature.city
end

function HexGrid:GetCellYields(cell)
	local ret = {}

	if cell.terrain == "mountain" then return ret end

	table.add(ret, cell.biome.yields)

	for dir=1,6 do
		if cell.rivers[dir] then
			table.add(ret, Yields.river)
			break
		end
	end

	if Yields[cell.terrain] then table.add(ret, Yields[cell.terrain]) end
	if Yields[cell.vegetation] then table.add(ret, Yields[cell.vegetation]) end

	return ret
end

--Incomplete
function HexGrid:GetCellMoveCost(cell)
	local ret = 0

	if cell.terrain == "mountain" then return 999 end

	table.add(ret, cell.biome.yields)

	for dir=1,6 do
		if cell.rivers[dir] then
			table.add(ret, Yields.river)
			break
		end
	end

	if Yields[cell.terrain] then table.add(ret, Yields[cell.terrain]) end
	if Yields[cell.vegetation] then table.add(ret, Yields[cell.vegetation]) end

	return ret
end

function HexGrid:GetHexCenter(cx, cy)
	local cornerX = (MID_X - (MID_X - self.rx) * TheCamera.sx) - TheCamera.x * TheCamera.sx
	local cornerY = (MID_Y - (MID_Y - self.ry) * TheCamera.sy) + TheCamera.y * TheCamera.sy
	local wx,wy = CartesianToWorld(cx,cy)
	wx = wx * TheCamera.sx
	wy = wy * TheCamera.sy
	return cornerX + HEX_RADIUS_SHORT*TheCamera.sx + wx, cornerY - HEX_RADIUS*TheCamera.sy + wy
end

function HexGrid:WorldToLocal(x, y)
	local cornerX = (MID_X - (MID_X - self.rx) * TheCamera.sx) - TheCamera.x * TheCamera.sx
	local cornerY = (MID_Y - (MID_Y - self.ry) * TheCamera.sy) + TheCamera.y * TheCamera.sy
	return (x - cornerX) / TheCamera.sx, (-y + cornerY) / TheCamera.sy
end

local function TestVision(unit, pos)
	assert(false, unit.cx.."/"..unit.cy..":"..pos.x.."/"..pos.y.."="..hex.distance({x=unit.cx, y=unit.cy}, pos))
	return hex.distance({x=unit.cx, y=unit.cy}, pos) <= unit.view
end

--TODO: Account for terrain
function HexGrid:Reveal(x, y, r, player, ignoreterrain)
	self:GetCell(x, y).visibility[player] = 2
	for i,v in ipairs(hex.range(x, y, r)) do
		local cell = self:GetCell(v.x, v.y)
		if cell then
			cell.visibility[player] = 2
		end
	end
end

function HexGrid:ClearVision(player)
	for y=0,self.h-1 do
		for x=0,self.w-1 do
			local cell = self:GetCell(x, y)
			if cell.visibility[player] == 2 then
				cell.visibility[player] = 1
			end
		end
	end
end

function HexGrid:RecalcVision(player)
	self:ClearVision(player)

	if REVEAL_ALL then
		for y=0,self.h-1 do
			for x=0,self.w-1 do
				self.cells[x][y].visibility[player] = 2
			end
		end
	end

	local current_player = TheGameManager.players[player]
	if current_player then
		for i,v in ipairs(current_player.cities) do
			self:Reveal(v.cx, v.cy, v.view, player)
		end
		for i,v in ipairs(current_player.units) do
			self:Reveal(v.cx, v.cy, v.view, player)
		end
	end
end

function HexGrid:GetTilesInRange(cx, cy, view)
	local ret = {}
end

--[[function HexGrid:RecalcVisionArea(x, y, r, player, ignoreterrain)
	self:GetCell(x, y).visibility[player] = 2
	for i,v in ipairs(hex.range(x, y, r)) do
		local flag = false
		for ii,vv in ipairs(TheGameManager.players[player].units) do
			if TestVision(vv, v) then
				flag = true
			end
		end
		for ii,vv in ipairs(TheGameManager.players[player].cities) do
			if TestVision(vv, v) then
				flag = true
			end
		end
		local cell = self:GetCell(v.x, v.y)
		if cell then
			if flag then
				cell.visibility[player] = 2
			else
				if cell.visibility[player] == 2 then cell.visibility[player] = 1 end
			end
		end
	end
end]]

function HexGrid:NextTurn()
	--assert(false)

	self:RecalcVision(TheGameManager.player_num)
end

return HexGrid