local thick = 5
local thick2 = 3
local radius = HEX_RADIUS_SHORT - thick
local mini_radius = radius - thick
local dot_radius = 5
local extra_dots = 1

local Pathfinder = Class(Prefab, function(self)
	self.base._ctor(self, 0, 0)

	self.pressed = false

	self.color = COLORS.YELLOW

	self.layer = LAYERS.UNIT_CONTROL
end)

function Pathfinder:Update(dt)
	if (not self.lock) and ActiveScreen == Screen_HUD then
		if TheGrid.selected and TheGrid.selected.unit and TheGameManager.player_num == TheGrid.selected.unit.owner then
			if love.mouse.isDown(2) then
				self.pressed = true
				local x,y = love.mouse.getPosition()
				x,y = TheGrid:WorldToLocal(x,y)
				local cx,cy = WorldToCartesian(x,y)
				self.target = TheGrid:GetCell(cx, cy)

				self.path = hex.path(TheGrid.selected, self.target)
			else
				if self.pressed then
					self.pressed = false
					if not self.target.unit then --TODO
						local unit = TheGrid.selected.unit
						unit:MoveAlong(self.path)
					end
					self.target = nil
				end
			end
		end
	end
end

function Pathfinder:SetLock(val)
	self.pressed = false
	self.lock = val
end

local function draw_dot(x, y, color)
	love.graphics.setColor(color)
	love.graphics.circle("fill",x,y,dot_radius)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(COLORS.BLACK)
	love.graphics.circle("line",x,y,dot_radius)
end

function Pathfinder:Draw(dt)
	if self.target then
		local unit = TheGrid.selected.unit
		local mp = unit.mp
		local turns = 0
		for i,v in ipairs(self.path) do
			local x,y = TheGrid:GetHexCenter(v.x, v.y)
			if mp > 0 then
				if i > 1 then draw_dot(x, y, self.color) end
			else
				turns = turns + 1

				if (not (v.x == self.target.x and v.y == self.target.y)) and (not (v.x == unit.cx and v.y == unit.cy)) then
					--Projected turns
					love.graphics.setColor(COLORS.THREE_QUARTER_BLACK)
					love.graphics.circle("fill",x,y,mini_radius)
					love.graphics.setColor(self.color)
					love.graphics.print(tostring(turns),x-6,y-14)

					love.graphics.setColor(self.color)
					love.graphics.setLineWidth(thick2)
					love.graphics.circle("line",x,y,mini_radius)
					love.graphics.setLineWidth(1)
					love.graphics.setColor(COLORS.BLACK)
					love.graphics.circle("line",x,y,mini_radius+thick2/2)
					love.graphics.circle("line",x,y,mini_radius-thick2/2)
				end
			end
			--Intermediate dots
			if i > 1 then
				local x2, y2 = TheGrid:GetHexCenter(self.path[i-1].x, self.path[i-1].y)
				for j=1,extra_dots do
					local t = j / (extra_dots + 1)
					local x3, y3 = math.lerp(x2, x, t), math.lerp(y2, y, t)
					draw_dot(x3, y3, self.color)
				end
			end
			mp = mp - 1
			if mp < 0 then mp = unit.max_mp end
		end
		--Destination marker
		local x,y = TheGrid:GetHexCenter(self.target.x, self.target.y)
		love.graphics.setColor(self.color)
		love.graphics.setLineWidth(thick)
		love.graphics.circle("line",x,y,radius)
		love.graphics.circle("fill",x,y,dot_radius)
		love.graphics.setLineWidth(1)
		love.graphics.setColor(COLORS.BLACK)
		love.graphics.circle("line",x,y,radius+thick/2)
		love.graphics.circle("line",x,y,radius-thick/2)
		love.graphics.circle("line",x,y,dot_radius)
		love.graphics.setColor(COLORS.WHITE)
	end
end

return Pathfinder